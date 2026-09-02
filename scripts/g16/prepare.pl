:- ensure_loaded('../../effect_membranes/miter_voice.pl').
:- initialization(main,main).
main :-
 miter_store_read_json('tests/fixtures/g16_inputs.json',F),
 forall(member(C,F.cases),prepare(C)).
prepare(C) :-
 string_concat("source-g16-",C.id,Event),
 I=_{schema:"miter-event-intent-v1",event_id:Event,event_kind:"voice-fixture-contact",
 occurred_at:"2026-09-02T07:32:00Z",recorded_at:"2026-09-02T07:32:00Z",
 source_surface:"g16-synthetic-fixture",source_principal:"principal:g16-human",
 audience_scope:"scope:g16-private",project_scope:"g16-voice",
 provenance_kind:"direct-contact",parent_event_ids:[],correlation_id:C.id,
 payload:_{text:C.text,kind:C.kind,synthetic:true}},
 format(atom(Intent),'runtime/g16/intents/~s.json',[C.id]),
 miter_store_write_json_atomic(Intent,I),
 miter_store_append_event('runtime/g16/store','runtime/g07/libmiter_store_posix.dylib',Intent,R),
 format('~s ~w~n',[C.id,R]),R=='event-appended',
 Q=C.put(source_event_id,Event),
 miter_voice_input_path('runtime/g16',C.id,Path),miter_store_write_json_atomic(Path,Q).
