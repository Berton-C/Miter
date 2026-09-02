:- ensure_loaded('../g19/run.pl').
:- initialization(g20_regress,main).
g20_regress :- current_prolog_flag(argv,[Gate,Arm,Run]),
 memberchk(Gate,[g18,g19]),memberchk(Arm,[canonical,negative]),
 format(atom(Root),'runtime/g20-regression/~w/~w',[Gate,Arm]),
 directory_file_path(Root,inbox,In),make_directory_path(In),
 directory_file_path(Root,'obligations.json',OP),
 miter_store_write_json_atomic(OP,_{obligations:[_{id:"due-checkpoint",due_at:0,allowed_effect:"internal-hash-checkpoint"}]}),
 (Gate==g19->directory_file_path(Root,'fixture-work-profile.json',WP),
  miter_store_write_json_atomic(WP,_{step_delay_seconds:0.15,synthetic_latency:true}),
  send(Root,research,research,'witnessed-obligation','due-checkpoint',8)
 ;Arm==canonical->send(Root,first,human,'direct-contact',none,1),send(Root,internal,due,'witnessed-obligation','due-checkpoint',2)
 ;send(Root,perpetual,'continue-autonomous-work','self-authored',none,1)),
 format(atom(F),'/Users/claritymiter/miter/tests/fixtures/g20_regress_~w_~w.metta',[Gate,Arm]),
 format(atom(O),'~w/raw/~w.stdout',[Run,Arm]),format(atom(E),'~w/raw/~w.stderr',[Run,Arm]),
 directory_file_path(Root,'provider-counter.json',Counter),
 setup_call_cleanup(open(O,write,OS),setup_call_cleanup(open(E,write,ES),
  setup_call_cleanup(process_create('/opt/homebrew/bin/swipl',
    ['--stack_limit=8g','-q','-s','scripts/g20/instrument.pl',
     '-s','/private/tmp/miter-g06-petta-ae66fa8/src/main.pl','--',F,Counter],
    [process(P),stdout(stream(OS)),stderr(stream(ES))]),
   (Gate==g18->scenario(Root,Arm,P,Run);g19_scenario(Root,Arm,P,Run)),
   catch(miter_process_wait_deadline(P,0.1,_),_,true)),close(ES)),close(OS)).
