% Mechanical observation of the dedicated-user open growth environment.
% This membrane reports configuration, runtime identity and filesystem presence.
% It does not choose a tool, command, site, purpose, credential or movement.

:- ensure_loaded('store.pl').
:- use_module(library(crypto)).
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

as_capability_environment_checked(Root0,
    ['capability-environment-observation-v1',
      'miter-open-growth-environment-v1',
      ['runtime-identity',ExpectedUser,ObservedUser,IdentityStanding],
      ['workspace',workspace,WorkspaceStanding],
      ['informational-network',InformationalNetwork,
        'proof-bound-get-head-broker-active'],
      ['terminal',Terminal,'configured-native-request-broker-pending'],
      ['reversible-writes',ReversibleWrites,
        'configured-native-request-broker-pending'],
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
    catch(as_capability_request_checked(Root0, Descriptor, Observation0), _,
      Observation0=['capability-observation-held-v1','unknown-request',
        'mechanical-boundary']),
    Observation=Observation0, !.

as_capability_request_checked(Root0, Descriptor, Observation) :-
    ce_root(Root0,Root),
    as_capability_environment_checked(Root,Environment),
    Environment=['capability-environment-observation-v1'|_],
    last(Environment,'available-open-growth-environment'),
    ce_request_descriptor(Descriptor,RequestId,Scope,Method,Url,Deadline,
      MaximumBytes,DescriptorHash),
    with_mutex(miter_capability_request,
      ce_request_once(Root,Descriptor,RequestId,Scope,Method,Url,Deadline,
        MaximumBytes,DescriptorHash,Observation)).

ce_request_descriptor(
    ['capability-request-descriptor-v1',RequestId0,IdempotencyKey0,Scope,
      ['source-contact',ContactId],
      ['source-movement',MovementReference],
      ['native-purpose',Purpose],
      ['exact-operation',['informational-http-v1',Method0,Url0]],
      ['limits',['deadline-seconds',Deadline],
        ['maximum-body-bytes',MaximumBytes]],
      ['native-proof',Proof],
      ['capability','open-http-https','no-credential',
        'informational-read-only'],prepared],
    RequestId,Scope,Method,Url,Deadline,MaximumBytes,DescriptorHash) :-
    ce_symbol(RequestId0,RequestId),ce_symbol(IdempotencyKey0,IdempotencyKey),
    RequestId==IdempotencyKey,
    as_local_scope(Scope),ce_symbol(ContactId,_),
    ce_bounded_text(Purpose,1,400),
    as_local_native_movement_proof(Proof,Scope,CutId,MovementReference,
      _Summary,_ParticipantReference,_ProofReference),
    CutId=['cut-of',ContactId,_],
    ce_http_method(Method0,Method),ce_http_url(Url0,Url),
    integer(Deadline),Deadline>=1,Deadline=<120,
    integer(MaximumBytes),MaximumBytes>=1,MaximumBytes=<1048576,
    ground(Descriptor),acyclic_term(Descriptor),
    term_string(Descriptor,DescriptorText,[quoted(true),ignore_ops(true)]),
    string_length(DescriptorText,DescriptorLength),DescriptorLength=<33554432,
    crypto_data_hash(DescriptorText,DescriptorHash,
      [algorithm(sha256),encoding(utf8)]),
    ce_request_identity_basis(ContactId,MovementReference,Method,Url,Deadline,
      MaximumBytes,Basis),
    as_native_id('c4-capability-request',Basis,RequestId).

ce_request_identity_basis(ContactId,MovementReference,Method,Url,Deadline,
    MaximumBytes,
    ['capability-request-v1',ContactId,MovementReference,
      ['informational-http-v1',Method,Url],
      ['limits',['deadline-seconds',Deadline],
        ['maximum-body-bytes',MaximumBytes]]]).

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

ce_request_once(Root,_Descriptor,RequestId,_Scope,_Method,_Url,_Deadline,
    _MaximumBytes,DescriptorHash,Observation) :-
    ce_observation_path(Root,RequestId,ObservationPath),
    exists_file(ObservationPath), !,
    ce_claim_path(Root,RequestId,ClaimPath),
    ce_claim_matches(ClaimPath,RequestId,DescriptorHash),
    ce_read_term(ObservationPath,Observation),
    ce_observation_identity(Observation,RequestId,DescriptorHash).
ce_request_once(Root,_Descriptor,RequestId,_Scope,_Method,_Url,_Deadline,
    _MaximumBytes,DescriptorHash,
    ['capability-observation-held-v1',RequestId,
      'claimed-without-observation-recovery-required']) :-
    ce_claim_path(Root,RequestId,ClaimPath),exists_file(ClaimPath),
    ce_claim_matches(ClaimPath,RequestId,DescriptorHash), !.
ce_request_once(Root,Descriptor,RequestId,Scope,Method,Url,Deadline,
    MaximumBytes,DescriptorHash,Observation) :-
    ce_claim_path(Root,RequestId,ClaimPath),
    ce_write_claim(ClaimPath,RequestId,DescriptorHash),
    get_time(Start),
    ce_http_observe(Method,Url,Deadline,MaximumBytes,Transport,HttpStatus,
      Body,Failure),
    get_time(End),ElapsedMilliseconds is round((End-Start)*1000),
    crypto_data_hash(Body,BodyHash,[algorithm(sha256),encoding(utf8)]),
    Observation=['capability-observation-v1',RequestId,Scope,
      ['request-descriptor-sha256',DescriptorHash],
      ['resource','open-http-https'],['transport',Transport],
      ['http-status',HttpStatus],['body',BodyHash,Body],
      ['elapsed-milliseconds',ElapsedMilliseconds],
      ['failure',Failure],
      'mechanical-observation-no-meaning-no-movement-authority'],
    ce_observation_identity(Observation,RequestId,DescriptorHash),
    ce_observation_path(Root,RequestId,ObservationPath),
    ce_write_term_durable(ObservationPath,Observation),
    ce_record_completion(ClaimPath,RequestId,DescriptorHash,Transport,
      HttpStatus,BodyHash,ElapsedMilliseconds),
    ground(Descriptor).

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

ce_record_completion(Path,RequestId,DescriptorHash,Transport,HttpStatus,
    BodyHash,ElapsedMilliseconds) :-
    get_time(Now),
    miter_store_write_json_atomic(Path,
      _{schema:"miter-capability-claim-v1",request_id:RequestId,
        descriptor_sha256:DescriptorHash,completed_at_epoch:Now,
        standing:"observation-durable",transport:Transport,
        http_status:HttpStatus,body_sha256:BodyHash,
        elapsed_milliseconds:ElapsedMilliseconds}).

ce_claim_matches(Path,RequestId,DescriptorHash) :-
    miter_store_read_json(Path,Claim),is_dict(Claim),
    Claim.schema=="miter-capability-claim-v1",
    ce_symbol(Claim.request_id,RequestId),
    ce_symbol(Claim.descriptor_sha256,DescriptorHash).

ce_observation_identity(
    ['capability-observation-v1',RequestId,_Scope,
      ['request-descriptor-sha256',DescriptorHash]|_],
    RequestId,DescriptorHash).

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
       schema,terminal,workspace_relative]),
    Config.schema=="miter-open-growth-environment-v1",
    Config.human_editable==true,memberchk(Config.enabled,[true,false]),
    Config.expected_runtime_user=="claritymiter",
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
    is_list(Config.operator_notes),maplist(string,Config.operator_notes).

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
