% Fixed provider worker. Arguments are paths, never executable model text.
:- ensure_loaded('miter_llm.pl').
:- initialization(main,main).
main :-
 current_prolog_flag(argv,[Prepared,Raw,Timing,Observation]),
 miter_lm_execute_request(Prepared,Raw,Timing,R),
 miter_lm_write_json_atomic(Observation,_{result:R}),
 (R=='raw-model-response-stored'->halt(0);halt(1)).
