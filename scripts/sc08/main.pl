:- ensure_loaded('/private/tmp/miter-g06-petta-ae66fa8/src/metta.pl').
:- ensure_loaded('../../effect_membranes/miter_development_cycle.pl').
:- initialization(main,main).
main([Root,silent]) :- miter_store_ensure_extension('/Users/claritymiter/miter/runtime/g07/libmiter_store_posix.dylib'),
 catch((dc_run(Root)->true;throw(error(development_runtime_failed,Root))),E,
 (term_string(E,S),catch(dc_write(Root,'runtime-fault.json',_{error:S}),_,true),print_message(error,E),halt(1))).
