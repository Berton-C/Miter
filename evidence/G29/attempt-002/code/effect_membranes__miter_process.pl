% Mechanical deadline for a child PID created by a fixed trusted broker.
% Not imported as a general PID-killing API into MeTTa or candidate code.
:- use_module(library(process)).
miter_process_wait_deadline(Pid,Seconds,Status) :-
 number(Seconds),Seconds>0,get_time(Start),Deadline is Start+Seconds,
 miter_process_poll(Pid,Deadline,Status).
miter_process_poll(Pid,Deadline,Status) :-
 process_wait(Pid,Now,[timeout(0)]),
 (Now\==timeout -> Status=Now
 ; get_time(T),
   (T>=Deadline ->
      catch(process_kill(Pid,term),_,true),Grace is T+1,
      miter_process_reap(Pid,Grace),Status=deadline_exceeded
   ; sleep(0.05),miter_process_poll(Pid,Deadline,Status))).
miter_process_reap(Pid,Grace) :-
 process_wait(Pid,Now,[timeout(0)]),
 (Now\==timeout -> true
 ; get_time(T),
   (T>=Grace -> catch(process_kill(Pid,kill),_,true),process_wait(Pid,_)
   ; sleep(0.05),miter_process_reap(Pid,Grace))).
