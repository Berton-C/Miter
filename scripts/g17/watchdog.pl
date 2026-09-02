:- ensure_loaded('../../effect_membranes/miter_process.pl').
:- use_module(library(process)).
:- use_module(library(http/json)).
:- initialization(main,main).
main([Out,Err,Report]) :-
 setup_call_cleanup(open(Out,write,O),setup_call_cleanup(open(Err,write,E),
   (get_time(T0),process_create('/opt/homebrew/bin/swipl',['--stack_limit=8g','-q','-s',
      '/private/tmp/miter-g06-petta-ae66fa8/src/main.pl','--',
      '/Users/claritymiter/miter/tests/fixtures/g17_unbounded.metta'],
      [process(P),stdout(stream(O)),stderr(stream(E))]),
    miter_process_wait_deadline(P,8,S),get_time(T1),D is T1-T0,
    \+catch(process_wait(P,_,[timeout(0)]),_,fail),
    setup_call_cleanup(open(Report,write,R),
      json_write_dict(R,_{status:S,elapsed_seconds:D,reaped:true},[width(0)]),close(R))),close(E)),close(O)),
 S==deadline_exceeded.
