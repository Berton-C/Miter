% G31 P3 bounded OpenRouter grant and Mattermost 11.7.7-shaped mock mechanics.
% This file has no Mattermost transport or credentials. Source meaning and
% candidate standing remain in MeTTa.

:- ensure_loaded('miter_openrouter.pl').
:- use_module(library(crypto)).
:- multifile or_spend/3.
:- multifile or_source_grant/4.

or_source_grant('openrouter-g31-p3-revision-1', bridge, 8192, 300).
or_spend(Root, bridge, 'openrouter-g31-p3-revision-1') :-
    atom_concat('/Users/claritymiter/miter/evidence/G31/', _, Root),
    Claim = '/Users/claritymiter/miter/evidence/G31/P3-call-1.claim',
    \+ exists_directory(Claim),
    make_directory(Claim),
    directory_file_path(Claim, 'owner.json', Owner),
    sd_durable_json(Owner, _{
        root:Root,
        request:'openrouter-g31-p3-revision-1',
        kind:bridge,
        slot:1,
        grant:'G31-P3',
        model:'z-ai/glm-5.3'
    }).

% Explicitly defined here so PeTTa imports this qualified surface rather than
% relying on a predicate that is only present through a transitive load.
g31_p3_openrouter_source(Root, Question, Observation) :-
    or_source(Root, Question, Observation).

% Effect-free: checks predicate/grant/slot visibility without reading a key or
% contacting the provider.
g31_p3_renderer_ready(Result) :-
    ( current_predicate(or_source/3),
      or_source_grant('openrouter-g31-p3-revision-1', bridge, 8192, 300),
      \+ exists_directory('/Users/claritymiter/miter/evidence/G31/P3-call-1.claim')
    -> Result = true
    ; Result = false
    ),
    !.

g31_p3_mock_trial(Candidate0, ExpectedHash0, Result) :-
    catch(g31_p3_mock_trial_checked(Candidate0, ExpectedHash0, Result0),
          Error, g31_p3_mock_error(Error, Result0)),
    Result = Result0,
    !.

g31_p3_mock_trial_checked(Candidate0, ExpectedHash0, Result) :-
    g31_p3_atom(Candidate0, Candidate),
    g31_p3_atom(ExpectedHash0, ExpectedHash),
    atom_concat('/Users/claritymiter/miter/evidence/G31/', _, Candidate),
    exists_file(Candidate),
    crypto_file_hash(Candidate, ExpectedHash,
                     [algorithm(sha256), encoding(octet)]),
    load_files(Candidate, [silent(true)]),
    g31_p3_prior_contract(PriorContract),
    g31_p3_config(Config),
    g31_p3_initial_state(State0),
    g31_p3_effect(Effect),
    miter_mattermost_bridge:surface_effect(
        Config, State0, Effect, State1, EffectOutcome),
    get_dict(status, EffectOutcome, accepted),
    get_dict(descriptor, EffectOutcome, Descriptor),
    get_dict(idempotency_key, Descriptor, Key),
    get_dict(body, Descriptor, Body),
    get_dict(pending_post_id, Body, Key),
    PendingMapped = true,
    miter_mattermost_bridge:surface_effect(
        Config, State1, Effect, State1, DuplicateOutcome),
    g31_p3_status_reason(DuplicateOutcome, suppressed,
                         duplicate_effect, LocalDuplicate),
    miter_mattermost_bridge:surface_panic(State1, PanicState),
    miter_mattermost_bridge:surface_effect(
        Config, PanicState, Effect, PanicState, PanicOutcome),
    g31_p3_status_reason(PanicOutcome, rejected,
                         panic_active, PanicDenied),
    g31_p3_first_accepted_lost(Descriptor, bot_user, 100,
                               Cache, Receipt, FirstCreates),
    g31_p3_retry(Cache, bot_user, 110, Descriptor,
                 RetryOutcome, RetryCreates),
    FirstCreates = 1,
    RetryCreates = 0,
    RetryOutcome = existing(Receipt),
    WithinWindowCreates is FirstCreates + RetryCreates,
    SameReceipt = true,
    g31_p3_inflight_cache(Descriptor, bot_user, 100, Inflight),
    g31_p3_retry(Inflight, bot_user, 110, Descriptor,
                 pending, 0),
    InflightTyped = true,
    g31_p3_retry(Cache, bot_user, 131, Descriptor,
                 created(_), 1),
    ExpiryCanDuplicate = true,
    g31_p3_retry([], bot_user, 110, Descriptor,
                 created(_), 1),
    RestartCanDuplicate = true,
    Result = ['g31-p3-mock-observation', ExpectedHash,
              PendingMapped, PriorContract, WithinWindowCreates,
              SameReceipt, InflightTyped, ExpiryCanDuplicate,
              RestartCanDuplicate, LocalDuplicate, PanicDenied, true].

g31_p3_prior_contract(true) :-
    g31_p3_config(Config),
    g31_p3_initial_state(State0),
    g31_p3_posted(Posted),
    miter_mattermost_bridge:surface_ingest(
        Config, State0, Posted, State1, PostedOutcome),
    get_dict(status, PostedOutcome, accepted),
    miter_mattermost_bridge:surface_ingest(
        Config, State1, Posted, State1, DuplicateOutcome),
    g31_p3_status_reason(DuplicateOutcome, suppressed, duplicate, true),
    g31_p3_edited(Edited),
    miter_mattermost_bridge:surface_ingest(
        Config, State1, Edited, State2, EditedOutcome),
    get_dict(status, EditedOutcome, accepted),
    g31_p3_unauthorized(Unauthorized),
    miter_mattermost_bridge:surface_ingest(
        Config, State2, Unauthorized, State2, UnauthorizedOutcome),
    g31_p3_status_reason(UnauthorizedOutcome, rejected, unauthorized, true),
    miter_mattermost_bridge:surface_reconnect(
        Config, State2, 200, ReconnectOutcome),
    get_dict(status, ReconnectOutcome, accepted),
    miter_mattermost_bridge:surface_reconnect(
        Config, State2, 50, StaleOutcome),
    g31_p3_status_reason(StaleOutcome, rejected, stale_cursor, true).

g31_p3_first_accepted_lost(Descriptor, Principal, Now,
                           [cache(Key, Principal, Receipt, Expires)],
                           Receipt, 1) :-
    g31_p3_descriptor_key(Descriptor, Key),
    Expires is Now + 30,
    Receipt = post_for(Key).

g31_p3_inflight_cache(Descriptor, Principal, Now,
                      [cache(Key, Principal, pending, Expires)]) :-
    g31_p3_descriptor_key(Descriptor, Key),
    Expires is Now + 30.

g31_p3_retry(Cache, Principal, Now, Descriptor, Outcome, Creates) :-
    g31_p3_descriptor_key(Descriptor, Key),
    ( memberchk(cache(Key, Principal, Receipt, Expires), Cache),
      Now < Expires
    -> ( Receipt == pending
       -> Outcome = pending, Creates = 0
       ; Outcome = existing(Receipt), Creates = 0 )
    ; Outcome = created(post_for(Key)), Creates = 1
    ).

g31_p3_descriptor_key(Descriptor, Key) :-
    get_dict(idempotency_key, Descriptor, Key),
    get_dict(body, Descriptor, Body),
    get_dict(pending_post_id, Body, Key).

g31_p3_config(_{server_id:s1, team_id:t1, channel_id:c1, user_id:u1,
                auth_ref:a1}).
g31_p3_initial_state(_{cursor:0, seen:[], effects:[], panic:false}).
g31_p3_effect(_{schema:'miter-surface-effect-v1', id:e1,
                idempotency_key:k1, channel_id:c1, message:hello}).
g31_p3_posted(_{server_id:s1, team_id:t1, channel_id:c1, user_id:u1,
                event:posted,
                data:_{id:p1, root_id:r1, create_at:100}, seq:1}).
g31_p3_edited(_{server_id:s1, team_id:t1, channel_id:c1, user_id:u1,
                event:post_edited,
                data:_{id:p1, root_id:r1, edit_at:200}, seq:3}).
% No event/data/seq: unauthorized must be decided before payload parsing.
g31_p3_unauthorized(_{server_id:s1, team_id:t1,
                      channel_id:foreign_channel, user_id:foreign_user}).

g31_p3_status_reason(Outcome, Status, Reason, Result) :-
    ( is_dict(Outcome), get_dict(status, Outcome, Status),
      get_dict(reason, Outcome, Reason)
    -> Result = true
    ; Result = false
    ).

g31_p3_secret_absent(Root0, Candidate0, Result) :-
    catch((g31_p3_atom(Root0, Root), g31_p3_atom(Candidate0, Candidate),
           atom_concat('/Users/claritymiter/miter/evidence/G31/', _, Root),
           atom_concat(Root, _, Candidate),
           or_profile(Profile), or_keychain(Profile, Key),
           or_tree_secret_absent(Root, Key),
           or_tree_secret_absent(Candidate, Key)
          -> Result = true ; Result = false), _, Result = false),
    !.

g31_p3_atom(Value, Atom) :-
    ( atom(Value) -> Atom = Value ; string(Value) -> atom_string(Atom, Value) ),
    atom_length(Atom, Length),
    Length > 0.

g31_p3_mock_error(Error, ['g31-p3-mock-failure', Text]) :-
    term_string(Error, Text, [quoted(true)]).
