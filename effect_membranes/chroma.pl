% Rebuildable semantic-memory projection and retrieval membrane.
%
% MeTTa supplies an exact, provenance-bearing query and later decides whether
% any returned material participates in cognition.  This membrane performs
% only loopback HTTP, embedding, exact-scope filtering, byte/hash validation,
% and projection of already-admitted continuity material.  Chroma order and
% distance never grant contact, evidential, movement, or action authority.

:- ensure_loaded('store.pl').
:- ensure_loaded('runtime_continuity.pl').
:- use_module(library(crypto)).
:- use_module(library(http/http_open)).
:- use_module(library(http/http_json)).
:- use_module(library(http/json)).
:- use_module(library(lists)).
:- use_module(library(pcre)).
:- use_module(library(pairs)).

as_chroma(Root0, Question, Observation) :-
    catch(
      catch(miter_chroma_query_checked(Root0,Question,Observation0),
        miter_chroma_hold(Reason),
        miter_chroma_unavailable(Question,Reason,Observation0)),
      _, miter_chroma_unavailable(Question,
        'unexpected-mechanical-boundary-failure',Observation0)),
    Observation=Observation0, !.

miter_chroma_query_checked(Root0, Question, Observation) :-
    miter_chroma_root(Root0,Root), ground(Question), acyclic_term(Question),
    miter_chroma_question(Question,QuestionReference,Scope,Text,MaxResults),
    miter_runtime_continuity_term_hash(Question,QueryHash),
    miter_chroma_config(Root,Config),
    miter_chroma_require(Config.enabled==true,'semantic-memory-disabled'),
    miter_chroma_runtime_id(Root,RuntimeId),
    miter_chroma_require(MaxResults=<Config.query.max_results,
      'semantic-memory-query-envelope-exceeded'),
    miter_chroma_query_path(Root,QueryHash,ObservationPath),
    ( exists_file(ObservationPath),
      catch(miter_store_read_json(ObservationPath,Cached),_,fail),
      catch(miter_chroma_observation_term(Root,Config,QuestionReference,Scope,
        QueryHash,Cached,Observation),_,fail)
    -> true
    ; miter_chroma_collection(Config,Collection),
      miter_chroma_embedding(Config,Text,Embedding),
      miter_chroma_query_collection(Config,Collection,RuntimeId,Scope,Embedding,
        MaxResults,Reply),
      miter_chroma_query_observation(Root,Config,RuntimeId,QuestionReference,Scope,
        QueryHash,Reply,Document),
      miter_store_write_json_atomic(ObservationPath,Document),
      miter_chroma_observation_term(Root,Config,QuestionReference,Scope,
        QueryHash,Document,Observation)
    ).

miter_chroma_unavailable(Question, Reason,
    ['c4-memory-observation-unavailable-v1',QuestionReference,Scope,
     'chroma-local',Reason,'no-candidate-admitted']) :-
    ( catch(miter_chroma_question(Question,QuestionReference,Scope,_,_),_,fail)
    -> true
    ; QuestionReference=['question-reference','unknown-contact',
        'continuity-recall'], Scope=['scope','unknown-principal',
        'unknown-audience','unknown-project'] ).

miter_chroma_question(
    ['c4-memory-query-v1',QuestionReference,Scope,
     ['exact-contact-text',ContentHash,Text,RawReference],
     ['query-contract','scoped-continuity-candidates','rank-not-authority',
       'no-contact-no-authority-no-choice'],
     ['resource-request','chroma-local',MaxResults]],
    QuestionReference,Scope,Text,MaxResults) :-
    QuestionReference=['question-reference',ContactId,'continuity-recall'],
    miter_chroma_symbol(ContactId), miter_chroma_scope(Scope),
    miter_chroma_sha256(ContentHash), string(Text),
    string_length(Text,Length), Length>=1, Length=<32768,
    crypto_data_hash(Text,ContentHash,[algorithm(sha256),encoding(utf8)]),
    miter_chroma_relative_reference(RawReference),
    integer(MaxResults), MaxResults>=1, MaxResults=<16.

miter_chroma_config(Root,Config) :-
    directory_file_path(Root,'semantic-memory.json',Path),
    miter_chroma_require(exists_file(Path),'semantic-memory-config-unavailable'),
    miter_chroma_require(miter_store_read_json(Path,Config),
      'semantic-memory-config-invalid'),
    miter_chroma_require(
      (is_dict(Config),
       miter_chroma_exact_keys(Config,[chroma,embedding,enabled,human_editable,
         operator_notes,projection,query,schema]),
       Config.schema=="miter-semantic-memory-config-v1",
       Config.human_editable==true, memberchk(Config.enabled,[true,false]),
       miter_chroma_exact_keys(Config.chroma,
         [collection,database,distance,origin,origin_policy,tenant]),
       Config.chroma.origin_policy=="loopback-only",
       miter_chroma_loopback_origin(Config.chroma.origin),
       miter_chroma_name(Config.chroma.tenant),
       miter_chroma_name(Config.chroma.database),
       miter_chroma_name(Config.chroma.collection),
       Config.chroma.distance=="cosine",
       miter_chroma_exact_keys(Config.embedding,
         [dimension,endpoint,endpoint_policy,model]),
       Config.embedding.endpoint_policy=="loopback-only",
       miter_chroma_loopback_embedding(Config.embedding.endpoint),
       miter_chroma_name(Config.embedding.model),
       integer(Config.embedding.dimension), Config.embedding.dimension==768,
       miter_chroma_exact_keys(Config.query,
         [max_body_characters,max_results]),
       integer(Config.query.max_results), Config.query.max_results>=1,
       Config.query.max_results=<15,
       integer(Config.query.max_body_characters),
       Config.query.max_body_characters>=256,
       Config.query.max_body_characters=<32768,
       miter_chroma_exact_keys(Config.projection,[authority,include,source]),
       Config.projection.source=="native-continuity-capsules-only",
       Config.projection.authority==
         "rebuildable-projection-never-continuity-authority",
       Config.projection.include==
         ["exact-human-contact","certified-delivered-expression"],
       is_list(Config.operator_notes), maplist(string,Config.operator_notes),
       miter_chroma_secret_free(Config)),
      'semantic-memory-config-invalid').

miter_chroma_collection(Config,Collection) :-
    miter_chroma_collection_url(Config,Url),
    miter_chroma_get_json(Url,Status,Reply),
    ( Status==200 -> Collection=Reply
    ; Status==404 -> miter_chroma_create_collection(Config,Collection)
    ; miter_chroma_throw('chroma-collection-unavailable') ),
    miter_chroma_validate_collection(Config,Collection).

miter_chroma_create_collection(Config,Collection) :-
    miter_chroma_collections_url(Config,Url),
    Body=_{name:Config.chroma.collection,get_or_create:true,
      metadata:_{schema:"miter-cleanroom-continuity-v1",
        authority:"rebuildable-projection-never-continuity-authority",
        embedding_model:Config.embedding.model,
        embedding_dimension:Config.embedding.dimension,
        distance:"cosine"},
      configuration:_{hnsw:_{space:"cosine"}}},
    miter_chroma_post_json(Url,Body,Status,Reply),
    miter_chroma_require(memberchk(Status,[200,201]),
      'chroma-collection-create-failed'),
    Collection=Reply.

miter_chroma_validate_collection(Config,Collection) :-
    miter_chroma_require(
      (is_dict(Collection),
       miter_store_nonempty_atom(Collection.id,CollectionId),
       re_match('^[0-9a-f-]{36}$',CollectionId),
       Collection.name==Config.chroma.collection,
       (Collection.dimension==null;
        Collection.dimension==Config.embedding.dimension),
       is_dict(Collection.metadata),
       Collection.metadata.schema=="miter-cleanroom-continuity-v1",
       Collection.metadata.authority==
         "rebuildable-projection-never-continuity-authority",
       Collection.metadata.embedding_model==Config.embedding.model,
       Collection.metadata.embedding_dimension==Config.embedding.dimension,
       Collection.metadata.distance=="cosine"),
      'chroma-collection-incompatible').

miter_chroma_embedding(Config,Text,Embedding) :-
    Body=_{model:Config.embedding.model,input:Text},
    miter_chroma_post_json(Config.embedding.endpoint,Body,Status,Reply),
    miter_chroma_require(Status==200,'embedding-http-failure'),
    miter_chroma_require(
      (is_dict(Reply),get_dict(data,Reply,[Row]),is_dict(Row),
       get_dict(embedding,Row,Embedding),is_list(Embedding),
       length(Embedding,Config.embedding.dimension),maplist(number,Embedding)),
      'embedding-response-invalid').

miter_chroma_query_collection(Config,Collection,RuntimeId,
    ['scope',Principal,Audience,Project],Embedding,MaxResults,Reply) :-
    miter_store_nonempty_atom(Collection.id,CollectionId),
    miter_chroma_collection_action_url(Config,CollectionId,query,Url),
    atom_string(Principal,PrincipalString), atom_string(Audience,AudienceString),
    atom_string(Project,ProjectString),atom_string(RuntimeId,RuntimeIdString),
    Where=_{'$and':[
      _{runtime_id:_{'$eq':RuntimeIdString}},
      _{principal:_{'$eq':PrincipalString}},
      _{audience:_{'$eq':AudienceString}},
      _{project:_{'$eq':ProjectString}}]},
    Body=_{query_embeddings:[Embedding],n_results:MaxResults,where:Where,
      include:["documents","metadatas","distances"]},
    miter_chroma_post_json(Url,Body,Status,Reply),
    miter_chroma_require(Status==200,'chroma-query-http-failure'),
    miter_chroma_require(is_dict(Reply),'chroma-query-response-invalid').

miter_chroma_query_observation(Root,Config,RuntimeId,QuestionReference,Scope,
    QueryHash,Reply,Document) :-
    miter_chroma_require(
      (get_dict(ids,Reply,[Ids]),get_dict(documents,Reply,[Documents]),
       get_dict(metadatas,Reply,[Metadatas]),
       get_dict(distances,Reply,[Distances]),
       is_list(Ids),is_list(Documents),is_list(Metadatas),is_list(Distances),
       same_length(Ids,Documents),same_length(Ids,Metadatas),
       same_length(Ids,Distances)),
      'chroma-query-response-invalid'),
    miter_chroma_result_documents(Root,RuntimeId,Scope,
      Config.query.max_body_characters,Ids,Documents,Metadatas,Distances,
      Results),
    ( Results==[] -> Standing="unavailable", Reason="no-scoped-match"
    ; Standing="available", Reason="scope-and-capsule-verified" ),
    term_string(QuestionReference,QuestionReferenceText,
      [quoted(true),ignore_ops(true)]),
    Scope=['scope',Principal,Audience,Project],
    atom_string(Principal,PrincipalString), atom_string(Audience,AudienceString),
    atom_string(Project,ProjectString), atom_string(QueryHash,QueryHashString),
    atom_string(RuntimeId,RuntimeIdString),
    Document=_{schema:"miter-chroma-query-observation-v1",
      runtime_id:RuntimeIdString,
      question_reference:QuestionReferenceText,principal:PrincipalString,
      audience:AudienceString,project:ProjectString,
      collection:Config.chroma.collection,
      embedding_profile:"lm-studio-nomic-embed-v1.5",
      query_sha256:QueryHashString,standing:Standing,reason:Reason,
      results:Results,authority:"rank-not-authority"}.

miter_chroma_result_documents(_,_,_,_,[],[],[],[],[]).
miter_chroma_result_documents(Root,RuntimeId,Scope,MaxBody,[Id0|Ids],
    [Body|Bodies],[Metadata|Metadatas],[Distance|Distances],[Result|Results]) :-
    miter_chroma_result_document(Root,RuntimeId,Scope,MaxBody,Id0,Body,Metadata,
      Distance,Result),
    miter_chroma_result_documents(Root,RuntimeId,Scope,MaxBody,Ids,Bodies,
      Metadatas,Distances,Results).

miter_chroma_result_document(Root,RuntimeId,
    ['scope',Principal,Audience,Project],MaxBody,Id0,Body,Metadata,Distance,
    Result) :-
    miter_chroma_require(
      (miter_store_nonempty_atom(Id0,MemoryId),miter_chroma_symbol(MemoryId),
       integer(MaxBody),MaxBody>=256,MaxBody=<32768,
       string(Body),string_length(Body,BodyLength),BodyLength>=1,
       BodyLength=<MaxBody,
       is_dict(Metadata),number(Distance),Distance>= -0.001,Distance=<2.001,
       miter_store_nonempty_atom(Metadata.runtime_id,RuntimeId),
       miter_store_nonempty_atom(Metadata.principal,Principal),
       miter_store_nonempty_atom(Metadata.audience,Audience),
       miter_store_nonempty_atom(Metadata.project,Project),
       miter_store_nonempty_atom(Metadata.memory_id,MemoryId),
       miter_store_nonempty_atom(Metadata.source_kind,SourceKind),
       memberchk(SourceKind,['human-contact','certified-expression']),
       miter_store_nonempty_atom(Metadata.source_ref,SourceReference),
       miter_chroma_relative_capsule_reference(SourceReference),
       miter_store_nonempty_atom(Metadata.source_sha256,SourceFileHash),
       miter_chroma_sha256(SourceFileHash),
       miter_store_nonempty_atom(Metadata.capsule_sha256,CapsuleHash),
       miter_chroma_sha256(CapsuleHash),
       miter_store_nonempty_atom(Metadata.source_key,SourceKey),
       miter_chroma_source_key(SourceKey),
       miter_store_nonempty_atom(Metadata.body_sha256,BodyHash),
       miter_chroma_sha256(BodyHash),
       crypto_data_hash(Body,BodyHash,[algorithm(sha256),encoding(utf8)]),
       miter_store_nonempty_atom(Metadata.snapshot_sha256,SnapshotHash),
       miter_chroma_sha256(SnapshotHash),
       miter_chroma_verified_capsule(Root,SourceReference,SourceFileHash,
         CapsuleHash,['scope',Principal,Audience,Project]),
       miter_chroma_memory_id(RuntimeId,['scope',Principal,Audience,Project],
         SourceKind,SourceKey,BodyHash,MemoryId)),
      'chroma-result-scope-source-or-hash-invalid'),
    atom_string(MemoryId,MemoryIdString),
    atom_string(SourceKind,SourceKindString),
    atom_string(SourceReference,SourceReferenceString),
    atom_string(SourceKey,SourceKeyString),
    atom_string(RuntimeId,RuntimeIdString),
    atom_string(SourceFileHash,SourceFileHashString),
    atom_string(CapsuleHash,CapsuleHashString),
    atom_string(BodyHash,BodyHashString),atom_string(SnapshotHash,SnapshotString),
    Result=_{memory_id:MemoryIdString,source_kind:SourceKindString,
      runtime_id:RuntimeIdString,
      source_ref:SourceReferenceString,source_sha256:SourceFileHashString,
      capsule_sha256:CapsuleHashString,source_key:SourceKeyString,
      body_sha256:BodyHashString,body:Body,
      snapshot_sha256:SnapshotString,distance:Distance}.

miter_chroma_observation_term(Root,Config,QuestionReference,Scope,QueryHash,
    Document,
    ['c4-memory-observation-v1',QuestionReference,Scope,Collection,
     'lm-studio-nomic-embed-v1.5',['standing',Standing],['reason',Reason],
     ['query-sha256',QueryHash],['memories',Memories],'rank-not-authority']) :-
    miter_chroma_require(
      (is_dict(Document),miter_chroma_exact_keys(Document,
        [authority,audience,collection,embedding_profile,principal,project,
         query_sha256,question_reference,reason,results,runtime_id,schema,
         standing]),
       Document.schema=="miter-chroma-query-observation-v1",
       term_string(QuestionReference,ExpectedReference,
         [quoted(true),ignore_ops(true)]),
       Document.question_reference==ExpectedReference,
       miter_chroma_runtime_id(Root,RuntimeId),
       miter_store_nonempty_atom(Document.runtime_id,RuntimeId),
       Scope=['scope',Principal,Audience,Project],
       miter_store_nonempty_atom(Document.principal,Principal),
       miter_store_nonempty_atom(Document.audience,Audience),
       miter_store_nonempty_atom(Document.project,Project),
       miter_store_nonempty_atom(Document.collection,Collection),
       miter_store_nonempty_atom(Config.chroma.collection,Collection),
       Document.embedding_profile=="lm-studio-nomic-embed-v1.5",
       miter_store_nonempty_atom(Document.query_sha256,QueryHash),
       memberchk(Document.standing,["available","unavailable"]),
       miter_store_nonempty_atom(Document.standing,Standing),
       miter_store_nonempty_atom(Document.reason,Reason),
       Document.authority=="rank-not-authority",
       is_list(Document.results),
       (Standing==available -> Document.results=[_|_]
       ; Document.results==[],Reason=='no-scoped-match')),
      'cached-chroma-observation-invalid'),
    maplist(miter_chroma_cached_result_term(Root,Scope,
      Config.query.max_body_characters),Document.results,Memories).

miter_chroma_cached_result_term(Root,Scope,MaxBody,Result,
    ['c4-memory-result-v1',MemoryId,SourceKind,
      ['source-capsule',SourceReference,SourceFileHash,CapsuleHash,
        ['source-occurrence',SourceKey],['runtime-id',RuntimeId]],
      ['body',BodyHash,Body],['snapshot-sha256',SnapshotHash],
      ['distance',Distance,'diagnostic-not-authority'],
      'scope-and-capsule-verified-locally']) :-
    Scope=['scope',Principal,Audience,Project],
    maplist(atom_string,[Principal,Audience,Project],
      [PrincipalString,AudienceString,ProjectString]),
    miter_chroma_runtime_id(Root,RuntimeId),
    miter_chroma_result_document(Root,RuntimeId,Scope,MaxBody,Result.memory_id,
      Result.body,_{memory_id:Result.memory_id,source_kind:Result.source_kind,
        runtime_id:Result.runtime_id,
        source_ref:Result.source_ref,source_sha256:Result.source_sha256,
        capsule_sha256:Result.capsule_sha256,source_key:Result.source_key,
        body_sha256:Result.body_sha256,
        snapshot_sha256:Result.snapshot_sha256,
        principal:PrincipalString,audience:AudienceString,
        project:ProjectString},
      Result.distance,Validated),
    miter_store_nonempty_atom(Validated.memory_id,MemoryId),
    miter_store_nonempty_atom(Validated.source_kind,SourceKind),
    miter_store_nonempty_atom(Validated.source_ref,SourceReference),
    miter_store_nonempty_atom(Validated.source_sha256,SourceFileHash),
    miter_store_nonempty_atom(Validated.capsule_sha256,CapsuleHash),
    miter_store_nonempty_atom(Validated.source_key,SourceKey),
    miter_store_nonempty_atom(Validated.runtime_id,RuntimeId),
    miter_store_nonempty_atom(Validated.body_sha256,BodyHash),
    miter_store_nonempty_atom(Validated.snapshot_sha256,SnapshotHash),
    Body=Validated.body,Distance=Validated.distance.

% Projection runs after the authoritative checkpoint pointer advances. Failure
% can degrade recall but can never roll back or invalidate native continuity.
miter_chroma_project_checkpoint(Root0,Snapshot,SnapshotHash,
    ContinuityRelative,Status) :-
    catch(miter_chroma_project_checkpoint_checked(Root0,Snapshot,SnapshotHash,
      ContinuityRelative,Status0),_,Status0='projection-degraded'),
    Status=Status0, !.

miter_chroma_project_checkpoint_checked(Root0,Snapshot,SnapshotHash,
    ContinuityRelative,Status) :-
    miter_chroma_root(Root0,Root),miter_chroma_sha256(SnapshotHash),
    miter_chroma_relative_reference(ContinuityRelative),
    miter_chroma_config(Root,Config),
    ( Config.enabled==true ->
      miter_runtime_continuity_model(Snapshot,SnapshotHash,Manifest),
      miter_chroma_runtime_id(Root,RuntimeId),
      Manifest=['miter-continuity-manifest-v1',SnapshotHash,References,_,_],
      miter_runtime_continuity_term_hash(Manifest,ManifestHash),
      atomic_list_concat(['continuity/native/manifests/',ManifestHash,'.term'],
        ContinuityRelative),
      miter_chroma_collection(Config,Collection),
      maplist(miter_chroma_project_reference(Root,Config,Collection,RuntimeId,
          SnapshotHash),
        References,Standings),
      Status=['semantic-projection-complete',Standings]
    ; Status='semantic-projection-disabled' ).

miter_chroma_project_reference(Root,Config,Collection,RuntimeId,SnapshotHash,
    ['continuity-capsule-reference',Scope,CapsuleHash,CapsuleRelative],Standing) :-
    miter_chroma_projection_path(Root,CapsuleHash,ReceiptPath),
    directory_file_path(Root,CapsuleRelative,CapsulePath),
    crypto_file_hash(CapsulePath,CapsuleFileHash,
      [algorithm(sha256),encoding(octet)]),
    miter_runtime_continuity_read_factorized(CapsulePath,Capsule),
    miter_runtime_continuity_term_hash(Capsule,CapsuleHash),
    Capsule=['miter-continuity-capsule-v1',Scope|_],
    ( exists_file(ReceiptPath),
      catch(miter_store_read_json(ReceiptPath,Receipt),_,fail),
      miter_chroma_projection_receipt(Receipt,Config,Collection,RuntimeId,
        CapsuleHash,CapsuleFileHash,Standing)
    -> true
    ;
      miter_chroma_projection_materials(Capsule,Config.query.max_body_characters,
        Materials),
      ( Materials==[] -> Standing='no-projectable-material',Count=0
      ; maplist(miter_chroma_projection_record(Config,RuntimeId,Scope,CapsuleHash,
          CapsuleRelative,CapsuleFileHash,SnapshotHash),Materials,Records),
        miter_chroma_upsert_records(Config,Collection,Records),
        Standing=projected,length(Records,Count) ),
      atom_string(CapsuleHash,CapsuleHashString),
      atom_string(CapsuleFileHash,CapsuleFileHashString),
      atom_string(RuntimeId,RuntimeIdString),
      miter_store_nonempty_atom(Collection.id,CollectionId),
      atom_string(CollectionId,CollectionIdString),
      atom_string(Config.chroma.collection,CollectionString),
      atom_string(Standing,StandingString),get_time(Now),
      miter_store_write_json_atomic(ReceiptPath,
        _{schema:"miter-chroma-projection-receipt-v4",
          runtime_id:RuntimeIdString,collection:CollectionString,
          collection_id:CollectionIdString,
          capsule_sha256:CapsuleHashString,
          capsule_file_sha256:CapsuleFileHashString,record_count:Count,
          standing:StandingString,authority:
            "rebuildable-projection-never-continuity-authority",
          observed_at_epoch:Now})
    ).

miter_chroma_projection_receipt(Receipt,Config,Collection,RuntimeId,
    CapsuleHash,CapsuleFileHash,Standing) :-
    is_dict(Receipt),
    miter_chroma_exact_keys(Receipt,
      [authority,capsule_file_sha256,capsule_sha256,collection,collection_id,
       observed_at_epoch,record_count,runtime_id,schema,standing]),
    Receipt.schema=="miter-chroma-projection-receipt-v4",
    Receipt.authority=="rebuildable-projection-never-continuity-authority",
    miter_store_nonempty_atom(Receipt.runtime_id,RuntimeId),
    miter_store_nonempty_atom(Receipt.collection,Config.chroma.collection),
    miter_store_nonempty_atom(Collection.id,CollectionId),
    miter_store_nonempty_atom(Receipt.collection_id,CollectionId),
    miter_store_nonempty_atom(Receipt.capsule_sha256,CapsuleHash),
    miter_store_nonempty_atom(Receipt.capsule_file_sha256,CapsuleFileHash),
    integer(Receipt.record_count),Receipt.record_count>=0,
    number(Receipt.observed_at_epoch),Receipt.observed_at_epoch>0,
    memberchk(Receipt.standing,["projected","no-projectable-material"]),
    miter_store_nonempty_atom(Receipt.standing,Standing),
    (Standing==projected -> Receipt.record_count>0
    ; Receipt.record_count==0).

miter_chroma_projection_materials(Capsule,Max,Materials) :-
    findall(material('human-contact',Body,BodyHash,RawReference),
      (sub_term(['participant-text-claim',ClaimedHash,Body,RawReference,
          'exact-human-utterance-not-movement-authority'],Capsule),
       string(Body),string_length(Body,Length),Length>=1,Length=<Max,
       miter_chroma_source_key(RawReference),
       crypto_data_hash(Body,BodyHash,[algorithm(sha256),encoding(utf8)]),
       ClaimedHash==BodyHash),HumanRows),
    findall(material('certified-expression',Body,BodyHash,ReplyContact),
      (sub_term(['effect-witness-v2',EffectResult,['payload',Certificate],_],Capsule),
       EffectResult=[EffectStanding|_],
       memberchk(EffectStanding,
         ['mattermost-effect-delivered','mattermost-effect-duplicate']),
       sub_term(['mattermost-response',ReplyContact,Body],Certificate),
       miter_chroma_source_key(ReplyContact),string(Body),
       string_length(Body,Length),Length>=1,Length=<Max,
       crypto_data_hash(Body,BodyHash,[algorithm(sha256),encoding(utf8)])),
      ExpressionRows),
    append(HumanRows,ExpressionRows,Rows),sort(Rows,Materials).

miter_chroma_projection_record(Config,RuntimeId,Scope,CapsuleHash,CapsuleRelative,
    CapsuleFileHash,SnapshotHash,
    material(SourceKind,Body,BodyHash,SourceKey),
    record(MemoryId,Body,Metadata,Embedding)) :-
    miter_chroma_memory_id(RuntimeId,Scope,SourceKind,SourceKey,BodyHash,MemoryId),
    miter_chroma_embedding(Config,Body,Embedding),
    Scope=['scope',Principal,Audience,Project],
    maplist(atom_string,
      [MemoryId,RuntimeId,Principal,Audience,Project,SourceKind,SourceKey,
       CapsuleRelative,
       CapsuleFileHash,CapsuleHash,BodyHash,SnapshotHash],
      [MemoryIdString,RuntimeIdString,PrincipalString,AudienceString,ProjectString,
       SourceKindString,SourceKeyString,CapsuleRelativeString,CapsuleFileHashString,
       CapsuleHashString,BodyHashString,SnapshotHashString]),
    Metadata=_{memory_id:MemoryIdString,runtime_id:RuntimeIdString,
      principal:PrincipalString,
      audience:AudienceString,project:ProjectString,source_kind:SourceKindString,
      source_key:SourceKeyString,
      source_ref:CapsuleRelativeString,source_sha256:CapsuleFileHashString,
      capsule_sha256:CapsuleHashString,body_sha256:BodyHashString,
      snapshot_sha256:SnapshotHashString,
      authority:"rebuildable-projection-never-continuity-authority"}.

miter_chroma_upsert_records(Config,Collection,Records) :-
    miter_chroma_records_columns(Records,Ids,Documents,Metadatas,Embeddings),
    miter_store_nonempty_atom(Collection.id,CollectionId),
    miter_chroma_collection_action_url(Config,CollectionId,upsert,Url),
    Body=_{ids:Ids,documents:Documents,metadatas:Metadatas,
      embeddings:Embeddings},
    miter_chroma_post_json(Url,Body,Status,_),
    miter_chroma_require(memberchk(Status,[200,201]),'chroma-upsert-failed').

miter_chroma_record_columns(record(Id,Document,Metadata,Embedding),
    IdString,Document,Metadata,Embedding) :- atom_string(Id,IdString).

miter_chroma_records_columns([],[],[],[],[]).
miter_chroma_records_columns([Record|Records],[Id|Ids],[Document|Documents],
    [Metadata|Metadatas],[Embedding|Embeddings]) :-
    miter_chroma_record_columns(Record,Id,Document,Metadata,Embedding),
    miter_chroma_records_columns(Records,Ids,Documents,Metadatas,Embeddings).

miter_chroma_memory_id(RuntimeId,Scope,SourceKind,SourceKey,BodyHash,MemoryId) :-
    term_string(['semantic-memory-v1',RuntimeId,Scope,SourceKind,SourceKey,
      BodyHash],Text,
      [quoted(true),ignore_ops(true)]),
    crypto_data_hash(Text,Hash,[algorithm(sha256),encoding(utf8)]),
    atom_concat('memory-',Hash,MemoryId).

miter_chroma_verified_capsule(Root,Relative,FileHash,CapsuleHash,Scope) :-
    directory_file_path(Root,Relative,Path),exists_file(Path),
    crypto_file_hash(Path,FileHash,[algorithm(sha256),encoding(octet)]),
    miter_runtime_continuity_read_factorized(Path,Capsule),
    miter_runtime_continuity_term_hash(Capsule,CapsuleHash),
    Capsule=['miter-continuity-capsule-v1',Scope|_].

miter_chroma_root(Root0,Root) :-
    miter_store_nonempty_atom(Root0,Root),is_absolute_file_name(Root),
    exists_directory(Root),directory_file_path(Root,'runtime.json',Marker),
    exists_file(Marker).

miter_chroma_runtime_id(Root,RuntimeId) :-
    directory_file_path(Root,'runtime.json',Path),miter_store_read_json(Path,Marker),
    Marker.schema=="miter-assistant-runtime-v1",
    miter_store_nonempty_atom(Marker.runtime_id,RuntimeId),
    re_match('^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      RuntimeId).

miter_chroma_query_path(Root,Hash,Path) :-
    atomic_list_concat(['semantic/queries/',Hash,'.json'],Relative),
    directory_file_path(Root,Relative,Path).
miter_chroma_projection_path(Root,Hash,Path) :-
    atomic_list_concat(['semantic/projections/',Hash,'.json'],Relative),
    directory_file_path(Root,Relative,Path).

miter_chroma_collections_url(Config,Url) :-
    format(atom(Url),'~w/api/v2/tenants/~w/databases/~w/collections',
      [Config.chroma.origin,Config.chroma.tenant,Config.chroma.database]).
miter_chroma_collection_url(Config,Url) :-
    miter_chroma_collections_url(Config,Base),
    format(atom(Url),'~w/~w',[Base,Config.chroma.collection]).
miter_chroma_collection_action_url(Config,CollectionId,Action,Url) :-
    miter_chroma_collections_url(Config,Base),
    format(atom(Url),'~w/~w/~w',[Base,CollectionId,Action]).

miter_chroma_get_json(Url,Status,Reply) :-
    setup_call_cleanup(http_open(Url,Stream,
      [status_code(Status),timeout(10),encoding(utf8),
       request_header('Accept'='application/json')]),
      miter_chroma_read_json(Stream,Reply),close(Stream)).
miter_chroma_post_json(Url,Body,Status,Reply) :-
    setup_call_cleanup(http_open(Url,Stream,
      [method(post),post(json(Body)),status_code(Status),timeout(30),
       redirect(false),encoding(utf8),
       request_header('Content-Type'='application/json'),
       request_header('Accept'='application/json')]),
      miter_chroma_read_json(Stream,Reply),close(Stream)).
miter_chroma_read_json(Stream,Reply) :-
    set_stream(Stream,encoding(utf8)),
    read_string(Stream,4194305,Raw),string_length(Raw,Length),Length=<4194304,
    ( Raw=="" -> Reply=_{} ; atom_json_dict(Raw,Reply,[]) ).

miter_chroma_scope(['scope',Principal,Audience,Project]) :-
    maplist(miter_chroma_symbol,[Principal,Audience,Project]).
miter_chroma_symbol(Value) :-
    miter_store_nonempty_atom(Value,Atom),
    re_match('^[A-Za-z][A-Za-z0-9_.:-]{0,127}$',Atom).
miter_chroma_name(Value) :- miter_chroma_symbol(Value).
miter_chroma_sha256(Value) :-
    miter_store_nonempty_atom(Value,Hash),atom_length(Hash,64),
    atom_codes(Hash,Codes),maplist(miter_store_hex_code,Codes).
miter_chroma_relative_reference(Value) :-
    miter_store_nonempty_atom(Value,Reference),\+ is_absolute_file_name(Reference),
    \+ sub_atom(Reference,_,_,_,'..'),\+ sub_atom(Reference,0,1,_,'/').
miter_chroma_relative_capsule_reference(Value) :-
    miter_chroma_relative_reference(Value),miter_store_nonempty_atom(Value,Reference),
    sub_atom(Reference,0,25,_,'continuity/native/scopes/'),
    file_name_extension(_,term,Reference).
miter_chroma_source_key(Value) :-
    miter_store_nonempty_atom(Value,SourceKey),atom_length(SourceKey,Length),
    Length>=1,Length=<512,re_match('^[A-Za-z0-9_.:/-]+$',SourceKey),
    \+ sub_atom(SourceKey,_,_,_,'..').
miter_chroma_loopback_origin(Value) :-
    miter_store_nonempty_atom(Value,Origin),
    re_match('^http://(127\\.0\\.0\\.1|localhost):[0-9]{1,5}$',Origin).
miter_chroma_loopback_embedding(Value) :-
    miter_store_nonempty_atom(Value,Endpoint),
    re_match('^http://(127\\.0\\.0\\.1|localhost):[0-9]{1,5}/v1/embeddings$',
      Endpoint).
miter_chroma_exact_keys(Dict,Expected) :-
    dict_pairs(Dict,_,Pairs),pairs_keys(Pairs,Keys),sort(Keys,Sorted),
    sort(Expected,Sorted).
miter_chroma_secret_free(Dict) :-
    is_dict(Dict),!,dict_pairs(Dict,_,Pairs),
    forall(member(Key-Value,Pairs),
      (\+ memberchk(Key,[api_key,authorization,password,secret,token]),
       miter_chroma_secret_free(Value))).
miter_chroma_secret_free(List) :-
    is_list(List),!,maplist(miter_chroma_secret_free,List).
miter_chroma_secret_free(_).
miter_chroma_require(Goal,Reason) :-
    (call(Goal)->true;throw(miter_chroma_hold(Reason))).
miter_chroma_throw(Reason) :- throw(miter_chroma_hold(Reason)).
