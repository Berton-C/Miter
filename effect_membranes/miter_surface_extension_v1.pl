% G29 local-model transport, inert materialization and mechanical inspection.
% No candidate is executed against a service and no semantic verdict is made here.
:- ensure_loaded('miter_surface_design_v1.pl').
:- ensure_loaded('miter_model_stream_v1.pl').
:- ensure_loaded('miter_llm.pl').
:- ensure_loaded('miter_process.pl').
:- use_module(library(http/json)).
:- use_module(library(readutil)).
:- use_module(library(utf8)).

% Compatibility names required by the already-pinned generic stream capturer.
% They delegate only JSON/durable-file mechanics; no voice semantics are loaded.
rv_json(P,D) :- sd_json(P,D).
tv_durable_json(P,D) :- sd_durable_json(P,D).

sx_name(Prefix,N,Name) :- atom(Prefix),integer(N),N>=0,N=<1024,format(atom(Name),'~w-~d',[Prefix,N]).
sx_part_name(Part,N,Name) :- memberchk(Part,[design,bridge,tests]),integer(N),N>=1,N=<4,format(atom(Name),'~w-~d',[Part,N]).
sx_repair_name(Part,N,Name) :- memberchk(Part,[bridge,tests]),integer(N),N>=1,N=<2,format(atom(Name),'repair-~w-~d',[Part,N]).
sx_old_file(C,Part,File) :- C=['surface-extension-candidate',_,_,_,_,_,Files,_],sx_part_path(Part,Expected),
 member(File,Files),File=['surface-candidate-file',Path,_,_],miter_store_nonempty_atom(Path,PathAtom),PathAtom==Expected,!.
sx_part_path(bridge,'extension/mattermost_bridge.pl').
sx_part_path(tests,'candidate_tests/mattermost_contract_tests.pl').
sx_save(R,N,V,S) :- sd_save(R,N,V,S).
sx_named(R,Id,Suffix,P) :- miter_store_nonempty_atom(Id,A),re_match('^[a-zA-Z0-9_-]+$',A),
 format(atom(F),'~w-~w.json',[A,Suffix]),sd_path(R,F,P).
sx_spend(R,Id) :- once((member(Slot,[1,2,3,4]),format(atom(P),'/Users/claritymiter/miter/evidence/G29/call-~d.claim',[Slot]),
 \+exists_directory(P),catch(make_directory(P),_,fail))),directory_file_path(P,'owner.json',O),
 sd_durable_json(O,_{root:R,request:Id,slot:Slot}).
sx_r1_spend(R,Id) :- once((member(Slot,[1,2,3,4]),format(atom(P),'/Users/claritymiter/miter/evidence/G29/R1-call-~d.claim',[Slot]),
 \+exists_directory(P),catch(make_directory(P),_,fail))),directory_file_path(P,'owner.json',O),
 sd_durable_json(O,_{root:R,request:Id,slot:Slot,grant:"G29-R1"}).
sx_r2_spend(R,Id) :- once((member(Slot,[1,2]),format(atom(P),'/Users/claritymiter/miter/evidence/G29/R2-call-~d.claim',[Slot]),
 \+exists_directory(P),catch(make_directory(P),_,fail))),directory_file_path(P,'owner.json',O),
 sd_durable_json(O,_{root:R,request:Id,slot:Slot,grant:"G29-R2"}).
sx_r3_spend(R,Id) :- once((member(Slot,[1,2]),format(atom(P),'/Users/claritymiter/miter/evidence/G29/R3-call-~d.claim',[Slot]),
 \+exists_directory(P),catch(make_directory(P),_,fail))),directory_file_path(P,'owner.json',O),
 sd_durable_json(O,_{root:R,request:Id,slot:Slot,grant:"G29-R3"}).
sx_r4_spend(R,Id) :- once((member(Slot,[1,2]),format(atom(P),'/Users/claritymiter/miter/evidence/G29/R4-call-~d.claim',[Slot]),
 \+exists_directory(P),catch(make_directory(P),_,fail))),directory_file_path(P,'owner.json',O),
 sd_durable_json(O,_{root:R,request:Id,slot:Slot,grant:"G29-R4"}).

sx_model(R,Q,Observation) :- catch((sx_model_checked(R,Q,Observation)->true;Observation=['surface-model-unavailable',unstaged_or_invalid]),E,
 (term_string(E,S),Observation=['surface-model-unavailable',S])),!.
sx_model_checked(R,Q,Observation) :- sd_verify(R),ground(Q),clause('&derived'('surface-generation-pending',R,Q),true),
 Q=['surface-generation',Id,DesignId,Design,Attempt,'qwen-local',Instructions,Feedback],
 atom(Id),atom(DesignId),integer(Attempt),Attempt>=1,Attempt=<4,string(Instructions),Design=['surface-design',DesignId|_],
 sx_named(R,Id,generation,GP),(exists_file(GP)->sd_json(GP,G),sd_document_native(G,Q);sd_encode(Q,Enc),sd_durable_json(GP,_{native:Q,term:Enc})),
 sx_named(R,Id,observation,OP),
 (exists_file(OP)->sd_json(OP,Stored),sd_document_native(Stored,Observation);
  sx_named(R,Id,request,RP),sx_named(R,Id,wire,Wire),sx_named(R,Id,header,Header),sx_named(R,Id,timing,Timing),
  (exists_file(RP)->
    (exists_file(Timing)->sd_json(Timing,TR);
     ms_capture(RP,Wire,Header,300,4194304,TR),sd_durable_json(Timing,TR)),
    sx_observation(Id,DesignId,Wire,TR,Observation);
   sx_named(R,Id,claim,Claim),make_directory(Claim),sx_spend(R,Id),
   sd_json('/Users/claritymiter/miter/config/mattermost-design-candidate-v1.json',Schema),
   sd_encode(Design,DesignDoc),sd_encode(Feedback,FeedbackDoc),
   with_output_to(string(User),json_write_dict(current_output,_{native_design:DesignDoc,observed_feedback:FeedbackDoc,
    official_interface:_{rest_base:"/api/v4",websocket:"/api/v4/websocket",websocket_event_fields:["event","data","broadcast","seq"],create_post:"POST /api/v4/posts"}},[width(0)])),
   Template=_{schema:"miter-schema-request-v1",request_id:Id,endpoint:"http://127.0.0.1:1234/v1/chat/completions",
    body:_{messages:[_{role:"system",content:Instructions},_{role:"user",content:User}],
     response_format:_{type:"json_schema",json_schema:_{name:"miter_mattermost_candidate",strict:true,schema:Schema}},
     temperature:0,top_p:1,reasoning_effort:"none",max_tokens:4096,seed:2901,stream:true,ttl:300}},
   sx_named(R,Id,template,TP),sd_durable_json(TP,Template),
   miter_lm_prepare_request('/Users/claritymiter/miter/config/local/g03-model-profiles.json','qwen-local',TP,RP,'model-request-prepared'),
   ms_capture(RP,Wire,Header,300,4194304,TR),sd_durable_json(Timing,TR),sx_observation(Id,DesignId,Wire,TR,Observation)),
  sd_encode(Observation,EObs),sd_durable_json(OP,_{native:Observation,term:EObs})).

sx_observation(Id,DesignId,Wire,T,['surface-model-observation',Id,Transport,T.http_status,T.elapsed_ms,Done,Finish,Parse,T.bytes,Content,Candidate]) :-
 miter_store_nonempty_atom(T.transport,Transport),
 (exists_file(Wire)->ms_decode(Wire,Done,Finish,StreamParse,Content,_,_),
  (StreamParse=='malformed-stream'->Parse='malformed-stream',Candidate=[];
   catch(atom_json_dict(Content,Product,[]),_,fail),sx_product(Id,DesignId,Product,Candidate)
   ->Parse='artifact-shaped';Parse='schema-mismatch',Candidate=[])
 ;Done=false,Finish=unknown,Parse='missing-response',Content="",Candidate=[]).
sx_product(Id,DesignId,D,['surface-extension-candidate',DesignId,Id,D.rationale,D.plan,Manifest,Files,['model-product',Id]]) :-
 is_dict(D),dict_pairs(D,_,Pairs),pairs_keys(Pairs,[files,manifest,plan,rationale]),string(D.rationale),string(D.plan),
 M=D.manifest,maplist(miter_store_nonempty_atom,
  [M.schema,M.kind,M.modality,M.role,M.source_interface,M.target_interface,M.permissions.network,M.permissions.live_activation,
   M.outbound_idempotency,M.cursor_reconnect,M.credential_isolation,M.memory_scope,M.failure_witness,M.panic,M.rollback],
  [Schema,Kind,Modality,Role,Source,Target,Network,Live,Idempotency,Reconnect,Credentials,Memory,Failure,Panic,Rollback]),
 maplist(miter_store_nonempty_atom,M.inbound_ids,Inbound),maplist(miter_store_nonempty_atom,M.tests,Tests),
 Manifest=['mattermost-manifest',Schema,Kind,Modality,Role,Source,Target,
  ['permissions',Network,M.permissions.credentials,Live],Inbound,Idempotency,Reconnect,Credentials,Memory,Failure,Panic,Rollback,Tests],
 is_list(D.files),maplist(sx_file,D.files,Files).
sx_file(D,['surface-candidate-file',D.path,D.content,H]) :- is_dict(D),string(D.path),string(D.content),
 crypto_data_hash(D.content,H,[algorithm(sha256),encoding(utf8)]).

sx_part_model(R,Q,Observation) :- catch((sx_part_model_checked(R,Q,Observation)->true;Observation=['surface-part-unavailable',unstaged_or_invalid]),E,
 (term_string(E,S),Observation=['surface-part-unavailable',S])),!.
sx_part_model_checked(R,Q,Observation) :- sd_verify(R),ground(Q),clause('&derived'('surface-part-generation-pending',R,Q),true),
 Q=['surface-part-generation',Id,DesignId,Context,Slot,Part,'qwen-local',Instructions,Feedback],
 atom(Id),atom(DesignId),memberchk(Part,[design,bridge,tests]),integer(Slot),Slot>=1,Slot=<4,string(Instructions),
 Context=['surface-render-context',DesignId|_],sx_named(R,Id,generation,GP),
 (exists_file(GP)->sd_json(GP,G),sd_document_native(G,Q);sd_encode(Q,Enc),sd_durable_json(GP,_{native:Q,term:Enc})),
 sx_named(R,Id,observation,OP),
 (exists_file(OP)->sd_json(OP,Stored),sd_document_native(Stored,Observation);
  sx_named(R,Id,request,RP),sx_named(R,Id,wire,Wire),sx_named(R,Id,header,Header),sx_named(R,Id,timing,Timing),
  sx_named(R,Id,claim,Claim),make_directory(Claim),sx_r1_spend(R,Id),
  (Part==design->SchemaPath='/Users/claritymiter/miter/config/mattermost-design-part-v1.json';SchemaPath='/Users/claritymiter/miter/config/mattermost-code-part-v1.json'),
  sd_json(SchemaPath,Schema),sd_encode(Context,ContextDoc),sd_encode(Feedback,FeedbackDoc),
  with_output_to(string(User),json_write_dict(current_output,_{native_design:ContextDoc,observed_prior:FeedbackDoc,
   official_interface:_{rest_base:"/api/v4",websocket:"/api/v4/websocket",fields:["event","data","broadcast","seq"],create_post:"POST /api/v4/posts"}},[width(0)])),
  Template=_{schema:"miter-schema-request-v1",request_id:Id,endpoint:"http://127.0.0.1:1234/v1/chat/completions",
   body:_{messages:[_{role:"system",content:Instructions},_{role:"user",content:User}],
    response_format:_{type:"json_schema",json_schema:_{name:"miter_mattermost_part",strict:true,schema:Schema}},
    temperature:0,top_p:1,reasoning_effort:"none",max_tokens:2048,seed:2902,stream:true,ttl:300}},
  sx_named(R,Id,template,TP),sd_durable_json(TP,Template),
  miter_lm_prepare_request('/Users/claritymiter/miter/config/local/g03-model-profiles.json','qwen-local',TP,RP,'model-request-prepared'),
  ms_capture(RP,Wire,Header,300,2097152,TR),sd_durable_json(Timing,TR),
  sx_part_observation(Id,DesignId,Part,Wire,TR,Observation),sd_encode(Observation,EO),sd_durable_json(OP,_{native:Observation,term:EO})).
sx_part_observation(Id,DesignId,Part,Wire,T,['surface-part-observation',Id,Part,Transport,T.http_status,T.elapsed_ms,Done,Finish,Parse,T.bytes,Content,Product]) :-
 miter_store_nonempty_atom(T.transport,Transport),
 (exists_file(Wire)->ms_decode(Wire,Done,Finish,StreamParse,Content,_,_),
  (StreamParse=='malformed-stream'->Parse='malformed-stream',Product=[];
   catch(atom_json_dict(Content,D,[]),_,fail),sx_part_product(Id,DesignId,Part,D,Product)
   ->Parse='artifact-shaped';Parse='schema-mismatch',Product=[])
 ;Done=false,Finish=unknown,Parse='missing-response',Content="",Product=[]).
sx_part_product(Id,DesignId,design,D,['surface-design-part',DesignId,Id,D.rationale,D.plan,Manifest,['model-product',Id]]) :-
 is_dict(D),string(D.rationale),string(D.plan),sx_manifest(D.manifest,Manifest).
sx_part_product(Id,DesignId,bridge,D,['surface-code-part',DesignId,Id,File,['model-product',Id]]) :-
 is_dict(D),string(D.content),crypto_data_hash(D.content,H,[algorithm(sha256),encoding(utf8)]),File=['surface-candidate-file',"extension/mattermost_bridge.pl",D.content,H].
sx_part_product(Id,DesignId,tests,D,['surface-code-part',DesignId,Id,File,['model-product',Id]]) :-
 is_dict(D),string(D.content),crypto_data_hash(D.content,H,[algorithm(sha256),encoding(utf8)]),File=['surface-candidate-file',"candidate_tests/mattermost_contract_tests.pl",D.content,H].

sx_repair_model(R,Q,Observation) :- catch((sx_repair_model_checked(R,Q,Observation)->true;Observation=['surface-part-unavailable',unstaged_or_invalid]),E,
 (term_string(E,S),Observation=['surface-part-unavailable',S])),!.
sx_repair_model_checked(R,Q,Observation) :- sd_verify(R),ground(Q),clause('&derived'('surface-repair-generation-pending',R,Q),true),
 Q=['surface-repair-generation',Id,DesignId,CandidateId,Part,Model,Instructions,OldFile,Observations],
 atom(Id),atom(DesignId),atom(CandidateId),memberchk(Part,[bridge,tests]),memberchk(Model,['qwen-local','nemotron-local']),string(Instructions),
 OldFile=['surface-candidate-file',OldPath0,OldSource0,OldHash],
 miter_store_nonempty_atom(OldPath0,OldPathAtom),atom_string(OldPathAtom,OldPath),
 miter_store_nonempty_atom(OldSource0,OldSourceAtom),atom_string(OldSourceAtom,OldSource),is_list(Observations),
 PromptFile=['surface-candidate-file',OldPath,OldSource,OldHash],
 sx_named(R,Id,generation,GP),(exists_file(GP)->sd_json(GP,G),sd_document_native(G,Q);sd_encode(Q,Enc),sd_durable_json(GP,_{native:Q,term:Enc})),
 sx_named(R,Id,observation,OP),
 (exists_file(OP)->sd_json(OP,Stored),sd_document_native(Stored,Observation);
  sx_named(R,Id,request,RP),sx_named(R,Id,wire,Wire),sx_named(R,Id,header,Header),sx_named(R,Id,timing,Timing),
  (exists_file(RP)->
    (exists_file(Timing)->sd_json(Timing,TR);ms_capture(RP,Wire,Header,300,2097152,TR),sd_durable_json(Timing,TR));
   sx_named(R,Id,claim,Claim),make_directory(Claim),sx_repair_spend(Model,R,Id),
   sd_json('/Users/claritymiter/miter/config/mattermost-code-part-v1.json',Schema),
   sd_encode(PromptFile,OldDoc),sd_encode(Observations,ObservationDoc),
   with_output_to(string(User),json_write_dict(current_output,_{design_id:DesignId,candidate_id:CandidateId,target:Part,
    prior_file:OldDoc,observed_consequences:ObservationDoc,unchanged_contract:_{module:"miter_mattermost_bridge",
     exports:["surface_ingest/5","surface_effect/5","surface_reconnect/4","surface_panic/2"],network:"none",credentials:[]}},[width(0)])),
   Template=_{schema:"miter-schema-request-v1",request_id:Id,endpoint:"http://127.0.0.1:1234/v1/chat/completions",
    body:_{messages:[_{role:"system",content:Instructions},_{role:"user",content:User}],
     response_format:_{type:"json_schema",json_schema:_{name:"miter_mattermost_repair_part",strict:true,schema:Schema}},
     temperature:0,top_p:1,reasoning_effort:"none",max_tokens:2048,seed:2903,stream:true,ttl:300}},
   sx_named(R,Id,template,TP),sd_durable_json(TP,Template),
   miter_lm_prepare_request('/Users/claritymiter/miter/config/local/g03-model-profiles.json',Model,TP,RP,'model-request-prepared'),
   ms_capture(RP,Wire,Header,300,2097152,TR),sd_durable_json(Timing,TR)),
  sx_part_observation(Id,DesignId,Part,Wire,TR,Observation),sd_encode(Observation,EO),sd_durable_json(OP,_{native:Observation,term:EO})).
sx_repair_spend('qwen-local',R,Id) :- sx_r2_spend(R,Id).
sx_repair_spend('nemotron-local',R,Id) :- sx_r3_spend(R,Id).

sx_repair_model_r4(R,Q,Observation) :- catch((sx_repair_model_r4_checked(R,Q,Observation)->true;Observation=['surface-part-unavailable',unstaged_or_invalid]),E,
 (term_string(E,S),Observation=['surface-part-unavailable',S])),!.
sx_repair_model_r4_checked(R,Q,Observation) :- sd_verify(R),ground(Q),clause('&derived'('surface-r4-generation-pending',R,Q),true),
 Q=['surface-r4-generation',Id,DesignId,CandidateId,Part,'nemotron-local',Instructions,OldFile,Observations],
 atom(Id),atom(DesignId),atom(CandidateId),memberchk(Part,[bridge,tests]),string(Instructions),
 OldFile=['surface-candidate-file',OldPath0,OldSource0,OldHash],miter_store_nonempty_atom(OldPath0,OldPathAtom),atom_string(OldPathAtom,OldPath),
 miter_store_nonempty_atom(OldSource0,OldSourceAtom),atom_string(OldSourceAtom,OldSource),is_list(Observations),PromptFile=['surface-candidate-file',OldPath,OldSource,OldHash],
 sx_named(R,Id,generation,GP),(exists_file(GP)->sd_json(GP,G),sd_document_native(G,Q);sd_encode(Q,Enc),sd_durable_json(GP,_{native:Q,term:Enc})),
 sx_named(R,Id,observation,OP),
 (exists_file(OP)->sd_json(OP,Stored),sd_document_native(Stored,Observation);
  sx_named(R,Id,request,RP),sx_named(R,Id,wire,Wire),sx_named(R,Id,header,Header),sx_named(R,Id,timing,Timing),
  (exists_file(RP)->(exists_file(Timing)->sd_json(Timing,TR);ms_capture(RP,Wire,Header,300,2097152,TR),sd_durable_json(Timing,TR));
   sx_named(R,Id,claim,Claim),make_directory(Claim),sx_r4_spend(R,Id),sd_json('/Users/claritymiter/miter/config/mattermost-code-part-v1.json',Schema),
   sd_encode(PromptFile,OldDoc),sd_encode(Observations,ObservationDoc),
   with_output_to(string(User),json_write_dict(current_output,_{design_id:DesignId,candidate_id:CandidateId,target:Part,prior_file:OldDoc,
    observed_consequences:ObservationDoc,unchanged_contract:_{module:"miter_mattermost_bridge",exports:["surface_ingest/5","surface_effect/5","surface_reconnect/4","surface_panic/2"],network:"none",credentials:[]}},[width(0)])),
   Template=_{schema:"miter-schema-request-v1",request_id:Id,endpoint:"http://127.0.0.1:1234/v1/chat/completions",
    body:_{messages:[_{role:"system",content:Instructions},_{role:"user",content:User}],response_format:_{type:"json_schema",json_schema:_{name:"miter_mattermost_repair_part",strict:true,schema:Schema}},
     temperature:0,top_p:1,reasoning_effort:"none",max_tokens:2048,seed:2904,stream:true,ttl:300}},
   sx_named(R,Id,template,TP),sd_durable_json(TP,Template),miter_lm_prepare_request('/Users/claritymiter/miter/config/local/g03-model-profiles.json','nemotron-local',TP,RP,'model-request-prepared'),
   ms_capture(RP,Wire,Header,300,2097152,TR),sd_durable_json(Timing,TR)),
  sx_part_observation(Id,DesignId,Part,Wire,TR,Observation),sd_encode(Observation,EO),sd_durable_json(OP,_{native:Observation,term:EO})).
sx_manifest(M,['mattermost-manifest',Schema,Kind,Modality,Role,Source,Target,['permissions',Network,M.permissions.credentials,Live],Inbound,
 Idempotency,Reconnect,Credentials,Memory,Failure,Panic,Rollback,Tests]) :-
 maplist(miter_store_nonempty_atom,
  [M.schema,M.kind,M.modality,M.role,M.source_interface,M.target_interface,M.permissions.network,M.permissions.live_activation,
   M.outbound_idempotency,M.cursor_reconnect,M.credential_isolation,M.memory_scope,M.failure_witness,M.panic,M.rollback],
  [Schema,Kind,Modality,Role,Source,Target,Network,Live,Idempotency,Reconnect,Credentials,Memory,Failure,Panic,Rollback]),
 maplist(miter_store_nonempty_atom,M.inbound_ids,Inbound),maplist(miter_store_nonempty_atom,M.tests,Tests).

sx_candidate_root(R,Id,P) :- sd_root(R,_),miter_store_nonempty_atom(Id,A),re_match('^mattermost-([1-4]|r1|r2|r3|r4)$',A),
 atom_concat('/Users/claritymiter/miter/runtime/g29/candidates/',A,P).
sx_rel("extension/mattermost_bridge.pl").
sx_rel("candidate_tests/mattermost_contract_tests.pl").
sx_materialize(R,C,Result) :- catch(
 (sd_verify(R),C=['surface-extension-candidate',_,Id,_,_,_,Files,_],
  sx_candidate_root(R,Id,Base),\+exists_directory(Base),make_directory_path(Base),
  forall(member(['surface-candidate-file',Rel,Text,H],Files),
   (sx_rel(Rel),directory_file_path(Base,Rel,P),file_directory_name(P,D),make_directory_path(D),
    setup_call_cleanup(open(P,write,S,[encoding(utf8)]),
     (write(S,Text),flush_output(S),miter_store_fsync_stream(S)),close(S)),
    crypto_file_hash(P,H,[algorithm(sha256),encoding(octet)]))),
  Result=['surface-candidate-materialized',Id]),_,Result=['surface-candidate-materialization-incomplete']),!.
sx_scan(R,C,['surface-candidate-scan',Id,Forbidden,Credential,FileStanding]) :- C=['surface-extension-candidate',_,Id,_,_,_,Files,_],
 (length(Files,2),findall(P,(member(['surface-candidate-file',P,_,_],Files),sx_rel(P)),Ps),sort(Ps,Sorted),
  Sorted==["candidate_tests/mattermost_contract_tests.pl","extension/mattermost_bridge.pl"]->FileStanding='exact-files';FileStanding='foreign-or-missing-files'),
 findall(['forbidden-core-access',Path,Token],(member(['surface-candidate-file',Path,Text,_],Files),string_lower(Text,L),
  member(Token,["chroma","miter_soul","src/soul","&soul","direct_memory"]),sub_string(L,_,_,_,Token)),F0),sort(F0,Forbidden),
 findall(['credential-literal',Path],(member(['surface-candidate-file',Path,Text,_],Files),
  re_match('(?i)(bearer[[:space:]]+[a-z0-9_-]{12,}|api[_-]?key[[:space:]]*[:=][[:space:]]*["''][^"'']{8,})',Text)),C0),sort(C0,Credential),
 sd_verify(R).
sx_syntax(R,C,['surface-candidate-syntax',BridgeCode,TestsCode,Truncated]) :- C=['surface-extension-candidate',_,Id|_],sx_candidate_root(R,Id,Base),
 directory_file_path(Base,'extension/mattermost_bridge.pl',Bridge),directory_file_path(Base,'candidate_tests/mattermost_contract_tests.pl',Tests),
 sx_exec('/opt/homebrew/bin/swipl',['-q','-g','halt','-s',Bridge],Base,20,1048576,BStatus,_,BErr,BT),
 sx_exec('/opt/homebrew/bin/swipl',['-q','-g','halt','-s',Bridge,'-s',Tests],Base,20,1048576,TStatus,_,TErr,TT),
 sx_validation_code(BStatus,BErr,BridgeCode),sx_validation_code(TStatus,TErr,TestsCode),
 ((BT==true;TT==true)->Truncated=true;Truncated=false).
sx_validation_code(exit(0),Err,0) :- \+sub_string(Err,_,_,_,"ERROR:"),!.
sx_validation_code(_,_,1).
sx_trial(R,C,['surface-candidate-trial',Code,ErrorCount,FailureCount,Truncated,Out,Err,StatusAtom]) :-
 C=['surface-extension-candidate',_,Id|_],sx_candidate_root(R,Id,Base),
 directory_file_path(Base,'extension/mattermost_bridge.pl',Bridge),directory_file_path(Base,'candidate_tests/mattermost_contract_tests.pl',Tests),
 directory_file_path(Base,'candidate_tests',Cwd),
 sx_exec('/opt/homebrew/bin/swipl',['-q','-f','none','-s',Bridge,'-s',Tests,'-g','run_tests','-t','halt'],Cwd,30,2097152,Status,Out,Err,Truncated),
 (Status=exit(Code)->true;Code=255),sx_occurrences(Err,"ERROR:",ErrorCount),sx_occurrences(Err,"failed",FailureCount),term_to_atom(Status,StatusAtom).
sx_occurrences(Text,Needle,Count) :- findall(B,sub_string(Text,B,_,_,Needle),Bs),length(Bs,Count).

sx_preload(R,Selection,['model-load-observation','nemotron-explicit-load',Code,Loaded,Truncated,Out,Err,State]) :-
 sd_verify(R),Selection=['runtime-recovery-selected','nemotron-explicit-load','nemotron-local',_],
 sx_lms_exec([ps],30,1048576,BeforeStatus,BeforeOut,BeforeErr,BeforeTruncated),
 BeforeStatus=exit(0),string_concat(BeforeOut,BeforeErr,Before),sub_string(Before,_,_,_,"No models are currently loaded"),BeforeTruncated==false,
 sx_lms_exec([load,'nemotron-3.5-30b-a3b-antislop-ftpo-i1','--gpu',max,'--context-length','8192','--ttl','900','--no-speculative-draft-mtp','--yes'],180,4194304,Status,Out,Err,LoadTruncated),
 sx_status_code(Status,Code),sx_lms_exec([ps],30,1048576,_,PsOut,PsErr,PsTruncated),string_concat(PsOut,PsErr,State),
 ((sub_string(State,_,_,_,"nemotron-3.5-30b-a3b-antislop-ftpo-i1"),Code=:=0)->Loaded=true;Loaded=false),
 ((LoadTruncated==true;PsTruncated==true)->Truncated=true;Truncated=false),!.
sx_preload(_,_,['model-load-observation','nemotron-explicit-load',255,false,false,"","precondition-failed",""]).
sx_unload(R,Selection,['model-unload-observation','nemotron-explicit-load',Code,Unloaded,Truncated,Out,Err,State]) :-
 sd_verify(R),Selection=['runtime-recovery-selected','nemotron-explicit-load','nemotron-local',_],
 sx_lms_exec([unload,'nemotron-3.5-30b-a3b-antislop-ftpo-i1'],60,1048576,Status,Out,Err,UnloadTruncated),sx_status_code(Status,Code0),
 sx_lms_exec([ps],30,1048576,PsStatus,PsOut,PsErr,PsTruncated),string_concat(PsOut,PsErr,State),
 ((sub_string(State,_,_,_,"No models are currently loaded"),PsStatus=exit(0))->Unloaded=true;Unloaded=false),
 (Unloaded==true->Code=0;Code=Code0),((UnloadTruncated==true;PsTruncated==true)->Truncated=true;Truncated=false),!.
sx_unload(_,_,['model-unload-observation','nemotron-explicit-load',255,false,false,"","unload-precondition-failed",""]).
sx_force_unload :- sx_lms_exec([ps],30,1048576,_,Out,Err,_),string_concat(Out,Err,State),
 (sub_string(State,_,_,_,"nemotron-3.5-30b-a3b-antislop-ftpo-i1")->sx_lms_exec([unload,'nemotron-3.5-30b-a3b-antislop-ftpo-i1'],60,1048576,_,_,_,_);true).
sx_status_code(exit(Code),Code) :- !.
sx_status_code(_,255).
sx_lms_exec(Args,Seconds,Limit,Status,Out,Err,Truncated) :-
 sx_exec_env('/Users/bcb/.lmstudio/bin/lms',Args,'/Users/bcb',Seconds,Limit,Status,Out,Err,Truncated).
sx_exec_env(P,A,C,S,L,Status,Out,Err,Truncated) :- message_queue_create(Q),setup_call_cleanup(true,
 (process_create(P,A,[cwd(C),stdin(null),stdout(pipe(O)),stderr(pipe(E)),process(Pid),environment(['HOME'='/Users/bcb','PATH'='/Users/bcb/.lmstudio/bin:/opt/homebrew/bin:/usr/bin:/bin'])]),
  thread_create(sx_read(O,L,Q,stdout),TO,[]),thread_create(sx_read(E,L,Q,stderr),TE,[]),miter_process_wait_deadline(Pid,S,Status),
  thread_get_message(Q,out(stdout,Out,OT)),thread_get_message(Q,out(stderr,Err,ET)),thread_join(TO,_),thread_join(TE,_),
  ((OT==true;ET==true)->Truncated=true;Truncated=false)),message_queue_destroy(Q)).
sx_read(S,Limit,Q,K) :- catch(read_string(S,Limit,T),_,T=""),catch(close(S),_,true),string_length(T,N),(N>=Limit->Tr=true;Tr=false),thread_send_message(Q,out(K,T,Tr)).
sx_exec(P,A,C,S,L,Status,Out,Err,Truncated) :- message_queue_create(Q),setup_call_cleanup(true,
 (process_create(P,A,[cwd(C),stdin(null),stdout(pipe(O)),stderr(pipe(E)),process(Pid),environment(['HOME'='/nonexistent','PATH'='/usr/bin:/bin'])]),
  thread_create(sx_read(O,L,Q,stdout),TO,[]),thread_create(sx_read(E,L,Q,stderr),TE,[]),miter_process_wait_deadline(Pid,S,Status),
  thread_get_message(Q,out(stdout,Out,OT)),thread_get_message(Q,out(stderr,Err,ET)),thread_join(TO,_),thread_join(TE,_),
  ((OT==true;ET==true)->Truncated=true;Truncated=false)),message_queue_destroy(Q)).
