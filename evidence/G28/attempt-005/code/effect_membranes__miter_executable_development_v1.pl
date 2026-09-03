% G28 mechanics only: source identity, local model transport, inert projection,
% exact workshop requests and observed bytes. Admission/comparison is MeTTa.
:- ensure_loaded('miter_workshop_v1.pl').
:- use_module(library(utf8)).
wx_root(R,A) :- miter_store_nonempty_atom(R,A),re_match('^/Users/claritymiter/miter/evidence/G28/attempt-[0-9]+$',A),exists_directory(A),wx_no_links(A).
wx_no_links('/Users/claritymiter/miter/evidence/G28') :- !.
wx_no_links(P) :- \+read_link(P,_,_),file_directory_name(P,D),D\==P,wx_no_links(D).
wx_path(R,F0,P) :- wx_root(R,A),miter_store_nonempty_atom(F0,F),re_match('^[a-zA-Z0-9_.-]+$',F),\+sub_atom(F,_,_,_,'..'),directory_file_path(A,F,P),\+read_link(P,_,_).
wx_verify(R,D) :- wx_path(R,'context.json',CP),rv_json(CP,D),D.schema=="miter-executable-context-v1",
 re_match('^/Users/claritymiter/miter/runtime/g27/attempt-28[0-9]{3}$',D.workshop_root),ww_grant(D.workshop_root,_),
 wx_path(R,'manifest.json',MP),rv_json(MP,M),forall(member(F,M.files),(crypto_file_hash(F.path,H,[algorithm(sha256),encoding(octet)]),atom_string(H,F.sha256))),
 forall(member(Rel,['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','src/executable_development_v1.metta','src/bootstrap_executable_development_v1.metta',
 'src/participation.metta','src/participation_support.metta','constitution/soul_compass_v02.metta','src/bootstrap_grounded_language.metta',
 'effect_membranes/miter_executable_development_v1.pl','effect_membranes/miter_workshop_v1.pl','effect_membranes/miter_llm.pl',
 'config/executable-candidate-schema-v1.json','config/local/g03-model-profiles.json']),
  (atom_concat('/Users/claritymiter/miter/',Rel,P),member(E,M.files),atom_string(P,E.path))),
 forall(member(Name,['input.json','context.json']),(wx_path(R,Name,P),member(E,M.files),atom_string(P,E.path))).
wx_input(R,N) :- catch((wx_verify(R,_),wx_path(R,'input.json',P),rv_json(P,D),rv_native(D.native,N)),_,fail),!.
wx_input(_,['executable-input-unavailable']).
wx_grant_id(R,Id) :- wx_verify(R,D),ww_grant(D.workshop_root,G),atom_string(Id,G.grant_id).
wx_save(R,Name0,N,Result) :- catch(
 ((wx_verify(R,_),miter_store_nonempty_atom(Name0,Name),atom_concat(Name,'.json',F),wx_path(R,F,P),
   (exists_file(P)->rv_json(P,Old),tv_document_native(Old,N);tv_encode(N,Enc),tv_durable_json(P,_{native:N,term:Enc})))
  ->Result=stored;Result='executable-storage-incomplete'),_,Result='executable-storage-incomplete'),!.
wx_name(Prefix,N,Name) :- atom(Prefix),integer(N),N>=0,N=<1024,format(atom(Name),'~w-~d',[Prefix,N]).
wx_string(S,true) :- string(S),string_length(S,N),N>0,N=<131072,!.
wx_string(_,false).
wx_named(R,Id,Suffix,P) :- ww_id(Id,A),format(atom(F),'~w-~w.json',[A,Suffix]),wx_path(R,F,P).
wx_model(R,Q,Candidate) :- catch((wx_model_checked(R,Q,Candidate)->true;Candidate=['executable-model-incomplete']),E,
 (term_string(E,S),Candidate=['executable-model-incomplete',S])),!.
wx_model_checked(R,Q,Candidate) :- wx_verify(R,_),ground(Q),clause('&derived'('executable-generation-pending',R,Q),true),
 Q=['executable-generation',Id,O,Attempt,'qwen-local',Instructions,Feedback],integer(Attempt),Attempt>=1,Attempt=<2,string(Instructions),atom_string(Id,IdS),
 O=['executable-opportunity',_,_,Contract,_,['executable-grant',_,_,2,1024,120],_],
 wx_path(R,'opportunity.json',OP),rv_json(OP,OD),tv_document_native(OD,O),
 wx_named(R,Id,generation,GP),(exists_file(GP)->rv_json(GP,G),tv_document_native(G,Q);tv_encode(Q,Enc),tv_durable_json(GP,_{native:Q,term:Enc})),
 wx_named(R,Id,raw,Raw),wx_named(R,Id,timing,Timing),
 (exists_file(Raw)->true;
  % A prepared request without a response is an uncertain/failed attempt, not
  % permission to spend the same grant again after a worker restart.
  wx_named(R,Id,request,RP),
  (exists_file(RP)->throw(error(model_response_unavailable_after_preparation,Id));true),
  rv_json('/Users/claritymiter/miter/config/executable-candidate-schema-v1.json',Schema),
  Contract=['executable-contract',SourceId|_],
  with_output_to(string(User),json_write_dict(current_output,_{candidate_id:IdS,source_id:SourceId,contract:Contract,observations:Feedback},[width(0)])),
  Template=_{schema:"miter-schema-request-v1",request_id:IdS,endpoint:"http://127.0.0.1:1234/v1/chat/completions",body:_{messages:[_{role:"system",content:Instructions},_{role:"user",content:User}],
   response_format:_{type:"json_schema",json_schema:_{name:"miter_executable_candidate",strict:true,schema:Schema}},temperature:0,top_p:1,reasoning_effort:"none",max_tokens:1024,seed:2801,stream:false,ttl:300}},
  wx_named(R,Id,template,TP),tv_durable_json(TP,Template),
  miter_lm_prepare_request('/Users/claritymiter/miter/config/local/g03-model-profiles.json','qwen-local',TP,RP,'model-request-prepared'),
  call_with_time_limit(120,miter_lm_execute_request_checked(RP,Raw,Timing,'raw-model-response-stored'))),
 rv_json(Raw,Response),Response.choices=[Choice|_],Choice.finish_reason\=="length",miter_lm_provider_product(Response,Product),
 Product.candidate_id==IdS,wx_project(Product,Candidate),wx_named(R,Id,product,PP),
 (exists_file(PP)->rv_json(PP,Old),miter_store_canonical_json(Old,J),miter_store_canonical_json(Product,J);tv_durable_json(PP,Product)).
wx_project(D,['executable-candidate',Id,Files,Manifest]) :- D.schema=="miter-executable-candidate-v1",ww_id(D.candidate_id,Id),
 dict_pairs(D,_,Ps),pairs_keys(Ps,[candidate_id,files,manifest,schema]),is_list(D.files),maplist(wx_file,D.files,Files),M=D.manifest,
 dict_pairs(M,_,MP),pairs_keys(MP,[allowed_paths,approval,credentials,effects,input_contract,language,memory_scope,network,output_contract,purpose,rollback,source_id,tests]),
 rv_native(['extension-manifest',M.source_id,M.purpose,M.input_contract,M.output_contract,M.allowed_paths,M.effects,M.network,M.credentials,M.language,M.memory_scope,M.tests,M.rollback,M.approval],Manifest).
wx_file(D,['candidate-file',D.path,D.contents,H]) :- dict_pairs(D,_,P),pairs_keys(P,[contents,path]),string(D.path),string(D.contents),crypto_data_hash(D.contents,H,[algorithm(sha256),encoding(utf8)]).
wx_candidate_bound(R,Id,C,Result) :- catch((wx_verify(R,_),wx_named(R,Id,raw,RP),rv_json(RP,Raw),miter_lm_provider_product(Raw,D),
 wx_named(R,Id,product,PP),rv_json(PP,Product),miter_store_canonical_json(D,J),miter_store_canonical_json(Product,J),wx_project(Product,C)
 ->Result='candidate-source-bound';Result='candidate-source-unbound'),_,Result='candidate-source-unbound'),!.
wx_request(R,Label,Operation,Id,Fields,Result) :- catch((wx_verify(R,D),ww_grant(D.workshop_root,G),
 ww_id(Id,Candidate),ww_id(Label,L),ww_id(Operation,Op),format(atom(RId),'~w-~w',[Candidate,L]),
 maplist(wx_field,Fields,Pairs),dict_create(Extra,_,Pairs),
 Base=_{schema:"miter-workshop-request-v1",request_id:RId,idempotency_key:RId,grant_id:G.grant_id,operation:Op,candidate_id:Candidate},
 put_dict(Extra,Base,Request),format(atom(File),'request-~w.json',[RId]),ww_path(D.workshop_root,File,P),
 (exists_file(P)->rv_json(P,Old),miter_store_canonical_json(Old,J),miter_store_canonical_json(Request,J);tv_durable_json(P,Request)),
 ww_request(D.workshop_root,File,Result)),_,Result=['executable-workshop-unavailable']),!.
wx_field([Key,Value],Key-Value) :- atom(Key),memberchk(Key,[path,contents,test_id,message,lineage,proposal,commit]).
wx_event(R,Receipt,Event) :- wx_verify(R,D),Receipt=['workshop-result',_,_,Id,Hash],format(atom(File),'events/~w.json',[Id]),ww_path(D.workshop_root,File,P),rv_json(P,Event),
 miter_store_canonical_json(Event.payload,J),crypto_data_hash(J,Hash,[algorithm(sha256),encoding(utf8)]).
wx_observe(R,Id,Receipt,Observation) :- catch((wx_event(R,Receipt,E),E.payload.request.operation=="run_declared_test",atom_string(Id,E.payload.request.test_id),
 Details=E.payload.details,miter_store_nonempty_atom(Details.exit,Exit),
 re_matchsub('^exit[(]([0-9]+)[)]$',Exit,M,[]),number_string(Code,M.1),Details.truncated==false,
 string_codes(Details.stdout,Chars),phrase(utf8_codes(Chars),Bytes),Observation=['io-observation',Id,Code,Bytes]),_,fail),!.
wx_observe(_,Id,Receipt,['io-incomplete',Id,Receipt]).
wx_details(R,commit,Receipt,Commit) :- wx_event(R,Receipt,E),E.payload.status=="candidate-committed",Commit=E.payload.details.commit,!.
wx_details(R,lineage,Q,Text) :- wx_verify(R,_),Q=['executable-generation',Id|_],
 findall(_{file:Name,sha256:H},(member(Name,[generation,raw,request,product]),wx_named(R,Id,Name,P),crypto_file_hash(P,H,[algorithm(sha256),encoding(octet)])),Files),
 with_output_to(string(Text),json_write_dict(current_output,_{generation:Q,files:Files,standing:"Miter-origin candidate, trial is not promotion"},[width(0)])),!.
wx_details(R,proposal,P,Text) :- wx_verify(R,_),with_output_to(string(Text),json_write_dict(current_output,_{native:P,standing:"awaiting-explicit-human-approval"},[width(0)])),!.
