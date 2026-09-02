:- ensure_loaded('../../effect_membranes/miter_reactor.pl').
:- ensure_loaded('../../effect_membranes/miter_process.pl').
:- use_module(library(process)).
:- initialization(main,main).
main([Arm,Run]) :-
 memberchk(Arm,[canonical,negative]),format(atom(Root),'runtime/g18/~w',[Arm]),
 directory_file_path(Root,inbox,In),make_directory_path(In),
 directory_file_path(Root,'obligations.json',OP),
 miter_store_write_json_atomic(OP,_{obligations:[_{id:"due-checkpoint",due_at:0,allowed_effect:"internal-hash-checkpoint"}]}),
 (Arm==canonical -> send(Root,first,human,'direct-contact',none,1),
   send(Root,internal,due,'witnessed-obligation','due-checkpoint',2)
 ;send(Root,perpetual,'continue-autonomous-work','self-authored',none,1)),
 format(atom(F),'/Users/claritymiter/miter/tests/fixtures/g18_~w.metta',[Arm]),
 format(atom(O),'~w/raw/~w.stdout',[Run,Arm]),format(atom(E),'~w/raw/~w.stderr',[Run,Arm]),
 setup_call_cleanup(open(O,write,OS),setup_call_cleanup(open(E,write,ES),
  setup_call_cleanup(process_create('/opt/homebrew/bin/swipl',
    ['--stack_limit=8g','-q','-s','/private/tmp/miter-g06-petta-ae66fa8/src/main.pl','--',F],
    [process(P),stdout(stream(OS)),stderr(stream(ES))]),
   scenario(Root,Arm,P,Run),catch(miter_process_wait_deadline(P,0.1,_),_,true)),close(ES)),close(OS)).
send(Root,Id,Kind,Provenance,Obligation,Steps) :-
 get_time(T),D=_{schema:"miter-reactor-input-v1",id:Id,kind:Kind,provenance:Provenance,
  obligation:Obligation,steps:Steps,sent_at:T},
 format(atom(F),'inbox/~w.json',[Id]),directory_file_path(Root,F,P),miter_store_write_json_atomic(P,D).
scenario(Root,Arm,P,Run) :-
 get_time(T0),wait_kind(Root,"quiescent-ready",1,10),
 (Arm==canonical -> sleep(0.15),send(Root,later,human,'direct-contact',none,1),
  wait_kind(Root,"quiescent-ready",2,5);sleep(0.15)),
 send(Root,stop,stop,'direct-contact',none,1),
 miter_process_wait_deadline(P,5,Status),term_string(Status,StatusText),get_time(T1),Elapsed is T1-T0,
 format(atom(RP),'~w/outputs/~w-process.json',[Run,Arm]),
 miter_store_write_json_atomic(RP,_{pid:P,status:StatusText,elapsed_seconds:Elapsed,
   external_watchdog_seconds:5,model_calls:0,model_transport_imported:false,
   model_call_count_basis:"fixed reactor import/call graph contains no model transport"}),
 directory_file_path(Root,store,S),format(atom(LP),'~w/outputs/~w-ledger.json',[Run,Arm]),
 miter_store_verify_ledger(S,LP,LR),LR=='trajectory-valid',Status==exit(0).
wait_kind(Root,Kind,N,Seconds) :- get_time(T),End is T+Seconds,wait_kind_until(Root,Kind,N,End).
wait_kind_until(Root,Kind,N,End) :-
 directory_file_path(Root,'trace.jsonl',P),
 (catch((read_file_to_string(P,S,[]),split_string(S,"\n","\r\n",Lines),
    findall(D,(member(L,Lines),L\="",atom_json_dict(L,D,[]),D.kind==Kind),Ds),length(Ds,C),C>=N),_,fail)->true
 ;get_time(T),(T<End->sleep(0.02),wait_kind_until(Root,Kind,N,End);throw(error(timeout_waiting(Kind,N),_)))).
