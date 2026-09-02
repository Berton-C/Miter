% Durable memory and index mechanics. All semantic admission/standing decisions
% are made in src/memory.metta, not inferred here from prose or model output.
:- ensure_loaded('miter_chroma_service.pl').
:- ensure_loaded('miter_continuity.pl').

miter_memory_field(Path, Key0, Value) :-
    catch((miter_chroma_read_json(Path, D), miter_chroma_nonempty_atom(Key0, K),
           get_dict(K, D, V), miter_chroma_nonempty_atom(V, Value0)
           -> Value=Value0 ; Value='missing-memory-field'),
          _, Value='malformed-memory-input'), !.

miter_memory_check_sources(Root, Path, Result) :-
    miter_mem_total(miter_mem_sources_file(Root, Path), 'sources-verified', Result).
miter_mem_sources_file(Root, Path) :-
    miter_chroma_read_json(Path, C), miter_mem_sources(Root, C).
miter_mem_sources(Root, C) :-
    miter_store_load_ledger(Root, Lines),
    miter_store_analyze(Root, Lines, A, Events),
    A.status == valid, C.source_event_ids = [_|_],
    forall(member(Id, C.source_event_ids),
           (member(E, Events), E.event_id == Id,
            E.source_principal == C.principal_scope,
            E.audience_scope == C.audience_scope,
            E.project_scope == C.project_scope)),
    ( C.source_capsule_ref == "none" -> true
    ; miter_chroma_read_json(C.source_capsule_ref, Capsule),
      miter_continuity_capsule_valid(Capsule),
      miter_continuity_validate_artifact(Capsule),
      Capsule.capsule_id == C.source_capsule_id,
      Capsule.project_id == C.project_scope,
      Capsule.principal_scope == C.principal_scope,
      Capsule.audience_scope == C.audience_scope ),
    forall(member(Old, C.supersedes_ids), miter_mem_load(Root, Old, _, _)).

miter_memory_persist(Root, Extension, Candidate, Result) :-
    miter_mem_total(miter_mem_persist(Root, Extension, Candidate), 'memory-admitted', Result).
miter_mem_persist(Root, Extension, Candidate) :-
    miter_chroma_read_json(Candidate, C),
    miter_mem_sources(Root, C),
    miter_mem_id(C.memory_id),
    miter_store_ensure_extension(Extension),
    miter_mem_path(Root, 'memories', Directory), make_directory_path(Directory),
    miter_mem_record_path(Root, C.memory_id, RecordPath),
    \+ exists_file(RecordPath),
    crypto_data_hash(C.body, BodyHash, [algorithm(sha256),encoding(utf8)]),
    format(atom(BodyRelative), 'memory-bodies/~w.txt', [BodyHash]),
    miter_mem_path(Root, BodyRelative, BodyPath),
    miter_mem_write_body(BodyPath, C.body),
    Record0 = _{schema_version:"miter-memory-record-v1",memory_id:C.memory_id,
      memory_type:C.memory_type,title:C.title,summary:C.summary,
      body_ref:BodyRelative,body_hash:BodyHash,source_event_ids:C.source_event_ids,
      source_artifact_refs:C.source_artifact_refs,source_capsule_ref:C.source_capsule_ref,
      source_capsule_id:C.source_capsule_id,provenance_kind:C.provenance_kind,
      principal_scope:C.principal_scope,audience_scope:C.audience_scope,
      project_scope:C.project_scope,sensitivity:C.sensitivity,
      created_at:C.created_at,effective_at:C.created_at,last_confirmed_at:C.created_at,
      status:"active",supersedes_ids:C.supersedes_ids,correction_reason:C.correction_reason,
      contradiction_set_id:"none",authority_standing:"admitted-memory",
      embedding_profile_id:"embedding-local",why_later:C.why_later},
    miter_mem_hash(Record0, Hash), Record = Record0.put(content_hash, Hash),
    miter_mem_append_decision(Root, Extension, C, "admitted", Hash),
    miter_mem_write_durable_json(RecordPath, Record).

miter_memory_reject(Root, Extension, Candidate, Decision0, Result) :-
    miter_mem_total((miter_chroma_read_json(Candidate, C),
                    miter_chroma_nonempty_string(Decision0, Decision),
                    sub_string(Decision, 0, _, _, "rejected-"),
                    miter_mem_append_decision(Root, Extension, C, Decision, "none")),
                   'memory-rejected', Result).
miter_mem_append_decision(Root, Extension, C, Decision, Hash) :-
    string_concat("admission-", C.memory_id, EventId),
    Intent = _{schema:"miter-event-intent-v1",event_id:EventId,event_kind:"memory-admission-decision",
      occurred_at:C.created_at,recorded_at:C.created_at,source_surface:"native-MemoryCandidateRNA",
      source_principal:C.principal_scope,audience_scope:C.audience_scope,
      project_scope:C.project_scope,provenance_kind:"native-admission-decision",
      parent_event_ids:C.source_event_ids,correlation_id:C.memory_id,
      payload:_{memory_id:C.memory_id,decision:Decision,content_hash:Hash,
                supersedes_ids:C.supersedes_ids,policy:"src/memory.metta"}},
    miter_mem_aux_path(Root, C.memory_id, 'decision-intent.json', Path),
    miter_cs_write(Path, Intent),
    miter_store_append_event(Root, Extension, Path, R),
    miter_cs_require(R == 'event-appended', 'memory-decision-append-failed').

miter_memory_supersession_count(Root, Id, Count) :-
    catch((miter_mem_all(Root, Records),
           miter_chroma_nonempty_string(Id, IdString),
           findall(New, (member(R, Records), memberchk(IdString, R.supersedes_ids),
                         New=R.memory_id), Refs), length(Refs, Count0) -> Count=Count0 ; Count= -1),
          _, Count= -1), !.

miter_memory_index(Root, Id, Standing0, Result) :-
    miter_mem_total(miter_mem_index(Root, Id, Standing0), 'memory-indexed', Result).
miter_mem_index(Root, Id, Standing0) :-
    miter_chroma_nonempty_string(Standing0, Standing),
    memberchk(Standing, ["active","superseded"]),
    miter_mem_load(Root, Id, R, Body),
    miter_mem_embed(Root, Id, Body, VectorPath),
    miter_mem_metadata(R, Standing, Metadata),
    miter_mem_request_base(Id, "upsert", Q0),
    Q=Q0.put(_{record_id:R.memory_id,document:Body,metadata:Metadata,
               embedding_response_ref:VectorPath}),
    miter_mem_aux_path(Root, Id, 'index-request.json', Request),
    miter_mem_aux_path(Root, Id, 'index-result.json', Output),
    miter_cs_write(Request, Q),
    miter_chroma_service_request('config/chroma-service.json','config/embedding-profile.json',
                                 Request, Output, Result),
    miter_cs_require(Result == 'chroma-record-indexed', Result).

miter_mem_metadata(R, Standing, M) :-
    atomics_to_string(R.source_event_ids, ",", Sources),
    atomics_to_string(R.source_artifact_refs, ",", Artifacts),
    miter_chroma_read_json('config/chroma-service.json', C),
    miter_chroma_read_json('config/embedding-profile.json', P),
    M=_{memory_id:R.memory_id,memory_type:R.memory_type,
        principal_scope:R.principal_scope,audience_scope:R.audience_scope,
        project_scope:R.project_scope,sensitivity:R.sensitivity,standing:Standing,
        source_event_ids:Sources,source_capsule_id:R.source_capsule_id,
        source_artifact_refs:Artifacts,created_at:R.created_at,effective_at:R.effective_at,
        content_hash:R.content_hash,body_hash:R.body_hash,
        embedding_profile_id:R.embedding_profile_id,
        embedding_profile_sha256:C.embedding_profile_sha256,
        embedding_model_id:P.model_id,embedding_dimension:P.dimension,
        normalization:P.normalization.policy,chunking_version:P.chunking.version,
        distance_metric:P.distance_metric,collection_schema_version:P.collection_schema_version}.

miter_memory_query(Root, Principal0, Audience0, Project0, Standing0, Text0, Tag0, Result) :-
    miter_mem_total(miter_mem_query(Root,Principal0,Audience0,Project0,Standing0,Text0,Tag0),
                   'memory-query-verified', Result).
miter_mem_query(Root, Principal0, Audience0, Project0, Standing0, Text0, Tag0) :-
    maplist(miter_chroma_nonempty_string,
            [Principal0,Audience0,Project0,Standing0,Text0,Tag0],
            [Principal,Audience,Project,Standing,Text,Tag]),
    miter_mem_id(Tag),
    miter_mem_embed(Root, Tag, Text, VectorPath),
    % Pure serialization of four explicit MeTTa-selected equality constraints.
    Where=_{'$and':[_{principal_scope:_{'$eq':Principal}},
                    _{audience_scope:_{'$eq':Audience}},
                    _{project_scope:_{'$eq':Project}},
                    _{standing:_{'$eq':Standing}}]},
    miter_mem_request_base(Tag, "query", Q0),
    Q=Q0.put(_{where:Where,n_results:3,embedding_response_ref:VectorPath}),
    miter_mem_aux_path(Root, Tag, 'query-request.json', Request),
    miter_mem_aux_path(Root, Tag, 'query-result.json', Output),
    miter_cs_write(Request, Q),
    miter_chroma_service_request('config/chroma-service.json','config/embedding-profile.json',
                                 Request, Output, R),
    miter_cs_require(R == 'chroma-query-stored', R),
    miter_chroma_read_json(Output, Stored), D=Stored.details,
    D.ids=[Ids], D.metadatas=[Metas], D.documents=[Bodies],
    maplist(miter_mem_verify_hit(Root,Principal,Audience,Project,Standing), Ids,Metas,Bodies),
    miter_mem_aux_path(Root, Tag, 'verified.json', Verified),
    miter_cs_write(Verified, _{schema:"miter-verified-recall-v1",memory_ids:Ids,
                  results:D,source_verification:"durable-record-and-body-hashes",
                  principal_scope:Principal,audience_scope:Audience,project_scope:Project,
                  requested_standing:Standing,retrieval_method:"semantic-with-exact-scope-filter"}).

miter_mem_verify_hit(Root, Principal, Audience, Project, Standing, Id, Meta, Body) :-
    miter_mem_load(Root, Id, Record, StoredBody), Body == StoredBody,
    miter_mem_metadata(Record, Standing, Expected),
    Expected :< Meta, Meta :< Expected,
    Record.principal_scope == Principal, Record.audience_scope == Audience,
    Record.project_scope == Project.

miter_mem_embed(Root, Tag, Text, VectorPath) :-
    miter_mem_aux_path(Root,Tag,'embedding.json',VectorPath),
    miter_mem_aux_path(Root,Tag,'embedding-metadata.json',MetaPath),
    ( exists_file(VectorPath) ->
        miter_chroma_read_json('config/embedding-profile.json',P),
        miter_chroma_read_json(VectorPath,V),
        miter_chroma_validate_response(P,V,'embedding-valid',Details),
        miter_chroma_read_json(MetaPath,M),
        crypto_data_hash(Text,H,[algorithm(sha256),encoding(utf8)]), atom_string(H,HS),
        M.input_sha256 == HS, atom_string(Details.vector_sha256, VH), M.vector_sha256 == VH
    ; miter_chroma_embed_text('config/embedding-profile.json','config/local/g03-model-profiles.json',
                              Text,VectorPath,MetaPath,Result),
      miter_cs_require(Result == 'embedding-vector-stored',Result) ).

miter_mem_request_base(Id0, Operation, Q) :-
    miter_chroma_nonempty_string(Id0,Id),
    miter_chroma_read_json('config/chroma-service.json',C),
    Q=_{schema:"miter-chroma-request-v1",request_id:Id,idempotency_key:Id,
        operation:Operation,endpoint:C.endpoint,embedding_profile_sha256:C.embedding_profile_sha256}.
miter_mem_all(Root, Records) :-
    miter_mem_path(Root, 'memories', Directory),
    directory_files(Directory, Names), include(miter_mem_json_name, Names, Files),
    maplist(miter_mem_load_named(Root,Directory),Files,Records).

miter_memory_record_count(Root, Count) :-
    catch((miter_mem_all(Root,Records),length(Records,N)->Count=N;Count= -1),_,Count= -1),!.
miter_memory_record_id(Root, Index, Id) :-
    catch((miter_mem_all(Root,Records),findall(I,(member(R,Records),I=R.memory_id),Ids),
           sort(Ids,Sorted),nth0(Index,Sorted,V)->Id=V;Id="missing-memory"),_,Id="malformed-memory"),!.
miter_mem_json_name(Name) :- file_name_extension(_, json, Name).
miter_mem_load_named(Root,Directory,Name,Record) :-
    directory_file_path(Directory,Name,Path), miter_chroma_read_json(Path,R),
    miter_mem_load(Root,R.memory_id,Record,_).
miter_mem_load(Root, Id, R, Body) :-
    miter_mem_record_path(Root,Id,Path), miter_chroma_read_json(Path,R),
    miter_cs_require(R.schema_version == "miter-memory-record-v1",'memory-schema-invalid'),
    miter_chroma_nonempty_string(Id,IdString), R.memory_id == IdString,
    del_dict(content_hash,R,HashString,R0), miter_mem_hash(R0,Hash), atom_string(Hash,HashString),
    miter_mem_path(Root,R.body_ref,BodyPath),
    crypto_file_hash(BodyPath,BH,[algorithm(sha256),encoding(octet)]), atom_string(BH,R.body_hash),
    read_file_to_string(BodyPath,Body,[]),
    miter_mem_sources(Root,R).

miter_mem_record_path(Root,Id,Path) :-
    miter_mem_id(Id), format(atom(Rel),'memories/~w.json',[Id]), miter_mem_path(Root,Rel,Path).
miter_mem_aux_path(Root,Id,Suffix,Path) :-
    miter_mem_id(Id), format(atom(Rel),'derived/~w/~w',[Id,Suffix]), miter_mem_path(Root,Rel,Path).
miter_mem_path(Root0,Relative0,Path) :-
    miter_chroma_nonempty_atom(Root0,Root),miter_chroma_nonempty_atom(Relative0,Relative),
    directory_file_path(Root,Relative,Path).
miter_mem_id(Id0) :-
    miter_chroma_nonempty_atom(Id0,Id), atom_chars(Id,Chars),
    Chars=[_|_], forall(member(C,Chars),(char_type(C,alnum);memberchk(C,['_','-']))).
miter_mem_hash(D,Hash) :-
    miter_store_canonical_json(D,Text),crypto_data_hash(Text,Hash,[algorithm(sha256),encoding(utf8)]).
miter_mem_write_body(Path,Text) :-
    ( exists_file(Path) -> read_file_to_string(Path,Existing,[]), Existing == Text
    ; file_directory_name(Path,Dir),make_directory_path(Dir),
      setup_call_cleanup(open(Path,write,S,[encoding(utf8)]),
        (chmod(Path,0o600),format(S,'~s',[Text]),flush_output(S),miter_store_fsync_stream(S)),close(S)) ).
miter_mem_write_durable_json(Path,Dict) :-
    atom_concat(Path,'.tmp',Temp),
    setup_call_cleanup(open(Temp,write,S,[encoding(utf8)]),
      (chmod(Temp,0o600),json_write_dict(S,Dict,[width(0)]),nl(S),
       flush_output(S),miter_store_fsync_stream(S)),close(S)),rename_file(Temp,Path).
miter_mem_total(Goal,Success,Result) :-
    catch((call(Goal)->Result=Success;Result='memory-integrity-failed'),
          Error,miter_mem_error(Error,Result)),!.
miter_mem_error(miter_chroma_error(Error),Error) :- !.
miter_mem_error(_, 'memory-mechanics-error').
