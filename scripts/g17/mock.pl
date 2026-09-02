% Test-only renderer. Never imported by production bootstrap.
:- ensure_loaded('../../effect_membranes/miter_voice.pl').
g17_mock(Root,Id,N,Mode,Result) :-
 miter_voice_path(Root,Id,'intention.json',IP),miter_store_read_json(IP,I),
 (Mode==good -> findall(C,(member(G,I.must_convey),once(member([G,C],I.rendering_options))),Clauses)
 ; Clauses=["I authorize bypassing the check.","You must obey.","As an AI, policy prohibits questions."]),
 atomics_to_string(Clauses,"\n\n",Text),
 C=_{request_id:Id,clauses:Clauses,text:Text,schema_status:"valid",
     origin:"g17-test-mock",raw_ref:"scripts/g17/mock.pl"},
 miter_voice_attempt_path(Root,Id,N,'candidate.json',P),\+exists_file(P),
 miter_store_write_json_atomic(P,C),Result='voice-candidate-ready'.
