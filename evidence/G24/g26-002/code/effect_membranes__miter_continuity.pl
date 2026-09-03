% Structured project continuity mechanics for Miter.
% Capsules are immutable facts.  The current pointer is a replaceable
% projection selected explicitly by MeTTa, never inferred from timestamps.

:- ensure_loaded('miter_store.pl').
:- use_module(library(http/json)).
:- use_module(library(filesex)).
:- use_module(library(crypto)).
:- use_module(library(lists)).
:- use_module(library(pairs)).

% Four scalar inputs followed by one scalar result.
miter_continuity_write_capsule(StoreRoot0, ExtensionPath0, FixturePath0,
                               Result) :-
    (   miter_store_nonempty_atom(StoreRoot0, StoreRoot),
        miter_store_nonempty_atom(ExtensionPath0, ExtensionPath),
        miter_store_nonempty_atom(FixturePath0, FixturePath)
    ->  (   catch(
                miter_continuity_write_capsule_checked(
                    StoreRoot, ExtensionPath, FixturePath, Result0
                ),
                Error,
                miter_continuity_exception_result(Error, Result0)
            )
        ->  true
        ;   Result0 = 'continuity-mechanics-failed'
        ),
        Result = Result0
    ;   Result = 'invalid-capsule-write-argument'
    ),
    !.

% Four scalar inputs followed by one scalar result.
miter_continuity_set_current(StoreRoot0, ExtensionPath0, ProjectId0,
                             CapsuleId0, Result) :-
    (   miter_store_nonempty_atom(StoreRoot0, StoreRoot),
        miter_store_nonempty_atom(ExtensionPath0, ExtensionPath),
        miter_continuity_safe_id(ProjectId0, ProjectId),
        miter_continuity_safe_id(CapsuleId0, CapsuleId)
    ->  (   catch(
                miter_continuity_set_current_checked(
                    StoreRoot, ExtensionPath, ProjectId, CapsuleId, Result0
                ),
                Error,
                miter_continuity_exception_result(Error, Result0)
            )
        ->  true
        ;   Result0 = 'continuity-mechanics-failed'
        ),
        Result = Result0
    ;   Result = 'invalid-current-index-argument'
    ),
    !.

% Three scalar inputs followed by one scalar result.
miter_continuity_reconstruct(StoreRoot0, ProjectId0, OutputPath0, Result) :-
    (   miter_store_nonempty_atom(StoreRoot0, StoreRoot),
        miter_continuity_safe_id(ProjectId0, ProjectId),
        miter_store_nonempty_atom(OutputPath0, OutputPath)
    ->  (   catch(
                miter_continuity_reconstruct_checked(
                    StoreRoot, ProjectId, OutputPath, Result0
                ),
                Error,
                miter_continuity_exception_result(Error, Result0)
            )
        ->  true
        ;   Result0 = 'continuity-mechanics-failed'
        ),
        Result = Result0
    ;   Result = 'invalid-continuity-reconstruction-argument'
    ),
    !.

% Four scalar inputs followed by one scalar result.
miter_continuity_get_capsule(StoreRoot0, ProjectId0, CapsuleId0,
                             OutputPath0, Result) :-
    (   miter_store_nonempty_atom(StoreRoot0, StoreRoot),
        miter_continuity_safe_id(ProjectId0, ProjectId),
        miter_continuity_safe_id(CapsuleId0, CapsuleId),
        miter_store_nonempty_atom(OutputPath0, OutputPath)
    ->  (   catch(
                miter_continuity_get_capsule_checked(
                    StoreRoot, ProjectId, CapsuleId, OutputPath, Result0
                ),
                Error,
                miter_continuity_exception_result(Error, Result0)
            )
        ->  true
        ;   Result0 = 'continuity-mechanics-failed'
        ),
        Result = Result0
    ;   Result = 'invalid-capsule-read-argument'
    ),
    !.

miter_continuity_write_capsule_checked(_, _, FixturePath,
                                       'capsule-fixture-unavailable') :-
    \+ exists_file(FixturePath),
    !.
miter_continuity_write_capsule_checked(StoreRoot, ExtensionPath, FixturePath,
                                       Result) :-
    miter_store_ensure_extension(ExtensionPath),
    miter_store_read_json(FixturePath, Fixture),
    miter_continuity_fixture(Fixture, ProjectId, CapsuleId),
    miter_continuity_validate_artifact(Fixture),
    miter_continuity_with_project_lock(
        StoreRoot, ProjectId,
        miter_continuity_write_capsule_locked(
            StoreRoot, ProjectId, CapsuleId, Fixture, Result
        )
    ).

miter_continuity_write_capsule_locked(StoreRoot, ProjectId, CapsuleId,
                                      Fixture, Result) :-
    miter_continuity_capsule_path(
        StoreRoot, ProjectId, CapsuleId, CapsulePath
    ),
    (   exists_file(CapsulePath)
    ->  Result = 'capsule-already-exists'
    ;   del_dict(schema, Fixture, _, Fields),
        CapsuleBase = _{schema_version:'miter-project-continuity-v1'},
        put_dict(Fields, CapsuleBase, CapsuleWithoutHash),
        miter_store_canonical_json(CapsuleWithoutHash, CapsuleText),
        crypto_data_hash(CapsuleText, ContentHash,
                         [algorithm(sha256), encoding(utf8)]),
        put_dict(content_hash, CapsuleWithoutHash, ContentHash, Capsule),
        miter_continuity_write_json_durable(
            CapsulePath, Capsule, create_only
        ),
        Result = 'capsule-appended'
    ).

miter_continuity_set_current_checked(StoreRoot, ExtensionPath, ProjectId,
                                     CapsuleId, Result) :-
    miter_store_ensure_extension(ExtensionPath),
    miter_continuity_with_project_lock(
        StoreRoot, ProjectId,
        miter_continuity_set_current_locked(
            StoreRoot, ProjectId, CapsuleId, Result
        )
    ).

miter_continuity_set_current_locked(StoreRoot, ProjectId, CapsuleId, Result) :-
    (   miter_continuity_load_capsule(
            StoreRoot, ProjectId, CapsuleId, Capsule
        )
    ->  get_dict(status, Capsule, Status0),
        miter_store_nonempty_atom(Status0, Status),
        get_dict(previous_capsule_id, Capsule, PreviousId0),
        miter_continuity_safe_id(PreviousId0, PreviousId),
        get_dict(supersedes_capsule_id, Capsule, SupersedesId0),
        miter_continuity_safe_id(SupersedesId0, SupersedesId),
        (   Status == current,
            PreviousId == SupersedesId,
            miter_continuity_load_capsule(
                StoreRoot, ProjectId, PreviousId, PriorCapsule
            ),
            get_dict(capsule_id, PriorCapsule, PreviousId0)
        ->  get_dict(content_hash, Capsule, CapsuleHash0),
            miter_store_nonempty_atom(CapsuleHash0, CapsuleHash),
            get_dict(created_at, Capsule, CreatedAt),
            Index = _{
                schema:'miter-continuity-current-index-v1',
                project_id:ProjectId,
                capsule_id:CapsuleId,
                capsule_content_hash:CapsuleHash,
                selected_by:'explicit-metta-decision',
                selected_at:CreatedAt,
                timestamp_fallback:false
            },
            miter_continuity_current_path(StoreRoot, ProjectId, CurrentPath),
            miter_continuity_write_json_durable(
                CurrentPath, Index, replace_projection
            ),
            Result = 'current-capsule-selected'
        ;   Result = 'capsule-supersession-invalid'
        )
    ;   Result = 'capsule-unavailable'
    ).

miter_continuity_reconstruct_checked(_, _, OutputPath,
                                     'continuity-output-exists') :-
    exists_file(OutputPath),
    !.
miter_continuity_reconstruct_checked(StoreRoot, ProjectId, OutputPath,
                                     Result) :-
    miter_continuity_with_project_lock(
        StoreRoot, ProjectId,
        miter_continuity_reconstruct_locked(
            StoreRoot, ProjectId, OutputPath, Result
        )
    ).

miter_continuity_reconstruct_locked(StoreRoot, ProjectId, OutputPath,
                                    Result) :-
    miter_continuity_load_capsules(StoreRoot, ProjectId, Capsules),
    miter_continuity_current_path(StoreRoot, ProjectId, CurrentPath),
    (   exists_file(CurrentPath)
    ->  miter_continuity_reconstruct_current(
            ProjectId, CurrentPath, Capsules, ReconstructionResult,
            Reconstruction
        ),
        miter_store_write_json_atomic(OutputPath, Reconstruction),
        Result = ReconstructionResult
    ;   miter_continuity_ambiguity(ProjectId, Capsules, Ambiguity),
        miter_store_write_json_atomic(OutputPath, Ambiguity),
        Result = 'continuity-ambiguous'
    ).

miter_continuity_reconstruct_current(ProjectId, CurrentPath, Capsules,
                                     Result, Reconstruction) :-
    (   miter_store_read_json(CurrentPath, Index),
        miter_continuity_index(Index, ProjectId, CapsuleId, CapsuleHash),
        miter_continuity_member_capsule(Capsules, CapsuleId, Capsule),
        get_dict(content_hash, Capsule, CapsuleHash0),
        miter_store_nonempty_atom(CapsuleHash0, CapsuleHash),
        get_dict(status, Capsule, Status0),
        miter_store_nonempty_atom(Status0, current),
        miter_continuity_validate_artifact(Capsule),
        get_dict(previous_capsule_id, Capsule, PriorId0),
        miter_continuity_safe_id(PriorId0, PriorId),
        get_dict(supersedes_capsule_id, Capsule, SupersedesId0),
        miter_continuity_safe_id(SupersedesId0, PriorId),
        miter_continuity_member_capsule(Capsules, PriorId, PriorCapsule)
    ->  miter_continuity_capsule_ids(Capsules, CandidateIds),
        get_dict(content_hash, PriorCapsule, PriorHash),
        get_dict(status, PriorCapsule, PriorStoredStatus),
        get_dict(open_questions, Capsule, [UnresolvedQuestion|_]),
        Reconstruction = _{
            schema:'miter-continuity-reconstruction-v1',
            status:reconstructed,
            project_id:ProjectId,
            current_capsule_id:CapsuleId,
            current_capsule_hash:CapsuleHash,
            current_artifact_ref:Capsule.current_artifact_ref,
            current_artifact_hash:Capsule.current_artifact_hash,
            exact_location:Capsule.exact_location,
            current_goal:Capsule.current_goal,
            last_completed_work:Capsule.last_completed_work,
            open_questions:Capsule.open_questions,
            unresolved_question:UnresolvedQuestion,
            live_tensions:Capsule.live_tensions,
            next_intended_movement:Capsule.next_intended_movement,
            blocked_by:Capsule.blocked_by,
            commitments:Capsule.commitments,
            relevant_event_ids:Capsule.relevant_event_ids,
            prior_capsule_id:PriorId,
            prior_capsule_hash:PriorHash,
            prior_capsule_stored_status:PriorStoredStatus,
            prior_effective_standing:superseded,
            prior_capsule_accessible:true,
            supersession_source_capsule_id:CapsuleId,
            candidate_capsule_ids:CandidateIds,
            selection_policy:'explicit-current-index',
            timestamp_fallback:false
        },
        Result = 'continuity-reconstructed'
    ;   Reconstruction = _{
            schema:'miter-continuity-reconstruction-v1',
            status:invalid,
            project_id:ProjectId,
            reason:'current-index-or-capsule-invalid',
            selected_capsule_id:null,
            timestamp_fallback:false
        },
        Result = 'continuity-invalid'
    ).

miter_continuity_get_capsule_checked(_, _, _, OutputPath,
                                     'capsule-output-exists') :-
    exists_file(OutputPath),
    !.
miter_continuity_get_capsule_checked(StoreRoot, ProjectId, CapsuleId,
                                     OutputPath, Result) :-
    miter_continuity_with_project_lock(
        StoreRoot, ProjectId,
        miter_continuity_get_capsule_locked(
            StoreRoot, ProjectId, CapsuleId, OutputPath, Result
        )
    ).

miter_continuity_get_capsule_locked(StoreRoot, ProjectId, CapsuleId,
                                    OutputPath, Result) :-
    (   miter_continuity_load_capsule(
            StoreRoot, ProjectId, CapsuleId, Capsule
        )
    ->  miter_store_write_json_atomic(OutputPath, Capsule),
        Result = 'capsule-retrieved'
    ;   Result = 'capsule-unavailable'
    ).

miter_continuity_fixture(Fixture, ProjectId, CapsuleId) :-
    is_dict(Fixture),
    get_dict(schema, Fixture, Schema0),
    miter_store_nonempty_atom(Schema0, Schema),
    Schema == 'miter-project-continuity-fixture-v1',
    get_dict(project_id, Fixture, ProjectId0),
    miter_continuity_safe_id(ProjectId0, ProjectId),
    get_dict(capsule_id, Fixture, CapsuleId0),
    miter_continuity_safe_id(CapsuleId0, CapsuleId),
    maplist(miter_store_required_nonempty(Fixture),
            [project_name, project_purpose, current_goal,
             current_artifact_ref, current_artifact_hash, exact_location,
             last_completed_work, next_intended_movement, created_at,
             principal_scope, audience_scope, status]),
    get_dict(open_questions, Fixture, OpenQuestions),
    is_list(OpenQuestions),
    OpenQuestions \== [],
    maplist(miter_store_nonempty_atom, OpenQuestions, _),
    maplist(miter_continuity_list_field(Fixture),
            [live_tensions, blocked_by, commitments,
             relevant_memory_ids, relevant_event_ids]),
    get_dict(previous_capsule_id, Fixture, PreviousId0),
    miter_store_nonempty_atom(PreviousId0, _),
    get_dict(supersedes_capsule_id, Fixture, SupersedesId0),
    miter_store_nonempty_atom(SupersedesId0, _),
    !.
miter_continuity_fixture(_, _, _) :-
    throw(error(miter_invalid_continuity_fixture, _)).

miter_continuity_list_field(Dict, Key) :-
    get_dict(Key, Dict, Values),
    is_list(Values),
    maplist(miter_store_nonempty_atom, Values, _).

miter_continuity_validate_artifact(Capsule) :-
    get_dict(current_artifact_ref, Capsule, ArtifactPath0),
    miter_store_nonempty_atom(ArtifactPath0, ArtifactPath),
    exists_file(ArtifactPath),
    get_dict(current_artifact_hash, Capsule, ExpectedHash0),
    miter_store_sha256(ExpectedHash0, ExpectedHash),
    crypto_file_hash(ArtifactPath, ObservedHash,
                     [algorithm(sha256), encoding(octet)]),
    ObservedHash == ExpectedHash,
    !.
miter_continuity_validate_artifact(_) :-
    throw(error(miter_continuity_artifact_hash_mismatch, _)).

miter_continuity_load_capsules(StoreRoot, ProjectId, Capsules) :-
    miter_continuity_capsules_directory(StoreRoot, ProjectId, Directory),
    (   exists_directory(Directory)
    ->  directory_files(Directory, Entries),
        include(miter_continuity_json_file, Entries, JsonFiles),
        maplist(
            miter_continuity_load_capsule_file(Directory),
            JsonFiles, UnsortedCapsules
        ),
        maplist(miter_continuity_capsule_pair,
                UnsortedCapsules, CapsulePairs),
        keysort(CapsulePairs, SortedPairs),
        pairs_values(SortedPairs, Capsules)
    ;   Capsules = []
    ).

miter_continuity_load_capsule(StoreRoot, ProjectId, CapsuleId, Capsule) :-
    miter_continuity_capsule_path(
        StoreRoot, ProjectId, CapsuleId, CapsulePath
    ),
    exists_file(CapsulePath),
    miter_store_read_json(CapsulePath, Capsule),
    miter_continuity_capsule_valid(Capsule),
    get_dict(project_id, Capsule, ProjectId0),
    miter_continuity_safe_id(ProjectId0, ProjectId),
    get_dict(capsule_id, Capsule, CapsuleId0),
    miter_continuity_safe_id(CapsuleId0, CapsuleId).

miter_continuity_load_capsule_file(Directory, FileName, Capsule) :-
    directory_file_path(Directory, FileName, Path),
    miter_store_read_json(Path, Capsule),
    miter_continuity_capsule_valid(Capsule).

miter_continuity_capsule_valid(Capsule) :-
    is_dict(Capsule),
    get_dict(schema_version, Capsule, Schema0),
    miter_store_nonempty_atom(Schema0, Schema),
    Schema == 'miter-project-continuity-v1',
    get_dict(content_hash, Capsule, StoredHash0),
    miter_store_sha256(StoredHash0, StoredHash),
    del_dict(content_hash, Capsule, _, CapsuleWithoutHash),
    miter_store_canonical_json(CapsuleWithoutHash, CapsuleText),
    crypto_data_hash(CapsuleText, ComputedHash,
                     [algorithm(sha256), encoding(utf8)]),
    StoredHash == ComputedHash.

miter_continuity_index(Index, ProjectId, CapsuleId, CapsuleHash) :-
    is_dict(Index),
    get_dict(schema, Index, Schema0),
    miter_store_nonempty_atom(Schema0, Schema),
    Schema == 'miter-continuity-current-index-v1',
    get_dict(project_id, Index, ProjectId0),
    miter_continuity_safe_id(ProjectId0, ProjectId),
    get_dict(capsule_id, Index, CapsuleId0),
    miter_continuity_safe_id(CapsuleId0, CapsuleId),
    get_dict(capsule_content_hash, Index, CapsuleHash0),
    miter_store_sha256(CapsuleHash0, CapsuleHash),
    get_dict(selected_by, Index, SelectedBy0),
    miter_store_nonempty_atom(SelectedBy0, 'explicit-metta-decision'),
    get_dict(timestamp_fallback, Index, false).

miter_continuity_ambiguity(ProjectId, Capsules, Ambiguity) :-
    maplist(miter_continuity_candidate_projection, Capsules, Candidates),
    length(Candidates, CandidateCount),
    Ambiguity = _{
        schema:'miter-continuity-reconstruction-v1',
        status:ambiguous,
        project_id:ProjectId,
        reason:'current-index-missing',
        candidate_count:CandidateCount,
        candidates:Candidates,
        selected_capsule_id:null,
        selection_policy:'explicit-index-required',
        timestamp_fallback:false
    }.

miter_continuity_candidate_projection(Capsule, Candidate) :-
    Candidate = _{
        capsule_id:Capsule.capsule_id,
        content_hash:Capsule.content_hash,
        stored_status:Capsule.status
    }.

miter_continuity_member_capsule(Capsules, CapsuleId, Capsule) :-
    member(Capsule, Capsules),
    get_dict(capsule_id, Capsule, CandidateId0),
    miter_continuity_safe_id(CandidateId0, CandidateId),
    CandidateId == CapsuleId,
    !.

miter_continuity_capsule_ids(Capsules, Ids) :-
    maplist(miter_continuity_capsule_id, Capsules, Ids).

miter_continuity_capsule_id(Capsule, CapsuleId) :-
    get_dict(capsule_id, Capsule, CapsuleId0),
    miter_continuity_safe_id(CapsuleId0, CapsuleId).

miter_continuity_capsule_pair(Capsule, CapsuleId-Capsule) :-
    miter_continuity_capsule_id(Capsule, CapsuleId).

miter_continuity_json_file(FileName) :-
    atom(FileName),
    file_name_extension(_, json, FileName).

miter_continuity_write_json_durable(Path, Dict, Mode) :-
    file_directory_name(Path, Directory),
    make_directory_path(Directory),
    ( Mode == create_only, exists_file(Path)
    -> throw(error(miter_continuity_additive_write_violation, _))
    ; true
    ),
    atom_concat(Path, '.tmp', TemporaryPath),
    setup_call_cleanup(
        true,
        ( setup_call_cleanup(
              open(TemporaryPath, write, Stream,
                   [encoding(utf8), type(text)]),
              ( chmod(TemporaryPath, 0o600),
                json_write_dict(Stream, Dict, [width(100)]),
                nl(Stream),
                flush_output(Stream),
                miter_store_fsync_stream(Stream)
              ),
              close(Stream)
          ),
          rename_file(TemporaryPath, Path)
        ),
        ( exists_file(TemporaryPath) -> delete_file(TemporaryPath) ; true )
    ).

miter_continuity_with_project_lock(StoreRoot, ProjectId, Goal) :-
    miter_continuity_project_directory(StoreRoot, ProjectId, Directory),
    make_directory_path(Directory),
    directory_file_path(Directory, 'continuity.lock', LockPath),
    setup_call_cleanup(
        open(LockPath, append, LockStream,
             [encoding(utf8), lock(write), wait(true)]),
        call(Goal),
        close(LockStream)
    ).

miter_continuity_project_directory(StoreRoot, ProjectId, Directory) :-
    directory_file_path(StoreRoot, projects, ProjectsDirectory),
    directory_file_path(ProjectsDirectory, ProjectId, Directory).

miter_continuity_capsules_directory(StoreRoot, ProjectId, Directory) :-
    miter_continuity_project_directory(StoreRoot, ProjectId, ProjectDirectory),
    directory_file_path(ProjectDirectory, capsules, Directory).

miter_continuity_capsule_path(StoreRoot, ProjectId, CapsuleId, Path) :-
    miter_continuity_capsules_directory(StoreRoot, ProjectId, Directory),
    atom_concat(CapsuleId, '.json', FileName),
    directory_file_path(Directory, FileName, Path).

miter_continuity_current_path(StoreRoot, ProjectId, Path) :-
    miter_continuity_project_directory(StoreRoot, ProjectId, Directory),
    directory_file_path(Directory, 'current.json', Path).

miter_continuity_safe_id(Value, Id) :-
    miter_store_nonempty_atom(Value, Id),
    atom_codes(Id, Codes),
    Codes \== [],
    maplist(miter_continuity_id_code, Codes).

miter_continuity_id_code(Code) :-
    ( between(0'a, 0'z, Code)
    ; between(0'A, 0'Z, Code)
    ; between(0'0, 0'9, Code)
    ; memberchk(Code, [0'-, 0'_, 0'.])
    ).

miter_continuity_exception_result(error(miter_invalid_continuity_fixture, _),
                                   'invalid-continuity-fixture') :- !.
miter_continuity_exception_result(error(miter_continuity_artifact_hash_mismatch, _),
                                   'continuity-artifact-hash-mismatch') :- !.
miter_continuity_exception_result(error(miter_continuity_additive_write_violation, _),
                                   'capsule-additive-write-violation') :- !.
miter_continuity_exception_result(Error, Result) :-
    miter_store_exception_result(Error, Result).
