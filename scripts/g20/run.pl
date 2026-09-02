:- ensure_loaded('../g18/run.pl').
:- ensure_loaded('../../effect_membranes/miter_interests.pl').
:- initialization(g20_main,main).
g20_main :- current_prolog_flag(argv,Args),g20_main(Args).
g20_main([Arm,Run]) :-
 memberchk(Arm,[canonical,claims,empty,forbidden,'soul-severed',alternative]),
 format(atom(Root),'runtime/g20/~w',[Arm]),directory_file_path(Root,inbox,In),make_directory_path(In),
 directory_file_path(Root,store,Store),make_directory_path(Store),
 (memberchk(Arm,[canonical,forbidden,'soul-severed',alternative])->
   directory_file_path(Store,'trajectory.jsonl',Ledger),copy_file('runtime/g17/store/trajectory.jsonl',Ledger),
   directory_file_path(Store,objects,Objects),copy_directory('runtime/g17/store/objects',Objects)
  ; Arm==claims->g20_claims(Store);true),
 miter_store_read_json('derived/interest-proposals.json',D),D.proposals=[Original],
 (Arm==forbidden->Q=Original.put(allowed_effects,["soul-write"])
 ;Arm==alternative->Q=Original.put(_{proposal_id:"expression-inquiry",soul_ground:"WonderPreservation",
    living_question:"What remains uncertain about the expression that produced these witnessed defects?"})
 ;Q=Original),
 directory_file_path(Root,'interest-proposals.json',PP),miter_store_write_json_atomic(PP,D.put(proposals,[Q])),
 directory_file_path(Root,'source-context.json',CP),miter_store_write_json_atomic(CP,_{voice_root:"runtime/g17"}),
 miter_interest_observations(Root,Obs),directory_file_path(Root,'observations-before.json',OB),miter_store_write_json_atomic(OB,Obs),
 format(atom(F),'/Users/claritymiter/miter/tests/fixtures/g20_~w.metta',[Arm]),
 format(atom(O),'~w/raw/~w.stdout',[Run,Arm]),format(atom(E),'~w/raw/~w.stderr',[Run,Arm]),
 directory_file_path(Root,'provider-counter.json',Counter),
 setup_call_cleanup(open(O,write,OS),setup_call_cleanup(open(E,write,ES),
  setup_call_cleanup(process_create('/opt/homebrew/bin/swipl',
    ['--stack_limit=8g','-q','-s','scripts/g20/instrument.pl',
     '-s','/private/tmp/miter-g06-petta-ae66fa8/src/main.pl','--',F,Counter],
    [process(P),stdout(stream(OS)),stderr(stream(ES))]),
   g20_scenario(Root,Arm,P,Run),catch(miter_process_wait_deadline(P,0.1,_),_,true)),close(ES)),close(OS)).
g20_claims(Store) :- forall(between(0,1,N),
 (miter_voice_attempt_path('runtime/g17',exhaustion,N,'audit.json',P),miter_store_read_json(P,A),
  format(string(Id),'self-claim-~d',[N]),
  I=_{schema:"miter-event-intent-v1",event_id:Id,event_kind:"voice-audit",
    occurred_at:"2026-09-02T08:26:00Z",recorded_at:"2026-09-02T08:26:00Z",
    source_surface:"self-assertion-fixture",source_principal:"miter:candidate",
    audience_scope:"scope:g16-private",project_scope:"g16-voice",provenance_kind:"self-authored",
    parent_event_ids:[],correlation_id:"exhaustion",payload:A},
  format(atom(F),'claim-~d.json',[N]),directory_file_path(Store,F,IP),miter_store_write_json_atomic(IP,I),
  miter_store_append_event(Store,'runtime/g07/libmiter_store_posix.dylib',IP,'event-appended'))).
g20_scenario(Root,Arm,P,Run) :-
 get_time(T0),wait_kind(Root,"quiescent-ready",1,15),wait_kind(Root,"idle-wait",3,5),
 send(Root,stop,stop,'direct-contact',none,1),miter_process_wait_deadline(P,5,Status),
 term_string(Status,ST),get_time(T1),Elapsed is T1-T0,
 directory_file_path(Root,'provider-counter.json',Counter),miter_store_read_json(Counter,Count),
 format(atom(RP),'~w/outputs/~w-process.json',[Run,Arm]),
 miter_store_write_json_atomic(RP,_{pid:P,status:ST,elapsed_seconds:Elapsed,model_calls:Count.provider_entry_calls,
  model_call_count_basis:"instrumented provider entry; positive counter control run separately"}),
 directory_file_path(Root,store,S),format(atom(LP),'~w/outputs/~w-ledger.json',[Run,Arm]),
 miter_store_verify_ledger(S,LP,'trajectory-valid'),Status==exit(0).
