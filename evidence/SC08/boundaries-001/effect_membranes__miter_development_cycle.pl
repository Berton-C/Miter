% SC08 trampoline and exact persistence/transport only. CStep owns disposition.
:- ensure_loaded('miter_voice_construction.pl').
:- dynamic dc_transport/2,dc_contact_cache/4.
dc_counter(N,true) :- integer(N),N>=0,N=<2,!.
dc_counter(_,false).
dc_path(R,F,P) :- atom(R),sub_atom(R,0,_,_,'/Users/claritymiter/miter/evidence/SC08/'),
 \+sub_atom(R,_,_,_,'..'),atom(F),\+sub_atom(F,_,_,_,'..'),\+sub_atom(F,0,_,_,'/'),directory_file_path(R,F,P).
dc_read(P,D) :- rv_json(P,J),dc_decode(J,D).
dc_decode(X,Y) :- (string(X)->atom_string(Y,X);is_list(X)->maplist(dc_decode,X,Y);
 is_dict(X)->dict_pairs(X,T,Ps),maplist(dc_pair,Ps,Qs),dict_pairs(Y,T,Qs);Y=X).
dc_pair(K-X,K-Y) :- dc_decode(X,Y).
dc_hash(X,H) :- miter_store_canonical_json(X,J),crypto_data_hash(J,H,[algorithm(sha256),encoding(utf8)]).
dc_write(R,F,D) :- dc_path(R,F,P),file_directory_name(P,Dir),make_directory_path(Dir),atom_concat(P,'.tmp',Tmp),
 setup_call_cleanup(open(Tmp,write,S,[encoding(utf8)]),(json_write_dict(S,D,[width(0)]),nl(S),miter_store_fsync_stream(S)),close(S)),rename_file(Tmp,P).
dc_once(R,F,D) :- dc_path(R,F,P),(exists_file(P)->dc_read(P,A),dc_hash(A,H),dc_hash(D,H);dc_write(R,F,D)).
dc_log(R,D) :- dc_path(R,'trace.jsonl',P),get_time(T),put_dict(wall_time,D,T,E),
 setup_call_cleanup(open(P,append,S,[encoding(utf8)]),(json_write_dict(S,E,[width(0)]),nl(S)),close(S)).
dc_manifest(R,M) :- dc_path(R,'manifest.json',P),dc_read(P,M),
 forall(member(F,M.files),(crypto_file_hash(F.path,H,[algorithm(sha256),encoding(octet)]),H==F.sha256)),
 forall(member(Rel,['src/bootstrap_development_cycle.metta','src/development_cycle.metta','effect_membranes/miter_development_cycle.pl']),
  (atom_concat('/Users/claritymiter/miter/',Rel,A),member(F,M.files),F.path==A)),
 dc_path(R,'seed.json',SP),member(SF,M.files),SF.path==SP,
 dc_path(R,'profile.json',CP),member(CF,M.files),CF.path==CP.
dc_history(R,Seed,State,N,Tip) :- dc_path(R,'history',Dir),make_directory_path(Dir),directory_files(Dir,Names),
 include(dc_json_name,Names,Files),sort(Files,Sorted),dc_replay(Sorted,Dir,Seed,0,genesis,State,N,Tip).
dc_json_name(N) :- file_name_extension(_,json,N).
dc_replay([],_,S,N,H,S,N,H).
dc_replay([F|Fs],Dir,Before,N,H,State,Count,Tip) :- directory_file_path(Dir,F,P),dc_read(P,E),
 N1 is N+1,E.body.sequence=:=N1,E.body.previous==H,E.body.before==Before,dc_hash(E.body,E.hash),
 dc_replay(Fs,Dir,E.body.after,N1,E.hash,State,Count,Tip).
dc_persist(R,Before,After,Obs,Reason,N,H,N1,H1) :-
 (Before==After->N1=N,H1=H;
 N1 is N+1,get_time(T),Body=_{sequence:N1,previous:H,before:Before,after:After,observation:Obs,reason:Reason,at:T},dc_hash(Body,H1),
 format(atom(F),'history/~|~\`0t~d~8+.json',[N1]),dc_once(R,F,_{body:Body,hash:H1}),
 dc_write(R,'checkpoint.json',_{state:After,sequence:N1,tip:H1}),dc_log(R,_{kind:native_transition,sequence:N1,phase:After,reason:Reason})).
dc_contact(R,M,Contact,Fp) :- dc_path(R,'input.json',P),read_file_to_string(P,Bytes,[]),
 (dc_contact_cache(R,Bytes,Contact,Fp)->true;
  atom_json_dict(Bytes,J,[]),dc_decode(J,Contact),dc_hash([M.semantic,Contact],Fp),
  atom_concat('contacts/',Fp,A),atom_concat(A,'.json',F),dc_once(R,F,Contact),
  retractall(dc_contact_cache(R,_,_,_)),assertz(dc_contact_cache(R,Bytes,Contact,Fp))).
dc_control(R,Control) :- dc_path(R,'control.json',P),
 (exists_file(P)->(catch((dc_read(P,D),Control=D.event),_,fail)->true;Control=['malformed-control']);Control=none).
dc_job(R,J) :- dc_path(R,request,J).
dc_worker_state(R,State,W) :- dc_job(R,J),
 (dc_transport(R,X)->W=X
 ;(vc_result(J,'candidate-available');dc_candidate_exists(J))->dc_product(J,W)
 ;vc_result(J,X)->W=X
 ;vc_thread(J,T),thread_property(T,status(running))->W=pending
 ;dc_stored_transport(J,X)->W=X
 ;nth0(8,State,P),P\==none->W='outcome-uncertain'
 ;W=none).
% Use explicit path construction rather than interpreting model-provided paths.
dc_product(J,[product,Module,Binding]) :- vc_candidate(J,Module),vc_binding(J,Binding).
dc_candidate_exists(J) :- directory_file_path(J,'candidate.json',P),exists_file(P).
dc_stored_transport(J,X) :- directory_file_path(J,'transport-result.json',P),exists_file(P),dc_read(P,D),X=D.result.
dc_dispatch(R,M,[dispatch,Q,O,RNA,Frame,Receipts,Grant]) :- dc_job(R,J),make_directory_path(J),
 vc_write(J,'receipts.json',_{records:Receipts,standing:"synthetic-fixture-native-audits-not-natural-incidents"}),
 vc_write(J,'frame.json',_{native:Frame}),vc_write(J,'grant.json',_{native:Grant}),
 findall(_{path:P,sha256:H},(member(F,['receipts.json','frame.json','grant.json']),vc_path(J,F,P),crypto_file_hash(P,H,[algorithm(sha256),encoding(octet)])),InputPins),
 append(M.files,InputPins,Files),vc_write(J,'manifest.json',_{files:Files}),
 vc_save(J,opportunity,O,stored),vc_save(J,develop,RNA,stored),
 vc_start(J,Q,Result),dc_log(R,_{kind:transport_start,result:Result}),
 (Result=='worker-started'->true;assertz(dc_transport(R,Result))).
dc_cancel(R) :- dc_job(R,J),
 (retract(vc_thread(J,T))->catch(thread_signal(T,throw(cancelled)),_,true),catch(thread_detach(T),_,true),Result='worker-cancel-requested';Result='no-active-worker'),
 dc_log(R,_{kind:cancellation,result:Result,server_confirmation:false}).
dc_effect(R,M,E) :- (E=[dispatch|_]->dc_dispatch(R,M,E);E==[cancel]->dc_cancel(R);throw(error(unknown_native_effect,E))).
dc_tick(R,M,S,N,H,Next,N1,H1,Reason) :-
 dc_contact(R,M,C,Fp),dc_control(R,Control),dc_worker_state(R,S,Worker),
 (catch(Obs=['cycle-observation',Fp,C.frame,C.receipts,C.surfaces,C.grant,Worker,Control],_,fail)->true;Obs=['malformed-observation']),
 findall(D,'CStep'(S,Obs,D),Ds),
 (Ds=[[ 'cycle-step',Next,Effects,Reason]],ground(Next),is_list(Effects)->true;throw(error(non_single_native_turn,Ds))),
 dc_persist(R,S,Next,Obs,Reason,N,H,N1,H1),
 forall(member(E,Effects),(dc_effect(R,M,E)->true;throw(error(effect_mechanics_failed,E)))).
dc_loop(R,M,C,S,N,H,Turn,Delay,Outcome) :-
 (0 is Turn mod 1000->statistics(localused,L),statistics(globalused,G),dc_log(R,_{kind:driver_sample,turn:Turn,local_bytes:L,global_bytes:G});true),
 once(dc_tick(R,M,S,N,H,Next,N1,H1,Reason)),
 (Next=[_,_,_,stopped|_]->Outcome='human-stop'
 ;Reason=['cycle-fault'|_]->Outcome=Reason
 ;C.watchdog_turns\==none,Turn>=C.watchdog_turns->Outcome='external-test-watchdog'
 ;(Next==S->D is min(C.idle_cap_seconds,max(C.poll_seconds,Delay*2));D=C.poll_seconds),
  (D=\=Delay->dc_log(R,_{kind:mechanical_pacing,seconds:D,progress_claim:false});true),
  sleep(D),T1 is Turn+1,dc_loop(R,M,C,Next,N1,H1,T1,D,Outcome)).
dc_run(R) :- dc_manifest(R,M),
 miter_store_ensure_extension('/Users/claritymiter/miter/runtime/g07/libmiter_store_posix.dylib'),
 file_directory_name(M.bootstrap,Boot),assertz(working_dir(Boot)),load_metta_file(M.bootstrap,_),
 current_predicate('CStep'/3),\+current_predicate('DApplyRules'/4),
 dc_path(R,'seed.json',SP),dc_read(SP,Seed),dc_path(R,'profile.json',CP),dc_read(CP,C),
 C.poll_seconds>=0,C.poll_seconds=<0.1,C.idle_cap_seconds>=C.poll_seconds,C.idle_cap_seconds=<0.1,
 (C.watchdog_turns==none;integer(C.watchdog_turns),C.watchdog_turns>0,C.watchdog_turns=<20000),
 dc_history(R,Seed.native,S,N,H),dc_write(R,'checkpoint.json',_{state:S,sequence:N,tip:H}),
 get_time(Start),format(atom(Session),'sessions/~6f',[Start]),dc_path(R,Session,SR),make_directory_path(SR),
 vc_snapshot(SR,before,_),dc_log(R,_{kind:driver_started,semantic:M.semantic,sequence:N,snapshots:SR}),
 setup_call_cleanup(true,dc_loop(R,M,C,S,N,H,0,C.poll_seconds,Outcome),dc_cancel(R)),
 (vc_snapshot(SR,after,_)->true;true),dc_log(R,_{kind:driver_returned,outcome:Outcome}),
 dc_write(R,'outcome.json',_{outcome:Outcome}).
