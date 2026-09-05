% AMA-1.2 bounded semantic-memory observation membrane.
%
% This layer verifies controlled-fixture bytes, exact scope, source identity,
% lineage, and declared standing.  It does not rank memories, interpret their
% meaning, choose a continuation, or grant contact/movement authority.  The
% resulting participant contributions must re-enter the native constitutive
% organization before they can affect cognition.

:- ensure_loaded('miter_store.pl').
:- ensure_loaded('miter_assistant_continuity_v1.pl').
:- use_module(library(crypto)).
:- use_module(library(http/json)).
:- use_module(library(lists)).
:- use_module(library(pairs)).

miter_assistant_semantic_restore(Root0, Result) :-
    catch(
      catch(miter_assistant_semantic_restore_with_reason(Root0, Result),
        miter_assistant_semantic_hold(Reason),
        Result=['semantic-source-set-held',Reason]),
      _, Result=['semantic-source-set-held',
                 'unexpected-mechanical-validation-failure']), !.

miter_assistant_semantic_restore_with_reason(Root0, Result) :-
    ( miter_assistant_semantic_restore_checked(Root0, Result0)
    -> Result=Result0
    ;  Result=['semantic-source-set-held','semantic-source-invalid']
    ).

miter_assistant_semantic_restore_checked(Root0,
    ['semantic-source-set-v1',Projections]) :-
    miter_assistant_semantic_require(
      (miter_store_nonempty_atom(Root0, Root), is_absolute_file_name(Root),
       exists_directory(Root)), 'runtime-root-unavailable'),
    directory_file_path(Root, 'scope-bindings.json', SourcePath),
    miter_assistant_semantic_require(
      (exists_file(SourcePath), miter_store_read_json(SourcePath, Document),
       miter_assistant_bindings_document(Document, Bindings)),
      'scope-binding-document-invalid'),
    miter_assistant_semantic_require(
      (get_dict(semantic_sources, Document, Sources), is_list(Sources)),
      'semantic-source-registry-invalid'),
    maplist(miter_assistant_semantic_source(Bindings), Sources, Projections),
    miter_assistant_semantic_projection_ids_unique(Projections).

miter_assistant_semantic_source(Bindings, Source,
    ['semantic-projection-v1',Scope,
     ['semantic-index-observation',SourceId,Collection,EmbeddingProfile,
      Standing,Reason,QueryId,ObservationHash,'rank-not-authority'],
     ['semantic-participants',Participants],
     ['semantic-source-lineage',SourceId,QueryId,ObservationHash,
      'controlled-fixture-only']]) :-
    miter_assistant_semantic_require(is_dict(Source),
      'semantic-source-record-malformed'),
    miter_assistant_semantic_require(
      (miter_assistant_semantic_exact_keys(Source,
        [observation_path,observation_sha256,principal,audience,project,source_id]),
       miter_assistant_dict_symbol(Source, source_id, SourceId),
       miter_assistant_dict_symbol(Source, principal, Principal),
       miter_assistant_dict_symbol(Source, audience, Audience),
       miter_assistant_dict_symbol(Source, project, Project)),
      'semantic-source-record-malformed'),
    Scope=[scope,Principal,Audience,Project],
    miter_assistant_semantic_require(
      miter_assistant_source_scope_bound(Bindings, Scope),
      'semantic-source-scope-unbound'),
    miter_assistant_semantic_require(
      (get_dict(observation_path, Source, Path0),
       miter_store_nonempty_atom(Path0, ObservationPath),
       is_absolute_file_name(ObservationPath), exists_file(ObservationPath)),
      'semantic-observation-unavailable'),
    miter_assistant_semantic_require(
      (get_dict(observation_sha256, Source, Hash0),
       miter_store_nonempty_atom(Hash0, ObservationHash),
       miter_assistant_semantic_sha256(ObservationHash)),
      'semantic-observation-hash-invalid'),
    crypto_file_hash(ObservationPath, ObservedHash,
      [algorithm(sha256),encoding(octet)]),
    miter_assistant_semantic_require(ObservedHash==ObservationHash,
      'semantic-observation-hash-mismatch'),
    miter_assistant_semantic_require(
      miter_store_read_json(ObservationPath, Observation),
      'semantic-observation-json-invalid'),
    miter_assistant_semantic_observation(Observation, SourceId, Scope,
      Collection, EmbeddingProfile, Standing, Reason, QueryId, Participants0),
    maplist(miter_assistant_semantic_bind_observation(
      SourceId,ObservationHash), Participants0, Participants).

miter_assistant_semantic_observation(Observation, SourceId,
    [scope,Principal,Audience,Project], Collection, EmbeddingProfile,
    Standing, Reason, QueryId, Participants) :-
    miter_assistant_semantic_require(
      (is_dict(Observation),
       miter_assistant_semantic_exact_keys(Observation,
         [schema,source_id,principal,audience,project,collection,
          embedding_profile,standing,reason,query_id,results]),
       miter_assistant_expect_symbol(Observation, schema,
         'miter-assistant-semantic-observation-v1'),
       miter_assistant_dict_symbol(Observation, source_id, SourceId),
       miter_assistant_dict_symbol(Observation, principal, Principal),
       miter_assistant_dict_symbol(Observation, audience, Audience),
       miter_assistant_dict_symbol(Observation, project, Project),
       miter_assistant_dict_symbol(Observation, collection, Collection),
       miter_assistant_dict_symbol(Observation, embedding_profile,
         EmbeddingProfile),
       miter_assistant_dict_symbol(Observation, standing, Standing),
       memberchk(Standing,[available,unavailable,degraded,incompatible]),
       miter_assistant_dict_symbol(Observation, reason, Reason),
       miter_assistant_dict_symbol(Observation, query_id, QueryId),
       get_dict(results, Observation, Results), is_list(Results)),
      'semantic-observation-schema-or-scope-invalid'),
    ( Standing==available ->
        maplist(miter_assistant_semantic_result(
          [scope,Principal,Audience,Project]), Results, Participants),
        miter_assistant_semantic_result_ids_unique(Participants)
    ; miter_assistant_semantic_require(Results==[],
        'nonavailable-semantic-source-carried-results'),
      Participants=[]
    ).

miter_assistant_semantic_result(Scope, Result,
    ['participant-contribution',MemoryId,memory,Scope,Lineage,
     ['participant-relation-claim',Target,Proposed,Evidence],Standing,
     'no-contact-no-movement-authority']) :-
    miter_assistant_semantic_require(
      (is_dict(Result),
       miter_assistant_semantic_exact_keys(Result,
         [memory_id,principal,audience,project,source_kind,source_ref,
          source_sha256,body_ref,body_sha256,lineage,claim,standing])),
      'semantic-result-schema-invalid'),
    Scope=[scope,Principal,Audience,Project],
    miter_assistant_semantic_require(
      (miter_assistant_dict_symbol(Result, memory_id, MemoryId),
       miter_assistant_dict_symbol(Result, principal, Principal),
       miter_assistant_dict_symbol(Result, audience, Audience),
       miter_assistant_dict_symbol(Result, project, Project),
       miter_assistant_dict_symbol(Result, source_kind, SourceKind),
       memberchk(SourceKind,['canonical-memory',episode,'project-material',
         'artifact-excerpt',summary]),
       miter_assistant_dict_symbol(Result, standing, Standing),
       memberchk(Standing,[candidate,supported,contradicted,unresolved]),
       get_dict(lineage, Result, Lineage0), is_list(Lineage0), Lineage0=[_|_],
       maplist(miter_assistant_symbol, Lineage0, LineageAtoms),
       sort(LineageAtoms, UniqueLineage),
       same_length(LineageAtoms, UniqueLineage),
       Lineage=[lineage,SourceKind|LineageAtoms]),
      'semantic-result-scope-lineage-or-standing-invalid'),
    miter_assistant_semantic_verified_file(Result, source_ref, source_sha256,
      'semantic-result-source-unavailable',
      'semantic-result-source-hash-mismatch'),
    miter_assistant_semantic_verified_file(Result, body_ref, body_sha256,
      'semantic-result-body-unavailable',
      'semantic-result-body-hash-mismatch'),
    miter_assistant_semantic_require(
      (get_dict(claim, Result, Claim), is_dict(Claim),
       miter_assistant_semantic_exact_keys(Claim,
         [kind,target,proposed_standing,evidence]),
       miter_assistant_expect_symbol(Claim, kind, relation),
       miter_assistant_dict_symbol(Claim, target, Target),
       miter_assistant_dict_symbol(Claim, proposed_standing, Proposed),
       memberchk(Proposed,[support,contradiction,unresolved]),
       miter_assistant_dict_symbol(Claim, evidence, Evidence)),
      'semantic-result-claim-invalid').

miter_assistant_semantic_verified_file(Result, RefKey, HashKey,
    MissingReason, MismatchReason) :-
    miter_assistant_semantic_require(
      (get_dict(RefKey, Result, Ref0), miter_store_nonempty_atom(Ref0, Ref),
       is_absolute_file_name(Ref), exists_file(Ref)), MissingReason),
    miter_assistant_semantic_require(
      (get_dict(HashKey, Result, Expected0),
       miter_store_nonempty_atom(Expected0, Expected),
       miter_assistant_semantic_sha256(Expected)),
      'semantic-result-hash-invalid'),
    crypto_file_hash(Ref, Actual,[algorithm(sha256),encoding(octet)]),
    miter_assistant_semantic_require(Actual==Expected, MismatchReason).

miter_assistant_semantic_projection_ids_unique(Projections) :-
    findall(Id, member(['semantic-projection-v1',_,
      ['semantic-index-observation',Id|_],_,_], Projections), Ids),
    sort(Ids, Unique),
    miter_assistant_semantic_require(same_length(Ids,Unique),
      'semantic-source-id-duplicate').

miter_assistant_semantic_result_ids_unique(Participants) :-
    findall(Id, member(['participant-contribution',Id|_],Participants), Ids),
    sort(Ids, Unique),
    miter_assistant_semantic_require(same_length(Ids,Unique),
      'semantic-result-id-duplicate').

miter_assistant_semantic_bind_observation(SourceId, ObservationHash,
    ['participant-contribution',MemoryId,memory,Scope,
     [lineage|LineageAtoms],Claim,Standing,Authority],
    ['participant-contribution',MemoryId,memory,Scope,
     [lineage,SourceId,ObservationHash|LineageAtoms],Claim,Standing,Authority]).

miter_assistant_semantic_exact_keys(Dict, Expected) :-
    dict_pairs(Dict, _, Pairs), pairs_keys(Pairs, Keys),
    sort(Keys, SortedKeys), sort(Expected, SortedExpected),
    SortedKeys==SortedExpected.

miter_assistant_semantic_sha256(Hash) :-
    atom_length(Hash,64), atom_codes(Hash,Codes),
    maplist(miter_store_hex_code,Codes).

miter_assistant_semantic_require(Goal, Reason) :-
    ( call(Goal) -> true ; throw(miter_assistant_semantic_hold(Reason)) ).
