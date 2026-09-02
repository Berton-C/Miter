:- ensure_loaded('../../effect_membranes/miter_voice.pl').
:- initialization(main,main).
main :-
 make_directory_path('runtime/g16-tamper'),
 copy_directory('runtime/g16/boundary','runtime/g16-tamper/boundary'),
 miter_voice_attempt_path('runtime/g16-tamper',boundary,1,'candidate.json',P),
 miter_store_read_json(P,C),string_concat(C.text," UNAUTHORIZED",Changed),
 miter_store_write_json_atomic(P,C.put(text,Changed)).
