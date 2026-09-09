% Mechanical observation of the dedicated-user open growth environment.
% This membrane reports configuration, runtime identity and filesystem presence.
% It does not choose a tool, command, site, purpose, credential or movement.

:- ensure_loaded('store.pl').
:- ensure_loaded('workshop.pl').
:- ensure_loaded('process.pl').
:- use_module(library(crypto)).
:- use_module(library(filesex)).
:- use_module(library(http/http_open)).
:- use_module(library(http/json)).
:- use_module(library(pcre)).
:- use_module(library(process)).
:- use_module(library(readutil)).
:- use_module(library(time)).
:- use_module(library(uri)).

as_capability_environment(Root0, Observation) :-
    catch(as_capability_environment_checked(Root0, Observation0), _,
      Observation0=['capability-environment-unavailable-v1',
        'mechanical-observation-failed']),
    Observation=Observation0, !.

% Persist one complete native movement proof before a compact capability
% request can refer to it.  The caller supplies the exact native identifier
% and proof; this membrane only validates, factorizes, hashes, writes and
% re-reads that exact term.  Repeated historical structure is represented once
% inside an immutable content-addressed object; no proof relation is summarized
% or omitted.  This membrane never selects an operation or interprets meaning.
as_capability_proof(Root0, ProofId0, Proof, Record) :-
    ( catch(as_capability_proof_checked(Root0,ProofId0,Proof,Record0),_,fail)
    -> Record=Record0
    ;  Record=['capability-native-proof-held-v1',ProofId0,
         'mechanical-boundary']
    ), !.

as_capability_proof_checked(Root0,ProofId0,Proof,Record) :-
    ce_root(Root0,Root),ce_symbol(ProofId0,ProofId),
    as_local_native_movement_proof(Proof,Scope,CutId,MovementReference,
      _Summary,_ParticipantReference,_ProofReference),
    ce_proof_flourishings(Proof,Flourishings),
    ce_capability_proof_identity(CutId,MovementReference,ComputedProofId),
    ProofId==ComputedProofId,
    with_mutex(miter_capability_proof,
      ce_write_factorized_proof_object(Root,Proof,ProofObject)),
    Record=['capability-native-proof-record-v2',ProofId,Scope,CutId,
      MovementReference,ProofObject,
      ['proof-flourishings',Flourishings],
      'persisted-before-capability'].

ce_capability_proof_identity(CutId,MovementReference,ProofId) :-
    as_native_id('c4-capability-proof',
      ['capability-native-proof-v1',CutId,MovementReference],ProofId).

ce_proof_flourishings(
    ['native-movement-proof-v1',_Cut,_Scope,Movement,_Participants],
    Flourishings) :-
    Movement=[_|_],nth0(4,Movement,Derivation),
    ( Derivation=['material-derivation'|_],nth0(6,Derivation,Requirements)
    ; Derivation=['material-derivation-v2'|_],nth0(5,Derivation,Requirements)
    ),
    Requirements=['flourishing-requirements',Flourishings],
    is_list(Flourishings),ground(Flourishings),!.

as_capability_environment_checked(Root0,
    ['capability-environment-observation-v1',
      'miter-open-growth-environment-v1',
      ['runtime-identity',ExpectedUser,ObservedUser,IdentityStanding],
      ['workspace',workspace,WorkspaceStanding],
      ['informational-network',InformationalNetwork,
        'proof-bound-get-head-broker-active'],
      ['terminal',Terminal,'proof-bound-direct-argv-broker-active'],
      ['reversible-writes',ReversibleWrites,
        'proof-bound-versioned-workspace-broker-active'],
      ['credential-access',CredentialAccess,'named-reference-only'],
      ['human-authority-boundaries'|Boundaries],
      OverallStanding]) :-
    ce_root(Root0,Root),
    directory_file_path(Root,'growth-environment.json',ConfigPath),
    miter_store_read_json(ConfigPath,Config),
    ce_config_valid(Config),
    ce_symbol(Config.expected_runtime_user,ExpectedUser),
    ce_observed_user(ObservedUser),
    ( ObservedUser==ExpectedUser -> IdentityStanding='identity-aligned'
    ; IdentityStanding='identity-mismatch' ),
    directory_file_path(Root,Config.workspace_relative,Workspace),
    ( exists_directory(Workspace), \+ read_link(Workspace,_,_) ->
        WorkspaceStanding='private-workspace-present'
    ; WorkspaceStanding='workspace-unavailable' ),
    ce_symbol(Config.informational_network,InformationalNetwork),
    ce_symbol(Config.terminal,Terminal),
    ce_symbol(Config.reversible_writes,ReversibleWrites),
    ce_symbol(Config.credential_access,CredentialAccess),
    maplist(ce_symbol,Config.human_authority_boundaries,Boundaries),
    ce_overall_standing(Config.enabled,IdentityStanding,WorkspaceStanding,
      OverallStanding).

ce_overall_standing(false,_,_,'held-environment-disabled') :- !.
ce_overall_standing(true,'identity-mismatch',_,
    'held-runtime-identity-mismatch') :- !.
ce_overall_standing(true,'identity-aligned','workspace-unavailable',
    'held-workspace-unavailable') :- !.
ce_overall_standing(true,'identity-aligned','private-workspace-present',
    'available-open-growth-environment').

% Execute one already-formed, proof-bound informational request.  The caller
% supplies the exact URL, movement proof, limits and idempotency identity.  This
% membrane does not infer a site, purpose, next step or meaning from any of
% those bytes.  A claim is durable before network transmission; an interrupted
% claim is held for recovery and is never blindly replayed.
as_capability_request(Root0, Descriptor, Observation) :-
    ( catch(as_capability_request_checked(Root0, Descriptor, Observation0), _,
        fail)
    -> Observation=Observation0
    ;  ce_descriptor_request_id(Descriptor,RequestId),
       Observation=['capability-observation-held-v1',RequestId,
         'mechanical-boundary']
    ), !.

ce_descriptor_request_id(
    [Version,RequestId0|_],RequestId) :-
    memberchk(Version,
      ['capability-request-descriptor-v1','capability-request-descriptor-v2']),
    ce_symbol(RequestId0,RequestId), !.
ce_descriptor_request_id(_,'unknown-request').

as_capability_request_checked(Root0, Descriptor, Observation) :-
    ce_root(Root0,Root),
    as_capability_environment_checked(Root,Environment),
    Environment=['capability-environment-observation-v1'|_],
    last(Environment,'available-open-growth-environment'),
    ce_request_descriptor(Root,Descriptor,RequestId,Scope,Operation,Capability,
      Deadline,MaximumBytes,DescriptorHash),
    with_mutex(miter_capability_request,
      ce_request_once(Root,Descriptor,RequestId,Scope,Operation,Capability,
        Deadline,MaximumBytes,DescriptorHash,Observation)).

ce_request_descriptor(Root,
    Descriptor,RequestId,Scope,Operation,Capability,Deadline,MaximumBytes,
    DescriptorHash) :-
    ce_request_descriptor_values(Root,Descriptor,
      [RequestId,Scope,Operation,Capability,Deadline,MaximumBytes,
        DescriptorHash]).

ce_request_descriptor_values(Root,Descriptor,Values) :-
    Descriptor=[DescriptorVersion,RequestId0,
      IdempotencyKey0,Scope,
      ['source-contact',ContactId],
      ['source-movement',DescriptorMovementReference],
      ['native-purpose',Purpose],
      ['exact-operation',Operation0],
      ['limits',['deadline-seconds',Deadline],
        ['maximum-body-bytes',MaximumBytes]],
      ProofCarrier,
      Capability0,prepared],
    memberchk(DescriptorVersion,
      ['capability-request-descriptor-v1','capability-request-descriptor-v2']),
    ce_symbol(RequestId0,RequestId),ce_symbol(IdempotencyKey0,IdempotencyKey),
    RequestId==IdempotencyKey,
    as_local_scope(Scope),ce_symbol(ContactId,_),
    ce_bounded_text(Purpose,1,400),
    ce_descriptor_native_proof(Root,DescriptorVersion,ProofCarrier,Scope,
      CutId,ProofMovementReference,_Proof),
    CutId=['cut-of',ContactId,_],
    DescriptorMovementReference==ProofMovementReference,
    ce_operation(Operation0,Operation,Capability),Capability0==Capability,
    integer(Deadline),Deadline>=1,Deadline=<120,
    integer(MaximumBytes),MaximumBytes>=1,MaximumBytes=<1048576,
    ground(Descriptor),acyclic_term(Descriptor),
    term_string(Descriptor,DescriptorText,[quoted(true),ignore_ops(true)]),
    string_length(DescriptorText,DescriptorLength),DescriptorLength=<33554432,
    crypto_data_hash(DescriptorText,DescriptorHash,
      [algorithm(sha256),encoding(utf8)]),
    % The native identifier was formed over the exact MeTTa operation carried
    % by the descriptor.  Validation may normalize strings to host atoms for
    % execution, but that mechanical representation must not change the
    % proof-bound identity basis.
    ce_request_identity_basis(ContactId,ProofMovementReference,Operation0,Deadline,
      MaximumBytes,Basis),
    as_native_id('c4-capability-request',Basis,ComputedRequestId),
    RequestId==ComputedRequestId,
    Values=[RequestId,Scope,Operation,Capability,Deadline,MaximumBytes,
      DescriptorHash].

ce_descriptor_native_proof(_Root,'capability-request-descriptor-v1',
    ['native-proof',Proof],Scope,CutId,MovementReference,Proof) :-
    as_local_native_movement_proof(Proof,Scope,CutId,MovementReference,
      _Summary,_ParticipantReference,_ProofReference).
ce_descriptor_native_proof(Root,'capability-request-descriptor-v2',
    ['native-proof-record',Record],Scope,CutId,MovementReference,Proof) :-
    ce_capability_proof_record(Root,Record,Scope,CutId,MovementReference,Proof).

ce_capability_proof_record(Root,
    ['capability-native-proof-record-v2',ProofId,Scope,CutId,
      MovementReference,ProofObject,
      ['proof-flourishings',Flourishings],
      'persisted-before-capability'],Scope,CutId,MovementReference,Proof) :-
    ce_symbol(ProofId,_),is_list(Flourishings),ground(Flourishings),
    ce_capability_proof_identity(CutId,MovementReference,ProofId),
    ce_read_factorized_proof_object(Root,ProofObject,Proof),
    as_local_native_movement_proof(Proof,Scope,CutId,MovementReference,
      _Summary,_ParticipantReference,_ProofReference),
    ce_proof_flourishings(Proof,Flourishings).

ce_request_identity_basis(ContactId,MovementReference,Operation,Deadline,
    MaximumBytes,
    ['capability-request-v1',ContactId,MovementReference,Operation,
      ['limits',['deadline-seconds',Deadline],
        ['maximum-body-bytes',MaximumBytes]]]).

ce_operation(['informational-http-v1',Method0,Url0],
    ['informational-http-v1',Method,Url],
    ['capability','open-http-https','no-credential',
      'informational-read-only']) :-
    ce_http_method(Method0,Method),ce_http_url(Url0,Url),!.
ce_operation(['direct-argv-v1',Executable0,Arguments0,WorkingDirectory0],
    ['direct-argv-v1',Executable,Arguments,WorkingDirectory],
    ['capability','typed-direct-argv','no-credential',
      'dedicated-user-owned-workspace']) :-
    ce_absolute_executable(Executable0,Executable),
    is_list(Arguments0),length(Arguments0,Count),Count=<64,
    maplist(ce_argument,Arguments0,Arguments),
    ce_workspace_location(WorkingDirectory0,WorkingDirectory),!.
ce_operation(['workspace-write-v1',Relative0,Contents,Expected0],
    ['workspace-write-v1',Relative,Contents,Expected],
    ['capability','versioned-owned-workspace','no-credential',
      'reversible-local-artifact']) :-
    ce_workspace_relative(Relative0,Relative),
    ce_bounded_text(Contents,0,1048576),
    ce_expected_prior(Expected0,Expected),!.
ce_operation(['workspace-read-v1',Relative0],
    ['workspace-read-v1',Relative],
    ['capability','versioned-owned-workspace','no-credential',
      'reversible-local-artifact']) :-
    ce_workspace_relative(Relative0,Relative),!.
ce_operation(['workspace-list-v1',Relative0],
    ['workspace-list-v1',Relative],
    ['capability','versioned-owned-workspace','no-credential',
      'reversible-local-artifact']) :-
    ce_workspace_location(Relative0,Relative),!.
ce_operation(['workspace-rollback-v1',SourceRequest0,Relative0,
      ['expected-current-sha256',Expected0]],
    ['workspace-rollback-v1',SourceRequest,Relative,
      ['expected-current-sha256',Expected]],
    ['capability','versioned-owned-workspace','no-credential',
      'reversible-local-artifact']) :-
    ce_symbol(SourceRequest0,SourceRequest),
    ce_workspace_relative(Relative0,Relative),
    miter_store_nonempty_atom(Expected0,Expected),ce_sha256(Expected),!.
ce_operation(Operation0,Operation,Capability) :-
    miter_workshop_operation(Operation0,Operation,Capability),!.

ce_expected_prior('no-prior-content','no-prior-content').
ce_expected_prior(['prior-sha256',Hash0],['prior-sha256',Hash]) :-
    miter_store_nonempty_atom(Hash0,Hash),ce_sha256(Hash).

ce_absolute_executable(Value,Executable) :-
    ce_text_atom(Value,Executable),is_absolute_file_name(Executable),
    exists_file(Executable),\+ read_link(Executable,_,_),access_file(Executable,execute).

ce_argument(Value,Argument) :-
    ( string(Value) -> Argument=Value
    ; atom(Value),atom_string(Value,Argument) ),
    ce_bounded_text(Argument,0,8192).

ce_workspace_relative(Value,Relative) :-
    ce_text_atom(Value,Relative),\+ is_absolute_file_name(Relative),
    atom_length(Relative,Length),Length>=1,Length=<4096,
    atomic_list_concat(Parts,'/',Relative),Parts=[_|_],
    forall(member(Part,Parts),
      (Part\=='',Part\=='.',Part\=='..',Part\=='.git',
       re_match('^[A-Za-z0-9_. -]+$',Part))).

ce_workspace_location(Value,'.') :-
    ce_text_atom(Value,'.'),!.
ce_workspace_location(Value,Relative) :-
    ce_workspace_relative(Value,Relative).

ce_text_atom(Value,Atom) :-
    ( atom(Value) -> Atom=Value ; string(Value),atom_string(Atom,Value) ).

ce_sha256(Hash) :-
    atom(Hash),atom_length(Hash,64),atom_codes(Hash,Codes),
    maplist(miter_store_hex_code,Codes).

ce_http_method(Method0,Method) :-
    ce_symbol(Method0,Method),memberchk(Method,[get,head]).

ce_http_url(Value,Url) :-
    ( string(Value) -> Url=Value
    ; atom(Value),atom_string(Value,Url) ),
    string_length(Url,Length),Length>=10,Length=<4096,
    uri_components(Url,uri_components(Scheme0,Authority0,_,_,_)),
    ce_url_atom(Scheme0,Scheme),memberchk(Scheme,[http,https]),
    ce_url_string(Authority0,Authority),Authority\="",
    \+ sub_string(Authority,_,_,_,'@'),
    \+ re_match('(?i)(api[_-]?key|access[_-]?token|token|password|secret|signature|authorization|auth)=',Url),
    \+ sub_string(Url,_,_,_,"\u0000").

ce_url_atom(Value,Atom) :-
    ( atom(Value) -> Atom=Value ; string(Value),atom_string(Atom,Value) ).
ce_url_string(Value,String) :-
    ( string(Value) -> String=Value ; atom(Value),atom_string(Value,String) ).

ce_request_once(Root,_Descriptor,RequestId,_Scope,_Operation,_Capability,
    _Deadline,_MaximumBytes,DescriptorHash,Observation) :-
    ce_observation_path(Root,RequestId,ObservationPath),
    exists_file(ObservationPath), !,
    ce_claim_path(Root,RequestId,ClaimPath),
    ce_claim_matches(ClaimPath,RequestId,DescriptorHash),
    ce_read_term(ObservationPath,Observation),
    ce_observation_identity(Observation,RequestId,DescriptorHash).
ce_request_once(Root,_Descriptor,RequestId,Scope,Operation,_Capability,
    _Deadline,_MaximumBytes,DescriptorHash,Observation) :-
    ce_claim_path(Root,RequestId,ClaimPath),exists_file(ClaimPath),
    ce_claim_matches(ClaimPath,RequestId,DescriptorHash),
    miter_workshop_reconcile(Root,RequestId,Operation,_Standing,Outcome,
      Failure,Completion),!,
    Observation=['capability-observation-v2',RequestId,Scope,
      ['request-descriptor-sha256',DescriptorHash],
      ['resource','executable-extension-workshop'],Outcome,
      ['elapsed-milliseconds',0],['failure',Failure],
      'mechanical-observation-no-meaning-no-movement-authority'],
    ce_observation_identity(Observation,RequestId,DescriptorHash),
    ce_observation_path(Root,RequestId,ObservationPath),
    ce_write_term_durable(ObservationPath,Observation),
    ce_record_completion(ClaimPath,RequestId,DescriptorHash,Completion,0).
ce_request_once(Root,_Descriptor,RequestId,_Scope,_Operation,_Capability,
    _Deadline,_MaximumBytes,DescriptorHash,
    ['capability-observation-held-v1',RequestId,
      'claimed-without-observation-recovery-required']) :-
    ce_claim_path(Root,RequestId,ClaimPath),exists_file(ClaimPath),
    ce_claim_matches(ClaimPath,RequestId,DescriptorHash), !.
ce_request_once(Root,Descriptor,RequestId,Scope,Operation,Capability,Deadline,
    MaximumBytes,DescriptorHash,Observation) :-
    ce_claim_path(Root,RequestId,ClaimPath),
    ce_write_claim(ClaimPath,RequestId,DescriptorHash),
    get_time(Start),
    ce_operation_observe(Root,RequestId,Operation,Scope,DescriptorHash,
      Capability,Deadline,MaximumBytes,Observation0,Completion),
    get_time(End),ElapsedMilliseconds is round((End-Start)*1000),
    ce_observation_elapsed(Observation0,ElapsedMilliseconds,Observation),
    ce_observation_identity(Observation,RequestId,DescriptorHash),
    ce_observation_path(Root,RequestId,ObservationPath),
    ce_write_term_durable(ObservationPath,Observation),
    ce_record_completion(ClaimPath,RequestId,DescriptorHash,Completion,
      ElapsedMilliseconds),
    ground(Descriptor).

ce_operation_observe(_Root,RequestId,
    ['informational-http-v1',Method,Url],Scope,DescriptorHash,_Capability,
    Deadline,MaximumBytes,
    ['capability-observation-v1',RequestId,Scope,
      ['request-descriptor-sha256',DescriptorHash],
      ['resource','open-http-https'],['transport',Transport],
      ['http-status',HttpStatus],['body',BodyHash,Body],
      ['elapsed-milliseconds',pending],['failure',Failure],
      'mechanical-observation-no-meaning-no-movement-authority'],
    _{resource:"open-http-https",standing:Transport,http_status:HttpStatus,
      body_sha256:BodyHash}) :-
    ce_http_observe(Method,Url,Deadline,MaximumBytes,Transport,HttpStatus,
      Body,Failure),
    crypto_data_hash(Body,BodyHash,[algorithm(sha256),encoding(utf8)]),!.
ce_operation_observe(Root,RequestId,
    ['direct-argv-v1',Executable,Arguments,WorkingDirectory],Scope,
    DescriptorHash,_Capability,Deadline,MaximumBytes,
    ['capability-observation-v2',RequestId,Scope,
      ['request-descriptor-sha256',DescriptorHash],
      ['resource','typed-direct-argv'],Outcome,
      ['elapsed-milliseconds',pending],['failure',Failure],
      'mechanical-observation-no-meaning-no-movement-authority'],
    _{resource:"typed-direct-argv",standing:Transport,
      exit_code:ExitCode,stdout_sha256:StdoutHash,
      stderr_sha256:StderrHash}) :-
    ( ce_workspace_directory(Root,WorkingDirectory,Directory) ->
        ce_process_observe(Executable,Arguments,Directory,Deadline,MaximumBytes,
          Transport,ExitCode,Stdout,Stderr,Failure)
    ; Transport=failed,ExitCode=unknown,Stdout="",Stderr="",
      Failure='working-directory-unavailable'
    ),
    crypto_data_hash(Stdout,StdoutHash,[algorithm(sha256),encoding(utf8)]),
    crypto_data_hash(Stderr,StderrHash,[algorithm(sha256),encoding(utf8)]),
    Outcome=['process-result-v1',Transport,['exit-code',ExitCode],
      ['stdout',StdoutHash,Stdout],['stderr',StderrHash,Stderr],
      'direct-argv-no-shell-string'],!.
ce_operation_observe(Root,RequestId,Operation,Scope,DescriptorHash,_Capability,
    Deadline,MaximumBytes,
    ['capability-observation-v2',RequestId,Scope,
      ['request-descriptor-sha256',DescriptorHash],
      ['resource','executable-extension-workshop'],Outcome,
      ['elapsed-milliseconds',pending],['failure',Failure],
      'mechanical-observation-no-meaning-no-movement-authority'],
    Completion) :-
    miter_workshop_operation(Operation,Operation,_),
    miter_workshop_observe(Root,RequestId,Operation,Deadline,MaximumBytes,
      _Standing,Outcome,Failure,Completion),!.
ce_operation_observe(Root,RequestId,Operation,Scope,DescriptorHash,_Capability,
    _Deadline,MaximumBytes,
    ['capability-observation-v2',RequestId,Scope,
      ['request-descriptor-sha256',DescriptorHash],
      ['resource','versioned-owned-workspace'],Outcome,
      ['elapsed-milliseconds',pending],['failure',Failure],
      'mechanical-observation-no-meaning-no-movement-authority'],
    _{resource:"versioned-owned-workspace",standing:Standing,
      result_sha256:ResultHash}) :-
    ce_workspace_observe(Root,RequestId,Operation,MaximumBytes,Standing,
      Relative,PriorHash,NewHash,Detail,Failure),
    term_string([Standing,Relative,PriorHash,NewHash,Detail],ResultText,
      [quoted(true),ignore_ops(true)]),
    crypto_data_hash(ResultText,ResultHash,
      [algorithm(sha256),encoding(utf8)]),
    Outcome=['workspace-result-v1',Standing,['path',Relative],
      ['prior-sha256',PriorHash],['result-sha256',NewHash],Detail],!.

ce_observation_elapsed(
    ['capability-observation-v1',A,B,C,D,E,F,G,
      ['elapsed-milliseconds',pending],I,J],Elapsed,
    ['capability-observation-v1',A,B,C,D,E,F,G,
      ['elapsed-milliseconds',Elapsed],I,J]).
ce_observation_elapsed(
    ['capability-observation-v2',A,B,C,D,E,
      ['elapsed-milliseconds',pending],G,H],Elapsed,
    ['capability-observation-v2',A,B,C,D,E,
      ['elapsed-milliseconds',Elapsed],G,H]).

ce_http_observe(Method,Url,Deadline,MaximumBytes,Transport,HttpStatus,
    Body,Failure) :-
    catch(call_with_time_limit(Deadline,
      ce_http_observe_open(Method,Url,Deadline,MaximumBytes,Transport0,
        HttpStatus0,Body0)),Error,
      ce_http_failure(Error,Transport0,HttpStatus0,Body0,Failure0)),
    ( var(Failure0) -> Failure=none ; Failure=Failure0 ),
    Transport=Transport0,HttpStatus=HttpStatus0,Body=Body0.

ce_http_observe_open(Method,Url,Deadline,MaximumBytes,Transport,HttpStatus,
    Body) :-
    ce_http_options(Method,Deadline,HttpStatus,Options),
    setup_call_cleanup(http_open(Url,Stream,Options),
      ce_bounded_http_body(Method,Stream,MaximumBytes,Transport,Body),
      close(Stream)).

ce_http_options(Method,Deadline,HttpStatus,
    [method(Method),status_code(HttpStatus),timeout(Deadline),max_redirect(0),
      request_header('Accept'='*/*'),
      request_header('User-Agent'='Miter-Open-Growth/1')]).

ce_bounded_http_body(head,_Stream,_MaximumBytes,eof,"") :- !.
ce_bounded_http_body(get,Stream,MaximumBytes,Transport,Body) :-
    ReadLimit is MaximumBytes+1,read_string(Stream,ReadLimit,Raw),
    string_length(Raw,Length),
    ( Length>MaximumBytes ->
        sub_string(Raw,0,MaximumBytes,_,Body),Transport=truncated
    ; Body=Raw,Transport=eof ).

ce_http_failure(time_limit_exceeded,deadline,unknown,"",deadline-exceeded) :- !.
ce_http_failure(Error,failed,unknown,"",Class) :-
    functor(Error,Functor,_),
    ( ce_symbol(Functor,Class) -> true ; Class='transport-error' ).

% Direct argv execution deliberately has no shell command string.  The process
% receives a minimal environment, an owned-workspace cwd, bounded output and a
% hard deadline.  Purpose and command selection have already happened in the
% native movement; this code only observes the exact vector it receives.
ce_process_observe(Executable,Arguments,Directory,Deadline,MaximumBytes,
    Transport,ExitCode,Stdout,Stderr,Failure) :-
    miter_process_observe(Executable,Arguments,Directory,Deadline,MaximumBytes,
      Transport,ExitCode,Stdout,Stderr,Failure).

ce_workspace_directory(Root,Relative,Path) :-
    directory_file_path(Root,workspace,Workspace),
    ( Relative=='.' -> Path=Workspace
    ; ce_existing_safe_path(Workspace,Relative,Path) ),
    exists_directory(Path).

% Resolve a workspace target without creating any path component. A failed
% read, rollback or compare-and-write therefore leaves the workspace exactly
% unchanged; creation happens only after the expected-prior check succeeds.
ce_workspace_target_path(Root,Relative,Path) :-
    directory_file_path(Root,workspace,Workspace),
    ce_workspace_relative(Relative,Relative),
    atomic_list_concat(Parts,'/',Relative),
    ce_noncreating_join_parts(Workspace,Parts,Path).

ce_noncreating_join_parts(Current,[Leaf],Path) :-
    directory_file_path(Current,Leaf,Path),\+ read_link(Path,_,_).
ce_noncreating_join_parts(Current,[Part|Rest],Path) :-
    directory_file_path(Current,Part,Next),
    ( exists_directory(Next) ->
        \+ read_link(Next,_,_),ce_noncreating_join_parts(Next,Rest,Path)
    ; \+ exists_file(Next),ce_join_remaining_parts(Next,Rest,Path) ).

ce_join_remaining_parts(Current,[],Current).
ce_join_remaining_parts(Current,[Part|Rest],Path) :-
    directory_file_path(Current,Part,Next),
    ce_join_remaining_parts(Next,Rest,Path).

ce_existing_safe_path(Base,Relative,Path) :-
    ce_workspace_relative(Relative,Relative),
    atomic_list_concat(Parts,'/',Relative),
    ce_existing_safe_parts(Base,Parts,Path).

ce_existing_safe_parts(Current,[],Current).
ce_existing_safe_parts(Current,[Part|Rest],Path) :-
    directory_file_path(Current,Part,Next),
    (exists_file(Next);exists_directory(Next)),
    \+ read_link(Next,_,_),ce_existing_safe_parts(Next,Rest,Path).

ce_workspace_observe(Root,RequestId,
    ['workspace-write-v1',Relative,Contents,Expected],_MaximumBytes,Standing,
    Relative,PriorHash,NewHash,['bytes',Bytes],Failure) :-
    ce_workspace_target_path(Root,Relative,Path),
    ce_current_file_identity(Path,PriorStanding,PriorHash),
    ( ce_prior_matches(Expected,PriorStanding,PriorHash) ->
        ce_archive_prior(Root,RequestId,Relative,Path,PriorStanding,PriorHash),
        ce_write_workspace_file(Path,Contents),
        crypto_file_hash(Path,NewHash,[algorithm(sha256),encoding(octet)]),
        string_length(Contents,Bytes),Standing=written,Failure=none
    ; Standing=conflict,NewHash=PriorHash,Bytes=0,
      Failure='expected-prior-mismatch' ),!.
ce_workspace_observe(Root,_RequestId,['workspace-read-v1',Relative],
    MaximumBytes,Standing,Relative,PriorHash,NewHash,Detail,Failure) :-
    ( ce_workspace_target_path(Root,Relative,Path),
      exists_file(Path),\+ exists_directory(Path),\+ read_link(Path,_,_),
      size_file(Path,Size),Size=<MaximumBytes ->
        read_file_to_string(Path,Contents,[]),
        crypto_file_hash(Path,Hash,[algorithm(sha256),encoding(octet)]),
        Standing=read,PriorHash=Hash,NewHash=Hash,
        Detail=['contents',Hash,Contents],Failure=none
    ; Standing=failed,PriorHash=unavailable,NewHash=unavailable,
      Detail=['contents',unavailable,""],Failure='file-unavailable-or-too-large' ),!.
ce_workspace_observe(Root,_RequestId,['workspace-list-v1',Relative],
    _MaximumBytes,Standing,Relative,PriorHash,NewHash,Detail,Failure) :-
    ( ce_existing_safe_path_from_workspace(Root,Relative,Path),
      exists_directory(Path),\+ read_link(Path,_,_) ->
        directory_files(Path,Entries0),exclude(ce_dot_entry,Entries0,Entries),
        sort(Entries,Sorted),term_string(Sorted,Listing,
          [quoted(true),ignore_ops(true)]),
        crypto_data_hash(Listing,Hash,[algorithm(sha256),encoding(utf8)]),
        Standing=listed,PriorHash=Hash,NewHash=Hash,
        Detail=['entries'|Sorted],Failure=none
    ; Standing=failed,PriorHash=unavailable,NewHash=unavailable,
      Detail=['entries'],Failure='directory-unavailable' ),!.
ce_workspace_observe(Root,_RequestId,
    ['workspace-rollback-v1',SourceRequest,Relative,
      ['expected-current-sha256',Expected]],_MaximumBytes,Standing,Relative,
    PriorHash,NewHash,Detail,Failure) :-
    ( ce_workspace_target_path(Root,Relative,Path),
      ce_current_file_identity(Path,present,CurrentHash) ->
        ( CurrentHash==Expected,
          ce_restore_prior(Root,SourceRequest,Relative,Path,PriorStanding,
            PriorHash0) ->
            Standing='rolled-back',PriorHash=CurrentHash,
            ce_current_file_identity(Path,AfterStanding,NewHash0),
            ce_identity_atom(AfterStanding,NewHash0,NewHash),
            Detail=['restored-prior',PriorStanding,PriorHash0],Failure=none
        ; Standing=conflict,PriorHash=CurrentHash,NewHash=CurrentHash,
          Detail=['restored-prior',unavailable,unavailable],
          Failure='rollback-lineage-or-current-hash-mismatch' )
    ; Standing=conflict,PriorHash=unavailable,NewHash=unavailable,
      Detail=['restored-prior',unavailable,unavailable],
      Failure='rollback-lineage-or-current-hash-mismatch' ),!.

ce_existing_safe_path_from_workspace(Root,'.',Workspace) :-
    directory_file_path(Root,workspace,Workspace),!.
ce_existing_safe_path_from_workspace(Root,Relative,Path) :-
    directory_file_path(Root,workspace,Workspace),
    ce_existing_safe_path(Workspace,Relative,Path).

ce_dot_entry('.').
ce_dot_entry('..').

ce_current_file_identity(Path,present,Hash) :-
    exists_file(Path),\+ exists_directory(Path),\+ read_link(Path,_,_),
    crypto_file_hash(Path,Hash,[algorithm(sha256),encoding(octet)]),!.
ce_current_file_identity(Path,invalid,unavailable) :-
    (exists_directory(Path);read_link(Path,_,_)),!.
ce_current_file_identity(Path,absent,absent) :- \+ exists_file(Path).

ce_prior_matches('no-prior-content',absent,absent).
ce_prior_matches(['prior-sha256',Expected],present,Expected).

ce_archive_prior(Root,RequestId,Relative,Path,Standing,Hash) :-
    atomic_list_concat(['capabilities/workspace-history/',RequestId],HistoryRel),
    directory_file_path(Root,HistoryRel,History),\+ exists_directory(History),
    make_directory_path(History),chmod(History,0o700),
    ( Standing==present ->
        directory_file_path(History,'prior.bytes',Prior),copy_file(Path,Prior),
        chmod(Prior,0o600)
    ; true ),
    directory_file_path(History,'lineage.json',Meta),
    atom_string(Relative,RelativeString),atom_string(Standing,StandingString),
    atom_string(Hash,HashString),
    miter_store_write_json_atomic(Meta,
      _{schema:"miter-workspace-lineage-v1",request_id:RequestId,
        relative_path:RelativeString,prior_standing:StandingString,
        prior_sha256:HashString}).

ce_restore_prior(Root,SourceRequest,Relative,Path,Standing,Hash) :-
    atomic_list_concat(['capabilities/workspace-history/',SourceRequest],Rel),
    directory_file_path(Root,Rel,History),
    directory_file_path(History,'lineage.json',MetaPath),
    miter_store_read_json(MetaPath,Meta),
    Meta.schema=="miter-workspace-lineage-v1",
    ce_symbol(Meta.request_id,SourceRequest),
    atom_string(Relative,Meta.relative_path),
    ce_symbol(Meta.prior_standing,Standing),memberchk(Standing,[present,absent]),
    miter_store_nonempty_atom(Meta.prior_sha256,Hash),
    ( Standing==present ->
        directory_file_path(History,'prior.bytes',Prior),exists_file(Prior),
        crypto_file_hash(Prior,Hash,[algorithm(sha256),encoding(octet)]),
        copy_file(Prior,Path),chmod(Path,0o600)
    ; Hash==absent,exists_file(Path),delete_file(Path) ).

ce_identity_atom(present,Hash,Hash).
ce_identity_atom(absent,absent,absent).

ce_write_workspace_file(Path,Contents) :-
    file_directory_name(Path,Parent),make_directory_path(Parent),
    current_prolog_flag(pid,Pid),format(atom(Suffix),'.tmp.~d',[Pid]),
    atom_concat(Path,Suffix,Temporary),\+ exists_file(Temporary),
    setup_call_cleanup(true,
      ( setup_call_cleanup(open(Temporary,write,Stream,[encoding(utf8)]),
          (chmod(Temporary,0o600),format(Stream,'~s',[Contents]),
           flush_output(Stream),miter_store_fsync_stream(Stream)),
          close(Stream)),
        rename_file(Temporary,Path),chmod(Path,0o600) ),
      (exists_file(Temporary)->delete_file(Temporary);true)).

ce_claim_path(Root,RequestId,Path) :-
    atomic_list_concat(['capabilities/claims/',RequestId,'.json'],Relative),
    directory_file_path(Root,Relative,Path).
ce_observation_path(Root,RequestId,Path) :-
    atomic_list_concat(['capabilities/observations/',RequestId,'.term'],Relative),
    directory_file_path(Root,Relative,Path).

ce_write_claim(Path,RequestId,DescriptorHash) :-
    get_time(Now),
    miter_store_write_json_atomic(Path,
      _{schema:"miter-capability-claim-v1",request_id:RequestId,
        descriptor_sha256:DescriptorHash,claimed_at_epoch:Now,
        standing:"claimed-before-transmission"}).

ce_record_completion(Path,RequestId,DescriptorHash,Completion,
    ElapsedMilliseconds) :-
    get_time(Now),
    put_dict(_{schema:"miter-capability-claim-v1",request_id:RequestId,
      descriptor_sha256:DescriptorHash,completed_at_epoch:Now,
      standing:"observation-durable",
      elapsed_milliseconds:ElapsedMilliseconds},Completion,Claim),
    miter_store_write_json_atomic(Path,Claim).

ce_claim_matches(Path,RequestId,DescriptorHash) :-
    miter_store_read_json(Path,Claim),is_dict(Claim),
    Claim.schema=="miter-capability-claim-v1",
    ce_symbol(Claim.request_id,RequestId),
    ce_symbol(Claim.descriptor_sha256,DescriptorHash).

ce_observation_identity(
    ['capability-observation-v1',RequestId,_Scope,
      ['request-descriptor-sha256',DescriptorHash]|_],
    RequestId,DescriptorHash).
ce_observation_identity(
    ['capability-observation-v2',RequestId,_Scope,
      ['request-descriptor-sha256',DescriptorHash]|_],
    RequestId,DescriptorHash).

ce_write_factorized_proof_object(Root,Proof,
    ['proof-object','prolog-factorized-term-v1',Relative,
      ['object-sha256',ObjectHash],['factor-count',FactorCount]]) :-
    ground(Proof),acyclic_term(Proof),
    term_factorized(Proof,Skeleton,Factors),
    length(Factors,FactorCount),
    Carrier=['miter-factorized-capability-proof-v1',Skeleton,Factors],
    directory_file_path(Root,'capabilities/proof-objects',Directory),
    make_directory_path(Directory),chmod(Directory,0o700),
    current_prolog_flag(pid,Pid),
    format(atom(StagedName),'.staged.~d.term',[Pid]),
    directory_file_path(Directory,StagedName,Staged),\+ exists_file(Staged),
    setup_call_cleanup(true,
      ( ce_write_term_durable(Staged,Carrier),
        crypto_file_hash(Staged,ObjectHash,
          [algorithm(sha256),encoding(octet)]),
        atomic_list_concat(['capabilities/proof-objects/',ObjectHash,'.term'],
          Relative),
        directory_file_path(Root,Relative,Path),
        ( exists_file(Path) ->
            ce_read_bounded_term(Path,33554432,Existing),Existing =@= Carrier
        ; rename_file(Staged,Path),chmod(Path,0o600) ) ),
      (exists_file(Staged)->delete_file(Staged);true)).

ce_read_factorized_proof_object(Root,
    ['proof-object','prolog-factorized-term-v1',Relative,
      ['object-sha256',ObjectHash],['factor-count',FactorCount]],Proof) :-
    ce_sha256(ObjectHash),integer(FactorCount),FactorCount>=0,
    atomic_list_concat(['capabilities/proof-objects/',ObjectHash,'.term'],
      ExpectedRelative),Relative==ExpectedRelative,
    directory_file_path(Root,Relative,Path),
    exists_file(Path),\+ read_link(Path,_,_),
    crypto_file_hash(Path,ObservedHash,[algorithm(sha256),encoding(octet)]),
    ObservedHash==ObjectHash,
    ce_read_bounded_term(Path,33554432,Carrier),
    Carrier=['miter-factorized-capability-proof-v1',Skeleton,Factors],
    is_list(Factors),length(Factors,FactorCount),
    ce_proof_factors_well_formed(Factors),
    maplist(ce_unify_proof_factor,Factors),
    ground(Skeleton),acyclic_term(Skeleton),Proof=Skeleton.

ce_proof_factors_well_formed([]).
ce_proof_factors_well_formed([Left=_|Rest]) :-
    var(Left),ce_proof_factors_well_formed(Rest).

ce_unify_proof_factor(Left=Right) :- Left=Right.

ce_read_bounded_term(Path,Maximum,Term) :-
    exists_file(Path),size_file(Path,Length),Length>0,Length=<Maximum,
    read_file_to_string(Path,Text,[encoding(utf8)]),
    term_string(Term,Text,[quoted(true),ignore_ops(true)]).

ce_read_term(Path,Term) :-
    read_file_to_string(Path,Text,[]),
    string_length(Text,Length),Length>0,Length=<2097152,
    term_string(Term,Text,[quoted(true),ignore_ops(true)]),ground(Term).

ce_write_term_durable(Path,Term) :-
    file_directory_name(Path,Directory),make_directory_path(Directory),
    atom_concat(Path,'.tmp',Temporary),\+ exists_file(Temporary),
    term_string(Term,Text,[quoted(true),ignore_ops(true)]),
    setup_call_cleanup(open(Temporary,write,Stream,[encoding(utf8)]),
      (chmod(Temporary,0o600),format(Stream,'~s',[Text]),flush_output(Stream),
       miter_store_fsync_stream(Stream)),close(Stream)),
    rename_file(Temporary,Path),chmod(Path,0o600).

ce_root(Value,Root) :-
    miter_store_nonempty_atom(Value,Root),is_absolute_file_name(Root),
    Root\=='/',exists_directory(Root),
    directory_file_path(Root,'runtime.json',Marker),exists_file(Marker).

ce_observed_user(User) :-
    process_create('/usr/bin/id',['-un'],
      [stdin(null),stdout(pipe(Output)),stderr(null),process(Pid)]),
    setup_call_cleanup(true,read_string(Output,128,Raw),close(Output)),
    process_wait(Pid,exit(0)),normalize_space(string(Name),Raw),ce_symbol(Name,User).

ce_config_valid(Config) :-
    is_dict(Config),
    ce_exact_keys(Config,
      [credential_access,enabled,expected_runtime_user,human_authority_boundaries,
       human_editable,informational_network,operator_notes,reversible_writes,
       schema,terminal,workshop,workspace_relative]),
    Config.schema=="miter-open-growth-environment-v1",
    Config.human_editable==true,memberchk(Config.enabled,[true,false]),
    ce_symbol(Config.expected_runtime_user,_ExpectedRuntimeUser),
    Config.workspace_relative=="workspace",
    Config.informational_network=="open-http-https",
    Config.terminal=="typed-direct-argv-broker",
    Config.credential_access=="named-reference-only",
    Config.reversible_writes=="versioned-owned-workspace",
    Config.human_authority_boundaries==[
      "bind-other-principal","cross-user-private-material",
      "use-named-credential","spend-or-transfer-value",
      "external-publication-or-message",
      "difficult-to-reverse-external-commitment"],
    is_list(Config.operator_notes),maplist(string,Config.operator_notes),
    ce_workshop_config_valid(Config.workshop).

ce_workshop_config_valid(Workshop) :-
    is_dict(Workshop),
    ce_exact_keys(Workshop,
      [broker,cpus,image,memory_megabytes,network,operator_notes,pids_limit,
        platform,root_filesystem,runner]),
    Workshop.runner=="docker-isolated-v1",
    Workshop.platform=="linux/arm64",Workshop.network=="none",
    Workshop.root_filesystem=="read-only",
    integer(Workshop.memory_megabytes),Workshop.memory_megabytes>=32,
    Workshop.memory_megabytes=<1024,
    number(Workshop.cpus),Workshop.cpus>0,Workshop.cpus=<2,
    integer(Workshop.pids_limit),Workshop.pids_limit>=8,
    Workshop.pids_limit=<128,
    is_dict(Workshop.broker),
    ce_exact_keys(Workshop.broker,
      [credential_reference,maximum_request_bytes,origin,schema]),
    Workshop.broker.schema=="miter-workshop-broker-client-v1",
    Workshop.broker.origin=="http://127.0.0.1:17891",
    Workshop.broker.maximum_request_bytes=:=4194304,
    is_dict(Workshop.broker.credential_reference),
    ce_exact_keys(Workshop.broker.credential_reference,[path,source]),
    Workshop.broker.credential_reference.source=="private-runtime-file",
    string(Workshop.broker.credential_reference.path),
    string(Workshop.image),string_length(Workshop.image,ImageLength),
    ImageLength>=72,ImageLength=<512,
    re_match('^[A-Za-z0-9][A-Za-z0-9._/-]*(:[A-Za-z0-9._-]+)?@sha256:[a-f0-9]{64}$',
      Workshop.image),
    is_list(Workshop.operator_notes),maplist(string,Workshop.operator_notes).

ce_exact_keys(Dict,Expected) :-
    dict_keys(Dict,Keys),sort(Keys,Sorted),sort(Expected,Sorted).

ce_symbol(Value,Atom) :-
    miter_store_nonempty_atom(Value,Atom),
    atom_length(Atom,Length),Length=<128,
    re_match('^[A-Za-z][A-Za-z0-9_.:-]{0,127}$',Atom).

ce_bounded_text(Value,Minimum,Maximum) :-
    string(Value),string_length(Value,Length),
    Length>=Minimum,Length=<Maximum,
    string_codes(Value,Codes),maplist(ce_text_code,Codes).

ce_text_code(Code) :-
    integer(Code),Code>=9,Code=<1114111,\+ memberchk(Code,[11,12,127]).
