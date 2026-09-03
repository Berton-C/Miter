% mattermost_contract_tests.pl
:- use_module(library(plunit)).
:- use_module('../extension/mattermost_bridge.pl').

:- begin_tests(mattermost_bridge).

test(authorized_stable_event_mapping) :-
    Config = _{server_id:s1, team_id:t1, channel_id:c1, user_id:u1,
               auth_ref:a1},
    State0 = _{cursor:0, seen:[], effects:[], panic:false},
    Frame = _{server_id:s1, team_id:t1, channel_id:c1, user_id:u1,
              event:posted,
              data:_{id:p1, root_id:r1, create_at:100},
              seq:1},
    surface_ingest(Config, State0, Frame, State, Outcome),
    Outcome = _{status:accepted, event:E},
    E = _{schema:'miter-surface-event-v1',
          server_id:s1,
          team_id:t1,
          channel_id:c1,
          user_id:u1,
          post_id:p1,
          root_id:r1,
          event_timestamp:100,
          cursor:1,
          authorization_ref:a1},
    State = _{cursor:100, seen:[p1-100], effects:[], panic:false}.

test(duplicate_version_suppression) :-
    Config = _{server_id:s1, team_id:t1, channel_id:c1, user_id:u1,
               auth_ref:a1},
    State0 = _{cursor:50, seen:[p1-100], effects:[], panic:false},
    Frame = _{server_id:s1, team_id:t1, channel_id:c1, user_id:u1,
              event:posted,
              data:_{id:p1, root_id:r1, create_at:100},
              seq:2},
    surface_ingest(Config, State0, Frame, State, Outcome),
    Outcome = _{status:suppressed, reason:duplicate},
    State = State0.

test(edited_version_distinction) :-
    Config = _{server_id:s1, team_id:t1, channel_id:c1, user_id:u1,
               auth_ref:a1},
    State0 = _{cursor:100, seen:[p1-100], effects:[], panic:false},
    Frame = _{server_id:s1, team_id:t1, channel_id:c1, user_id:u1,
              event:post_edited,
              data:_{id:p1, root_id:r1, edit_at:200},
              seq:3},
    surface_ingest(Config, State0, Frame, State, Outcome),
    Outcome = _{status:accepted, event:E},
    E = _{schema:'miter-surface-event-v1',
          server_id:s1,
          team_id:t1,
          channel_id:c1,
          user_id:u1,
          post_id:p1,
          root_id:r1,
          event_timestamp:200,
          cursor:3,
          authorization_ref:a1},
    State = _{cursor:200, seen:[p1-200, p1-100], effects:[], panic:false}.

test(unauthorized_channel_user_before_payload) :-
    Config = _{server_id:s1, team_id:t1, channel_id:c1, user_id:u1,
               auth_ref:a1},
    State0 = _{cursor:0, seen:[], effects:[], panic:false},
    Frame = _{server_id:s1, team_id:t1, channel_id:c2, user_id:u2,
              event:junk,
              data:not_a_dict,
              seq:1},
    surface_ingest(Config, State0, Frame, State, Outcome),
    Outcome = _{status:rejected, reason:unauthorized},
    State = State0.

test(outbound_idempotency) :-
    Config = _{server_id:s1, team_id:t1, channel_id:c1, user_id:u1,
               auth_ref:a1},
    State0 = _{cursor:0, seen:[], effects:[], panic:false},
    Effect = _{schema:'miter-surface-effect-v1',
               id:e1,
               idempotency_key:k1,
               channel_id:c1,
               message:hello},
    surface_effect(Config, State0, Effect, State, Outcome),
    Outcome = _{status:accepted, descriptor:D},
    D = _{method:post,
          path:'/api/v4/posts',
          body:_{channel_id:c1, message:hello},
          idempotency_key:k1},
    State = _{cursor:0, seen:[], effects:[e1-k1], panic:false},
    surface_effect(Config, State, Effect, State2, Outcome2),
    Outcome2 = _{status:suppressed, reason:duplicate_effect},
    State2 = State.

test(malformed_effect_rejection) :-
    Config = _{server_id:s1, team_id:t1, channel_id:c1, user_id:u1,
               auth_ref:a1},
    State0 = _{cursor:0, seen:[], effects:[], panic:false},
    surface_effect(Config, State0, not_a_dict, State, Outcome),
    Outcome = _{status:rejected, reason:invalid_effect},
    State = State0.

test(unauthorized_effect_rejection) :-
    Config = _{server_id:s1, team_id:t1, channel_id:c1, user_id:u1,
               auth_ref:a1},
    State0 = _{cursor:0, seen:[], effects:[], panic:false},
    Effect = _{schema:'miter-surface-effect-v1',
               id:e1,
               idempotency_key:k1,
               channel_id:c2,
               message:hello},
    surface_effect(Config, State0, Effect, State, Outcome),
    Outcome = _{status:rejected, reason:unauthorized_channel},
    State = State0.

test(reconnect_and_cursor_resume) :-
    Config = _{server_id:s1, team_id:t1, channel_id:c1, user_id:u1,
               auth_ref:a1},
    State0 = _{cursor:100, seen:[], effects:[], panic:false},
    surface_reconnect(Config, State0, 150, Outcome),
    Outcome = _{status:accepted, resume_cursor:150},
    surface_reconnect(Config, State0, 50, Outcome2),
    Outcome2 = _{status:rejected, reason:stale_cursor}.

test(panic_denial) :-
    Config = _{server_id:s1, team_id:t1, channel_id:c1, user_id:u1,
               auth_ref:a1},
    State0 = _{cursor:0, seen:[], effects:[], panic:false},
    surface_panic(State0, State1),
    State1 = _{cursor:0, seen:[], effects:[], panic:true},
    Effect = _{schema:'miter-surface-effect-v1',
               id:e1,
               idempotency_key:k1,
               channel_id:c1,
               message:hello},
    surface_effect(Config, State1, Effect, State2, Outcome),
    Outcome = _{status:rejected, reason:panic_active},
    State2 = State1.

:- end_tests(mattermost_bridge).