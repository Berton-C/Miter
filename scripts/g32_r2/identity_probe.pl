:- initialization(main, main).
:- use_module(library(http/json)).

main([Mode]) :-
    consult('/Users/claritymiter/miter/evidence/G31/p3-351/candidate/extension/mattermost_bridge.pl'),
    Config = _{server_id:server_fixture, team_id:team_fixture,
               channel_id:channel_fixture, user_id:principal_fixture,
               auth_ref:keychain_reference_only},
    State0 = _{cursor:0, seen:[], effects:[], panic:false},
    Base = _{event:posted, seq:1,
             data:_{id:post_fixture, root_id:'', create_at:1}},
    Canonical = Base.put(_{server_id:server_fixture, team_id:team_fixture,
                           channel_id:channel_fixture, user_id:principal_fixture}),
    Denied = Base.put(_{server_id:server_fixture, team_id:team_fixture,
                        channel_id:denied_channel, user_id:principal_fixture}),
    identity_observation(Mode, Config, State0, Canonical, Denied, Observation),
    json_write_dict(current_output, Observation, []), nl.

identity_observation(canonical, Config, State0, Canonical, _Denied, Observation) :-
    miter_mattermost_bridge:surface_ingest(Config, State0, Canonical, _State, Outcome),
    get_dict(status, Outcome, accepted),
    Observation = _{outcome:Outcome, state_unchanged:false,
                    body_field_present:false, network_requests:0,
                    credential_lookups:0, effects:0}.
identity_observation(severed, Config, State0, _Canonical, Denied, Observation) :-
    miter_mattermost_bridge:surface_ingest(Config, State0, Denied, State, Outcome),
    get_dict(status, Outcome, rejected), get_dict(reason, Outcome, unauthorized),
    State == State0,
    Observation = _{outcome:Outcome, state_unchanged:true,
                    body_field_present:false, network_requests:0,
                    credential_lookups:0, effects:0}.
