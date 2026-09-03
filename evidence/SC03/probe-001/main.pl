:- ensure_loaded('/private/tmp/miter-g06-petta-ae66fa8/src/metta.pl').
:- ensure_loaded('../../effect_membranes/miter_undertaking.pl').
:- initialization(main,main).
main([init,Root,silent]) :- !,catch(u_initialize(Root),E,(print_message(error,E),halt(1))).
main([Root,silent]) :- catch(u_run(Root),E,(print_message(error,E),halt(1))).
