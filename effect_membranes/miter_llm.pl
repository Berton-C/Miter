% LM Studio mechanics for Miter's PeTTa runtime boundary.
% These predicates discover exact service IDs and maintain only local aliases.

:- use_module(library(http/http_open)).
:- use_module(library(http/http_client)).
:- use_module(library(http/http_json)).
:- use_module(library(http/json)).
:- use_module(library(uri)).
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

% Function form: four scalar inputs followed by exactly one scalar result.
% MeTTa supplies the profile choice; this grounding only prepares transport JSON.
miter_lm_prepare_request(ConfigPath0, Alias0, TemplatePath0, PreparedPath0, Result) :-
    (   miter_lm_nonempty_atom(ConfigPath0, ConfigPath),
        miter_lm_nonempty_atom(Alias0, Alias),
        miter_lm_nonempty_atom(TemplatePath0, TemplatePath),
        miter_lm_nonempty_atom(PreparedPath0, PreparedPath)
    ->  catch(
            miter_lm_prepare_request_checked(
                ConfigPath, Alias, TemplatePath, PreparedPath, Result0
            ),
            _,
            Result0 = 'request-preparation-error'
        ),
        Result = Result0
    ;   Result = 'invalid-request-preparation-argument'
    ),
    !.

% Function form: three scalar inputs followed by exactly one scalar result.
% The provider body is retained verbatim; timing is a separate mechanical record.
miter_lm_execute_request(PreparedPath0, RawPath0, TimingPath0, Result) :-
    (   miter_lm_nonempty_atom(PreparedPath0, PreparedPath),
        miter_lm_nonempty_atom(RawPath0, RawPath),
        miter_lm_nonempty_atom(TimingPath0, TimingPath),
        RawPath \== TimingPath
    ->  catch(
            miter_lm_execute_request_checked(
                PreparedPath, RawPath, TimingPath, Result0
            ),
            Error,
            miter_lm_execute_exception_result(Error, Result0)
        ),
        Result = Result0
    ;   Result = 'invalid-inference-argument'
    ),
    !.

% Function form: three scalar inputs followed by exactly one scalar result.
% This predicate parses JSON as data and never evaluates provider content.
miter_lm_parse_result(TemplatePath0, RawPath0, TypedPath0, Result) :-
    (   miter_lm_nonempty_atom(TemplatePath0, TemplatePath),
        miter_lm_nonempty_atom(RawPath0, RawPath),
        miter_lm_nonempty_atom(TypedPath0, TypedPath),
        RawPath \== TypedPath
    ->  catch(
            miter_lm_parse_result_checked(
                TemplatePath, RawPath, TypedPath, Result0
            ),
            _,
            Result0 = 'semantic-result-write-error'
        ),
        Result = Result0
    ;   Result = 'invalid-result-parse-argument'
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

miter_lm_prepare_request_checked(
    ConfigPath, Alias, TemplatePath, PreparedPath, Result
) :-
    (   exists_file(PreparedPath)
    ->  Result = 'prepared-request-output-exists'
    ;   miter_lm_resolve_profile_checked(ConfigPath, Alias, Resolution),
        (   miter_lm_profile_resolution_error(Resolution)
        ->  Result = Resolution
        ;   miter_lm_read_json_file(TemplatePath, Template),
            (   miter_lm_request_template(
                    Template, RequestId, Endpoint, RequestBody
                )
            ->  put_dict(model, RequestBody, Resolution, ProviderBody),
                Prepared = _{
                    schema:'miter-prepared-model-request-v1',
                    request_id:RequestId,
                    alias:Alias,
                    endpoint:Endpoint,
                    body:ProviderBody
                },
                miter_lm_write_json_atomic(PreparedPath, Prepared),
                Result = 'model-request-prepared'
            ;   Result = 'invalid-request-template'
            )
        )
    ).

miter_lm_execute_request_checked(PreparedPath, _RawPath, _TimingPath, Result) :-
    \+ exists_file(PreparedPath),
    !,
    Result = 'prepared-request-unavailable'.
miter_lm_execute_request_checked(_PreparedPath, RawPath, TimingPath, Result) :-
    (   exists_file(RawPath)
    ;   exists_file(TimingPath)
    ),
    !,
    Result = 'inference-output-exists'.
miter_lm_execute_request_checked(PreparedPath, RawPath, TimingPath, Result) :-
    miter_lm_read_json_file(PreparedPath, Prepared),
    (   miter_lm_prepared_request(
            Prepared, RequestId, Alias, ModelId, Endpoint, ProviderBody
        )
    ->  get_time(StartedAt),
        miter_lm_http_post_raw(Endpoint, ProviderBody, HttpStatus, RawBody),
        get_time(CompletedAt),
        DurationMs is round((CompletedAt - StartedAt) * 1000),
        miter_lm_write_text_atomic(RawPath, RawBody),
        Timing = _{
            schema:'miter-model-timing-v1',
            request_id:RequestId,
            alias:Alias,
            model:ModelId,
            http_status:HttpStatus,
            started_at_epoch:StartedAt,
            completed_at_epoch:CompletedAt,
            duration_ms:DurationMs
        },
        miter_lm_write_json_atomic(TimingPath, Timing),
        (   HttpStatus =:= 200
        ->  Result = 'raw-model-response-stored'
        ;   Result = 'lm-studio-inference-http-error'
        )
    ;   Result = 'invalid-prepared-request'
    ).

miter_lm_parse_result_checked(TemplatePath, RawPath, TypedPath, Result) :-
    (   exists_file(TypedPath)
    ->  Result = 'semantic-result-output-exists'
    ;   exists_file(TemplatePath),
        exists_file(RawPath)
    ->  (   catch(
                miter_lm_validated_provider_product(
                    TemplatePath, RawPath, TypedProduct
                ),
                _,
                fail
            )
        ->  miter_lm_write_json_atomic(TypedPath, TypedProduct),
            Result = 'semantic-result-valid'
        ;   Result = 'malformed-model-response'
        )
    ;   Result = 'model-response-input-unavailable'
    ).

miter_lm_profile_resolution_error('unknown-model-profile').
miter_lm_profile_resolution_error('local-model-config-unavailable').
miter_lm_profile_resolution_error('invalid-local-model-config').
miter_lm_profile_resolution_error('local-model-config-io-error').

miter_lm_request_template(Template, RequestId, Endpoint, Body) :-
    is_dict(Template),
    get_dict(schema, Template, Schema0),
    miter_lm_nonempty_atom(Schema0, Schema),
    Schema == 'miter-schema-request-v1',
    get_dict(request_id, Template, RequestId0),
    miter_lm_nonempty_atom(RequestId0, RequestId),
    get_dict(endpoint, Template, Endpoint0),
    miter_lm_nonempty_atom(Endpoint0, Endpoint),
    miter_lm_local_chat_endpoint(Endpoint),
    get_dict(body, Template, Body),
    is_dict(Body),
    \+ get_dict(model, Body, _),
    get_dict(messages, Body, Messages),
    is_list(Messages),
    Messages \== [],
    get_dict(response_format, Body, ResponseFormat),
    is_dict(ResponseFormat).

miter_lm_local_chat_endpoint(Endpoint) :-
    uri_components(
        Endpoint,
        uri_components(http, Authority, '/v1/chat/completions', Search, Fragment)
    ),
    var(Search),
    var(Fragment),
    uri_authority_components(
        Authority,
        uri_authority(User, Password, Host0, Port)
    ),
    var(User),
    var(Password),
    downcase_atom(Host0, Host),
    memberchk(Host, ['127.0.0.1', localhost]),
    integer(Port),
    between(1, 65535, Port).

miter_lm_prepared_request(
    Prepared, RequestId, Alias, ModelId, Endpoint, ProviderBody
) :-
    is_dict(Prepared),
    get_dict(schema, Prepared, Schema0),
    miter_lm_nonempty_atom(Schema0, Schema),
    Schema == 'miter-prepared-model-request-v1',
    get_dict(request_id, Prepared, RequestId0),
    miter_lm_nonempty_atom(RequestId0, RequestId),
    get_dict(alias, Prepared, Alias0),
    miter_lm_nonempty_atom(Alias0, Alias),
    get_dict(endpoint, Prepared, Endpoint0),
    miter_lm_nonempty_atom(Endpoint0, Endpoint),
    miter_lm_local_chat_endpoint(Endpoint),
    get_dict(body, Prepared, ProviderBody),
    is_dict(ProviderBody),
    get_dict(model, ProviderBody, ModelId0),
    miter_lm_nonempty_atom(ModelId0, ModelId).

miter_lm_http_post_raw(Endpoint, ProviderBody, HttpStatus, RawBody) :-
    setup_call_cleanup(
        http_open(
            Endpoint,
            Stream,
            [ method(post),
              post(json(ProviderBody)),
              status_code(HttpStatus),
              timeout(900),
              request_header('Accept'='application/json')
            ]
        ),
        read_string(Stream, _, RawBody),
        close(Stream)
    ).

miter_lm_validated_provider_product(TemplatePath, RawPath, TypedProduct) :-
    miter_lm_read_json_file(TemplatePath, Template),
    miter_lm_request_template(Template, RequestId, _, _),
    miter_lm_read_json_file(RawPath, ProviderResponse),
    miter_lm_provider_product(ProviderResponse, ProviderProduct),
    miter_lm_typed_product(ProviderProduct, RequestId, TypedProduct).

miter_lm_provider_product(ProviderResponse, ProviderProduct) :-
    is_dict(ProviderResponse),
    get_dict(choices, ProviderResponse, [Choice|_]),
    is_dict(Choice),
    get_dict(finish_reason, Choice, FinishReason0),
    miter_lm_nonempty_atom(FinishReason0, FinishReason),
    FinishReason == stop,
    get_dict(message, Choice, Message),
    is_dict(Message),
    get_dict(content, Message, Content),
    string(Content),
    string_length(Content, ContentLength),
    ContentLength > 0,
    atom_string(ContentAtom, Content),
    atom_json_dict(ContentAtom, ProviderProduct, []).

miter_lm_typed_product(Product, RequestId, TypedProduct) :-
    is_dict(Product),
    dict_pairs(Product, _, ProductPairs),
    pairs_keys(ProductPairs, ProductKeys0),
    sort(ProductKeys0, ProductKeys),
    ProductKeys == [
        answer,
        completion_status,
        evidence_spans,
        request_id,
        uncertainty
    ],
    get_dict(request_id, Product, ProductRequestId0),
    miter_lm_nonempty_atom(ProductRequestId0, ProductRequestId),
    ProductRequestId == RequestId,
    get_dict(answer, Product, Answer),
    miter_lm_bounded_json_string(Answer, 1, 240),
    get_dict(uncertainty, Product, Uncertainty),
    number(Uncertainty),
    Uncertainty >= 0,
    Uncertainty =< 1,
    get_dict(evidence_spans, Product, EvidenceSpans),
    is_list(EvidenceSpans),
    length(EvidenceSpans, EvidenceCount),
    between(1, 3, EvidenceCount),
    maplist(miter_lm_evidence_span, EvidenceSpans),
    get_dict(completion_status, Product, CompletionStatus),
    string(CompletionStatus),
    memberchk(CompletionStatus, ["complete", "insufficient_evidence"]),
    TypedProduct = _{
        request_id:ProductRequestId0,
        answer:Answer,
        uncertainty:Uncertainty,
        evidence_spans:EvidenceSpans,
        completion_status:CompletionStatus
    }.

miter_lm_evidence_span(Span) :-
    miter_lm_bounded_json_string(Span, 1, 160).

miter_lm_bounded_json_string(Value, Minimum, Maximum) :-
    string(Value),
    string_length(Value, Length),
    Length >= Minimum,
    Length =< Maximum.

miter_lm_read_json_file(Path, Dict) :-
    setup_call_cleanup(
        open(Path, read, Stream, [encoding(utf8)]),
        json_read_dict(Stream, Dict),
        close(Stream)
    ).

miter_lm_write_json_atomic(Path, Dict) :-
    file_directory_name(Path, Directory),
    make_directory_path(Directory),
    atom_concat(Path, '.tmp', TemporaryPath),
    setup_call_cleanup(
        true,
        ( setup_call_cleanup(
              open(TemporaryPath, write, Stream, [encoding(utf8)]),
              ( json_write_dict(Stream, Dict, [width(100)]),
                nl(Stream)
              ),
              close(Stream)
          ),
          chmod(TemporaryPath, 0o600),
          rename_file(TemporaryPath, Path)
        ),
        ( exists_file(TemporaryPath) -> delete_file(TemporaryPath) ; true )
    ).

miter_lm_write_text_atomic(Path, Text) :-
    file_directory_name(Path, Directory),
    make_directory_path(Directory),
    atom_concat(Path, '.tmp', TemporaryPath),
    setup_call_cleanup(
        true,
        ( setup_call_cleanup(
              open(TemporaryPath, write, Stream, [encoding(utf8)]),
              format(Stream, '~s', [Text]),
              close(Stream)
          ),
          chmod(TemporaryPath, 0o600),
          rename_file(TemporaryPath, Path)
        ),
        ( exists_file(TemporaryPath) -> delete_file(TemporaryPath) ; true )
    ).

miter_lm_execute_exception_result(error(socket_error(_, _), _),
                                  'lm-studio-unavailable') :- !.
miter_lm_execute_exception_result(error(timeout_error(_, _), _),
                                  'lm-studio-unavailable') :- !.
miter_lm_execute_exception_result(error(permission_error(_, _, _), _),
                                  'inference-output-write-error') :- !.
miter_lm_execute_exception_result(_, 'inference-transport-error').

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
