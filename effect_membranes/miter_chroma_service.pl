% Bounded HTTP mechanics. MeTTa owns admission and recall authority.
% Only the pinned Miter endpoint can receive a request; no legacy transport.
:- ensure_loaded('miter_chroma.pl').

% Four scalar artifact references, one total scalar result. Provider bodies
% remain opaque files. Request-local counters are transport diagnostics only.
miter_chroma_service_request(ConfigPath, ProfilePath, RequestPath, OutputPath, Result) :-
    nb_setval(miter_cs_http_count, 0),
    catch((miter_cs_request(ConfigPath, ProfilePath, RequestPath, OutputPath, R)
           -> Result = R ; Result = 'chroma-invalid-request'),
          Error, miter_cs_error(Error, Result)),
    !.

miter_cs_request(ConfigPath, ProfilePath, RequestPath, OutputPath, Result) :-
    maplist(miter_chroma_nonempty_atom,
            [ConfigPath, ProfilePath, RequestPath, OutputPath], [CP, PP, RP, OP]),
    miter_chroma_read_json(CP, Config),
    miter_chroma_read_json(PP, Profile),
    miter_chroma_read_json(RP, Request),
    catch((miter_cs_dispatch(Config, PP, Profile, Request, OP, Result0, Details0)
           -> true
           ; Result0 = 'chroma-invalid-request', Details0 = _{}),
          Error, (miter_cs_error(Error, Result0), Details0 = _{})),
    nb_getval(miter_cs_http_count, Count),
    miter_cs_write(OP, _{schema:"miter-chroma-result-v1", result:Result0,
                        http_requests:Count, details:Details0}),
    Result = Result0.

miter_cs_dispatch(C, PP, P, Q, OP, Result, Details) :-
    miter_cs_config(C),
    miter_cs_require(Q.schema == "miter-chroma-request-v1", 'chroma-invalid-request'),
    miter_cs_require(miter_chroma_nonempty_string(Q.request_id, _), 'chroma-invalid-request'),
    miter_cs_require(miter_chroma_nonempty_string(Q.idempotency_key, _), 'chroma-invalid-request'),
    % These guards run before any network operation, including health checks.
    miter_cs_require(Q.endpoint == C.endpoint, 'chroma-target-blocked'),
    crypto_file_hash(PP, Hash, [algorithm(sha256), encoding(octet)]),
    atom_string(Hash, HashString),
    miter_cs_require(HashString == C.embedding_profile_sha256, 'chroma-profile-mismatch'),
    miter_cs_require(Q.embedding_profile_sha256 == HashString, 'chroma-profile-mismatch'),
    miter_chroma_profile(P, _, _, _, _, _, _, _, _),
    miter_cs_require(memberchk(Q.operation, ["create", "snapshot", "add", "upsert", "query", "get", "list", "delete-disposable"]),
                     'chroma-operation-blocked'),
    % Validate add payload before health/collection queries as well.
    ( memberchk(Q.operation,["add","upsert"]) -> miter_cs_validate_add(P, Q) ; true ),
    ( Q.operation == "query" ->
        miter_chroma_read_json(Q.embedding_response_ref, QR),
        miter_chroma_validate_response(P, QR, QV, _),
        miter_cs_require(QV == 'embedding-valid', QV),
        miter_cs_require((is_dict(Q.where), integer(Q.n_results),
                          between(1, 20, Q.n_results)), 'chroma-query-invalid')
    ; true ),
    miter_cs_http(C, get, '/api/v2/version', none, OP, Version),
    miter_cs_require(Version == C.api_version_response, 'chroma-server-version-mismatch'),
    miter_cs_operation(Q.operation, C, P, Q, OP, Result, Details).

miter_cs_config(C) :-
    miter_cs_require((C.schema == "miter-chroma-service-v1",
                      C.endpoint == "http://127.0.0.1:8001",
                      C.distribution_version == "1.5.9",
                      C.api_version_response == "1.0.0",
                      C.image == "docker.io/chromadb/chroma:1.5.9@sha256:1e0b73a187a28757c572acba508c46f48c9e8b0acaf5c20e6d95cdedce1acdf6",
                      C.tenant == "default_tenant",
                      C.database == "default_database",
                      C.collection == "miter-ltm-v1"), 'chroma-config-invalid').

miter_cs_base('/api/v2/tenants/default_tenant/databases/default_database/collections').

miter_cs_metadata(C, P, Created, M) :-
    M = _{schema_version:P.collection_schema_version,
          embedding_profile_id:P.profile_id,
          embedding_profile_sha256:C.embedding_profile_sha256,
          embedding_model_id:P.model_id, embedding_dimension:P.dimension,
          normalization:P.normalization.policy,
          chunking_algorithm:P.chunking.algorithm,
          chunking_version:P.chunking.version,
          distance_metric:P.distance_metric,
          created_at:Created, source_store_root:C.source_store_root,
          miter_version:C.miter_version, collection_status:"active"}.

miter_cs_operation("create", C, P, Q, OP, 'chroma-collection-created', Collection) :-
    miter_chroma_nonempty_string(Q.created_at, Created),
    miter_cs_metadata(C, P, Created, Metadata),
    Body = _{name:C.collection, metadata:Metadata, get_or_create:false,
             configuration:_{hnsw:_{space:P.distance_metric}}},
    miter_cs_base(Base),
    miter_cs_http(C, post, Base, Body, OP, Collection).
miter_cs_operation("snapshot", C, P, _, OP, 'chroma-snapshot-stored', Details) :-
    miter_cs_base(Base),
    miter_cs_http(C, get, Base, none, OP, Collections),
    miter_cs_get_collection(C, P, OP, Collection),
    format(atom(Path), '~w/~s/count', [Base, Collection.id]),
    miter_cs_http(C, get, Path, none, OP, Count),
    Details = _{collections:Collections, collection:Collection, count:Count}.
miter_cs_operation("add", C, P, Q, OP, 'chroma-record-added', _{record_id:Q.record_id}) :-
    miter_cs_write_record("add", C, P, Q, OP).
miter_cs_operation("upsert", C, P, Q, OP, 'chroma-record-indexed', _{record_id:Q.record_id}) :-
    miter_cs_write_record("upsert", C, P, Q, OP).
miter_cs_operation("query", C, P, Q, OP, 'chroma-query-stored', Response) :-
    miter_cs_get_collection(C, P, OP, Collection),
    miter_chroma_read_json(Q.embedding_response_ref, ER),
    miter_chroma_response_vector(ER, _, Vector),
    miter_cs_base(Base), format(atom(Path), '~w/~s/query', [Base, Collection.id]),
    miter_cs_http(C, post, Path,
        _{query_embeddings:[Vector],where:Q.where,n_results:Q.n_results,
          include:["metadatas","documents","distances"]}, OP, Response).
miter_cs_operation("get", C, P, _, OP, 'chroma-records-stored', Response) :-
    miter_cs_get_collection(C, P, OP, Collection),
    miter_cs_base(Base), format(atom(Path), '~w/~s/get', [Base, Collection.id]),
    miter_cs_http(C, post, Path, _{include:["metadatas","documents"]}, OP, Response).
miter_cs_operation("list", C, _, _, OP, 'chroma-collections-listed', _{collections:Collections}) :-
    miter_cs_base(Base),miter_cs_http(C,get,Base,none,OP,Collections).
miter_cs_operation("delete-disposable", C, P, Q, OP, 'chroma-disposable-collection-deleted', Details) :-
    miter_cs_require(Q.confirm_disposable == true,'chroma-delete-not-confirmed'),
    miter_cs_get_collection(C,P,OP,Collection),
    miter_cs_require(Collection.id == Q.expected_collection_id,'chroma-delete-identity-mismatch'),
    miter_cs_base(Base),format(atom(CountPath),'~w/~s/count',[Base,Collection.id]),
    miter_cs_http(C,get,CountPath,none,OP,Count),
    miter_cs_require(Count == Q.expected_count,'chroma-delete-count-mismatch'),
    format(atom(Path),'~w/~s',[Base,C.collection]),
    miter_cs_http(C,delete,Path,none,OP,_),
    Details=_{collection_id:Collection.id}.

% Request-local probe instruments: transport state, never cognitive state.
miter_chroma_probe_reset('transport-probe-started') :- nb_setval(miter_cs_http_count,0),!.
miter_chroma_probe_report(Path,Result) :-
    catch((nb_getval(miter_cs_http_count,Count),
           miter_cs_write(Path,_{http_requests_observed:Count})
           ->Result='transport-probe-stored';Result='transport-probe-error'),
          _,Result='transport-probe-error'),!.

miter_cs_write_record(Operation, C, P, Q, OP) :-
    miter_cs_get_collection(C, P, OP, Collection),
    miter_chroma_read_json(Q.embedding_response_ref, Response),
    miter_chroma_response_vector(Response, _, Vector),
    miter_cs_base(Base),
    format(atom(Path), '~w/~s/~s', [Base, Collection.id, Operation]),
    Body = _{ids:[Q.record_id], embeddings:[Vector], documents:[Q.document],
             metadatas:[Q.metadata]},
    miter_cs_http(C, post, Path, Body, OP, _).

miter_cs_get_collection(C, P, OP, Collection) :-
    miter_cs_base(Base),
    format(atom(Path), '~w/~s', [Base, C.collection]),
    miter_cs_http(C, get, Path, none, OP, Collection),
    miter_cs_require(Collection.name == C.collection, 'chroma-collection-mismatch'),
    miter_cs_metadata(C, P, Collection.metadata.created_at, Expected),
    miter_cs_require(Collection.metadata :< Expected, 'chroma-collection-profile-mismatch'),
    miter_cs_require(Expected :< Collection.metadata, 'chroma-collection-profile-mismatch'),
    miter_cs_require(Collection.configuration_json.hnsw.space == P.distance_metric,
                     'chroma-distance-mismatch').

miter_cs_validate_add(P, Q) :-
    miter_chroma_nonempty_string(Q.record_id, _),
    miter_chroma_nonempty_string(Q.document, _),
    is_dict(Q.metadata),
    miter_cs_require(Q.metadata.embedding_profile_sha256 == Q.embedding_profile_sha256,
                     'chroma-record-profile-mismatch'),
    miter_chroma_read_json(Q.embedding_response_ref, Response),
    miter_chroma_validate_response(P, Response, Validation, _),
    miter_cs_require(Validation == 'embedding-valid', Validation).

miter_cs_http(C, Method, Path, Body, OP, Response) :-
    atom_string(Endpoint, C.endpoint), atom_concat(Endpoint, Path, URL),
    ( Body == none -> BodyOptions = [] ; BodyOptions = [post(json(Body))] ),
    nb_getval(miter_cs_http_count, Before), After is Before + 1,
    nb_setval(miter_cs_http_count, After),
    setup_call_cleanup(
        http_open(URL, Stream, [method(Method), timeout(20), redirect(false),
                              status_code(Status)|BodyOptions]),
        read_string(Stream, _, Raw), close(Stream)),
    format(atom(RawPath), '~w.http.~d.json', [OP, After]),
    miter_chroma_write_text_atomic(RawPath, Raw),
    miter_cs_require(between(200, 299, Status), 'chroma-http-error'),
    ( Raw == "" -> Response = _{} ; atom_string(A, Raw), atom_json_dict(A, Response, []) ).

miter_cs_write(Path, Dict) :-
    file_directory_name(Path, Directory), make_directory_path(Directory),
    atom_concat(Path, '.tmp', Temp),
    setup_call_cleanup(open(Temp, write, S, [encoding(utf8)]),
                       (chmod(Temp, 0o600), json_write_dict(S, Dict, [width(0)]), nl(S)),
                       close(S)),
    rename_file(Temp, Path).

miter_cs_require(Goal, Error) :- (call(Goal) -> true ; throw(miter_chroma_error(Error))).
miter_cs_error(miter_chroma_error(Error), Error) :- !.
miter_cs_error(error(socket_error(_, _), _), 'chroma-service-unavailable') :- !.
miter_cs_error(error(timeout_error(_, _), _), 'chroma-service-unavailable') :- !.
miter_cs_error(_, 'chroma-membrane-error').
