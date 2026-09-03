% Fixed mechanical broker; no arbitrary host shell, moral judgment or promotion.
:- ensure_loaded('miter_voice_trials_v2.pl').
:- ensure_loaded('miter_process.pl').
:- use_module(library(pcre)).
ww_docker('/Applications/Docker.app/Contents/Resources/bin/docker').
ww_base('/Users/claritymiter/miter/runtime/g27').
ww_root(R,A) :- miter_store_nonempty_atom(R,A),re_match('^/Users/claritymiter/miter/runtime/g27/attempt-[0-9]+$',A),exists_directory(A),ww_no_links(A).
ww_no_links('/Users/claritymiter/miter/runtime/g27') :- !.
ww_no_links(P) :- \+read_link(P,_,_),file_directory_name(P,D),D\==P,ww_no_links(D).
ww_id(X,A) :- miter_store_nonempty_atom(X,A),re_match('^[a-zA-Z0-9][a-zA-Z0-9_-]{0,63}$',A).
ww_path(R,F0,P) :- ww_root(R,A),miter_store_nonempty_atom(F0,F),\+sub_atom(F,_,_,_,'..'),\+sub_atom(F,0,_,_,'/'),directory_file_path(A,F,P),ww_no_links(P).
ww_contract(C) :- rv_json('/Users/claritymiter/miter/config/workshop-contract-v1.json',C).
ww_grant(R,G) :- ww_path(R,'grant.json',P),rv_json(P,G),G.schema=="miter-workshop-grant-v1",ww_id(G.grant_id,_),ww_root(R,A),
 directory_file_path(A,seed,Seed),atom_string(Seed,G.repository),directory_file_path(A,contracts,Tests),atom_string(Tests,G.contracts),
 exists_directory(Seed),exists_directory(Tests),
 forall(member(F,G.integrity),(crypto_file_hash(F.path,H,[algorithm(sha256),encoding(octet)]),atom_string(H,F.sha256))),
 forall(member(Rel,['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','config/workshop-contract-v1.json','src/workshop_boundary_v1.metta','src/bootstrap_workshop_boundary_v1.metta','effect_membranes/miter_workshop_v1.pl','effect_membranes/miter_process.pl']),
  (atom_concat('/Users/claritymiter/miter/',Rel,RP),member(E,G.integrity),atom_string(RP,E.path))),
 ww_exec('/usr/bin/git',['-C',Seed,'rev-parse','refs/heads/main'],A,6,1024,exit(0),Out,_,false),normalize_space(string(Base),Out),Base==G.base_commit.

% Drain both pipes concurrently with hard caps; the child is deadline-reaped.
ww_read(S,Limit,Q,Kind) :- catch(read_string(S,Limit,Text),_,Text=""),catch(close(S),_,true),string_length(Text,L),
 (L>=Limit->Truncated=true;Truncated=false),thread_send_message(Q,out(Kind,Text,Truncated)).
ww_exec(Program,Args,Cwd,Seconds,Limit,Status,Out,Err,Truncated) :-
 message_queue_create(Q),
 setup_call_cleanup(true,
  (process_create(Program,Args,[cwd(Cwd),stdin(null),stdout(pipe(O)),stderr(pipe(E)),process(P),
    environment(['GIT_CONFIG_GLOBAL'='/dev/null','GIT_CONFIG_NOSYSTEM'='1','GIT_TERMINAL_PROMPT'='0'])]),
   thread_create(ww_read(O,Limit,Q,stdout),TO,[]),thread_create(ww_read(E,Limit,Q,stderr),TE,[]),
   miter_process_wait_deadline(P,Seconds,Status),thread_get_message(Q,out(stdout,Out,OT)),thread_get_message(Q,out(stderr,Err,ET)),
   thread_join(TO,_),thread_join(TE,_),((OT==true;ET==true)->Truncated=true;Truncated=false)),message_queue_destroy(Q)).
ww_git(R,GitDir,Tree,Args,Status,Out,Err) :-
 append(['-c','core.hooksPath=/dev/null','-c','core.attributesFile=/dev/null','--git-dir',GitDir,'--work-tree',Tree],Args,Full),
 ww_exec('/usr/bin/git',Full,R,6,32768,Status,Out,Err,_).
ww_state(R,Id,S) :- ww_id(Id,I),format(atom(F),'states/~w.json',[I]),ww_path(R,F,P),rv_json(P,S),S.status=="active",
 ww_path(R,S.relative_path,Tree),atom_string(Tree,S.path),ww_path(R,S.relative_gitdir,GD),atom_string(GD,S.gitdir).
ww_save_state(R,Id,S) :- ww_id(Id,I),format(atom(F),'states/~w.json',[I]),ww_path(R,F,P),file_directory_name(P,D),make_directory_path(D),tv_durable_json(P,S).
ww_relative(Rel,Parts) :- miter_store_nonempty_atom(Rel,A),\+sub_atom(A,0,_,_,'/'),atomic_list_concat(Parts,'/',A),Parts=[Root|Rest],
 memberchk(Root,[extension,candidate_tests]),Rest\==[],forall(member(C,Parts),(C\=='',C\=='.',C\=='..',re_match('^[a-zA-Z0-9_.-]+$',C),C\=='.git')).
ww_candidate_path(R,S,Rel,P) :- ww_relative(Rel,_),miter_store_nonempty_atom(Rel,A),directory_file_path(S.path,A,P),ww_no_links(P),ww_root(R,_).
ww_keys(D,Extra) :- dict_pairs(D,_,Pairs),pairs_keys(Pairs,Keys),append([schema,request_id,idempotency_key,grant_id,operation,candidate_id],Extra,Allowed),
 forall(member(K,Keys),memberchk(K,Allowed)),forall(member(K,Allowed),get_dict(K,D,_)).
ww_request(R,File,Result) :- catch(ww_request_checked(R,File,Result),_,Result=['workshop-unavailable','integrity-or-malformed']),!.
ww_request_checked(R,File,Result) :- ww_root(R,A),miter_store_nonempty_atom(File,F),re_match('^request-[a-zA-Z0-9_-]+[.]json$',F),ww_path(R,F,P),rv_json(P,D),
 miter_store_canonical_json(D,Json),crypto_data_hash(Json,Hash,[algorithm(sha256),encoding(utf8)]),
 with_mutex(miter_workshop,(ww_grant(R,G)->ww_dispatch(A,G,D,Hash,Result);ww_finish(R,D,Hash,'request-rejected',_{reason:"invalid-grant"},none,Result))).
ww_dispatch(R,G,D,H,Result) :-
 (ww_valid_request(G,D,Id,Key)->
   format(atom(RF),'receipts/~w.json',[Key]),ww_path(R,RF,RP),
   (exists_file(RP)->rv_json(RP,Old),(miter_store_nonempty_atom(Old.request_hash,H)->ww_result(R,Id,Old,Result);ww_finish(R,D,H,'idempotency-conflict',_{},none,Result))
   ;format(atom(PF),'prepared/~w.json',[Key]),ww_path(R,PF,PP),
    (exists_file(PP)->ww_finish(R,D,H,'workshop-recovery-required',_{},none,Result)
    ;file_directory_name(PP,PD),make_directory_path(PD),tv_durable_json(PP,_{request_hash:H,request:D}),
     (catch(ww_operation(R,G,D,Status,Details),E,(Status='operation-incomplete',term_string(E,Error),Details=_{error:Error}))->true;Status='operation-denied',Details=_{reason:"scope-schema-or-state"}),
     ww_finish(R,D,H,Status,Details,RP,Result)))
 ;ww_finish(R,D,H,'request-rejected',_{reason:"missing-or-invalid-identity"},none,Result)).
ww_valid_request(G,D,Id,Key) :- get_dict(schema,D,Schema),Schema=="miter-workshop-request-v1",
 get_dict(grant_id,D,Grant),Grant==G.grant_id,get_dict(request_id,D,Request),get_dict(idempotency_key,D,Idempotency),
 get_dict(candidate_id,D,Candidate),get_dict(operation,D,Operation),
 ww_id(Request,Id),ww_id(Idempotency,Key),ww_id(Candidate,_),string(Operation).
ww_result(_,Id,Receipt,['workshop-result',Id,Status,Event,Hash]) :-
 miter_store_nonempty_atom(Receipt.status,Status),miter_store_nonempty_atom(Receipt.event_id,Event),miter_store_nonempty_atom(Receipt.result_hash,Hash).
ww_finish(R,D,H,Status,Details,ReceiptPath,Result) :-
 (get_dict(request_id,D,ID),ww_id(ID,Id)->true;atom_concat('invalid-',H,Id)),
 get_time(Now),stamp_date_time(Now,UTC,'UTC'),format_time(string(Time),'%FT%TZ',UTC),
 Payload=_{request:D,request_hash:H,status:Status,details:Details},miter_store_canonical_json(Payload,PJ),crypto_data_hash(PJ,RH,[algorithm(sha256),encoding(utf8)]),
 atom_concat('workshop-',RH,EventId),directory_file_path(R,journal,Store),make_directory_path(Store),
 miter_store_load_ledger(Store,Lines),miter_store_analyze(Store,Lines,A,Events),A.status==valid,
 (Events=[]->Parents=[];last(Events,Last),Parents=[Last.event_id]),
 Intent=_{schema:"miter-event-intent-v1",event_id:EventId,event_kind:"workshop-operation",occurred_at:Time,recorded_at:Time,
  source_surface:"native-workshop-boundary",source_principal:"miter-laboratory",audience_scope:"isolated-builder-lab",project_scope:"G27",
  provenance_kind:"mechanical-operation-result",correlation_id:Id,parent_event_ids:Parents,payload:Payload},
 format(atom(F),'events/~w.json',[EventId]),ww_path(R,F,P),file_directory_name(P,PD),make_directory_path(PD),
 (exists_file(P)->true;tv_durable_json(P,Intent)),
 miter_store_append_event(Store,'/Users/claritymiter/miter/runtime/g07/libmiter_store_posix.dylib',P,Written),memberchk(Written,['event-appended','duplicate-event-id']),
 Receipt=_{request_hash:H,status:Status,event_id:EventId,result_hash:RH},
 (ReceiptPath==none->true;file_directory_name(ReceiptPath,RD),make_directory_path(RD),tv_durable_json(ReceiptPath,Receipt)),ww_result(R,Id,Receipt,Result).

ww_operation(R,G,D,'candidate-created',_{branch:Branch,path:Path,base:G.base_commit}) :- D.operation=="create_candidate_worktree",ww_keys(D,[]),ww_id(D.candidate_id,Id),
 format(atom(Rel),'candidates/~w',[Id]),ww_path(R,Rel,Path),\+exists_directory(Path),file_directory_name(Path,Parent),make_directory_path(Parent),
 atom_concat('candidate-',Id,Branch),miter_store_nonempty_atom(G.repository,Repo),atom_concat(Repo,'/.git',GD),
 ww_git(R,GD,G.repository,['worktree','add','-b',Branch,Path,G.base_commit],exit(0),_,_),
 directory_file_path(Path,'.git',Pointer),read_file_to_string(Pointer,Text,[]),split_string(Text,"\n"," \n",[Line]),sub_string(Line,8,_,0,MetaString),atom_string(Meta,MetaString),
 atom_concat(GD,'/worktrees/',Prefix),atom_concat(Prefix,_,Meta),atom_concat(R,'/',RP),atom_concat(RP,MetaRel,Meta),
 forall(member(Sub,[extension,candidate_tests]),(directory_file_path(Path,Sub,SP),make_directory_path(SP))),
 atom_string(Rel,RelS),atom_string(MetaRel,MetaRS),ww_save_state(R,Id,_{status:"active",path:Path,relative_path:RelS,gitdir:Meta,relative_gitdir:MetaRS,branch:Branch,base:G.base_commit}).
ww_operation(R,_,D,'candidate-written',_{path:Relative,sha256:H,bytes:Bytes}) :- D.operation=="write_candidate_file",ww_keys(D,[path,contents]),Relative=D.path,
 ww_state(R,D.candidate_id,S),ww_candidate_path(R,S,D.path,P),string(D.contents),string_length(D.contents,Bytes),ww_contract(C),Bytes=<C.file_limit,
 file_directory_name(P,Parent),make_directory_path(Parent),ww_no_links(Parent),atom_concat(P,'.write-tmp',Tmp),\+exists_file(Tmp),
 setup_call_cleanup(open(Tmp,write,Stream,[encoding(utf8)]),(write(Stream,D.contents),flush_output(Stream),miter_store_fsync_stream(Stream)),close(Stream)),rename_file(Tmp,P),crypto_file_hash(P,H,[algorithm(sha256),encoding(octet)]).
ww_operation(R,_,D,'candidate-read',_{path:Relative,contents:Text,sha256:H}) :- D.operation=="read_candidate_file",ww_keys(D,[path]),Relative=D.path,
 ww_state(R,D.candidate_id,S),ww_candidate_path(R,S,D.path,P),exists_file(P),size_file(P,Size),ww_contract(C),Size=<C.file_limit,
 read_file_to_string(P,Text,[]),crypto_file_hash(P,H,[algorithm(sha256),encoding(octet)]).
ww_operation(R,_,D,'candidate-tree',_{entries:Entries}) :- D.operation=="list_candidate_tree",ww_keys(D,[]),ww_state(R,D.candidate_id,S),
 findall(_{path:Sub,entries:Files},(member(Sub,[extension,candidate_tests]),directory_file_path(S.path,Sub,P),directory_files(P,Files)),Entries).
ww_operation(R,_,D,'candidate-diff',_{diff:Out}) :- D.operation=="get_diff",ww_keys(D,[]),ww_state(R,D.candidate_id,S),
 ww_git(R,S.gitdir,S.path,['add','--','extension','candidate_tests'],exit(0),_,_),
 ww_git(R,S.gitdir,S.path,['diff','--cached','--no-ext-diff','--no-textconv',S.base,'--','extension','candidate_tests'],exit(0),Out,_).
ww_operation(R,G,D,Status,Details) :- D.operation=="run_declared_test",ww_keys(D,[test_id]),ww_state(R,D.candidate_id,S),
 ww_id(D.test_id,Test),member(T,G.tests),atom_string(Test,T.id),ww_container(R,S,G,Test,Status,Details).
ww_operation(R,_,D,'test-artifact',_{result_hash:Hash,event_id:Event}) :- D.operation=="get_test_artifact",ww_keys(D,[test_key]),
 ww_id(D.test_key,K),format(atom(F),'receipts/~w.json',[K]),ww_path(R,F,P),rv_json(P,Receipt),Hash=Receipt.result_hash,Event=Receipt.event_id.
ww_operation(R,G,D,'candidate-archived',_{path:Archive}) :- D.operation=="discard_candidate",ww_keys(D,[]),ww_state(R,D.candidate_id,S),
 ww_id(D.candidate_id,Id),format(atom(Rel),'archive/~w',[Id]),ww_path(R,Rel,Archive),\+exists_directory(Archive),file_directory_name(Archive,AP),make_directory_path(AP),
 miter_store_nonempty_atom(G.repository,Repo),atom_concat(Repo,'/.git',GD),ww_git(R,GD,G.repository,['worktree','move',S.path,Archive],exit(0),_,_),ww_save_state(R,Id,S.put(_{status:"archived",archive:Archive})).
ww_operation(_,_,D,'operation-unsupported',_{operation:D.operation}) :- ww_keys(D,[]),
 memberchk(D.operation,["run_declared_build","start_declared_fixture","stop_declared_fixture","submit_promotion_request"]).

ww_container(R,S,G,Test,Status,Details) :- ww_contract(C),ww_docker(Docker),
 current_prolog_flag(pid,Pid),gensym(miter_g27_,Unique),format(atom(Name),'~w-~d',[Unique,Pid]),
 directory_file_path(S.path,extension,Ext),directory_file_path(S.path,candidate_tests,CT),
 format(atom(M1),'type=bind,src=~w,dst=/workspace/extension',[Ext]),format(atom(M2),'type=bind,src=~w,dst=/workspace/candidate_tests',[CT]),
 format(atom(M3),'type=bind,src=~w,dst=/contract,readonly',[G.contracts]),format(atom(TestPath),'/contract/~w.sh',[Test]),
 Args=['run','--name',Name,'--pull','never','--network','none','--read-only','--cap-drop','ALL','--security-opt','no-new-privileges',
  '--user',C.user,'--memory',C.memory,'--cpus',C.cpus,'--pids-limit','32','--tmpfs','/tmp:rw,noexec,nosuid,size=16m',
  '--mount',M1,'--mount',M2,'--mount',M3,'--workdir','/workspace/extension','--entrypoint','/bin/sh',C.image,TestPath],
 setup_call_cleanup(true,
  (ww_exec(Docker,Args,R,C.timeout_seconds,C.output_limit,Exit,Out,Err,Truncated),
   ww_exec(Docker,['inspect',Name],R,6,65536,InspectStatus,Inspect,InspectError,_),
   (Truncated==true->Status='test-incomplete-output';Exit==deadline_exceeded->Status='test-incomplete-timeout';Exit==exit(0)->Status='test-completed';Status='test-failed'),
   term_string(Exit,ExitText),term_string(InspectStatus,IS),
   Details=_{exit:ExitText,stdout:Out,stderr:Err,truncated:Truncated,container:Name,argv:Args,inspect_status:IS,inspect:Inspect,inspect_error:InspectError}),
  ww_exec(Docker,['rm','--force',Name],R,6,4096,_,_,_,_)).
