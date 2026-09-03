:- module(miter_mattermost_bridge, [
    surface_ingest/5,
    surface_effect/5,
    surface_reconnect/4,
    surface_panic/2
]).

:- use_module(library(dicts)).

%% ------------------------------------------------------------------
%% Ingest: authorize server/team/channel/user BEFORE reading event data.
%% ------------------------------------------------------------------

surface_ingest(Config, State0, Frame, State, Outcome) :-
    ingest_frame(Config, State0, Frame, State, Outcome).

ingest_frame(_Config, State0, Frame, State, Outcome) :-
    \+ is_dict(Frame), !,
    State = State0,
    Outcome = _{status:rejected, reason:invalid_frame}.
ingest_frame(Config, State0, Frame, State, Outcome) :-
    authorized(Config, Frame, SID, TID, CID, UID), !,
    (   frame_payload(Frame, E, D, Seq)
    ->  (   event_version(E, D, PID, RID, TS)
        ->  ingest_event(Config, SID, TID, CID, UID,
                         PID, RID, TS, Seq, State0, State, Outcome)
        ;   State = State0,
            Outcome = _{status:rejected, reason:unsupported_event}
        )
    ;   State = State0,
        Outcome = _{status:rejected, reason:invalid_frame}
    ).
ingest_frame(_Config, State0, _Frame, State, Outcome) :-
    State = State0,
    Outcome = _{status:rejected, reason:unauthorized}.

authorized(Config, Frame, SID, TID, CID, UID) :-
    is_dict(Config),
    is_dict(Frame),
    get_dict(server_id, Frame, SID),
    get_dict(team_id, Frame, TID),
    get_dict(channel_id, Frame, CID),
    get_dict(user_id, Frame, UID),
    get_dict(server_id, Config, SID),
    get_dict(team_id, Config, TID),
    get_dict(channel_id, Config, CID),
    get_dict(user_id, Config, UID).

frame_payload(Frame, E, D, Seq) :-
    get_dict(event, Frame, E),
    get_dict(data, Frame, D),
    get_dict(seq, Frame, Seq).

%% Stable IDs; update-aware version = post id + version timestamp.
event_version(posted, D, PID, RID, TS) :-
    get_dict(id, D, PID),
    get_dict(root_id, D, RID),
    get_dict(create_at, D, TS).
event_version(post_edited, D, PID, RID, TS) :-
    get_dict(id, D, PID),
    get_dict(root_id, D, RID),
    get_dict(edit_at, D, TS).

ingest_event(Config, SID, TID, CID, UID, PID, RID, TS, Seq, State0, State, Outcome) :-
    get_dict(cursor, State0, Cursor),
    get_dict(seen, State0, Seen),
    get_dict(auth_ref, Config, AuthRef),
    (   TS =< Cursor
    ->  State = State0,
        Outcome = _{status:suppressed, reason:stale_cursor}
    ;   memberchk(PID-TS, Seen)
    ->  State = State0,
        Outcome = _{status:suppressed, reason:duplicate}
    ;   NewCursor is max(Cursor, TS),
        State = State0.put(cursor, NewCursor).put(seen, [PID-TS|Seen]),
        Outcome = _{status:accepted,
                    event:_{schema:'miter-surface-event-v1',
                            server_id:SID,
                            team_id:TID,
                            channel_id:CID,
                            user_id:UID,
                            post_id:PID,
                            root_id:RID,
                            event_timestamp:TS,
                            cursor:Seq,
                            authorization_ref:AuthRef}}
    ).

%% ------------------------------------------------------------------
%% Effect: inert descriptor only; id/idempotency dedupe; panic gate.
%% ------------------------------------------------------------------

surface_effect(Config, State0, Effect, State, Outcome) :-
    effect_frame(Config, State0, Effect, State, Outcome).

effect_frame(_Config, State0, _Effect, State, Outcome) :-
    get_dict(panic, State0, true), !,
    State = State0,
    Outcome = _{status:rejected, reason:panic_active}.
effect_frame(_Config, State0, Effect, State, Outcome) :-
    \+ is_dict(Effect), !,
    State = State0,
    Outcome = _{status:rejected, reason:invalid_effect}.
effect_frame(Config, State0, Effect, State, Outcome) :-
    get_dict(schema, Effect, 'miter-surface-effect-v1'),
    get_dict(id, Effect, ID),
    get_dict(idempotency_key, Effect, IK),
    get_dict(channel_id, Effect, CID),
    get_dict(message, Effect, M), !,
    (   get_dict(channel_id, Config, ConfigCID),
        CID == ConfigCID
    ->  get_dict(effects, State0, Effects),
        (   memberchk(ID-IK, Effects)
        ->  State = State0,
            Outcome = _{status:suppressed, reason:duplicate_effect}
        ;   State = State0.put(effects, [ID-IK|Effects]),
            Outcome = _{status:accepted,
                        descriptor:_{method:post,
                                     path:'/api/v4/posts',
                                     body:_{channel_id:CID, message:M},
                                     idempotency_key:IK}}
        )
    ;   State = State0,
        Outcome = _{status:rejected, reason:unauthorized_channel}
    ).
effect_frame(_Config, State0, _Effect, State, Outcome) :-
    State = State0,
    Outcome = _{status:rejected, reason:invalid_effect}.

%% ------------------------------------------------------------------
%% Reconnect: monotone cursor only.
%% ------------------------------------------------------------------

surface_reconnect(_Config, State0, Cursor, Outcome) :-
    get_dict(cursor, State0, Current),
    (   Cursor >= Current
    ->  Outcome = _{status:accepted, resume_cursor:Cursor}
    ;   Outcome = _{status:rejected, reason:stale_cursor}
    ).

%% ------------------------------------------------------------------
%% Panic: irreversible latch.
%% ------------------------------------------------------------------

surface_panic(State0, State) :-
    State = State0.put(panic, true).