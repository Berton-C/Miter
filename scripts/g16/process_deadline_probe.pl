:- ensure_loaded('../../effect_membranes/miter_process.pl').
:- initialization(main,main).
main :-
 get_time(Start),process_create('/bin/sleep',['5'],[process(Pid)]),
 miter_process_wait_deadline(Pid,0.25,Status),get_time(End),Duration is End-Start,
 format('status=~w duration_seconds=~3f child_pid=~d~n',[Status,Duration,Pid]),
 Status==deadline_exceeded,Duration<2,
 process_create('/usr/bin/true',[],[process(Positive)]),
 miter_process_wait_deadline(Positive,1,exit(0)),
 writeln('process-deadline-positive-and-severed-pass').
