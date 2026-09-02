:- ensure_loaded('../g18/run.pl').
:- initialization(g19_main,main).
g19_main :- current_prolog_flag(argv,Args),g19_main(Args).
g19_main([Arm,Run]) :-
 memberchk(Arm,[canonical,negative]),format(atom(Root),'runtime/g19/~w',[Arm]),
 directory_file_path(Root,inbox,In),make_directory_path(In),
 directory_file_path(Root,'obligations.json',OP),
 miter_store_write_json_atomic(OP,_{obligations:[_{id:"due-checkpoint",due_at:0,allowed_effect:"internal-hash-checkpoint"}]}),
 directory_file_path(Root,'fixture-work-profile.json',WP),
 miter_store_write_json_atomic(WP,_{step_delay_seconds:0.15,synthetic_latency:true}),
 send(Root,research,research,'witnessed-obligation','due-checkpoint',8),
 format(atom(F),'/Users/claritymiter/miter/tests/fixtures/g19_~w.metta',[Arm]),
 format(atom(O),'~w/raw/~w.stdout',[Run,Arm]),format(atom(E),'~w/raw/~w.stderr',[Run,Arm]),
 setup_call_cleanup(open(O,write,OS),setup_call_cleanup(open(E,write,ES),
  setup_call_cleanup(process_create('/opt/homebrew/bin/swipl',
    ['--stack_limit=8g','-q','-s','/private/tmp/miter-g06-petta-ae66fa8/src/main.pl','--',F],
    [process(P),stdout(stream(OS)),stderr(stream(ES))]),
   g19_scenario(Root,Arm,P,Run),catch(miter_process_wait_deadline(P,0.1,_),_,true)),close(ES)),close(OS)).
g19_scenario(Root,Arm,P,Run) :-
 get_time(T0),wait_kind(Root,"step-witness",1,10),
 send(Root,interrupt,human,'direct-contact',none,1),
 wait_kind(Root,"quiescent-ready",1,5),wait_kind(Root,"idle-wait",5,3),
 send(Root,later,human,'direct-contact',none,1),
 wait_kind(Root,"quiescent-ready",2,5),wait_kind(Root,"idle-wait",10,3),
 send(Root,due,due,'witnessed-obligation','due-checkpoint',1),
 wait_kind(Root,"quiescent-ready",3,5),send(Root,stop,stop,'direct-contact',none,1),
 miter_process_wait_deadline(P,5,Status),term_string(Status,ST),get_time(T1),Elapsed is T1-T0,
 format(atom(RP),'~w/outputs/~w-process.json',[Run,Arm]),
 miter_store_write_json_atomic(RP,_{pid:P,status:ST,elapsed_seconds:Elapsed,
  model_calls:0,model_call_count_basis:"reactor has no model transport"}),
 directory_file_path(Root,store,S),format(atom(LP),'~w/outputs/~w-ledger.json',[Run,Arm]),
 miter_store_verify_ledger(S,LP,LR),LR=='trajectory-valid',Status==exit(0).
