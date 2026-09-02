% Deliberately unsafe test surface, never part of Miter's bootstrap.
:- ensure_loaded('../../effect_membranes/miter_voice.pl').
:- initialization(main,main).
main :-
 miter_voice_candidate('runtime/g16',boundary,0,C),
 miter_lm_write_text_atomic('runtime/g16/severed-surface/boundary.txt',C.text),
 writeln('audit-severed-bad-text-reached-mock-surface').
