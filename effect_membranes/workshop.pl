% Mechanical executable-extension workshop for Miter's open growth environment.
% Native MeTTa forms every operation and decides whether returned contact
% warrants another movement.  This membrane owns only isolated Git worktrees,
% exact file/hash checks, bounded process observation, durable operation records,
% atomic active-version transitions and mechanical rollback.

:- ensure_loaded('store.pl').
:- use_module(library(crypto)).
:- use_module(library(filesex)).
:- use_module(library(lists)).
:- use_module(library(pcre)).
:- use_module(library(process)).
:- use_module(library(readutil)).

miter_workshop_operation(Operation0,Operation,
    ['capability','executable-extension-workshop','no-credential',
      'reversible-local-tentacle']) :-
    mw_operation(Operation0,Operation).

miter_workshop_observe(Root,RequestId,Operation,Deadline,MaximumBytes,
    Standing,Outcome,Failure,Completion) :-
    catch(mw_observe(Root,RequestId,Operation,Deadline,MaximumBytes,
      Standing0,Detail0,Failure0,Completion0),Error,
      mw_error_observation(Error,Standing0,Detail0,Failure0,Completion0)),
    mw_operation_subject(Operation,Kind,ExtensionId,Version),
    Standing=Standing0,Failure=Failure0,Completion=Completion0,
    Outcome=['extension-workshop-result-v1',Standing,
      ['operation',Kind],['extension',ExtensionId,Version],Detail0,
      'mechanical-observation-no-meaning-no-movement-authority'].

% Reconcile only an operation that already has durable mechanical evidence.
% Invocation is intentionally excluded: after an uncertain process boundary it
% must remain held rather than execute twice.  Prepared registry transitions
% may be completed because their exact prior state and candidate lineage were
% durably fixed before the active pointer was changed.
miter_workshop_reconcile(Root,RequestId,Operation,Standing,Outcome,Failure,
    Completion) :-
    catch(mw_reconcile(Root,RequestId,Operation,Standing0,Detail0,Failure0),
      _,fail),
    mw_operation_subject(Operation,Kind,ExtensionId,Version),
    Standing=Standing0,Failure=Failure0,
    Outcome=['extension-workshop-result-v1',Standing,
      ['operation',Kind],['extension',ExtensionId,Version],Detail0,
      'mechanical-observation-no-meaning-no-movement-authority'],
    mw_completion(Standing,Detail0,Completion).

mw_error_observation(Error,failed,['mechanical-error',Class],Class,
    _{resource:"executable-extension-workshop",standing:"failed"}) :-
    functor(Error,Functor,_),
    ( atom(Functor) -> Class=Functor ; Class='workshop-error' ).

mw_operation(['extension-stage-v1',Manifest0],
    ['extension-stage-v1',Manifest]) :-
    mw_manifest(Manifest0,Manifest),!.
mw_operation(['extension-trial-v1',Id0,Version0,StageRequest0],
    ['extension-trial-v1',Id,Version,StageRequest]) :-
    mw_id(Id0,Id),mw_id(Version0,Version),mw_id(StageRequest0,StageRequest),!.
mw_operation(['extension-activate-v1',Id0,Version0,StageRequest0,
      TrialRequest0,Expected0],
    ['extension-activate-v1',Id,Version,StageRequest,TrialRequest,Expected]) :-
    mw_id(Id0,Id),mw_id(Version0,Version),mw_id(StageRequest0,StageRequest),
    mw_id(TrialRequest0,TrialRequest),mw_expected_active(Expected0,Expected),!.
mw_operation(['extension-invoke-v1',Id0,Version0,Arguments0],
    ['extension-invoke-v1',Id,Version,Arguments]) :-
    mw_id(Id0,Id),mw_id(Version0,Version),is_list(Arguments0),
    length(Arguments0,Count),Count=<64,maplist(mw_argument,Arguments0,Arguments),!.
mw_operation(['extension-rollback-v1',Id0,ExpectedVersion0],
    ['extension-rollback-v1',Id,ExpectedVersion]) :-
    mw_id(Id0,Id),mw_id(ExpectedVersion0,ExpectedVersion),!.

mw_operation_subject(['extension-stage-v1',Manifest],stage,Id,Version) :-
    mw_manifest_identity(Manifest,Id,Version),!.
mw_operation_subject(['extension-trial-v1',Id,Version,_],trial,Id,Version) :- !.
mw_operation_subject(['extension-activate-v1',Id,Version,_,_,_],activate,Id,Version) :- !.
mw_operation_subject(['extension-invoke-v1',Id,Version,_],invoke,Id,Version) :- !.
mw_operation_subject(['extension-rollback-v1',Id,Version],rollback,Id,Version).

% executable-extension-manifest-v1 contains every C-095 carrier.  Textual
% purpose and pressure remain data for native cognition; this parser validates
% only the closed mechanical shape needed to execute the already-formed move.
mw_manifest(Manifest0,Manifest) :-
    Manifest0=['executable-extension-manifest-v1',
      ['extension-id',Id0],['extension-version',Version0],
      ['purpose',Purpose],['source-pressure',Pressure],
      ['source-files',Files0],['entrypoint',Entrypoint0],
      ['interface-contract',InterfaceVersion0,InputContract0,OutputContract0],
      ['state-contract',StateSchema0,Compatibility0],
      ['authority-contract',['permissions',Permissions0],
        ['network-surfaces',Network0],['credential-capabilities',Credentials0],
        ['effect-classes',Effects0]],
      ['resource-envelope',['deadline-seconds',ExtensionDeadline],
        ['maximum-output-bytes',ExtensionMaximum]],
      ['independent-trials',Trials0],
      ['runtime-contract',Runner0,Image0,Program0,PrefixArguments0],
      ['memory-scopes',MemoryScopes0],
      ['rollback','previous-active-version'],
      ['module-provenance',Source0,Lineage0],
      ['human-approval',Approval0],
      'candidate-not-self-certifying'],
    mw_id(Id0,Id),mw_id(Version0,Version),
    mw_bounded_text(Purpose,1,1000),mw_bounded_text(Pressure,1,4000),
    is_list(Files0),Files0=[_|_],length(Files0,FileCount),FileCount=<64,
    maplist(mw_source_file,Files0,Files),
    mw_unique_source_paths(Files),
    mw_relative(Entrypoint0,Entrypoint),
    member(['extension-file',_,Entrypoint,_],Files),
    mw_id(InterfaceVersion0,InterfaceVersion),
    mw_id(InputContract0,InputContract),mw_id(OutputContract0,OutputContract),
    mw_id(StateSchema0,StateSchema),mw_id(Compatibility0,Compatibility),
    memberchk(Compatibility,
      ['stateless-compatible','state-compatible','requires-migration',
       'migration-proven']),
    is_list(Permissions0),length(Permissions0,PermissionCount),
    PermissionCount=<64,
    maplist(mw_id_value,Permissions0,Permissions),
    is_list(Network0),length(Network0,NetworkCount),NetworkCount=<64,
    maplist(mw_id_value,Network0,Network),
    is_list(Credentials0),length(Credentials0,CredentialCount),
    CredentialCount=<64,
    maplist(mw_id_value,Credentials0,Credentials),
    is_list(Effects0),length(Effects0,EffectCount),EffectCount=<64,
    maplist(mw_id_value,Effects0,Effects),
    integer(ExtensionDeadline),ExtensionDeadline>=1,ExtensionDeadline=<120,
    integer(ExtensionMaximum),ExtensionMaximum>=1,
    ExtensionMaximum=<1048576,
    is_list(Trials0),length(Trials0,TrialCount),TrialCount>=2,TrialCount=<32,
    maplist(mw_trial,Trials0,Trials),mw_unique_trial_ids(Trials),
    mw_id(Runner0,Runner),Runner=='docker-isolated-v1',
    mw_container_image(Image0,Image),mw_container_program(Program0,Program),
    is_list(PrefixArguments0),length(PrefixArguments0,PrefixCount),
    PrefixCount=<32,maplist(mw_argument,PrefixArguments0,PrefixArguments),
    member("{entrypoint}",PrefixArguments),
    is_list(MemoryScopes0),length(MemoryScopes0,MemoryScopeCount),
    MemoryScopeCount=<64,maplist(mw_id_value,MemoryScopes0,MemoryScopes),
    mw_id(Source0,Source),mw_id(Lineage0,Lineage),mw_id(Approval0,Approval),
    Manifest=['executable-extension-manifest-v1',
      ['extension-id',Id],['extension-version',Version],
      ['purpose',Purpose],['source-pressure',Pressure],
      ['source-files',Files],['entrypoint',Entrypoint],
      ['interface-contract',InterfaceVersion,InputContract,OutputContract],
      ['state-contract',StateSchema,Compatibility],
      ['authority-contract',['permissions',Permissions],
        ['network-surfaces',Network],['credential-capabilities',Credentials],
        ['effect-classes',Effects]],
      ['resource-envelope',['deadline-seconds',ExtensionDeadline],
        ['maximum-output-bytes',ExtensionMaximum]],
      ['independent-trials',Trials],
      ['runtime-contract',Runner,Image,Program,PrefixArguments],
      ['memory-scopes',MemoryScopes],
      ['rollback','previous-active-version'],
      ['module-provenance',Source,Lineage],
      ['human-approval',Approval],
      'candidate-not-self-certifying'].

mw_manifest_identity(Manifest,Id,Version) :-
    Manifest=['executable-extension-manifest-v1',['extension-id',Id],
      ['extension-version',Version]|_].

mw_source_file(['extension-file',Workspace0,Candidate0,Hash0],
    ['extension-file',Workspace,Candidate,Hash]) :-
    mw_relative(Workspace0,Workspace),mw_relative(Candidate0,Candidate),
    mw_sha256(Hash0,Hash).

mw_trial(['extension-trial-v1',Id0,Arguments0,ExpectedExit,
      ExpectedStdout0],
    ['extension-trial-v1',Id,Arguments,ExpectedExit,ExpectedStdout]) :-
    mw_id(Id0,Id),is_list(Arguments0),length(Arguments0,Count),Count=<64,
    maplist(mw_argument,Arguments0,Arguments),integer(ExpectedExit),
    ExpectedExit>=0,ExpectedExit=<255,mw_sha256(ExpectedStdout0,ExpectedStdout).

mw_unique_trial_ids(Trials) :-
    findall(Id,member(['extension-trial-v1',Id|_],Trials),Ids),
    sort(Ids,Unique),same_length(Ids,Unique).

mw_unique_source_paths(Files) :-
    findall(Workspace,member(['extension-file',Workspace,_,_],Files),Workspaces),
    sort(Workspaces,UniqueWorkspaces),same_length(Workspaces,UniqueWorkspaces),
    findall(Candidate,member(['extension-file',_,Candidate,_],Files),Candidates),
    sort(Candidates,UniqueCandidates),same_length(Candidates,UniqueCandidates).

mw_expected_active('no-active-version','no-active-version').
mw_expected_active(['active-version',Version0,Commit0],
    ['active-version',Version,Commit]) :-
    mw_id(Version0,Version),mw_git_oid(Commit0,Commit).

mw_observe(Root,RequestId,['extension-stage-v1',Manifest],_Deadline,
    _MaximumBytes,Standing,Detail,Failure,Completion) :- !,
    mw_stage(Root,RequestId,Manifest,Standing,Detail,Failure),
    mw_completion(Standing,Detail,Completion).
mw_observe(Root,RequestId,['extension-trial-v1',Id,Version,StageRequest],
    Deadline,MaximumBytes,Standing,Detail,Failure,Completion) :- !,
    mw_run_trials(Root,RequestId,Id,Version,StageRequest,Deadline,MaximumBytes,
      Standing,Detail,Failure),mw_completion(Standing,Detail,Completion).
mw_observe(Root,RequestId,
    ['extension-activate-v1',Id,Version,StageRequest,TrialRequest,Expected],
    _Deadline,_MaximumBytes,Standing,Detail,Failure,Completion) :- !,
    mw_activate(Root,RequestId,Id,Version,StageRequest,TrialRequest,Expected,
      Standing,Detail,Failure),mw_completion(Standing,Detail,Completion).
mw_observe(Root,RequestId,['extension-invoke-v1',Id,Version,Arguments],
    Deadline,MaximumBytes,Standing,Detail,Failure,Completion) :- !,
    mw_invoke(Root,RequestId,Id,Version,Arguments,Deadline,MaximumBytes,
      Standing,Detail,Failure),mw_completion(Standing,Detail,Completion).
mw_observe(Root,RequestId,['extension-rollback-v1',Id,ExpectedVersion],
    _Deadline,_MaximumBytes,Standing,Detail,Failure,Completion) :-
    mw_rollback(Root,RequestId,Id,ExpectedVersion,Standing,Detail,Failure),
    mw_completion(Standing,Detail,Completion).

mw_completion(Standing,Detail,
    _{resource:"executable-extension-workshop",standing:StandingString,
      result_sha256:HashString}) :-
    atom_string(Standing,StandingString),
    term_string(Detail,Text,[quoted(true),ignore_ops(true)]),
    crypto_data_hash(Text,Hash,[algorithm(sha256),encoding(utf8)]),
    atom_string(Hash,HashString).

mw_reconcile(Root,RequestId,['extension-stage-v1',Manifest],staged,Detail,none) :-
    mw_stage(Root,RequestId,Manifest,staged,Detail,none).
mw_reconcile(Root,RequestId,
    ['extension-trial-v1',Id,Version,StageRequest],Standing,
    ['trial',RequestId,['stage-request',StageRequest],['commit',Commit],
      ['results',Results],'recovered-from-durable-trial-record'],Failure) :-
    mw_trial_record(Root,Id,Version,RequestId,
      ['extension-trial-record-v1',RequestId,StageRequest,Commit,_Manifest,
        Results,Standing]),
    ( Standing=='trial-passed' -> Failure=none
    ; Failure='independent-trial-mismatch' ).
mw_reconcile(Root,RequestId,
    ['extension-activate-v1',Id,Version,StageRequest,TrialRequest,_Expected],
    activated,
    ['activation',RequestId,['active',Active],['trial-request',TrialRequest],
      Compatibility,'recovered-from-durable-prepared-transition'],none) :-
    mw_prepared_index(Root,RequestId,PreparedPath),
    mw_read_term(PreparedPath,
      ['extension-activation-prepared-v1',RequestId,Id,Version,StageRequest,
        TrialRequest,ManifestHash,Commit,Prior,Compatibility]),
    mw_stage_record(Root,Id,Version,StageRequest,
      ['extension-stage-record-v1',StageRequest,ManifestHash,Commit,_Branch,
        CandidateRelative,Manifest]),
    mw_trial_record(Root,Id,Version,TrialRequest,
      ['extension-trial-record-v1',TrialRequest,StageRequest,Commit,Manifest,
        Results,'trial-passed']),
    forall(member(Result,Results),nth0(6,Result,passed)),
    mw_candidate_verified(Root,CandidateRelative,Commit,Manifest,_),
    Active=['active-executable-extension-v1',Id,Version,Commit,Manifest,
      ['activation-reference',RequestId],['prior-active',Prior],
      'hot-at-serialized-capability-cut'],
    mw_active_index(Root,Id,ActivePath),
    mw_finish_exact_active_transition(ActivePath,Prior,Active).
mw_reconcile(Root,RequestId,
    ['extension-rollback-v1',Id,ExpectedVersion],'rolled-back',
    ['rollback',RequestId,['from',Current],['restored',Prior],
      'history-retained','recovered-from-durable-prepared-transition'],none) :-
    mw_prepared_index(Root,RequestId,PreparedPath),
    mw_read_term(PreparedPath,
      ['extension-rollback-prepared-v1',RequestId,Current,Prior]),
    Current=['active-executable-extension-v1',Id,ExpectedVersion|_],
    mw_active_index(Root,Id,ActivePath),
    mw_finish_exact_rollback(ActivePath,Current,Prior).

mw_finish_exact_active_transition(Path,Prior,Active) :-
    ( exists_file(Path),mw_read_term(Path,Active) -> true
    ; mw_active_state_exact(Path,Prior),mw_write_term(Path,Active) ).

mw_finish_exact_rollback(Path,Current,Prior) :-
    ( mw_active_state_exact(Path,Prior) -> true
    ; exists_file(Path),mw_read_term(Path,Current),
      ( Prior=='no-active-version' -> delete_file(Path)
      ; mw_write_term(Path,Prior) ) ).

mw_active_state_exact(Path,'no-active-version') :- \+ exists_file(Path),!.
mw_active_state_exact(Path,Active) :-
    exists_file(Path),mw_read_term(Path,Active).

mw_stage(Root,RequestId,Manifest,Standing,Detail,Failure) :-
    mw_manifest_identity(Manifest,Id,Version),mw_manifest_hash(Manifest,Hash),
    mw_stage_index(Root,Id,Version,Index),
    ( exists_file(Index) ->
        mw_read_term(Index,Stored),
        Stored=['extension-stage-record-v1',RequestId,Hash,Commit,Branch,
          CandidateRelative,Manifest],
        Standing=staged,Failure=none,
        Detail=['stage',RequestId,Hash,Commit,Branch,CandidateRelative,
          'duplicate-observed']
    ; mw_ensure_repository(Root,Repository),
      mw_candidate_relative(Id,Version,CandidateRelative),
      directory_file_path(Root,CandidateRelative,Candidate),
      term_string([Id,Version,Hash],BranchBasis,
        [quoted(true),ignore_ops(true)]),
      crypto_data_hash(BranchBasis,BranchHash,
        [algorithm(sha256),encoding(utf8)]),
      atom_concat('candidate-',BranchHash,Branch),
      mw_prepared_index(Root,RequestId,PreparedPath),
      mw_write_once_term(PreparedPath,
        ['extension-stage-prepared-v1',RequestId,Id,Version,Hash,Branch,
          CandidateRelative,Manifest]),
      mw_ensure_candidate_commit(Root,Repository,Candidate,Branch,Manifest,
        Commit),
      Record=['extension-stage-record-v1',RequestId,Hash,Commit,Branch,
        CandidateRelative,Manifest],mw_write_once_term(Index,Record),
      Standing=staged,Failure=none,
      Detail=['stage',RequestId,Hash,Commit,Branch,CandidateRelative,
        'isolated-worktree-committed'] ).

mw_ensure_candidate_commit(Root,Repository,Candidate,Branch,Manifest,Commit) :-
    ( exists_directory(Candidate) ->
        mw_git_output(Root,Candidate,['branch','--show-current'],ObservedBranch0),
        normalize_space(atom(ObservedBranch),ObservedBranch0),
        ObservedBranch==Branch
    ; mw_git(Root,Repository,['worktree','add','-b',Branch,Candidate,'main']) ),
    mw_copy_manifest_sources(Root,Candidate,Manifest),
    mw_git(Root,Candidate,['add','--','.']),
    mw_git_output(Root,Candidate,['status','--porcelain'],Status0),
    normalize_space(string(Status),Status0),
    ( Status=="" -> true
    ; mw_git(Root,Candidate,
        ['-c','user.name=Miter executable workshop',
         '-c','user.email=miter-workshop@example.invalid','commit','-m',
         'Stage executable extension candidate']) ),
    mw_git_output(Root,Candidate,['rev-parse','HEAD'],Commit0),
    normalize_space(atom(Commit),Commit0),mw_git_oid(Commit,Commit),
    mw_candidate_verified_path(Candidate,Commit,Manifest).

mw_run_trials(Root,RequestId,Id,Version,StageRequest,Deadline,MaximumBytes,
    Standing,Detail,Failure) :-
    mw_stage_record(Root,Id,Version,StageRequest,Stage),
    Stage=['extension-stage-record-v1',StageRequest,_ManifestHash,Commit,_Branch,
      CandidateRelative,Manifest],
    mw_candidate_verified(Root,CandidateRelative,Commit,Manifest,Candidate),
    nth0(11,Manifest,['independent-trials',Trials]),
    findall(Result,(member(Trial,Trials),
      mw_one_trial(Candidate,Manifest,Trial,Deadline,MaximumBytes,Result)),Results),
    ( forall(member(Result,Results),nth0(6,Result,passed)) ->
        Standing='trial-passed',Failure=none
    ; Standing='trial-failed',Failure='independent-trial-mismatch' ),
    Detail=['trial',RequestId,['stage-request',StageRequest],['commit',Commit],
      ['results',Results]],
    mw_trial_index(Root,Id,Version,RequestId,TrialIndex),
    mw_write_once_term(TrialIndex,
      ['extension-trial-record-v1',RequestId,StageRequest,Commit,Manifest,
        Results,Standing]).

mw_one_trial(Candidate,Manifest,
    ['extension-trial-v1',TrialId,Arguments,ExpectedExit,ExpectedStdout],
    RequestedDeadline,RequestedMaximum,
    ['extension-trial-result-v1',TrialId,['exit-code',ExitCode],
      ['stdout',StdoutHash,Stdout],['stderr',StderrHash,Stderr],
      Transport,Standing]) :-
    mw_runtime(Manifest,Candidate,_Image,_Program,Prefix,ManifestDeadline,
      ManifestMaximum),
    min_list([RequestedDeadline,ManifestDeadline],Deadline),
    min_list([RequestedMaximum,ManifestMaximum],Maximum),
    append(Prefix,Arguments,Argv),
    mw_container_observe(Candidate,Manifest,Argv,Deadline,Maximum,Transport,
      ExitCode,Stdout,Stderr,_Failure),
    crypto_data_hash(Stdout,StdoutHash,[algorithm(sha256),encoding(utf8)]),
    crypto_data_hash(Stderr,StderrHash,[algorithm(sha256),encoding(utf8)]),
    ( ExitCode==ExpectedExit,StdoutHash==ExpectedStdout,Transport==eof ->
        Standing=passed
    ; Standing=failed ).

mw_activate(Root,RequestId,Id,Version,StageRequest,TrialRequest,Expected,
    Standing,Detail,Failure) :-
    mw_stage_record(Root,Id,Version,StageRequest,Stage),
    Stage=['extension-stage-record-v1',StageRequest,ManifestHash,Commit,_Branch,
      CandidateRelative,Manifest],
    mw_trial_record(Root,Id,Version,TrialRequest,Trial),
    Trial=['extension-trial-record-v1',TrialRequest,StageRequest,Commit,Manifest,
      Results,'trial-passed'],
    forall(member(Result,Results),nth0(6,Result,passed)),
    mw_candidate_verified(Root,CandidateRelative,Commit,Manifest,_Candidate),
    mw_active_index(Root,Id,ActivePath),
    mw_active_or_none(ActivePath,Current),
    ( mw_expected_matches(Current,Expected),
      mw_within_open_growth_authority(Manifest),
      mw_compatible(Current,Manifest,Compatibility) ->
        Prepared=['extension-activation-prepared-v1',RequestId,Id,Version,
          StageRequest,TrialRequest,ManifestHash,Commit,Current,Compatibility],
        mw_prepared_index(Root,RequestId,PreparedPath),
        mw_write_once_term(PreparedPath,Prepared),
        Active=['active-executable-extension-v1',Id,Version,Commit,Manifest,
          ['activation-reference',RequestId],['prior-active',Current],
          'hot-at-serialized-capability-cut'],
        mw_write_term(ActivePath,Active),
        Standing=activated,Failure=none,
        Detail=['activation',RequestId,['active',Active],
          ['trial-request',TrialRequest],Compatibility]
    ; mw_activation_hold(Current,Expected,Manifest,Standing,Failure),
      Detail=['activation-held',RequestId,['current',Current],
        ['expected',Expected],['reason',Failure]] ).

mw_activation_hold(Current,Expected,_Manifest,held,
    'expected-active-version-mismatch') :-
    \+ mw_expected_matches(Current,Expected),!.
mw_activation_hold(_Current,_Expected,Manifest,held,
    'relational-authority-requires-human') :-
    \+ mw_within_open_growth_authority(Manifest),!.
mw_activation_hold(_Current,_Expected,_Manifest,held,
    'interface-or-state-migration-incompatible').

mw_invoke(Root,RequestId,Id,Version,Arguments,RequestedDeadline,
    RequestedMaximum,Standing,Detail,Failure) :-
    mw_active_index(Root,Id,ActivePath),mw_read_term(ActivePath,Active),
    Active=['active-executable-extension-v1',Id,Version,Commit,Manifest|_],
    mw_candidate_relative(Id,Version,CandidateRelative),
    mw_candidate_verified(Root,CandidateRelative,Commit,Manifest,Candidate),
    mw_runtime(Manifest,Candidate,_Image,_Program,Prefix,ManifestDeadline,
      ManifestMaximum),
    min_list([RequestedDeadline,ManifestDeadline],Deadline),
    min_list([RequestedMaximum,ManifestMaximum],Maximum),append(Prefix,Arguments,Argv),
    mw_container_observe(Candidate,Manifest,Argv,Deadline,Maximum,Transport,
      ExitCode,Stdout,Stderr,ProcessFailure),
    crypto_data_hash(Stdout,StdoutHash,[algorithm(sha256),encoding(utf8)]),
    crypto_data_hash(Stderr,StderrHash,[algorithm(sha256),encoding(utf8)]),
    ( Transport==eof -> Standing=invoked,Failure=none
    ; Standing=failed,Failure=ProcessFailure ),
    Detail=['invocation',RequestId,['commit',Commit],['transport',Transport],
      ['exit-code',ExitCode],['stdout',StdoutHash,Stdout],
      ['stderr',StderrHash,Stderr]].

mw_rollback(Root,RequestId,Id,ExpectedVersion,Standing,Detail,Failure) :-
    mw_active_index(Root,Id,ActivePath),
    ( exists_file(ActivePath),mw_read_term(ActivePath,Current),
      Current=['active-executable-extension-v1',Id,ExpectedVersion|_],
      nth0(6,Current,['prior-active',Prior]) ->
        mw_prepared_index(Root,RequestId,PreparedPath),
        mw_write_once_term(PreparedPath,
          ['extension-rollback-prepared-v1',RequestId,Current,Prior]),
        ( Prior=='no-active-version' -> delete_file(ActivePath),Restored=Prior
        ; mw_write_term(ActivePath,Prior),Restored=Prior ),
        Standing='rolled-back',Failure=none,
        Detail=['rollback',RequestId,['from',Current],['restored',Restored],
          'history-retained']
    ; Standing=held,Failure='active-or-expected-version-mismatch',
      Detail=['rollback-held',RequestId,['reason',Failure]] ).

mw_manifest_hash(Manifest,Hash) :-
    term_string(Manifest,Text,[quoted(true),ignore_ops(true)]),
    crypto_data_hash(Text,Hash,[algorithm(sha256),encoding(utf8)]).

mw_copy_manifest_sources(Root,Candidate,Manifest) :-
    nth0(5,Manifest,['source-files',Files]),
    forall(member(['extension-file',WorkspaceRelative,CandidateRelative,Hash],Files),
      ( mw_workspace_source(Root,WorkspaceRelative,Source),
        crypto_file_hash(Source,Hash,[algorithm(sha256),encoding(octet)]),
        mw_candidate_target(Candidate,CandidateRelative,Target),
        \+ read_link(Target,_,_),copy_file(Source,Target),chmod(Target,0o644) )),
    nth0(6,Manifest,['entrypoint',Entrypoint]),
    directory_file_path(Candidate,Entrypoint,Entry),chmod(Entry,0o755).

mw_candidate_target(Base,Relative,Path) :-
    mw_relative(Relative,Relative),atomic_list_concat(Parts,'/',Relative),
    mw_candidate_parts(Base,Parts,Path).
mw_candidate_parts(Current,[Leaf],Path) :-
    \+ read_link(Current,_,_),directory_file_path(Current,Leaf,Path).
mw_candidate_parts(Current,[Part|Rest],Path) :-
    \+ read_link(Current,_,_),directory_file_path(Current,Part,Next),
    ( exists_directory(Next) -> \+ read_link(Next,_,_)
    ; \+ exists_file(Next),make_directory(Next),chmod(Next,0o700) ),
    mw_candidate_parts(Next,Rest,Path).

mw_runtime(Manifest,Candidate,Image,Program,Arguments,Deadline,Maximum) :-
    nth0(12,Manifest,
      ['runtime-contract','docker-isolated-v1',Image,Program,Prefix]),
    nth0(6,Manifest,['entrypoint',Entrypoint]),
    directory_file_path(Candidate,Entrypoint,Entry),
    exists_file(Entry),\+ read_link(Entry,_,_),
    maplist(mw_expand_entrypoint(Entrypoint),Prefix,Arguments),
    nth0(10,Manifest,['resource-envelope',['deadline-seconds',Deadline],
      ['maximum-output-bytes',Maximum]]).

mw_expand_entrypoint(Entrypoint,"{entrypoint}",Expanded) :- !,
    atom_concat('/workspace/extension/',Entrypoint,Path),
    atom_string(Path,Expanded).
mw_expand_entrypoint(_Entry,Argument,Argument).

mw_container_observe(Candidate,Manifest,Arguments,Deadline,
    Maximum,Transport,ExitCode,Stdout,Stderr,Failure) :-
    mw_runtime(Manifest,Candidate,Image,Program,_Prefix,_ManifestDeadline,
      _ManifestMaximum),
    mw_workshop_configuration(Candidate,Image,Docker,Platform,Memory,Cpus,Pids),
    current_prolog_flag(pid,Pid),get_time(Now),Stamp is round(Now*1000),
    format(atom(Container),'miter-extension-~d-~d',[Pid,Stamp]),
    atom_concat(Container,'-loader',Loader),
    atom_concat(Container,'-source',Volume),
    format(atom(MemoryArg),'~dm',[Memory]),format(atom(CpuArg),'~w',[Cpus]),
    format(atom(PidsArg),'~d',[Pids]),
    format(atom(SourceMount),
      'type=volume,src=~w,dst=/workspace/extension,readonly',[Volume]),
    append([
      ['create','--name',Container,'--platform',Platform,
       '--label','io.singularitynet.miter.workshop=true',
       '--network','none','--read-only','--cap-drop','ALL','--security-opt',
       'no-new-privileges','--memory',MemoryArg,'--cpus',CpuArg,
       '--pids-limit',PidsArg,'--tmpfs','/tmp:rw,noexec,nosuid,size=16m',
       '--tmpfs','/workspace/state:rw,noexec,nosuid,size=16m',
       '--mount',SourceMount,'--workdir',
       '/workspace/extension','--entrypoint',Program,Image],Arguments],DockerArgs),
    mw_candidate_export(Candidate,Manifest,Container,Export),
    setup_call_cleanup(true,
      ( mw_prepare_source_volume(Docker,Export,Image,Platform,Loader,Volume,
          Deadline,Maximum),
        mw_container_lifecycle(Docker,DockerArgs,Container,Candidate,Deadline,
          Maximum,Transport,ExitCode,Stdout,Stderr,Failure) ),
      ( mw_remove_container_resources(Docker,Container,Loader,Volume,Candidate),
        mw_remove_candidate_export(Export) )).

% Export only the exact manifest-enumerated candidate bytes.  The Git control
% file, workshop bookkeeping and unrelated runtime state never enter the
% candidate volume.  This is data minimisation at the effect membrane, not a
% restriction on which candidate the Soul may choose to construct and test.
mw_candidate_export(Candidate,Manifest,Container,Export) :-
    mw_candidate_root(Candidate,Root),
    directory_file_path(Root,'workshop/exports',Exports),
    make_directory_path(Exports),chmod(Exports,0o700),
    directory_file_path(Exports,Container,Export),
    \+ exists_file(Export),\+ exists_directory(Export),
    make_directory(Export),chmod(Export,0o700),
    nth0(5,Manifest,['source-files',Files]),
    forall(member(['extension-file',_,Relative,Hash],Files),
      ( directory_file_path(Candidate,Relative,Source),exists_file(Source),
        \+ read_link(Source,_,_),
        crypto_file_hash(Source,Hash,[algorithm(sha256),encoding(octet)]),
        mw_candidate_target(Export,Relative,Target),copy_file(Source,Target),
        chmod(Target,0o644) )),
    nth0(6,Manifest,['entrypoint',Entrypoint]),
    directory_file_path(Export,Entrypoint,Entry),chmod(Entry,0o755).

mw_candidate_root(Candidate,Root) :-
    file_directory_name(Candidate,VersionDirectory),
    file_directory_name(VersionDirectory,ExtensionDirectory),
    file_directory_name(ExtensionDirectory,CandidatesDirectory),
    file_directory_name(CandidatesDirectory,Root).

mw_remove_candidate_export(Export) :-
    catch((exists_directory(Export),\+ read_link(Export,_,_),
      delete_directory_and_contents(Export)),_,true).

mw_prepare_source_volume(Docker,Export,Image,Platform,Loader,Volume,Deadline,
    Maximum) :-
    ce_process_observe(Docker,
      ['volume','create','--label','io.singularitynet.miter.workshop=true',Volume],
      Export,Deadline,Maximum,eof,0,_VolumeOut,_VolumeErr,none),
    format(atom(SourceMount),'type=volume,src=~w,dst=/workspace/extension',
      [Volume]),
    ce_process_observe(Docker,
      ['create','--name',Loader,'--platform',Platform,'--network','none',
       '--label','io.singularitynet.miter.workshop=true',
       '--cap-drop','ALL','--security-opt','no-new-privileges','--mount',
       SourceMount,'--entrypoint','/bin/true',Image],Export,Deadline,Maximum,
      eof,0,_LoaderOut,_LoaderErr,none),
    atom_concat(Loader,':/workspace/extension',ContainerTarget),
    atom_concat(Export,'/.',CandidateSource),
    ce_process_observe(Docker,['cp',CandidateSource,ContainerTarget],Export,
      Deadline,Maximum,eof,0,_CopyOut,_CopyErr,none),
    mw_remove_container(Docker,Loader,Export).

mw_container_lifecycle(Docker,CreateArguments,Container,Candidate,Deadline,
    Maximum,Transport,ExitCode,Stdout,Stderr,Failure) :-
    ce_process_observe(Docker,CreateArguments,Candidate,Deadline,Maximum,
      CreateTransport,CreateExit,_CreateOut,CreateErr,CreateFailure),
    ( CreateTransport==eof,CreateExit==0 ->
        ce_process_observe(Docker,['start','--attach',Container],Candidate,
          Deadline,Maximum,Transport,ExitCode,Stdout,Stderr,Failure)
    ; Transport=failed,ExitCode=CreateExit,Stdout="",Stderr=CreateErr,
      Failure=['container-create-failed',CreateFailure] ).

mw_workshop_configuration(Candidate,Image,Docker,Platform,Memory,Cpus,Pids) :-
    mw_candidate_root(Candidate,Root),
    directory_file_path(Root,'growth-environment.json',ConfigPath),
    miter_store_read_json(ConfigPath,Config),Workshop=Config.workshop,
    Workshop.runner=="docker-isolated-v1",Workshop.network=="none",
    Workshop.root_filesystem=="read-only",
    atom_string(Image,Workshop.image),atom_string(Platform,Workshop.platform),
    Memory=Workshop.memory_megabytes,integer(Memory),Memory>=32,Memory=<1024,
    Cpus=Workshop.cpus,number(Cpus),Cpus>0,Cpus=<2,
    Pids=Workshop.pids_limit,integer(Pids),Pids>=8,Pids=<128,
    mw_docker_executable(Docker).

mw_docker_executable('/Applications/Docker.app/Contents/Resources/bin/docker') :-
    access_file('/Applications/Docker.app/Contents/Resources/bin/docker',execute),!.
mw_docker_executable('/usr/local/bin/docker') :-
    access_file('/usr/local/bin/docker',execute),!.
mw_docker_executable('/opt/homebrew/bin/docker') :-
    access_file('/opt/homebrew/bin/docker',execute).

mw_remove_container(Docker,Container,Directory) :-
    catch(ce_process_observe(Docker,['rm','--force',Container],Directory,10,4096,
      _Transport,_Exit,_Out,_Err,_Failure),_,true).

mw_remove_container_resources(Docker,Container,Loader,Volume,Directory) :-
    mw_remove_container(Docker,Container,Directory),
    mw_remove_container(Docker,Loader,Directory),
    catch(ce_process_observe(Docker,['volume','rm','--force',Volume],Directory,
      10,4096,_Transport,_Exit,_Out,_Err,_Failure),_,true).

% A supervisor restart can follow a hard kill between container creation and
% cleanup.  The exact Miter workshop label is the sole recovery selector; no
% unrelated Docker object is inspected or removed.  This runs before a new
% PeTTa child starts and has no access to contact meaning or movement choice.
miter_workshop_cleanup_orphans(Root0,Result) :-
    ( catch(mw_cleanup_orphans_checked(Root0,Result0),_,fail) ->
        Result=Result0
    ; Result=['workshop-orphan-recovery-v1',held,
        'docker-unavailable-or-recovery-failed'] ),!.

mw_cleanup_orphans_checked(Root0,
    ['workshop-orphan-recovery-v1',Standing,
      ['removed-containers',ContainerCount],['removed-volumes',VolumeCount]]) :-
    miter_store_nonempty_atom(Root0,Root),is_absolute_file_name(Root),
    exists_directory(Root),directory_file_path(Root,workspace,Workspace),
    exists_directory(Workspace),mw_docker_executable(Docker),
    mw_labeled_docker_objects(Docker,Workspace,containers,Containers),
    mw_labeled_docker_objects(Docker,Workspace,volumes,Volumes),
    maplist(mw_remove_labeled_container(Docker,Workspace),Containers),
    maplist(mw_remove_labeled_volume(Docker,Workspace),Volumes),
    mw_labeled_docker_objects(Docker,Workspace,containers,RemainingContainers),
    mw_labeled_docker_objects(Docker,Workspace,volumes,RemainingVolumes),
    length(Containers,ContainerCount),length(Volumes,VolumeCount),
    ( RemainingContainers==[],RemainingVolumes==[] -> Standing=clean
    ; Standing=held ).

mw_labeled_docker_objects(Docker,Directory,containers,Objects) :-
    ce_process_observe(Docker,
      ['ps','-aq','--filter','label=io.singularitynet.miter.workshop=true'],
      Directory,10,65536,eof,0,Output,_Error,none),
    mw_docker_object_lines(Output,Objects).
mw_labeled_docker_objects(Docker,Directory,volumes,Objects) :-
    ce_process_observe(Docker,
      ['volume','ls','-q','--filter',
        'label=io.singularitynet.miter.workshop=true'],
      Directory,10,65536,eof,0,Output,_Error,none),
    mw_docker_object_lines(Output,Objects).

mw_docker_object_lines(Output,Objects) :-
    normalize_space(string(Normalized),Output),
    ( Normalized=="" -> Objects=[]
    ; split_string(Normalized,"\n"," \t\r\n",Values),
      maplist(mw_docker_object_atom,Values,Objects) ).

mw_docker_object_atom(Value,Object) :-
    atom_string(Object,Value),atom_length(Object,Length),Length>=1,Length=<128,
    re_match('^[A-Za-z0-9][A-Za-z0-9_.:-]*$',Object).

mw_remove_labeled_container(Docker,Directory,Container) :-
    ce_process_observe(Docker,['rm','--force',Container],Directory,10,4096,
      eof,0,_Output,_Error,none).
mw_remove_labeled_volume(Docker,Directory,Volume) :-
    ce_process_observe(Docker,['volume','rm','--force',Volume],Directory,10,4096,
      eof,0,_Output,_Error,none).

mw_candidate_verified(Root,CandidateRelative,Commit,Manifest,Candidate) :-
    directory_file_path(Root,CandidateRelative,Candidate),
    mw_candidate_verified_path(Candidate,Commit,Manifest).

mw_candidate_verified_path(Candidate,Commit,Manifest) :-
    exists_directory(Candidate),\+ read_link(Candidate,_,_),
    mw_git_output(_,Candidate,['rev-parse','HEAD'],Observed0),
    normalize_space(atom(Observed),Observed0),Observed==Commit,
    mw_git_output(_,Candidate,['status','--porcelain'],Status0),
    normalize_space(string(Status),Status0),Status=="",
    nth0(5,Manifest,['source-files',Files]),
    forall(member(['extension-file',_,Relative,Hash],Files),
      (directory_file_path(Candidate,Relative,Path),exists_file(Path),
       \+ read_link(Path,_,_),
       crypto_file_hash(Path,Hash,[algorithm(sha256),encoding(octet)]))),
    mw_git_output(_,Candidate,['ls-files'],Tracked0),
    split_string(Tracked0,"\n","\n",TrackedStrings),
    maplist(atom_string,TrackedAtoms,TrackedStrings),sort(TrackedAtoms,Tracked),
    findall(Relative,member(['extension-file',_,Relative,_],Files),Expected0),
    sort(['.gitignore'|Expected0],Expected),Tracked==Expected.

mw_within_open_growth_authority(Manifest) :-
    nth0(9,Manifest,['authority-contract',['permissions',[]],
      ['network-surfaces',[]],['credential-capabilities',[]],
      ['effect-classes',['local-observation-only']]]),
    nth0(16,Manifest,['human-approval','not-required-within-open-growth-class']).

mw_compatible('no-active-version',Manifest,'new-extension-no-migration') :-
    nth0(8,Manifest,
      ['state-contract','stateless-v1','stateless-compatible']).
mw_compatible(Current,Manifest,'exact-interface-stateless-compatible') :-
    Current=['active-executable-extension-v1',_,_,_,PriorManifest|_],
    nth0(7,PriorManifest,Interface),nth0(7,Manifest,Interface),
    nth0(8,PriorManifest,['state-contract','stateless-v1',_]),
    nth0(8,Manifest,
      ['state-contract','stateless-v1','stateless-compatible']).
mw_compatible(Current,Manifest,'exact-interface-state-compatible') :-
    Current=['active-executable-extension-v1',_,_,_,PriorManifest|_],
    nth0(7,PriorManifest,Interface),nth0(7,Manifest,Interface),
    nth0(8,PriorManifest,['state-contract',Schema,_]),
    Schema\=='stateless-v1',
    nth0(8,Manifest,['state-contract',Schema,'state-compatible']).

mw_expected_matches('no-active-version','no-active-version').
mw_expected_matches(Current,['active-version',Version,Commit]) :-
    Current=['active-executable-extension-v1',_,Version,Commit|_].

mw_active_or_none(Path,Current) :-
    ( exists_file(Path) -> mw_read_term(Path,Current) ; Current='no-active-version' ).

mw_stage_record(Root,Id,Version,RequestId,Record) :-
    mw_stage_index(Root,Id,Version,Path),mw_read_term(Path,Record),
    Record=['extension-stage-record-v1',RequestId|_].
mw_trial_record(Root,Id,Version,RequestId,Record) :-
    mw_trial_index(Root,Id,Version,RequestId,Path),mw_read_term(Path,Record),
    Record=['extension-trial-record-v1',RequestId|_].

mw_ensure_repository(Root,Repository) :-
    directory_file_path(Root,'workshop/repository',Repository),
    directory_file_path(Repository,'.git',Git),
    ( exists_directory(Git) -> true
    ; make_directory_path(Repository),chmod(Repository,0o700),
      mw_git(Root,Repository,['init','-b','main','.']),
      directory_file_path(Repository,'.gitignore',Ignore),
      mw_write_text(Ignore,".miter-tmp\n"),
      mw_git(Root,Repository,['add','--','.gitignore']),
      mw_git(Root,Repository,
        ['-c','user.name=Miter executable workshop',
         '-c','user.email=miter-workshop@example.invalid','commit','-m',
         'Initialize Miter executable extension workshop']) ).

mw_git(Root,Directory,Arguments) :-
    ce_process_observe('/usr/bin/git',Arguments,Directory,30,131072,
      eof,0,_Out,_Err,none),
    nonvar(Root).

mw_git_output(_Root,Directory,Arguments,Output) :-
    ce_process_observe('/usr/bin/git',Arguments,Directory,30,131072,
      eof,0,Output,_Stderr,none).

mw_workspace_source(Root,Relative,Path) :-
    directory_file_path(Root,workspace,Workspace),
    mw_existing_safe_parts(Workspace,Relative,Path),exists_file(Path),
    \+ exists_directory(Path),\+ read_link(Path,_,_).

mw_existing_safe_parts(Base,Relative,Path) :-
    mw_relative(Relative,Relative),atomic_list_concat(Parts,'/',Relative),
    mw_existing_parts(Base,Parts,Path).
mw_existing_parts(Current,[],Current).
mw_existing_parts(Current,[Part|Rest],Path) :-
    directory_file_path(Current,Part,Next),(exists_file(Next);exists_directory(Next)),
    \+ read_link(Next,_,_),mw_existing_parts(Next,Rest,Path).

mw_candidate_relative(Id,Version,Relative) :-
    atomic_list_concat(['workshop/candidates',Id,Version],'/',Relative).
mw_stage_index(Root,Id,Version,Path) :-
    atomic_list_concat(['workshop/staged',Id,Version],'/',Base),
    atom_concat(Base,'.term',Relative),directory_file_path(Root,Relative,Path).
mw_trial_index(Root,Id,Version,RequestId,Path) :-
    atomic_list_concat(['workshop/trials',Id,Version,RequestId],'/',Base),
    atom_concat(Base,'.term',Relative),directory_file_path(Root,Relative,Path).
mw_active_index(Root,Id,Path) :-
    atomic_list_concat(['workshop/active',Id],'/',Base),
    atom_concat(Base,'.term',Relative),directory_file_path(Root,Relative,Path).
mw_prepared_index(Root,RequestId,Path) :-
    atomic_list_concat(['workshop/prepared',RequestId], '/',Base),
    atom_concat(Base,'.term',Relative),directory_file_path(Root,Relative,Path).

mw_read_term(Path,Term) :-
    exists_file(Path),\+ read_link(Path,_,_),size_file(Path,Length),
    Length>0,Length=<33554432,read_file_to_string(Path,Text,[encoding(utf8)]),
    term_string(Term,Text,[quoted(true),ignore_ops(true)]),ground(Term).

mw_write_term(Path,Term) :-
    ground(Term),term_string(Term,Text,[quoted(true),ignore_ops(true)]),
    mw_write_text(Path,Text).

mw_write_once_term(Path,Term) :-
    ( exists_file(Path) -> mw_read_term(Path,Term)
    ; mw_write_term(Path,Term) ).

mw_write_text(Path,Text) :-
    file_directory_name(Path,Directory),make_directory_path(Directory),
    chmod(Directory,0o700),current_prolog_flag(pid,Pid),
    format(atom(Suffix),'.tmp.~d',[Pid]),atom_concat(Path,Suffix,Temporary),
    setup_call_cleanup(true,
      ( setup_call_cleanup(open(Temporary,write,Stream,[encoding(utf8)]),
          (chmod(Temporary,0o600),format(Stream,'~s',[Text]),flush_output(Stream),
           miter_store_fsync_stream(Stream)),close(Stream)),
        rename_file(Temporary,Path),chmod(Path,0o600) ),
      (exists_file(Temporary)->delete_file(Temporary);true)).

mw_id(Value,Atom) :-
    miter_store_nonempty_atom(Value,Atom),atom_length(Atom,Length),Length=<128,
    re_match('^[A-Za-z0-9][A-Za-z0-9_.-]*$',Atom).
mw_id_value(Value,Atom) :- mw_id(Value,Atom).
mw_sha256(Value,Hash) :-
    miter_store_nonempty_atom(Value,Hash),atom_length(Hash,64),
    atom_codes(Hash,Codes),maplist(miter_store_hex_code,Codes).
mw_git_oid(Value,Oid) :-
    miter_store_nonempty_atom(Value,Oid),atom_length(Oid,Length),
    memberchk(Length,[40,64]),atom_codes(Oid,Codes),
    maplist(miter_store_hex_code,Codes).
mw_argument(Value,String) :-
    (string(Value)->String=Value;atom(Value),atom_string(Value,String)),
    string_length(String,Length),Length=<8192,
    \+ sub_string(String,_,_,_,"\u0000").
mw_bounded_text(Value,Minimum,Maximum) :-
    (string(Value)->String=Value;atom(Value),atom_string(Value,String)),
    string_length(String,Length),Length>=Minimum,Length=<Maximum,
    \+ sub_string(String,_,_,_,"\u0000").
mw_relative(Value,Relative) :-
    (atom(Value)->Relative=Value;string(Value),atom_string(Relative,Value)),
    \+ is_absolute_file_name(Relative),atom_length(Relative,Length),
    Length>=1,Length=<4096,atomic_list_concat(Parts,'/',Relative),Parts=[_|_],
    forall(member(Part,Parts),(Part\=='',Part\=='.',Part\=='..',Part\=='.git',
      re_match('^[A-Za-z0-9_. -]+$',Part))).
mw_container_image(Value,Image) :-
    (atom(Value)->Image=Value;string(Value),atom_string(Image,Value)),
    atom_length(Image,Length),Length>=72,Length=<512,
    re_match('^[A-Za-z0-9][A-Za-z0-9._/-]*(:[A-Za-z0-9._-]+)?@sha256:[a-f0-9]{64}$',
      Image).
mw_container_program(Value,Program) :-
    (atom(Value)->Program=Value;string(Value),atom_string(Program,Value)),
    atom_length(Program,Length),Length>=2,Length=<512,
    sub_atom(Program,0,1,_,'/'),
    re_match('^/[A-Za-z0-9][A-Za-z0-9._/-]*$',Program).
