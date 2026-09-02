:- ensure_loaded('../../effect_membranes/miter_store.pl').
:- initialization(main,main).
main :-
 miter_store_read_json('tests/fixtures/g15_inputs.json',F),
 forall(member(C,F.cases),prepare(C)).
prepare(C) :-
 string_concat("source-g15-",C.id,Event),
 I=_{schema:"miter-event-intent-v1",event_id:Event,event_kind:"affective-language-fixture-contact",
 occurred_at:"2026-09-02T07:20:00Z",recorded_at:"2026-09-02T07:20:00Z",
 source_surface:"g15-synthetic-fixture",source_principal:"principal:g15-human",
 audience_scope:"scope:g15-private",project_scope:"g15-language-cues",
 provenance_kind:"direct-contact",parent_event_ids:[],correlation_id:C.id,
 payload:_{text:C.text,synthetic:true}},
 format(atom(Intent),'runtime/g15/intents/~s.json',[C.id]),
 miter_store_write_json_atomic(Intent,I),
 miter_store_append_event('runtime/g15/store','runtime/g07/libmiter_store_posix.dylib',Intent,R),
 format('~s ~w~n',[C.id,R]),R=='event-appended',
 Q=_{cue_id:C.id,source_event_id:Event,text:C.text,store_root:"runtime/g15/store"},
 format(atom(Path),'runtime/g15/inputs/~s.json',[C.id]),
 miter_store_write_json_atomic(Path,Q).
