:- module(miter_mattermost_bridge, [surface_ingest/5, surface_effect/5, surface_reconnect/4, surface_panic/2]).

:- use_module(library(dicts)).

surface_ingest(Config, State0, Frame, State, Outcome) :-
    (   Frame = {server_id:SID, team_id:TID, channel_id:CID, user_id:UID, event:E, data:D, seq:Seq}
    ;   Frame = {server_id:SID, team_id:TID, channel_id:CID, user_id:UID, event:E, data:D, seq:Seq, _:_}
    ),
    (   SID == Config.server_id, TID == Config.team_id, CID == Config.channel_id, UID == Config.user_id
    ->  true
    ;   State = State0, Outcome = {status:rejected, reason:unauthorized}, !
    ),
    (   E == posted, D = {id:PID, root_id:RID, create_at:TS}
    ;   E == post_edited, D = {id:PID, root_id:RID, edit_at:TS}
    ),
    (   TS > State0.cursor
    ->  true
    ;   State = State0, Outcome = {status:suppressed, reason:stale_cursor}, !
    ),
    (   State0.seen =.. [_, PID, TS]
    ->  State = State0, Outcome = {status:suppressed, reason:duplicate}, !
    ;   true
    ),
    State = State0.put(cursor, TS).put(seen, [PID, TS]),
    Outcome = {status:accepted, event:{schema:miter-surface-event-v1, server_id:SID, team_id:TID, channel_id:CID, user_id:UID, post_id:PID, root_id:RID, event_timestamp:TS, cursor:Seq, authorization_ref:Config.auth_ref}}.

surface_effect(Config, State0, Effect, State, Outcome) :-
    (   State0.panic == true
    ->  State = State0, Outcome = {status:rejected, reason:panic_active}, !
    ;   Effect = {schema:miter-surface-effect-v1, id:ID, idempotency_key:IK, channel_id:CID, message:M}
    ->  (   CID == Config.channel_id
        ->  true
        ;   State = State0, Outcome = {status:rejected, reason:unauthorized_channel}, !
        ),
        (   State0.effects =.. [_, ID, IK]
        ->  State = State0, Outcome = {status:suppressed, reason:duplicate_effect}, !
        ;   true
        ),
        State = State0.put(effects, [ID, IK]),
        Outcome = {status:accepted, descriptor:{method:post, path:/api/v4/posts, body:{channel_id:CID, message:M}, idempotency_key:IK}}
    ;   State = State0, Outcome = {status:rejected, reason:invalid_effect}
    ).

surface_reconnect(Config, State0, Cursor, Outcome) :-
    (   Cursor >= State0.cursor
    ->  Outcome = {status:accepted, resume_cursor:Cursor}
    ;   Outcome = {status:rejected, reason:stale_cursor}
    ).

surface_panic(State0, State) :-
    State = State0.put(panic, true).