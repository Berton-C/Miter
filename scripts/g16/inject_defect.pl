% Test-only fault injection; never imported by production modules.
:- ensure_loaded('../../effect_membranes/miter_voice.pl').
:- initialization(main,main).
main :-
 miter_voice_attempt_path('runtime/g16',boundary,0,'candidate.json',Path),
 miter_voice_attempt_path('runtime/g16',boundary,0,'provider-candidate.json',Backup),
 \+exists_file(Backup),copy_file(Path,Backup),
 miter_store_read_json('tests/fixtures/g16_bad_candidate.json',Bad),
 miter_store_write_json_atomic(Path,Bad),
 writeln('original-provider-candidate-preserved-and-labeled-defect-injected').
