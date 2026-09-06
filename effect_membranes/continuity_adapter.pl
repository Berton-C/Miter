% Non-cognitive scope and continuity membrane.
% This bounded local-source implementation resolves stable carrier identities to an
% explicit principal/audience/project scope before a payload becomes native
% contact. It does not inspect contact meaning or select a movement.

:- ensure_loaded('store.pl').
:- ensure_loaded('continuity.pl').
:- use_module(library(crypto)).
:- use_module(library(http/json)).
:- use_module(library(lists)).
:- use_module(library(pcre)).

miter_assistant_scope_bind(Root0, Surface, DeclaredScope, Result) :-
    ( catch(miter_assistant_scope_bind_checked(
              Root0, Surface, DeclaredScope, Result0), _, fail)
    -> Result=Result0
    ;  Result=['scope-binding-rejected','malformed-or-unavailable-binding']
    ), !.

miter_assistant_scope_bind_checked(Root0, Surface, DeclaredScope, Result) :-
    miter_store_nonempty_atom(Root0, Root),
    is_absolute_file_name(Root), exists_directory(Root),
    miter_assistant_surface(Surface, Route, EventIdentity),
    miter_assistant_declared_scope(DeclaredScope, Scope),
    directory_file_path(Root, 'scope-bindings.json', BindingsPath),
    miter_store_read_json(BindingsPath, Document),
    miter_assistant_bindings_document(Document, Bindings),
    findall(Binding,
      (member(Candidate, Bindings),
       miter_assistant_binding(Candidate, Route, Scope, Binding)),
      Matches),
    ( Matches=[Only] ->
        Result=['scope-binding-v1',Route,Scope,EventIdentity,
                'authorized-before-payload-cognition',Only]
    ; Matches=[] ->
        Result=['scope-binding-rejected','stable-identity-or-scope-not-authorized']
    ; Result=['scope-binding-rejected','ambiguous-stable-identity-binding']
    ).

miter_assistant_bindings_document(Document, Bindings) :-
    is_dict(Document),
    miter_assistant_expect_symbol(Document, schema,
      'miter-assistant-scope-bindings-v1'),
    miter_assistant_expect_symbol(Document, authority_mode,
      'controlled-fixture-only'),
    get_dict(bindings, Document, Bindings), is_list(Bindings).

miter_assistant_surface(Surface,
    ['surface-route','controlled-fixture',Server,Team,Channel,Principal],
    ['surface-event',Post,Thread,Version]) :-
    is_dict(Surface),
    miter_assistant_expect_symbol(Surface, carrier_kind, 'controlled-fixture'),
    miter_assistant_dict_symbol(Surface, server_id, Server),
    miter_assistant_dict_symbol(Surface, team_id, Team),
    miter_assistant_dict_symbol(Surface, channel_id, Channel),
    miter_assistant_dict_symbol(Surface, principal_id, Principal),
    miter_assistant_dict_symbol(Surface, post_id, Post),
    miter_assistant_dict_symbol(Surface, thread_id, Thread),
    miter_assistant_dict_symbol(Surface, event_version, Version).

miter_assistant_declared_scope(Declared,
    [scope,Principal,Audience,Project]) :-
    is_dict(Declared),
    miter_assistant_dict_symbol(Declared, principal, Principal),
    miter_assistant_dict_symbol(Declared, audience, Audience),
    miter_assistant_dict_symbol(Declared, project, Project).

miter_assistant_binding(Binding,
    ['surface-route','controlled-fixture',Server,Team,Channel,StablePrincipal],
    [scope,Principal,Audience,Project],
    ['binding-record',BindingId,'controlled-fixture']) :-
    is_dict(Binding),
    miter_assistant_dict_symbol(Binding, binding_id, BindingId),
    miter_assistant_expect_symbol(Binding, carrier_kind, 'controlled-fixture'),
    miter_assistant_dict_symbol(Binding, server_id, Server),
    miter_assistant_dict_symbol(Binding, team_id, Team),
    miter_assistant_dict_symbol(Binding, channel_id, Channel),
    miter_assistant_dict_symbol(Binding, principal_id, StablePrincipal),
    miter_assistant_dict_symbol(Binding, principal, Principal),
    miter_assistant_dict_symbol(Binding, audience, Audience),
    miter_assistant_dict_symbol(Binding, project, Project),
    miter_assistant_expect_symbol(Binding, standing, authorized).

miter_assistant_expect_symbol(Dict, Key, Expected) :-
    get_dict(Key, Dict, Value), miter_assistant_symbol(Value, Atom), Atom==Expected.
miter_assistant_dict_symbol(Dict, Key, Atom) :-
    get_dict(Key, Dict, Value), miter_assistant_symbol(Value, Atom).

miter_assistant_symbol(Value, Atom) :-
    miter_store_nonempty_atom(Value, Atom),
    re_match('^[A-Za-z][A-Za-z0-9_.:-]{0,127}$', Atom).

% Four-plane source rehydration. The membrane establishes byte identity,
% canonical sequence, exact capsule selection, artifact hash, and declared
% semantic-index availability. It does not decide how any of them matter.
miter_assistant_continuity_restore(Root0, Result) :-
    catch(
      catch(miter_assistant_continuity_restore_with_reason(Root0, Result),
        miter_assistant_continuity_hold(Reason),
        Result=['continuity-source-set-held',Reason]),
      _, Result=['continuity-source-set-held',
                 'unexpected-mechanical-validation-failure']), !.

miter_assistant_continuity_restore_with_reason(Root0, Result) :-
    ( miter_assistant_continuity_restore_checked(Root0, Result0)
    -> Result=Result0
    ;  Result=['continuity-source-set-held','continuity-source-invalid']
    ).

miter_assistant_continuity_restore_checked(Root0,
    ['continuity-source-set-v1',Projections]) :-
    miter_assistant_continuity_require(
      (miter_store_nonempty_atom(Root0, Root), is_absolute_file_name(Root),
       exists_directory(Root)), 'runtime-root-unavailable'),
    directory_file_path(Root, 'scope-bindings.json', SourcePath),
    miter_assistant_continuity_require(
      (exists_file(SourcePath), miter_store_read_json(SourcePath, Document),
       miter_assistant_bindings_document(Document, Bindings)),
      'scope-binding-document-invalid'),
    miter_assistant_continuity_require(
      (get_dict(continuity_sources, Document, Sources), is_list(Sources)),
      'continuity-source-registry-invalid'),
    maplist(miter_assistant_continuity_source(Bindings), Sources, Projections).

miter_assistant_continuity_source(Bindings, Source,
    ['continuity-projection-v1',Scope,
     ['trajectory-plane',SourceId,HeadId,HeadHash,EventCount,
      'canonical-append-only'],
     ['capsule-plane',CapsuleId,CapsuleHash,ArtifactRef,ArtifactHash,
      ExactLocation,CurrentGoal,LastCompleted,OpenQuestions,LiveTensions,
      NextMovement,Commitments,RelevantEvents,'exact-authoritative'],
     ['raw-artifact-plane',ArtifactRef,ArtifactHash,
      'hash-verified-independent-source'],
     ['semantic-plane',Collection,EmbeddingProfile,SemanticStanding,
      'index-not-authority'],
     ['relationship-organization',Relationships],
     ['undertaking-organization',Undertaking,OpenAlternatives,NextMovement],
     ['attention-organization',Attention,LiveTensions],
     ['rna-organization',RNA,'bounded-renewable'],
     ['pending-consequence-organization',PendingConsequences],
     ['learned-relation-organization',LearnedRelations],
     ['source-lineage',SourceId,CapsuleId,HeadId]]) :-
    miter_assistant_continuity_require(
      (is_dict(Source),
       miter_assistant_dict_symbol(Source, source_id, SourceId),
       miter_assistant_dict_symbol(Source, principal, Principal),
       miter_assistant_dict_symbol(Source, audience, Audience),
       miter_assistant_dict_symbol(Source, project, Project)),
      'continuity-source-record-malformed'),
    Scope=[scope,Principal,Audience,Project],
    miter_assistant_continuity_require(
      miter_assistant_source_scope_bound(Bindings, Scope),
      'continuity-source-scope-unbound'),
    miter_assistant_continuity_require(
      miter_assistant_dict_path(Source, capsule_store, CapsuleStore),
      'continuity-capsule-store-unavailable'),
    miter_assistant_continuity_require(
      miter_assistant_dict_path(Source, trajectory_store, TrajectoryStore),
      'continuity-trajectory-store-unavailable'),
    miter_assistant_continuity_require(
      miter_assistant_current_capsule_candidate(CapsuleStore, Scope, Capsule),
      'current-capsule-invalid-or-unavailable'),
    miter_assistant_continuity_artifact_check(Capsule),
    miter_assistant_continuity_require(
      catch(miter_assistant_current_capsule(CapsuleStore, Scope, Capsule),_,fail),
      'current-capsule-invalid-or-unavailable'),
    miter_assistant_continuity_require(
      miter_assistant_capsule_fields(Capsule, Project, CapsuleId, CapsuleHash,
        ArtifactRef, ArtifactHash, ExactLocation, CurrentGoal, LastCompleted,
        OpenQuestions, LiveTensions, NextMovement, Commitments, RelevantEvents),
      'current-capsule-schema-invalid'),
    miter_assistant_continuity_require(
      miter_assistant_trajectory_plane(TrajectoryStore, Scope, RelevantEvents,
        HeadId, HeadHash, EventCount),
      'trajectory-integrity-or-scope-invalid'),
    miter_assistant_continuity_require(
      (miter_assistant_dict_symbol(Source, semantic_collection, Collection),
       miter_assistant_dict_symbol(Source, embedding_profile, EmbeddingProfile),
       miter_assistant_dict_symbol(Source, semantic_standing, SemanticStanding),
       memberchk(SemanticStanding,[available,unavailable,degraded,incompatible]),
       miter_assistant_dict_symbol(Source, undertaking_id, Undertaking),
       miter_assistant_dict_symbol(Source, attention_id, Attention),
       miter_assistant_dict_symbol(Source, rna_id, RNA),
       miter_assistant_dict_list(Source, relationships, Relationships),
       miter_assistant_dict_list(Source, open_alternatives, OpenAlternatives),
       miter_assistant_dict_list(Source, pending_consequences, PendingConsequences),
       miter_assistant_dict_list(Source, learned_relations, LearnedRelations)),
      'continuity-organization-record-invalid').

miter_assistant_continuity_artifact_check(Capsule) :-
    miter_assistant_continuity_require(
      (get_dict(current_artifact_ref, Capsule, Ref0),
       miter_store_nonempty_atom(Ref0, Ref), is_absolute_file_name(Ref),
       exists_file(Ref)), 'raw-artifact-unavailable'),
    miter_assistant_continuity_require(
      (get_dict(current_artifact_hash, Capsule, Expected0),
       miter_store_nonempty_atom(Expected0, Expected)),
      'raw-artifact-hash-invalid'),
    crypto_file_hash(Ref, Actual,[algorithm(sha256),encoding(octet)]),
    miter_assistant_continuity_require(Actual==Expected,
      'raw-artifact-hash-mismatch').

miter_assistant_source_scope_bound(Bindings, Scope) :-
    member(Binding, Bindings),
    miter_assistant_binding(Binding, _, Scope, _), !.

miter_assistant_dict_path(Dict, Key, Path) :-
    get_dict(Key, Dict, Value), miter_store_nonempty_atom(Value, Path),
    is_absolute_file_name(Path), exists_directory(Path).

miter_assistant_dict_list(Dict, Key, Values) :-
    get_dict(Key, Dict, Raw), is_list(Raw),
    maplist(miter_store_nonempty_atom, Raw, Values).

miter_assistant_current_capsule(Store, [scope,Principal,Audience,Project], Capsule) :-
    miter_continuity_current_path(Store, Project, CurrentPath),
    exists_file(CurrentPath),
    miter_continuity_load_capsules(Store, Project, Capsules),
    miter_continuity_reconstruct_current(Project, CurrentPath, Capsules,
      'continuity-reconstructed', Reconstruction),
    get_dict(current_capsule_id, Reconstruction, CapsuleId0),
    miter_store_nonempty_atom(CapsuleId0, CapsuleId),
    miter_continuity_load_capsule(Store, Project, CapsuleId, Capsule),
    get_dict(principal_scope, Capsule, Principal0),
    miter_store_nonempty_atom(Principal0, Principal),
    get_dict(audience_scope, Capsule, Audience0),
    miter_store_nonempty_atom(Audience0, Audience).

% Read the explicitly indexed capsule before the legacy reconstruction helper
% validates its artifact.  This lets the membrane distinguish a missing raw
% artifact from changed bytes, then still require the full reconstruction.
miter_assistant_current_capsule_candidate(Store,
    [scope,Principal,Audience,Project], Capsule) :-
    miter_continuity_current_path(Store, Project, CurrentPath),
    exists_file(CurrentPath),
    miter_store_read_json(CurrentPath, Index),
    miter_continuity_index(Index, Project, CapsuleId, CapsuleHash),
    miter_continuity_load_capsule(Store, Project, CapsuleId, Capsule),
    get_dict(content_hash, Capsule, CapsuleHash0),
    miter_store_nonempty_atom(CapsuleHash0, CapsuleHash),
    get_dict(status, Capsule, Status0),
    miter_store_nonempty_atom(Status0, current),
    get_dict(principal_scope, Capsule, Principal0),
    miter_store_nonempty_atom(Principal0, Principal),
    get_dict(audience_scope, Capsule, Audience0),
    miter_store_nonempty_atom(Audience0, Audience).

miter_assistant_capsule_fields(Capsule, Project, CapsuleId, CapsuleHash,
    ArtifactRef, ArtifactHash, ExactLocation, CurrentGoal, LastCompleted,
    OpenQuestions, LiveTensions, NextMovement, Commitments, RelevantEvents) :-
    get_dict(project_id, Capsule, Project0), miter_store_nonempty_atom(Project0, Project),
    get_dict(capsule_id, Capsule, CapsuleId0), miter_store_nonempty_atom(CapsuleId0, CapsuleId),
    get_dict(content_hash, Capsule, CapsuleHash0),
    miter_store_nonempty_atom(CapsuleHash0, CapsuleHash),
    get_dict(current_artifact_ref, Capsule, ArtifactRef0),
    miter_store_nonempty_atom(ArtifactRef0, ArtifactRef),
    get_dict(current_artifact_hash, Capsule, ArtifactHash0),
    miter_store_nonempty_atom(ArtifactHash0, ArtifactHash),
    crypto_file_hash(ArtifactRef, ObservedArtifactHash,
      [algorithm(sha256),encoding(octet)]),
    ObservedArtifactHash==ArtifactHash,
    get_dict(exact_location, Capsule, ExactLocation0),
    miter_store_nonempty_atom(ExactLocation0, ExactLocation),
    get_dict(current_goal, Capsule, CurrentGoal0),
    miter_store_nonempty_atom(CurrentGoal0, CurrentGoal),
    get_dict(last_completed_work, Capsule, LastCompleted0),
    miter_store_nonempty_atom(LastCompleted0, LastCompleted),
    get_dict(next_intended_movement, Capsule, NextMovement0),
    miter_store_nonempty_atom(NextMovement0, NextMovement),
    miter_assistant_capsule_list(Capsule, open_questions, OpenQuestions),
    miter_assistant_capsule_list(Capsule, live_tensions, LiveTensions),
    miter_assistant_capsule_list(Capsule, commitments, Commitments),
    miter_assistant_capsule_list(Capsule, relevant_event_ids, RelevantEvents).

miter_assistant_capsule_list(Capsule, Key, Values) :-
    get_dict(Key, Capsule, Raw), is_list(Raw),
    maplist(miter_store_nonempty_atom, Raw, Values).

miter_assistant_trajectory_plane(Store, Scope, RelevantEvents,
    HeadId, HeadHash, EventCount) :-
    miter_store_load_ledger(Store, Lines),
    miter_store_analyze(Store, Lines, Analysis, Events),
    get_dict(status, Analysis, valid), Events=[_|_],
    RelevantEvents=[_|_],
    maplist(miter_assistant_relevant_event(Events, Scope), RelevantEvents),
    length(Events, EventCount), last(Events, Head),
    get_dict(event_id, Head, HeadId0), miter_store_nonempty_atom(HeadId0, HeadId),
    get_dict(event_hash, Head, HeadHash0), miter_store_nonempty_atom(HeadHash0, HeadHash).

miter_assistant_relevant_event(Events, [scope,Principal,Audience,Project], EventId) :-
    member(Event, Events),
    get_dict(event_id, Event, EventId0), miter_store_nonempty_atom(EventId0, EventId),
    get_dict(source_principal, Event, Principal0),
    miter_store_nonempty_atom(Principal0, Principal),
    get_dict(audience_scope, Event, Audience0),
    miter_store_nonempty_atom(Audience0, Audience),
    get_dict(project_scope, Event, Project0),
    miter_store_nonempty_atom(Project0, Project), !.

miter_assistant_continuity_require(Goal, Reason) :-
    ( call(Goal) -> true ; throw(miter_assistant_continuity_hold(Reason)) ).
