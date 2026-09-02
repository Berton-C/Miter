:- ensure_loaded('../../effect_membranes/miter_memory.pl').
:- initialization(main, main).
main :-
    miter_chroma_read_json('tests/fixtures/g10_candidates.json', F),
    forall(member(Delta,F.candidates),prepare(F.base,Delta)).
prepare(Base,Delta) :-
    C=Base.put(Delta),
    format(atom(Path),'runtime/g10/candidates/~s.json',[C.memory_id]),
    miter_cs_write(Path,C),
    C.source_event_ids=[EventId],
    Intent=_{schema:"miter-event-intent-v1",event_id:EventId,event_kind:"memory-source-contact",
      occurred_at:C.created_at,recorded_at:C.created_at,source_surface:"g10-synthetic-fixture",
      source_principal:C.principal_scope,audience_scope:C.audience_scope,
      project_scope:C.project_scope,provenance_kind:"direct-contact",
      parent_event_ids:["evt-g07-fork-0004"],correlation_id:C.memory_id,
      payload:_{synthetic:true,body:C.body,capsule_id:C.source_capsule_id}},
    format(atom(IntentPath),'runtime/g10/source-intents/~s.json',[EventId]),
    miter_cs_write(IntentPath,Intent),
    miter_store_append_event('runtime/g10/store','runtime/g07/libmiter_store_posix.dylib',IntentPath,R),
    format('~s ~w~n',[EventId,R]), R == 'event-appended'.
