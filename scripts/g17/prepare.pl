:- ensure_loaded('../../effect_membranes/miter_voice.pl').
:- initialization(main,main).
main :-
 miter_voice_read_input('runtime/g16',boundary,Q),
 forall(member(Root-Id,['runtime/g17'-exhaustion,'runtime/g17'-'first-valid',
                       'runtime/g17'-'bad-budget','runtime/g17-runaway'-runaway]),
   (miter_voice_input_path(Root,Id,P),miter_store_write_json_atomic(P,Q.put(id,Id)))).
