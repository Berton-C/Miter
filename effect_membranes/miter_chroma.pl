% Typed HTTP and validation mechanics for Miter semantic memory.
% G06 deliberately exposes embedding operations only: there is no Chroma
% collection mutation predicate in this gate.

:- use_module(library(http/http_open)).
:- use_module(library(http/http_json)).
:- use_module(library(http/json)).
:- use_module(library(uri)).
:- use_module(library(filesex)).
:- use_module(library(crypto)).
:- use_module(library(lists)).

% Five scalar inputs followed by one scalar result. Provider JSON is retained
% as an opaque artifact; only validated vector metadata crosses the membrane.
miter_chroma_embed_text(ProfilePath0, LocalConfigPath0, Input0,
                        RawPath0, MetadataPath0, Result) :-
    (   miter_chroma_nonempty_atom(ProfilePath0, ProfilePath),
        miter_chroma_nonempty_atom(LocalConfigPath0, LocalConfigPath),
        miter_chroma_nonempty_string(Input0, Input),
        miter_chroma_nonempty_atom(RawPath0, RawPath),
        miter_chroma_nonempty_atom(MetadataPath0, MetadataPath),
        RawPath \== MetadataPath
    ->  catch(
            miter_chroma_embed_text_checked(
                ProfilePath, LocalConfigPath, Input, RawPath, MetadataPath,
                Result0
            ),
            Error,
            miter_chroma_exception_result(Error, Result0)
        ),
        Result = Result0
    ;   Result = 'invalid-embedding-argument'
    ),
    !.

% Two scalar inputs followed by one scalar result. This is the fail-closed
% pre-insertion validator used by the wrong-dimension negative control.
miter_chroma_validate_embedding_response(ProfilePath0, RawPath0, Result) :-
    (   miter_chroma_nonempty_atom(ProfilePath0, ProfilePath),
        miter_chroma_nonempty_atom(RawPath0, RawPath)
    ->  catch(
            miter_chroma_validate_embedding_response_checked(
                ProfilePath, RawPath, Result0
            ),
            Error,
            miter_chroma_exception_result(Error, Result0)
        ),
        Result = Result0
    ;   Result = 'invalid-embedding-validation-argument'
    ),
    !.

miter_chroma_embed_text_checked(_, _, _, RawPath, _,
                                'embedding-output-exists') :-
    exists_file(RawPath),
    !.
miter_chroma_embed_text_checked(_, _, _, _, MetadataPath,
                                'embedding-output-exists') :-
    exists_file(MetadataPath),
    !.
miter_chroma_embed_text_checked(ProfilePath, LocalConfigPath, Input,
                                RawPath, MetadataPath, Result) :-
    miter_chroma_read_json(ProfilePath, Profile),
    miter_chroma_profile(Profile, ProfileId, ModelId, Dimension, Tolerance,
                         Endpoint, ChunkingVersion, DistanceMetric,
                         CollectionSchemaVersion),
    miter_chroma_resolve_local_profile(
        LocalConfigPath, ProfileId, ResolvedModelId
    ),
    (   ResolvedModelId \== ModelId
    ->  Result = 'embedding-profile-resolution-mismatch'
    ;   ProviderBody = _{model:ModelId, input:Input},
        get_time(StartedAt),
        miter_chroma_http_post_raw(
            Endpoint, ProviderBody, HttpStatus, RawBody
        ),
        get_time(CompletedAt),
        miter_chroma_write_text_atomic(RawPath, RawBody),
        (   HttpStatus =:= 200
        ->  atom_string(RawAtom, RawBody),
            atom_json_dict(RawAtom, Response, []),
            miter_chroma_validate_response(
                Profile, Response, Validation, Details
            ),
            miter_chroma_finish_embedding(
                Validation, Details, ProfileId, ModelId, Dimension,
                Tolerance, ChunkingVersion, DistanceMetric,
                CollectionSchemaVersion, Input, HttpStatus,
                StartedAt, CompletedAt, MetadataPath, Result
            )
        ;   Result = 'lm-studio-embedding-http-error'
        )
    ).

miter_chroma_finish_embedding('embedding-valid', Details, ProfileId, ModelId,
                               Dimension, Tolerance, ChunkingVersion,
                               DistanceMetric, CollectionSchemaVersion, Input,
                               HttpStatus, StartedAt, CompletedAt,
                               MetadataPath, 'embedding-vector-stored') :-
    get_dict(vector_sha256, Details, VectorHash),
    get_dict(l2_norm, Details, Norm),
    crypto_data_hash(Input, InputHash,
                     [algorithm(sha256), encoding(utf8)]),
    DurationMs is round((CompletedAt - StartedAt) * 1000),
    Metadata = _{
        schema:'miter-embedding-vector-metadata-v1',
        profile_id:ProfileId,
        model_id:ModelId,
        dimension:Dimension,
        normalization:_{policy:'provider-l2-unit',
                        observed_l2_norm:Norm,
                        tolerance:Tolerance},
        chunking_version:ChunkingVersion,
        distance_metric:DistanceMetric,
        collection_schema_version:CollectionSchemaVersion,
        input_sha256:InputHash,
        vector_sha256:VectorHash,
        http_status:HttpStatus,
        duration_ms:DurationMs
    },
    miter_chroma_write_json_atomic(MetadataPath, Metadata),
    !.
miter_chroma_finish_embedding(Validation, _, _, _, _, _, _, _, _, _, _, _,
                               _, _, _, Validation).

miter_chroma_validate_embedding_response_checked(ProfilePath, RawPath,
                                                  Result) :-
    (   exists_file(ProfilePath),
        exists_file(RawPath)
    ->  miter_chroma_read_json(ProfilePath, Profile),
        miter_chroma_profile(Profile, _, _, _, _, _, _, _, _),
        miter_chroma_read_json(RawPath, Response),
        miter_chroma_validate_response(Profile, Response, Result, _)
    ;   Result = 'embedding-validation-input-unavailable'
    ).

miter_chroma_validate_response(Profile, Response, Result, Details) :-
    miter_chroma_profile(Profile, _, ModelId, ExpectedDimension, Tolerance,
                         _, _, _, _),
    (   miter_chroma_response_vector(Response, ProviderModelId, Vector)
    ->  (   ProviderModelId \== ModelId
        ->  Result = 'embedding-provider-model-mismatch',
            Details = _{}
        ;   length(Vector, ObservedDimension),
            (   ObservedDimension =\= ExpectedDimension
            ->  Result = 'embedding-dimension-mismatch',
                Details = _{expected_dimension:ExpectedDimension,
                            observed_dimension:ObservedDimension}
            ;   maplist(miter_chroma_finite_number, Vector)
            ->  miter_chroma_l2_norm(Vector, Norm),
                Difference is abs(Norm - 1.0),
                (   Difference =< Tolerance
                ->  term_string(Vector, VectorText,
                                [quoted(true), numbervars(true)]),
                    crypto_data_hash(
                        VectorText, VectorHash,
                        [algorithm(sha256), encoding(utf8)]
                    ),
                    Result = 'embedding-valid',
                    Details = _{dimension:ObservedDimension,
                                l2_norm:Norm,
                                vector_sha256:VectorHash}
                ;   Result = 'embedding-normalization-mismatch',
                    Details = _{observed_l2_norm:Norm,
                                tolerance:Tolerance}
                )
            ;   Result = 'embedding-vector-invalid',
                Details = _{}
            )
        )
    ;   Result = 'malformed-embedding-response',
        Details = _{}
    ).

miter_chroma_profile(Profile, ProfileId, ModelId, Dimension, Tolerance,
                      Endpoint, ChunkingVersion, DistanceMetric,
                      CollectionSchemaVersion) :-
    is_dict(Profile),
    get_dict(schema, Profile, Schema0),
    miter_chroma_nonempty_atom(Schema0, Schema),
    Schema == 'miter-embedding-profile-v1',
    get_dict(profile_id, Profile, ProfileId0),
    miter_chroma_nonempty_atom(ProfileId0, ProfileId),
    ProfileId == 'embedding-local',
    get_dict(model_id, Profile, ModelId0),
    miter_chroma_nonempty_atom(ModelId0, ModelId),
    get_dict(dimension, Profile, Dimension),
    integer(Dimension),
    Dimension > 0,
    get_dict(normalization, Profile, Normalization),
    is_dict(Normalization),
    get_dict(policy, Normalization, Policy0),
    miter_chroma_nonempty_atom(Policy0, Policy),
    Policy == 'provider-l2-unit',
    get_dict(l2_tolerance, Normalization, Tolerance),
    number(Tolerance),
    Tolerance > 0,
    Tolerance < 0.01,
    get_dict(chunking, Profile, Chunking),
    is_dict(Chunking),
    get_dict(version, Chunking, ChunkingVersion0),
    miter_chroma_nonempty_atom(ChunkingVersion0, ChunkingVersion),
    get_dict(distance_metric, Profile, DistanceMetric0),
    miter_chroma_nonempty_atom(DistanceMetric0, DistanceMetric),
    DistanceMetric == cosine,
    get_dict(collection_schema_version, Profile, CollectionSchemaVersion0),
    miter_chroma_nonempty_atom(
        CollectionSchemaVersion0, CollectionSchemaVersion
    ),
    get_dict(service, Profile, Service),
    is_dict(Service),
    get_dict(endpoint, Service, Endpoint0),
    miter_chroma_nonempty_atom(Endpoint0, Endpoint),
    miter_chroma_local_embedding_endpoint(Endpoint),
    !.
miter_chroma_profile(_, _, _, _, _, _, _, _, _) :-
    throw(error(miter_invalid_embedding_profile, _)).

miter_chroma_resolve_local_profile(ConfigPath, Alias, ModelId) :-
    miter_chroma_read_json(ConfigPath, Config),
    get_dict(schema, Config, Schema0),
    miter_chroma_nonempty_atom(Schema0, Schema),
    Schema == 'miter-local-model-profiles-v1',
    get_dict(profiles, Config, Profiles),
    is_list(Profiles),
    findall(
        Candidate,
        ( member(Profile, Profiles),
          is_dict(Profile),
          get_dict(alias, Profile, Alias0),
          miter_chroma_nonempty_atom(Alias0, StoredAlias),
          StoredAlias == Alias,
          get_dict(id, Profile, Candidate0),
          miter_chroma_nonempty_atom(Candidate0, Candidate)
        ),
        Matches
    ),
    Matches = [ModelId],
    !.
miter_chroma_resolve_local_profile(_, _, _) :-
    throw(error(miter_embedding_profile_unresolved, _)).

miter_chroma_response_vector(Response, ModelId, Vector) :-
    is_dict(Response),
    get_dict(model, Response, ModelId0),
    miter_chroma_nonempty_atom(ModelId0, ModelId),
    get_dict(data, Response, [Item]),
    is_dict(Item),
    get_dict(index, Item, 0),
    get_dict(embedding, Item, Vector),
    is_list(Vector),
    Vector \== [].

miter_chroma_finite_number(Number) :-
    number(Number),
    (   integer(Number)
    ->  true
    ;   float_class(Number, Class),
        memberchk(Class, [normal, subnormal, zero])
    ).

miter_chroma_l2_norm(Vector, Norm) :-
    foldl(miter_chroma_add_square, Vector, 0.0, Sum),
    Norm is sqrt(Sum).

miter_chroma_add_square(Value, Accumulator, Sum) :-
    Sum is Accumulator + (Value * Value).

miter_chroma_local_embedding_endpoint(Endpoint) :-
    uri_components(
        Endpoint,
        uri_components(http, Authority, '/v1/embeddings', Search, Fragment)
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

miter_chroma_http_post_raw(Endpoint, ProviderBody, HttpStatus, RawBody) :-
    setup_call_cleanup(
        http_open(
            Endpoint,
            Stream,
            [ method(post),
              post(json(ProviderBody)),
              status_code(HttpStatus),
              timeout(300),
              request_header('Accept'='application/json')
            ]
        ),
        read_string(Stream, _, RawBody),
        close(Stream)
    ).

miter_chroma_read_json(Path, Dict) :-
    setup_call_cleanup(
        open(Path, read, Stream, [encoding(utf8)]),
        json_read_dict(Stream, Dict),
        close(Stream)
    ).

miter_chroma_write_json_atomic(Path, Dict) :-
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

miter_chroma_write_text_atomic(Path, Text) :-
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

miter_chroma_nonempty_atom(Value, Atom) :-
    (   atom(Value)
    ->  Atom = Value
    ;   string(Value)
    ->  atom_string(Atom, Value)
    ),
    atom_length(Atom, Length),
    Length > 0.

miter_chroma_nonempty_string(Value, String) :-
    (   string(Value)
    ->  String = Value
    ;   atom(Value)
    ->  atom_string(Value, String)
    ),
    string_length(String, Length),
    Length > 0.

miter_chroma_exception_result(error(socket_error(_, _), _),
                               'embedding-service-unavailable') :- !.
miter_chroma_exception_result(error(timeout_error(_, _), _),
                               'embedding-service-unavailable') :- !.
miter_chroma_exception_result(error(miter_invalid_embedding_profile, _),
                               'invalid-embedding-profile') :- !.
miter_chroma_exception_result(error(miter_embedding_profile_unresolved, _),
                               'embedding-profile-unresolved') :- !.
miter_chroma_exception_result(error(permission_error(_, _, _), _),
                               'embedding-output-write-error') :- !.
miter_chroma_exception_result(error(existence_error(_, _), _),
                               'embedding-input-unavailable') :- !.
miter_chroma_exception_result(_, 'embedding-membrane-error').
