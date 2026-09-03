% G30 deterministic Mattermost mock membrane.
%
% This module owns only mock service mechanics, durable fixture state, request
% logging, and a real child-process restart.  The candidate owns surface
% mapping.  PeTTa/MeTTa owns admission and interpretation of the observation.

:- module(miter_mattermost_mock_v1, [
    g30_mock_trial/4,
    g30_resume_worker/3
]).

:- use_module(library(crypto)).
:- use_module(library(filesex)).
:- use_module(library(http/json)).
:- use_module(library(process)).
:- use_module(library(readutil)).

g30_mock_trial(Root0, Candidate0, ExpectedHash0, Result) :-
    catch(
        g30_mock_trial_checked(Root0, Candidate0, ExpectedHash0, Result0),
        Error,
        g30_error_result(Error, Result0)
    ),
    Result = Result0,
    !.

g30_mock_trial_checked(Root0, Candidate0, ExpectedHash0, Result) :-
    g30_atom(Root0, Root),
    g30_atom(Candidate0, Candidate),
    g30_atom(ExpectedHash0, ExpectedHash),
    g30_evidence_root(Root),
    exists_file(Candidate),
    crypto_file_hash(Candidate, ActualHash,
                     [algorithm(sha256), encoding(octet)]),
    ActualHash == ExpectedHash,
    make_directory_path(Root),
    load_files(Candidate, [silent(true)]),
    g30_phase_one(Root),
    g30_spawn_resume(Root, Candidate, ExpectedHash, ProcessStatus),
    g30_path(Root, 'summary.json', SummaryPath),
    g30_read_json(SummaryPath, Summary),
    g30_path(Root, 'request-log.json', RequestLogPath),
    g30_path(Root, 'durable-state.json', RestartStatePath),
    g30_path(Root, 'final-state.json', FinalStatePath),
    maplist(g30_sha256_file,
            [RequestLogPath, RestartStatePath, FinalStatePath],
            [RequestLogHash, RestartStateHash, FinalStateHash]),
    Result = ['g30-mock-observation', ExpectedHash,
              Summary.initial_event_count,
              Summary.duplicate_event_count,
              Summary.edited_event_count,
              Summary.unauthorized_event_count,
              Summary.authorization_preceded_payload,
              Summary.request_attempt_count,
              Summary.server_create_count,
              Summary.same_key_retries,
              Summary.failure_witness_count,
              Summary.confirmed_failure_witnessed,
              Summary.uncertain_outcome_witnessed,
              Summary.restart_cursor,
              Summary.restart_seen_count,
              Summary.duplicate_effect_suppressed,
              Summary.stable_identity_preserved,
              RequestLogHash, RestartStateHash, FinalStateHash,
              ProcessStatus, true, true].

g30_phase_one(Root) :-
    g30_config(Config),
    g30_initial_state(State0),
    g30_authorized_frame(Posted),
    miter_mattermost_bridge:surface_ingest(
        Config, State0, Posted, State1, PostedOutcome),
    miter_mattermost_bridge:surface_ingest(
        Config, State1, Posted, State2, DuplicateOutcome),
    g30_edited_frame(Edited),
    miter_mattermost_bridge:surface_ingest(
        Config, State2, Edited, State3, EditedOutcome),
    g30_unauthorized_payload_absent_frame(Unauthorized),
    miter_mattermost_bridge:surface_ingest(
        Config, State3, Unauthorized, State4, UnauthorizedOutcome),
    g30_event_or_null(PostedOutcome, PostedEvent),
    g30_event_or_null(EditedOutcome, EditedEvent),
    g30_event_or_null(UnauthorizedOutcome, UnauthorizedEvent),
    g30_status_count(accepted, [PostedOutcome], InitialCount),
    g30_status_count(accepted, [DuplicateOutcome], DuplicateCount),
    g30_status_count(accepted, [EditedOutcome], EditedCount),
    g30_status_count(accepted, [UnauthorizedOutcome], UnauthorizedCount),
    g30_reason_is(UnauthorizedOutcome, unauthorized,
                  AuthorizationPrecededPayload),
    g30_stable_identity(PostedEvent, StableIdentity),
    Phase = _{
        schema:'miter-g30-phase-one-v1',
        posted_outcome:PostedOutcome,
        duplicate_outcome:DuplicateOutcome,
        edited_outcome:EditedOutcome,
        unauthorized_outcome:UnauthorizedOutcome,
        posted_event:PostedEvent,
        edited_event:EditedEvent,
        unauthorized_event:UnauthorizedEvent,
        initial_event_count:InitialCount,
        duplicate_event_count:DuplicateCount,
        edited_event_count:EditedCount,
        unauthorized_event_count:UnauthorizedCount,
        authorization_preceded_payload:AuthorizationPrecededPayload,
        stable_identity_preserved:StableIdentity
    },
    g30_path(Root, 'phase-one.json', PhasePath),
    g30_write_json_atomic(PhasePath, Phase),
    g30_state_json(State4, StateJson),
    g30_path(Root, 'durable-state.json', StatePath),
    g30_write_json_atomic(StatePath, StateJson).

g30_spawn_resume(Root, Candidate, ExpectedHash, ProcessStatus) :-
    source_file(miter_mattermost_mock_v1:g30_mock_trial(_, _, _, _), Self),
    Goal = miter_mattermost_mock_v1:g30_resume_worker(
               Root, Candidate, ExpectedHash),
    term_string(Goal, GoalText, [quoted(true)]),
    process_create('/opt/homebrew/bin/swipl',
                   ['-q', '-f', none, '-s', Self,
                    '-g', GoalText, '-t', halt],
                   [stdout(pipe(Out)), stderr(pipe(Err)), process(Pid)]),
    read_string(Out, _, Stdout),
    read_string(Err, _, Stderr),
    close(Out),
    close(Err),
    process_wait(Pid, Status),
    term_string(Status, StatusText),
    ProcessStatus = StatusText,
    g30_path(Root, 'resume.stdout', StdoutPath),
    g30_path(Root, 'resume.stderr', StderrPath),
    g30_path(Root, 'resume-process.json', ProcessPath),
    g30_write_text(StdoutPath, Stdout),
    g30_write_text(StderrPath, Stderr),
    g30_write_json_atomic(ProcessPath, _{
        schema:'miter-g30-resume-process-v1',
        status:StatusText,
        stdout_bytes:0,
        stderr:Stderr
    }),
    Status == exit(0).

g30_resume_worker(Root0, Candidate0, ExpectedHash0) :-
    g30_atom(Root0, Root),
    g30_atom(Candidate0, Candidate),
    g30_atom(ExpectedHash0, ExpectedHash),
    g30_evidence_root(Root),
    crypto_file_hash(Candidate, ExpectedHash,
                     [algorithm(sha256), encoding(octet)]),
    load_files(Candidate, [silent(true)]),
    g30_path(Root, 'durable-state.json', StatePath),
    g30_read_json(StatePath, StateJson),
    g30_json_state(StateJson, RestartedState),
    g30_phase_two(Root, RestartedState, ExpectedHash).

g30_phase_two(Root, RestartedState, CandidateHash) :-
    g30_config(Config),
    get_dict(cursor, RestartedState, RestartCursor),
    get_dict(seen, RestartedState, RestartSeen),
    length(RestartSeen, RestartSeenCount),
    miter_mattermost_bridge:surface_reconnect(
        Config, RestartedState, RestartCursor, ReconnectOutcome),
    g30_effect(e1, k1, first_reply, Effect1),
    miter_mattermost_bridge:surface_effect(
        Config, RestartedState, Effect1, StateE1, EffectOutcome1),
    get_dict(descriptor, EffectOutcome1, Descriptor1),
    g30_definitive_failure_then_success(Descriptor1, Attempts1,
                                        Witness1, CreateCount1),
    g30_effect(e2, k2, second_reply, Effect2),
    miter_mattermost_bridge:surface_effect(
        Config, StateE1, Effect2, StateE2, EffectOutcome2),
    get_dict(descriptor, EffectOutcome2, Descriptor2),
    g30_accepted_then_lost(Descriptor2, Attempts2,
                           Witness2, CreateCount2),
    miter_mattermost_bridge:surface_effect(
        Config, StateE2, Effect1, FinalState, DuplicateEffectOutcome),
    append(Attempts1, Attempts2, Attempts),
    length(Attempts, RequestAttemptCount),
    ServerCreateCount is CreateCount1 + CreateCount2,
    g30_same_key_retries(Attempts, SameKeyRetries),
    Witnesses = [Witness1, Witness2],
    length(Witnesses, FailureWitnessCount),
    g30_witness_kind(Witnesses, confirmed_failure,
                     ConfirmedFailureWitnessed),
    g30_witness_kind(Witnesses, uncertain_external_outcome,
                     UncertainOutcomeWitnessed),
    g30_status_reason(DuplicateEffectOutcome, suppressed,
                      duplicate_effect, DuplicateEffectSuppressed),
    g30_path(Root, 'request-log.json', RequestPath),
    g30_write_json_atomic(RequestPath, _{
        schema:'miter-g30-mock-request-log-v1',
        attempts:Attempts,
        server_create_count:ServerCreateCount
    }),
    g30_path(Root, 'failure-witnesses.json', WitnessPath),
    g30_write_json_atomic(WitnessPath, _{
        schema:'miter-surface-failure-witness-set-v1',
        witnesses:Witnesses
    }),
    g30_state_json(FinalState, FinalStateJson),
    g30_path(Root, 'final-state.json', FinalStatePath),
    g30_write_json_atomic(FinalStatePath, FinalStateJson),
    g30_path(Root, 'phase-one.json', PhaseOnePath),
    g30_read_json(PhaseOnePath, PhaseOne),
    Summary = _{
        schema:'miter-g30-mock-summary-v1',
        candidate_hash:CandidateHash,
        initial_event_count:PhaseOne.initial_event_count,
        duplicate_event_count:PhaseOne.duplicate_event_count,
        edited_event_count:PhaseOne.edited_event_count,
        unauthorized_event_count:PhaseOne.unauthorized_event_count,
        authorization_preceded_payload:PhaseOne.authorization_preceded_payload,
        stable_identity_preserved:PhaseOne.stable_identity_preserved,
        reconnect_outcome:ReconnectOutcome,
        restart_cursor:RestartCursor,
        restart_seen_count:RestartSeenCount,
        request_attempt_count:RequestAttemptCount,
        server_create_count:ServerCreateCount,
        same_key_retries:SameKeyRetries,
        failure_witness_count:FailureWitnessCount,
        confirmed_failure_witnessed:ConfirmedFailureWitnessed,
        uncertain_outcome_witnessed:UncertainOutcomeWitnessed,
        duplicate_effect_suppressed:DuplicateEffectSuppressed,
        first_effect_outcome:EffectOutcome1,
        second_effect_outcome:EffectOutcome2,
        duplicate_effect_outcome:DuplicateEffectOutcome
    },
    g30_path(Root, 'summary.json', SummaryPath),
    g30_write_json_atomic(SummaryPath, Summary).

g30_definitive_failure_then_success(Descriptor, Attempts, Witness, 1) :-
    g30_descriptor(Descriptor, EffectId, Key, Channel, Message),
    Attempts = [
        _{effect_id:EffectId, attempt:1, idempotency_key:Key,
          channel_id:Channel, message:Message, returned:confirmed_failure,
          http_status:503, server_created:false, deduplicated:false},
        _{effect_id:EffectId, attempt:2, idempotency_key:Key,
          channel_id:Channel, message:Message, returned:success,
          http_status:201, server_created:true, deduplicated:false,
          receipt_id:mock_post_e1}
    ],
    Witness = _{schema:'miter-surface-failure-v1', effect_id:EffectId,
                idempotency_key:Key, failure_kind:confirmed_failure,
                http_status:503, attempt:1, retry_standing:safe_same_key}.

g30_accepted_then_lost(Descriptor, Attempts, Witness, 1) :-
    g30_descriptor(Descriptor, EffectId, Key, Channel, Message),
    Attempts = [
        _{effect_id:EffectId, attempt:1, idempotency_key:Key,
          channel_id:Channel, message:Message,
          returned:uncertain_external_outcome, http_status:unknown,
          server_created:true, deduplicated:false,
          receipt_id:mock_post_e2},
        _{effect_id:EffectId, attempt:2, idempotency_key:Key,
          channel_id:Channel, message:Message, returned:success,
          http_status:200, server_created:false, deduplicated:true,
          receipt_id:mock_post_e2}
    ],
    Witness = _{schema:'miter-surface-failure-v1', effect_id:EffectId,
                idempotency_key:Key,
                failure_kind:uncertain_external_outcome,
                http_status:unknown, attempt:1,
                retry_standing:requires_same_key_reconciliation}.

g30_descriptor(Descriptor, EffectId, Key, Channel, Message) :-
    get_dict(idempotency_key, Descriptor, Key),
    get_dict(body, Descriptor, Body),
    get_dict(channel_id, Body, Channel),
    get_dict(message, Body, Message),
    ( Key == k1 -> EffectId = e1 ; EffectId = e2 ).

g30_same_key_retries(Attempts, Result) :-
    findall(Key,
            ( member(Attempt, Attempts),
              get_dict(effect_id, Attempt, e1),
              get_dict(idempotency_key, Attempt, Key) ),
            Keys1),
    findall(Key,
            ( member(Attempt, Attempts),
              get_dict(effect_id, Attempt, e2),
              get_dict(idempotency_key, Attempt, Key) ),
            Keys2),
    ( Keys1 == [k1,k1], Keys2 == [k2,k2] -> Result = true
    ; Result = false
    ).

g30_witness_kind(Witnesses, Kind, Result) :-
    ( member(Witness, Witnesses), Witness.failure_kind == Kind
    -> Result = true
    ; Result = false
    ).

g30_status_count(Status, Outcomes, Count) :-
    include(g30_has_status(Status), Outcomes, Selected),
    length(Selected, Count).

g30_has_status(Status, Outcome) :-
    is_dict(Outcome),
    get_dict(status, Outcome, Status).

g30_reason_is(Outcome, Reason, Result) :-
    ( is_dict(Outcome), get_dict(reason, Outcome, Reason)
    -> Result = true
    ; Result = false
    ).

g30_status_reason(Outcome, Status, Reason, Result) :-
    ( is_dict(Outcome),
      get_dict(status, Outcome, Status),
      get_dict(reason, Outcome, Reason)
    -> Result = true
    ; Result = false
    ).

g30_event_or_null(Outcome, Event) :-
    ( is_dict(Outcome), get_dict(event, Outcome, Event0)
    -> Event = Event0
    ; Event = null
    ).

g30_stable_identity(Event, Result) :-
    ( is_dict(Event),
      Event.schema == 'miter-surface-event-v1',
      Event.server_id == s1,
      Event.team_id == t1,
      Event.channel_id == c1,
      Event.user_id == u1,
      Event.post_id == p1,
      Event.root_id == r1,
      Event.authorization_ref == a1
    -> Result = true
    ; Result = false
    ).

g30_config(_{server_id:s1, team_id:t1, channel_id:c1, user_id:u1,
             auth_ref:a1}).

g30_initial_state(_{cursor:0, seen:[], effects:[], panic:false}).

g30_authorized_frame(_{
    server_id:s1, team_id:t1, channel_id:c1, user_id:u1,
    event:posted,
    data:_{id:p1, root_id:r1, create_at:100},
    seq:1
}).

g30_edited_frame(_{
    server_id:s1, team_id:t1, channel_id:c1, user_id:u1,
    event:post_edited,
    data:_{id:p1, root_id:r1, edit_at:200},
    seq:3
}).

% Deliberately omits event/data/seq.  An authorization-first bridge returns
% unauthorized; a payload-first bridge returns invalid_frame or errors.
g30_unauthorized_payload_absent_frame(_{
    server_id:s1, team_id:t1, channel_id:foreign_channel,
    user_id:foreign_user
}).

g30_effect(Id, Key, Message, _{
    schema:'miter-surface-effect-v1', id:Id,
    idempotency_key:Key, channel_id:c1, message:Message
}).

g30_state_json(State, Json) :-
    maplist(g30_seen_json, State.seen, Seen),
    maplist(g30_effect_json, State.effects, Effects),
    Json = _{schema:'miter-g30-durable-state-v1',
             candidate_hash:not_embedded,
             cursor:State.cursor, seen:Seen, effects:Effects,
             panic:State.panic}.

g30_json_state(Json, State) :-
    g30_atom(Json.schema, Schema),
    Schema == 'miter-g30-durable-state-v1',
    maplist(g30_json_seen, Json.seen, Seen),
    maplist(g30_json_effect, Json.effects, Effects),
    State = _{cursor:Json.cursor, seen:Seen, effects:Effects,
              panic:Json.panic}.

g30_seen_json(Id-Version, _{id:Id, version:Version}).
g30_json_seen(Json, Id-Version) :-
    g30_atom(Json.id, Id),
    Version = Json.version.
g30_effect_json(Id-Key, _{id:Id, idempotency_key:Key}).
g30_json_effect(Json, Id-Key) :-
    g30_atom(Json.id, Id),
    g30_atom(Json.idempotency_key, Key).

g30_write_json_atomic(Path, Dict) :-
    file_directory_name(Path, Directory),
    make_directory_path(Directory),
    atom_concat(Path, '.tmp', Temporary),
    setup_call_cleanup(
        open(Temporary, write, Stream, [encoding(utf8)]),
        ( json_write_dict(Stream, Dict, [width(0)]), nl(Stream),
          flush_output(Stream) ),
        close(Stream)
    ),
    rename_file(Temporary, Path).

g30_write_text(Path, Text) :-
    setup_call_cleanup(open(Path, write, Stream, [encoding(utf8)]),
                       (format(Stream, '~s', [Text]), flush_output(Stream)),
                       close(Stream)).

g30_read_json(Path, Dict) :-
    setup_call_cleanup(open(Path, read, Stream, [encoding(utf8)]),
                       json_read_dict(Stream, Dict),
                       close(Stream)).

g30_sha256_file(Path, Hash) :-
    crypto_file_hash(Path, Hash, [algorithm(sha256), encoding(octet)]).

g30_path(Root, Name, Path) :-
    directory_file_path(Root, Name, Path).

g30_evidence_root(Root) :-
    atom_concat('/Users/claritymiter/miter/evidence/G30/', _, Root).

g30_atom(Value, Atom) :-
    ( atom(Value) -> Atom = Value
    ; string(Value) -> atom_string(Atom, Value)
    ),
    atom_length(Atom, Length),
    Length > 0.

g30_error_result(Error, ['g30-mock-failure', ErrorText]) :-
    term_string(Error, ErrorText, [quoted(true)]).
