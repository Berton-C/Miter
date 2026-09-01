% LM Studio mechanics for Miter's PeTTa runtime boundary.
% These predicates discover exact service IDs and maintain only local aliases.

:- use_module(library(http/http_open)).
:- use_module(library(http/json)).
:- use_module(library(filesex)).
:- use_module(library(lists)).
:- use_module(library(pairs)).

% Function form: five scalar inputs followed by exactly one scalar result.
miter_lm_bind_profile(Endpoint0, ConfigPath0, Alias0, TokenA0, TokenB0, Result) :-
    (   miter_lm_nonempty_atom(Endpoint0, Endpoint),
        miter_lm_nonempty_atom(ConfigPath0, ConfigPath),
        miter_lm_nonempty_atom(Alias0, Alias),
        miter_lm_nonempty_atom(TokenA0, TokenA),
        miter_lm_nonempty_atom(TokenB0, TokenB)
    ->  catch(
            miter_lm_bind_profile_checked(
                Endpoint, ConfigPath, Alias, TokenA, TokenB, Result0
            ),
            Error,
            miter_lm_exception_result(Error, Result0)
        ),
        Result = Result0
    ;   Result = 'invalid-model-profile-argument'
    ),
    !.

% Function form: two scalar inputs followed by exactly one scalar result.
miter_lm_resolve_profile(ConfigPath0, Alias0, Result) :-
    (   miter_lm_nonempty_atom(ConfigPath0, ConfigPath),
        miter_lm_nonempty_atom(Alias0, Alias)
    ->  catch(
            miter_lm_resolve_profile_checked(ConfigPath, Alias, Result0),
            Error,
            miter_lm_exception_result(Error, Result0)
        ),
        Result = Result0
    ;   Result = 'invalid-model-profile-argument'
    ),
    !.

miter_lm_bind_profile_checked(Endpoint, ConfigPath, Alias, TokenA, TokenB, Result) :-
    miter_lm_fetch_catalog(Endpoint, Status, Payload),
    (   Status =:= 200
    ->  miter_lm_payload_models(Payload, Models, PayloadResult),
        miter_lm_bind_from_models(
            PayloadResult, Models, Endpoint, ConfigPath, Alias, TokenA, TokenB,
            Result
        )
    ;   Result = 'lm-studio-http-error'
    ).

miter_lm_bind_from_models(ok, Models, Endpoint, ConfigPath, Alias, TokenA, TokenB, Result) :-
    miter_lm_matching_ids(Models, TokenA, TokenB, Matches),
    (   Matches = [ModelId]
    ->  miter_lm_load_profiles(ConfigPath, Endpoint, Profiles),
        miter_lm_replace_profile(Profiles, Alias, ModelId, UpdatedProfiles),
        miter_lm_write_profiles(ConfigPath, Endpoint, UpdatedProfiles),
        Result = 'model-profile-bound'
    ;   Matches = []
    ->  Result = 'model-profile-not-found'
    ;   Result = 'ambiguous-model-profile'
    ).
miter_lm_bind_from_models(error, _, _, _, _, _, _, 'invalid-lm-studio-response').

miter_lm_resolve_profile_checked(ConfigPath, Alias, Result) :-
    (   exists_file(ConfigPath)
    ->  miter_lm_read_config(ConfigPath, Config),
        miter_lm_config_endpoint(Config, _),
        miter_lm_config_profiles(Config, Profiles),
        (   member(Profile, Profiles),
            get_dict(alias, Profile, StoredAlias0),
            miter_lm_nonempty_atom(StoredAlias0, StoredAlias),
            StoredAlias == Alias,
            get_dict(id, Profile, ModelId0),
            miter_lm_nonempty_atom(ModelId0, ModelId)
        ->  Result = ModelId
        ;   Result = 'unknown-model-profile'
        )
    ;   Result = 'local-model-config-unavailable'
    ).

miter_lm_fetch_catalog(Endpoint, Status, Payload) :-
    setup_call_cleanup(
        http_open(
            Endpoint,
            Stream,
            [ status_code(Status),
              timeout(10),
              request_header('Accept'='application/json')
            ]
        ),
        json_read_dict(Stream, Payload),
        close(Stream)
    ).

miter_lm_payload_models(Payload, Models, ok) :-
    is_dict(Payload),
    get_dict(data, Payload, Models),
    is_list(Models),
    !.
miter_lm_payload_models(_, [], error).

miter_lm_matching_ids(Models, TokenA, TokenB, Matches) :-
    downcase_atom(TokenA, LowerTokenA),
    downcase_atom(TokenB, LowerTokenB),
    findall(
        ModelId,
        ( member(Model, Models),
          is_dict(Model),
          get_dict(id, Model, ModelId0),
          miter_lm_nonempty_atom(ModelId0, ModelId),
          downcase_atom(ModelId, LowerModelId),
          sub_atom(LowerModelId, _, _, _, LowerTokenA),
          sub_atom(LowerModelId, _, _, _, LowerTokenB)
        ),
        RawMatches
    ),
    sort(RawMatches, Matches).

miter_lm_load_profiles(ConfigPath, Endpoint, Profiles) :-
    (   exists_file(ConfigPath)
    ->  miter_lm_read_config(ConfigPath, Config),
        miter_lm_config_endpoint(Config, StoredEndpoint),
        (   StoredEndpoint == Endpoint
        ->  miter_lm_config_profiles(Config, Profiles)
        ;   throw(error(miter_local_config_endpoint_mismatch, _))
        )
    ;   Profiles = []
    ).

miter_lm_read_config(ConfigPath, Config) :-
    setup_call_cleanup(
        open(ConfigPath, read, Stream, [encoding(utf8)]),
        json_read_dict(Stream, Config),
        close(Stream)
    ).

miter_lm_config_endpoint(Config, Endpoint) :-
    is_dict(Config),
    get_dict(schema, Config, Schema0),
    miter_lm_nonempty_atom(Schema0, Schema),
    Schema == 'miter-local-model-profiles-v1',
    get_dict(endpoint, Config, Endpoint0),
    miter_lm_nonempty_atom(Endpoint0, Endpoint),
    !.
miter_lm_config_endpoint(_, _) :-
    throw(error(miter_invalid_local_model_config, _)).

miter_lm_config_profiles(Config, Profiles) :-
    is_dict(Config),
    get_dict(profiles, Config, Profiles),
    is_list(Profiles),
    !.
miter_lm_config_profiles(_, _) :-
    throw(error(miter_invalid_local_model_config, _)).

miter_lm_replace_profile(Profiles, Alias, ModelId, UpdatedProfiles) :-
    exclude(miter_lm_profile_has_alias(Alias), Profiles, RemainingProfiles),
    maplist(
        miter_lm_profile_pair,
        [_{alias:Alias, id:ModelId}|RemainingProfiles],
        ProfilePairs
    ),
    keysort(ProfilePairs, SortedPairs),
    pairs_values(SortedPairs, UpdatedProfiles).

miter_lm_profile_has_alias(Alias, Profile) :-
    is_dict(Profile),
    get_dict(alias, Profile, StoredAlias0),
    miter_lm_nonempty_atom(StoredAlias0, StoredAlias),
    StoredAlias == Alias.

miter_lm_profile_pair(Profile, Alias-Profile) :-
    get_dict(alias, Profile, Alias0),
    miter_lm_nonempty_atom(Alias0, Alias).

miter_lm_write_profiles(ConfigPath, Endpoint, Profiles) :-
    file_directory_name(ConfigPath, Directory),
    make_directory_path(Directory),
    atom_concat(ConfigPath, '.tmp', TemporaryPath),
    Config = _{
        schema:'miter-local-model-profiles-v1',
        endpoint:Endpoint,
        profiles:Profiles
    },
    setup_call_cleanup(
        true,
        ( setup_call_cleanup(
              open(TemporaryPath, write, Stream, [encoding(utf8)]),
              ( json_write_dict(Stream, Config, [width(80)]),
                nl(Stream)
              ),
              close(Stream)
          ),
          chmod(TemporaryPath, 0o600),
          rename_file(TemporaryPath, ConfigPath)
        ),
        ( exists_file(TemporaryPath) -> delete_file(TemporaryPath) ; true )
    ).

miter_lm_nonempty_atom(Value, Atom) :-
    (   atom(Value)
    ->  Atom = Value
    ;   string(Value)
    ->  atom_string(Atom, Value)
    ),
    atom_length(Atom, Length),
    Length > 0.

miter_lm_exception_result(error(socket_error(_, _), _), 'lm-studio-unavailable') :- !.
miter_lm_exception_result(error(timeout_error(_, _), _), 'lm-studio-unavailable') :- !.
miter_lm_exception_result(error(miter_local_config_endpoint_mismatch, _),
                          'local-model-config-endpoint-mismatch') :- !.
miter_lm_exception_result(error(miter_invalid_local_model_config, _),
                          'invalid-local-model-config') :- !.
miter_lm_exception_result(error(permission_error(_, _, _), _),
                          'local-model-config-write-error') :- !.
miter_lm_exception_result(error(existence_error(_, _), _),
                          'local-model-config-io-error') :- !.
miter_lm_exception_result(_, 'lm-membrane-error').
