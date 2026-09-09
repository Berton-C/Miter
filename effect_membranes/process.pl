% Shared bounded direct-process mechanics for non-cognitive membranes.
% Callers supply an executable and an argument vector; this layer never uses a
% shell and never interprets output, chooses a movement, or grants authority.

:- use_module(library(filesex)).
:- use_module(library(process)).

miter_process_observe(Executable,Arguments,Directory,Deadline,MaximumBytes,
    Transport,ExitCode,Stdout,Stderr,Failure) :-
    directory_file_path(Directory,'.miter-tmp',Temporary),
    make_directory_path(Temporary),chmod(Temporary,0o700),
    atom_string(Directory,Home),atom_string(Temporary,Tmp),
    Environment=['HOME'=Home,'TMPDIR'=Tmp,
      'PATH'='/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin',
      'LANG'='en_US.UTF-8','LC_ALL'='en_US.UTF-8'],
    message_queue_create(Queue),
    setup_call_cleanup(
      process_create(Executable,Arguments,
        [cwd(Directory),stdin(null),stdout(pipe(Out)),stderr(pipe(Err)),
         process(Pid),env(Environment)]),
      mp_collect(Pid,Out,Err,Deadline,MaximumBytes,Queue,
        Transport,ExitCode,Stdout,Stderr,Failure),
      mp_cleanup(Pid,Out,Err,Queue)).

mp_collect(Pid,Out,Err,Deadline,MaximumBytes,Queue,Transport,
    ExitCode,Stdout,Stderr,Failure) :-
    ReadLimit is MaximumBytes+1,
    thread_create(mp_read(Out,ReadLimit,Queue,stdout),OutThread,[]),
    thread_create(mp_read(Err,ReadLimit,Queue,stderr),ErrThread,[]),
    mp_wait_deadline(Pid,Deadline,Status),
    thread_get_message(Queue,stream(stdout,Stdout0,OutTruncated)),
    thread_get_message(Queue,stream(stderr,Stderr0,ErrTruncated)),
    thread_join(OutThread,_),thread_join(ErrThread,_),
    mp_status(Status,OutTruncated,ErrTruncated,Transport,ExitCode,Failure),
    mp_truncate(Stdout0,MaximumBytes,Stdout),
    mp_truncate(Stderr0,MaximumBytes,Stderr).

mp_read(Stream,Limit,Queue,Kind) :-
    catch(read_string(Stream,Limit,Text),_,Text=""),
    string_length(Text,Length),(Length>=Limit->Truncated=true;Truncated=false),
    catch(close(Stream),_,true),
    thread_send_message(Queue,stream(Kind,Text,Truncated)).

mp_wait_deadline(Pid,Deadline,Status) :-
    get_time(Start),End is Start+Deadline,
    mp_wait_until(Pid,End,Status).

mp_wait_until(Pid,End,Status) :-
    catch(process_wait(Pid,Observed,[timeout(0)]),_,Observed=timeout),
    ( Observed\==timeout -> Status=Observed
    ; get_time(Now),Now>=End ->
        catch(process_kill(Pid,term),_,true),
        sleep(0.2),
        catch(process_wait(Pid,AfterTerm,[timeout(0)]),_,AfterTerm=timeout),
        ( AfterTerm==timeout ->
            catch(process_kill(Pid,kill),_,true),
            catch(process_wait(Pid,_,[]),_,true)
        ; true ),
        Status=deadline_exceeded
    ; sleep(0.02),mp_wait_until(Pid,End,Status) ).

mp_status(deadline_exceeded,_,_,deadline,unknown,deadline-exceeded) :- !.
mp_status(exit(Code),true,_,truncated,Code,output-truncated) :- !.
mp_status(exit(Code),_,true,truncated,Code,output-truncated) :- !.
mp_status(exit(0),false,false,eof,0,none) :- !.
mp_status(exit(Code),false,false,failed,Code,nonzero-exit) :- !.
mp_status(killed(Signal),_,_,failed,killed,Signal) :- !.
mp_status(_,_,_,failed,unknown,process-status-unavailable).

mp_cleanup(Pid,Out,Err,Queue) :-
    catch(close(Out,[force(true)]),_,true),
    catch(close(Err,[force(true)]),_,true),
    catch(process_wait(Pid,Observed,[timeout(0)]),_,Observed=finished),
    ( Observed==timeout -> catch(process_kill(Pid,kill),_,true) ; true ),
    catch(message_queue_destroy(Queue),_,true).

mp_truncate(Text,Maximum,Truncated) :-
    string_length(Text,Length),
    ( Length=<Maximum -> Truncated=Text
    ; sub_string(Text,0,Maximum,_,Truncated) ).
