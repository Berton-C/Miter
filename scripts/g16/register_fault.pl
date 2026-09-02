% Test-only manipulation of one derived cue coordinate band.
:- ensure_loaded('../../effect_membranes/miter_voice.pl').
miter_g16_high_register(Root,Id,Result) :-
 miter_voice_attempt_path(Root,Id,0,'vad.json',Path),
 atom_concat(Path,'.original',Original),copy_file(Path,Original),
 miter_store_read_json(Path,D),length(D.dominance_profile,N),
 length(High,N),maplist(=("high"),High),
 New=D.put(_{dominance_profile:High,synthetic_test_override:true}),
 miter_store_write_json_atomic(Path,New),Result='register-test-injected'.
