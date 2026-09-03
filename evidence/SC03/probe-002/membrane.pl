% SC03 isolated graph transport, serialization, worker cancellation and trampoline.
% No purpose, support, value, plan selection or semantic success judgment here.
:- ensure_loaded('miter_store.pl').
:- dynamic u_worker/3.

u_decode(X,Y) :- (string(X)->atom_string(Y,X);is_list(X)->maplist(u_decode,X,Y);
 is_dict(X)->dict_pairs(X,T,Ps),maplist(u_pair,Ps,Qs),dict_pairs(Y,T,Qs);Y=X).
u_pair(K-V,K-W) :- u_decode(V,W).
u_hash(T,H) :- copy_term(T,C),numbervars(C,0,_),term_string(C,S,[quoted(true),ignore_ops(true)]),
 crypto_data_hash(S,H,[algorithm(sha256),encoding(utf8)]).
u_path(R,F,P) :- atom(R),sub_atom(R,0,_,_,'/Users/claritymiter/miter/evidence/SC03/'),
 \+sub_atom(R,_,_,_,'..'),directory_file_path(R,F,P).
u_read_json(P,D) :- miter_store_read_json(P,X),u_decode(X,D).
u_write(P,D) :- atom_concat(P,'.tmp',T),setup_call_cleanup(open(T,write,S,[encoding(utf8)]),
 (json_write_dict(S,D,[width(0)]),nl(S),miter_store_fsync_stream(S)),close(S)),rename_file(T,P).
u_load(R,W) :- u_path(R,'world.json',P),u_read_json(P,D),u_hash(D.body,H),H==D.checksum,W=D.body.
u_save(R,W) :- u_path(R,'world.json',P),u_hash(W,H),u_write(P,_{body:W,checksum:H}).
u_log(R,D) :- u_path(R,'trace.jsonl',P),get_time(T),put_dict(wall_time,D,T,E),
 setup_call_cleanup(open(P,append,S,[encoding(utf8)]),(json_write_dict(S,E,[width(0)]),nl(S)),close(S)).
u_edge_record(Scope,Edge,[node,Id,'external-contact',[Principal],Project,H,Edge,[]],
 [observation,Id,'external-contact',[Principal],Project,H,Edge],[at,Id,H]) :-
 Scope=[scope,_,Principal,Project,_],u_hash(Edge,H),atom_concat('graph-',H,Id).
u_observe(W,Semantic,Observation,Fingerprint) :-
 W.scope=[scope,_,Principal,Project,Route],format(atom(Cut),'graph-cut-~d',[W.revision]),
 Scope=[scope,Cut,Principal,Project,Route],
 findall(N-G-C,(member(Edge,W.edges),u_edge_record(Scope,Edge,N,G,C)),Triples),
 findall(N,member(N-_-_,Triples),Ns),findall(G,member(_-G-_,Triples),Gs),findall(C,member(_-_-C,Triples),Cs),
 append(Ns,W.records,Nodes),append(Gs,W.registry,Registry),append(Cs,W.current,Current),
 Observation=['observation-frame',Scope,Nodes,Registry,Current,W.edges,W.revision,W.receipts,W.grant],
 u_hash(Observation-Semantic,Fingerprint).

% Independent artifact application is exact list/set mechanics in a single process.
% One locked atomic world object contains graph, receipt and pending checkpoint.
u_apply(R,Pending,Semantic) :- with_mutex(miter_undertaking_world,
 (u_load(R,W),Pending=[prepared,Key,Version,Before,After,Op,Pin],
  (member([receipt,Key,applied,_,Pending],W.receipts)->u_log(R,_{kind:effect_replayed,key:Key})
  ;Pin==Semantic,W.semantic==Semantic,W.grant=[lab-grant,_,_,active],
   W.revision=:=Version,sort(W.edges,SortedBefore),sort(Before,SortedBefore),
   memberchk(Op,W.operations),Op=[operation,_,Required,Add,Remove],
   forall(member(E,Required),memberchk(E,W.edges)),subtract(W.edges,Remove,Rest),append(Rest,Add,Added),
   sort(Added,SortedAfter),sort(After,SortedAfter),V2 is Version+1,
   append(W.receipts,[[receipt,Key,applied,V2,Pending]],Receipts),
   put_dict(_{edges:SortedAfter,revision:V2,receipts:Receipts},W,Next),u_save(R,Next),
   u_log(R,_{kind:effect_applied,key:Key,version:V2,operation:Op})))) .
u_worker_body(R,Pending,Semantic,Delay) :-
 catch((sleep(Delay),u_apply(R,Pending,Semantic)),E,
   (term_string(E,T),u_log(R,_{kind:worker_exit,error:T}))).
u_start_worker(R,Pending,Semantic,Delay) :- Pending=[prepared,Key|_],
 (u_worker(R,Key,T),thread_property(T,status(running))->true
 ; (retract(u_worker(R,Key,Old))->catch(thread_join(Old,_),_,true);true),
   thread_create(u_worker_body(R,Pending,Semantic,Delay),T,[]),assertz(u_worker(R,Key,T)),
   u_log(R,_{kind:worker_started,key:Key})).
u_cancel_workers(R) :- forall(retract(u_worker(R,_,T)),
 (catch(thread_signal(T,throw(cancelled)),_,true),catch(thread_join(T,_),_,true))).
u_collect_workers(R) :- forall((u_worker(R,K,T),thread_property(T,status(Status)),Status\==running),
 (retract(u_worker(R,K,T)),catch(thread_join(T,_),_,true))).

% Inbox identity/order are transport. The native turn validates scope and meaning.
u_input(R,Seen,Event,Consumed) :- u_path(R,inbox,Dir),directory_files(Dir,Files),sort(Files,Sorted),
 (member(F,Sorted),file_name_extension(_,json,F),\+memberchk(F,Seen),
  directory_file_path(Dir,F,P),u_read_json(P,D),Event=D.event,
  Event=[control,_,_,_,_,Amount],number(Amount),Amount>=0,Amount=<1000,
  Consumed=F->true;Event=none,Consumed=none).
u_native(State,Observation,Event,Semantic,Fingerprint,Decision) :-
 findall(D,'UTurn'(State,Observation,Event,Semantic,Fingerprint,D),Ds),
 (Ds=[Decision]->true;throw(error(non_single_native_turn,Ds))).
u_tick(R,Semantic,Config,Decision) :-
 u_collect_workers(R),
 with_mutex(miter_undertaking_world,
   (u_load(R,W),u_input(R,W.inbox_seen,Event,Consumed),u_observe(W,Semantic,Observation,Fingerprint),
    u_native(W.state,Observation,Event,Semantic,Fingerprint,Decision),
    (Decision=[turn,Next,_,Reason]->
      (Consumed==none->Seen=W.inbox_seen;append(W.inbox_seen,[Consumed],Seen)),
      (Next==W.state,Seen==W.inbox_seen->true;put_dict(_{state:Next,inbox_seen:Seen},W,W2),u_save(R,W2),
       u_log(R,_{kind:native_transition,event:Event,before:W.state,after:Next,reason:Reason}))
    ;throw(error(native_fault,Decision))))),
 Decision=[turn,_,Action,_],
 (Action=[apply,Pending]->u_start_worker(R,Pending,Semantic,Config.worker_delay_seconds)
 ;memberchk(Action,[stop,'cancel-worker'])->u_cancel_workers(R);Action==wait),
 (Event\==none->u_log(R,_{kind:ingress_observed,event:Event});true).
u_loop(R,Semantic,Config,N,Outcome) :-
 statistics(localused,Local),statistics(globalused,Global),
 (0 is N mod 1000->u_log(R,_{kind:driver_sample,turn:N,local_bytes:Local,global_bytes:Global});true),
 once(u_tick(R,Semantic,Config,Decision)),
 (Decision=[turn,_,stop,_]->Outcome=human_stop
 ;N>=Config.watchdog_turns->Outcome=external_test_watchdog
 ;sleep(Config.poll_seconds),N2 is N+1,u_loop(R,Semantic,Config,N2,Outcome)).

u_bundle_hash(Files,Hash) :- findall([P,H],(member(P,Files),crypto_file_hash(P,H,[algorithm(sha256),encoding(octet)])),Pairs),u_hash(Pairs,Hash).
u_verify_manifest(M) :- forall(member(E,M.files),
 (crypto_file_hash(E.path,H,[algorithm(sha256),encoding(octet)]),H==E.sha256)),
 findall(H,(member(E,M.files),H=E.sha256),Hashes),atomics_to_string(Hashes,'\n',Text),
 crypto_data_hash(Text,Expected,[algorithm(sha256),encoding(utf8)]),Expected==M.semantic.
u_initialize(R) :-
 miter_store_ensure_extension('/Users/claritymiter/miter/runtime/g07/libmiter_store_posix.dylib'),
 u_path(R,'seed.json',P),u_read_json(P,W),u_path(R,'world.json',WP),\+exists_file(WP),u_save(R,W).
u_run(R) :-
 u_path(R,'manifest.json',MP),u_read_json(MP,M),u_verify_manifest(M),
 miter_store_ensure_extension('/Users/claritymiter/miter/runtime/g07/libmiter_store_posix.dylib'),
 file_directory_name(M.bootstrap,BootDirectory),assertz(working_dir(BootDirectory)),
 load_metta_file(M.bootstrap,_),
 (current_predicate('UTurn'/6)->true;throw(error(native_undertaking_not_loaded,M.bootstrap))),
 u_path(R,'profile.json',CP),u_read_json(CP,C),
 C.poll_seconds>=0,C.poll_seconds=<1,C.worker_delay_seconds>=0,C.worker_delay_seconds=<5,
 integer(C.watchdog_turns),C.watchdog_turns>0,C.watchdog_turns=<20000,
 u_log(R,_{kind:driver_started,semantic:M.semantic}),
 setup_call_cleanup(true,u_loop(R,M.semantic,C,0,Outcome),u_cancel_workers(R)),
 u_log(R,_{kind:driver_stopped,outcome:Outcome}).
