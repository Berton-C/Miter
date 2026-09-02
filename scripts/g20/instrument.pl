% Test-only measured provider-entry counter, including a separate positive control.
:- ensure_loaded('../../effect_membranes/miter_interests.pl').
:- use_module(library(prolog_wrap)).
:- initialization(g20_instrument).
g20_instrument :-
 current_prolog_flag(argv,[_Fixture,Report|_]),
 nb_setval(g20_count,0),nb_setval(g20_count_report,Report),
 wrap_predicate(miter_lm_execute_request(_A,_B,_C,_D),g20_count,Wrapped,
   (nb_getval(g20_count,N),Next is N+1,nb_setval(g20_count,Next),call(Wrapped))),
 at_halt(g20_write_counter).
g20_write_counter :-
 nb_getval(g20_count,N),nb_getval(g20_count_report,P),
 miter_store_write_json_atomic(P,_{provider_entry_calls:N,probe:"wrapped-miter_lm_execute_request/4"}).
