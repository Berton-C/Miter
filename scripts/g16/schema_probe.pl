:- ensure_loaded('../../effect_membranes/miter_voice_transport.pl').
:- initialization(main,main).
main :-
 Good=_{request_id:"fixed",clauses:["one","two","three"]},
 miter_voice_structural(Good,"fixed"),
 Extra=Good.put(task_verdict,"approved"),\+miter_voice_structural(Extra,"fixed"),
 Changed=Good.put(request_id,"other-intention"),\+miter_voice_structural(Changed,"fixed"),
 Malformed=Good.put(clauses,[]),\+miter_voice_structural(Malformed,"fixed"),
 writeln('schema-and-intention-override-probes-pass').
