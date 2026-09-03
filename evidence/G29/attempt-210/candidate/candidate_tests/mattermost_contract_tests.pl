% mattermost_contract_tests.pl
:- use_module(library(plunit)).
:- use_module(library(dicts)).
:- use_module('../extension/mattermost_bridge.pl').

:- begin_tests(mattermost_bridge).

test(authorized_stable_event_mapping) :-
    Config = {server_id:s1, team_id:t1, channel_id:c1, user_id:u1, auth_ref:a1},
    State0 = {cursor:0, seen:[], effects:[], panic:false},
    Frame = {server_id:s1, team_id:t1, channel_id:c1, user_id:u1, event:posted, data:{id:p1, root_id:r1, create_at:100}, seq:1},
    surface_ingest(Config, State0, Frame, State, Outcome),
    Outcome = {status:accepted, event:E},
    E = {schema:miter-surface-event-v1, server_id:s1, team_id:t1, channel_id:c1, user_id:u1, post_id:p1, root_id:r1, event_timestamp:100, cursor:1, authorization_ref:a1},
    State = {cursor:100, seen:[p1,100], effects:[], panic:false}.

test(duplicate_suppression) :-
    Config = {server_id:s1, team_id:t1, channel_id:c1, user_id:u1, auth_ref:a1},
    State0 = {cursor:100, seen:[p1,100], effects:[], panic:false},
    Frame = {server_id:s1, team_id:t1, channel_id:c1, user_id:u1, event:posted, data:{id:p1, root_id:r1, create_at:100}, seq:2},
    surface_ingest(Config, State0, Frame, State, Outcome),
    Outcome = {status:suppressed, reason:duplicate},
    State = State0.

test(edited_post_distinction) :-
    Config = {server_id:s1, team_id:t1, channel_id:c1, user_id:u1, auth_ref:a1},
    State0 = {cursor:100, seen:[p1,100], effects:[], panic:false},
    Frame = {server_id:s1, team_id:t1, channel_id:c1, user_id:u1, event:post_edited, data:{id:p1, root_id:r1, edit_at:200}, seq:3},
    surface_ingest(Config, State0, Frame, State, Outcome),
    Outcome = {status:accepted, event:E},
    E = {schema:miter-surface-event-v1, server_id:s1, team_id:t1, channel_id:c1, user_id:u1, post_id:p1, root_id:r1, event_timestamp:200, cursor:3, authorization_ref:a1},
    State = {cursor:200, seen:[p1,200], effects:[], panic:false}.

test(unauthorized_channel_user_before_payload) :-
    Config = {server_id:s1, team_id:t1, channel_id:c1, user_id:u1, auth_ref:a1},
    State0 = {cursor:0, seen:[], effects:[], panic:false},
    Frame = {server_id:s1, team_id:t1, channel_id:c2, user_id:u1, event:posted, data:{id:p1, root_id:r1, create_at:100}, seq:1},
    surface_ingest(Config, State0, Frame, State, Outcome),
    Outcome = {status:rejected, reason:unauthorized},
    State = State0.

test(idempotent_outbound_request) :-
    Config = {server_id:s1, team_id:t1, channel_id:c1, user_id:u1, auth_ref:a1},
    State0 = {cursor:0, seen:[], effects:[], panic:false},
    Effect = {schema:miter-surface-effect-v1, id:e1, idempotency_key:k1, channel_id:c1, message:hello},
    surface_effect(Config, State0, Effect, State, Outcome),
    Outcome = {status:accepted, descriptor:D},
    D = {method:post, path:/api/v4/posts, body:{channel_id:c1, message:hello}, idempotency_key:k1},
    State = {cursor:0, seen:[], effects:[e1,k1], panic:false},
    surface_effect(Config, State, Effect, State2, Outcome2),
    Outcome2 = {status:suppressed, reason:duplicate_effect},
    State2 = State.

test(malformed_send_failure_rejection) :-
    Config = {server_id:s1, team_id:t1, channel_id:c1, user_id:u1, auth_ref:a1},
    State0 = {cursor:0, seen:[], effects:[], panic:false},
    Effect = {schema:miter-surface-effect-v1, id:e1, idempotency_key:k1, channel_id:c2, message:hello},
    surface_effect(Config, State0, Effect, State, Outcome),
    Outcome = {status:rejected, reason:unauthorized_channel},
    State = State0.

test(reconnect_and_cursor_resume) :-
    Config = {server_id:s1, team_id:t1, channel_id:c1, user_id:u1, auth_ref:a1},
    State0 = {cursor:100, seen:[], effects:[], panic:false},
    surface_reconnect(Config, State0, 150, Outcome),
    Outcome = {status:accepted, resume_cursor:150},
    surface_reconnect(Config, State0, 50, Outcome2),
    Outcome2 = {status:rejected, reason:stale_cursor}.

test(panic_denial) :-
    Config = {server_id:s1, team_id:t1, channel_id:c1, user_id:u1, auth_ref:a1},
    State0 = {cursor:0, seen:[], effects:[], panic:false},
    surface_panic(State0, State1),
    State1 = {cursor:0, seen:[], effects:[], panic:true},
    Effect = {schema:miter-surface-effect-v1, id:e1, idempotency_key:k1, channel_id:c1, message:hello},
    surface_effect(Config, State1, Effect, State2, Outcome),
    Outcome = {status:rejected, reason:panic_active},
    State2 = State1.

:- end_tests(mattermost_bridge).