% G28 mechanics only: source identity, local model transport, inert projection,
% exact workshop requests and observed bytes. Admission/comparison is MeTTa.
:- ensure_loaded('miter_workshop_v1.pl').
:- use_module(library(utf8)).
:- ensure_loaded('miter_model_stream_v1.pl').
wz_root(R,A) :- miter_store_nonempty_atom(R,A),re_match('^/Users/claritymiter/miter/evidence/G28-R2/attempt-[0-9]+$',A),exists_directory(A),wz_no_links(A).
wz_no_links('/Users/claritymiter/miter/evidence/G28-R2') :- !.
wz_no_links(P) :- \+read_link(P,_,_),file_directory_name(P,D),D\==P,wz_no_links(D).
wz_path(R,F0,P) :- wz_root(R,A),miter_store_nonempty_atom(F0,F),re_match('^[a-zA-Z0-9_.-]+$',F),\+sub_atom(F,_,_,_,'..'),directory_file_path(A,F,P),\+read_link(P,_,_).
wz_verify(R,D) :- wz_path(R,'context.json',CP),rv_json(CP,D),D.schema=="miter-executable-context-v3",
 re_match('^/Users/claritymiter/miter/runtime/g27/attempt-282[0-9]{2}$',D.workshop_root),ww_grant(D.workshop_root,_),
 wz_path(R,'manifest.json',MP),rv_json(MP,M),forall(member(F,M.files),(crypto_file_hash(F.path,H,[algorithm(sha256),encoding(octet)]),atom_string(H,F.sha256))),
 forall(member(Rel,['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','src/executable_development_v3.metta','src/bootstrap_executable_development_v3.metta',
 'src/development_continuation_v1.metta','src/executable_partial_revision_v1.metta','effect_membranes/miter_model_stream_v1.pl','src/participation.metta','src/participation_support.metta','constitution/soul_compass_v02.metta','src/bootstrap_grounded_language.metta',
 'effect_membranes/miter_executable_development_v3.pl','effect_membranes/miter_workshop_v1.pl','effect_membranes/miter_llm.pl',
 'config/executable-candidate-schema-v3.json','config/local/g03-model-profiles.json']),
  (atom_concat('/Users/claritymiter/miter/',Rel,P),member(E,M.files),atom_string(P,E.path))),
 forall(member(Name,['input.json','context.json']),(wz_path(R,Name,P),member(E,M.files),atom_string(P,E.path))),
 D.prior_root=="/Users/claritymiter/miter/evidence/G28-R1/attempt-003",
 forall(member(Name,['candidate-1.json','trial-1.json','executable-1-wire.json','executable-1-timing.json']),
  (directory_file_path(D.prior_root,Name,P),member(E,M.files),atom_string(P,E.path))).
wz_input(R,N) :- catch((wz_verify(R,_),wz_path(R,'input.json',P),rv_json(P,D),rv_native(D.native,N)),_,fail),!.
wz_input(_,['executable-input-unavailable']).
wz_grant_id(R,Id) :- wz_verify(R,D),ww_grant(D.workshop_root,G),atom_string(Id,G.grant_id).
wz_prior(R,['prior-executable-trial',C,T,['retained-history',D.prior_root,CH,TH]]) :-
 wz_verify(R,D),directory_file_path(D.prior_root,'candidate-1.json',CP),rv_json(CP,CD),tv_document_native(CD,C),
 directory_file_path(D.prior_root,'trial-1.json',TP),rv_json(TP,TD),tv_document_native(TD,T),
 T=['executable-trial',C,_,_,_],C=['executable-candidate',_,Files,_],
 directory_file_path(D.prior_root,'executable-1-wire.json',Wire),directory_file_path(D.prior_root,'executable-1-timing.json',Time),rv_json(Time,Timing),
 crypto_file_hash(Wire,WH,[algorithm(sha256),encoding(octet)]),atom_string(WH,Timing.wire_sha256),
 ms_decode(Wire,true,stop,'artifact-shaped',_,Files,_),
 crypto_file_hash(CP,CH,[algorithm(sha256),encoding(octet)]),crypto_file_hash(TP,TH,[algorithm(sha256),encoding(octet)]),!.
wz_prior(_,['prior-executable-unavailable']).
wz_save(R,Name0,N,Result) :- catch(
 ((wz_verify(R,_),miter_store_nonempty_atom(Name0,Name),atom_concat(Name,'.json',F),wz_path(R,F,P),
   (exists_file(P)->rv_json(P,Old),tv_document_native(Old,N);tv_encode(N,Enc),tv_durable_json(P,_{native:N,term:Enc})))
  ->Result=stored;Result='executable-storage-incomplete'),_,Result='executable-storage-incomplete'),!.
wz_name(Prefix,N,Name) :- atom(Prefix),integer(N),N>=0,N=<1024,format(atom(Name),'~w-~d',[Prefix,N]).
wz_key(Prefix,Value,Name) :- atom(Prefix),tv_encode(Value,T),miter_store_canonical_json(T,J),
 crypto_data_hash(J,H,[algorithm(sha256),encoding(utf8)]),atomic_list_concat([Prefix,H],'-',Name).
wz_string(S,true) :- string(S),string_length(S,N),N>0,N=<131072,!.
wz_string(_,false).
wz_named(R,Id,Suffix,P) :- ww_id(Id,A),format(atom(F),'~w-~w.json',[A,Suffix]),wz_path(R,F,P).
wz_model(R,Q,Observation) :- catch((wz_model_checked(R,Q,Observation)->true;Observation=['model-unavailable',unstaged_or_invalid]),E,
 (term_string(E,S),Observation=['model-unavailable',S])),!.
wz_model_checked(R,Q,Observation) :- wz_verify(R,_),ground(Q),clause('&derived'('executable-generation-pending',R,Q),true),
 Q=['executable-generation',Id,O,Attempt,'qwen-local',Instructions,Feedback],
 integer(Attempt),Attempt>=1,string(Instructions),
 O=['executable-opportunity',_,_,Contract,_,['executable-grant',_,_,Calls,Tokens,Seconds],_],
 integer(Calls),Calls>=1,Calls=<4,Attempt=<Calls,integer(Tokens),Tokens>0,Tokens=<2048,integer(Seconds),Seconds>0,Seconds=<300,
 wz_path(R,'opportunity.json',OP),rv_json(OP,OD),tv_document_native(OD,O),
 wz_named(R,Id,generation,GP),(exists_file(GP)->rv_json(GP,G),tv_document_native(G,Q);tv_encode(Q,Enc),tv_durable_json(GP,_{native:Q,term:Enc})),
 wz_named(R,Id,observation,ObsPath),
 (exists_file(ObsPath)->rv_json(ObsPath,Stored),tv_document_native(Stored,Observation);
  wz_named(R,Id,request,RP),wz_named(R,Id,wire,Wire),wz_named(R,Id,header,Header),wz_named(R,Id,timing,Timing),
  (exists_file(RP)->
    (exists_file(Timing)->rv_json(Timing,TimingRecord);
     (exists_file(Wire)->size_file(Wire,Size);Size=0),
     (exists_file(Header)->rv_json(Header,HD),Http=HD.http_status;Http=0),
     TimingRecord=_{transport:unknown_after_preparation,http_status:Http,elapsed_ms:unknown,bytes:Size}),
    wz_observation(Id,Wire,TimingRecord,Observation);
   % mkdir is an exclusive inter-process spending claim, never removed/reused.
   wz_named(R,Id,claim,Claim),make_directory(Claim),wz_spend_claim(R,Id),
   rv_json('/Users/claritymiter/miter/config/executable-candidate-schema-v3.json',Schema),
   Contract=['executable-contract',_,_,_,_,Description,_],
 with_output_to(string(User),json_write_dict(current_output,_{contract:Description,diagnostics:Feedback},[width(0)])),
   Template=_{schema:"miter-schema-request-v1",request_id:Id,endpoint:"http://127.0.0.1:1234/v1/chat/completions",
    body:_{messages:[_{role:"system",content:Instructions},_{role:"user",content:User}],
     response_format:_{type:"json_schema",json_schema:_{name:"miter_executable_files",strict:true,schema:Schema}},
     temperature:0,top_p:1,reasoning_effort:"none",max_tokens:Tokens,seed:2801,stream:true,ttl:300}},
   wz_named(R,Id,template,TP),tv_durable_json(TP,Template),
   miter_lm_prepare_request('/Users/claritymiter/miter/config/local/g03-model-profiles.json','qwen-local',TP,RP,'model-request-prepared'),
   ms_capture(RP,Wire,Header,Seconds,2097152,TimingRecord),tv_durable_json(Timing,TimingRecord),
   wz_observation(Id,Wire,TimingRecord,Observation)),
  tv_encode(Observation,Encoded),tv_durable_json(ObsPath,_{native:Observation,term:Encoded})).

% This renewed experiment has four slots in total, not four per new directory.
% An uncertain claim is retained and counted, including a crash before send.
wz_spend_claim(R,Id) :-
 (once((member(Slot,[1,2,3,4]),format(atom(P),'/Users/claritymiter/miter/evidence/G28-R2/call-~d.claim',[Slot]),
  \+exists_directory(P),catch(make_directory(P),_,fail)))->true;
  throw(error(model_grant_exhausted,'G28-R2 has four retained spending claims'))),
 directory_file_path(P,'owner.json',Owner),tv_durable_json(Owner,_{root:R,request:Id,slot:Slot}).

wz_observation(Id,Wire,T,['model-observation',Id,Transport,T.http_status,T.elapsed_ms,Done,Finish,Parse,T.bytes,Content,Files]) :-
 miter_store_nonempty_atom(T.transport,Transport),
 (exists_file(Wire)->ms_decode(Wire,Done,Finish,OriginalParse,Content,_,_),
   (OriginalParse=='malformed-stream'->Parse=OriginalParse,Files=[];
    catch(atom_json_dict(Content,Product,[]),_,fail)->
     (is_dict(Product),dict_pairs(Product,_,[smoke-Text]),string(Text),string_length(Text,N),N>0,N=<131072
      ->ms_file("candidate_tests/smoke.sh",Text,File),Files=[File],Parse='artifact-shaped';Parse='schema-mismatch',Files=[])
     ;Parse='malformed-artifact',Files=[]);
  Done=false,Finish=unknown,Parse='missing-response',Content="",Files=[]).
wz_candidate_bound(R,Id,C,Result) :- catch((wz_verify(R,_),
 C=['executable-candidate',Id,Files,_],
 atom(Id),re_matchsub('^executable-([0-9]+)$',Id,Match,[]),number_string(N,Match.1),
 format(atom(CF),'candidate-~d.json',[N]),wz_path(R,CF,CP),rv_json(CP,CD),tv_document_native(CD,C),
 wz_named(R,Id,wire,Wire),wz_named(R,Id,timing,Timing),rv_json(Timing,T),
 crypto_file_hash(Wire,H,[algorithm(sha256),encoding(octet)]),atom_string(H,T.wire_sha256),
 wz_observation(Id,Wire,T,O),O=['model-observation',Id,eof,200,_,true,stop,'artifact-shaped',_,_,Generated],
 wz_named(R,Id,observation,OP),rv_json(OP,D),tv_document_native(D,O),
 format(atom(RF),'revision-~d.json',[N]),wz_path(R,RF,RPath),rv_json(RPath,RD),tv_document_native(RD,Revision),
 Revision=['partial-revision',Targets,Retained,[],_],Targets=[['candidate-file',"candidate_tests/smoke.sh",_,_]],
 wz_prior(R,['prior-executable-trial',Prior,_,_]),Prior=['executable-candidate',_,PriorFiles,_],
 forall(member(F,Retained),memberchk(F,PriorFiles)),
 append(Retained,Generated,Files),
 wz_path(R,'opportunity.json',OPath),rv_json(OPath,OD),tv_document_native(OD,Opportunity),
 Opportunity=['executable-opportunity',_,_,Contract,_,_,_],
 Prior=['executable-candidate',_,_,['extension-manifest',Source,_,In,Out|_]],
 Contract=['executable-contract',Source,_,In,Out,_,_]
 ->Result='candidate-source-bound';Result='candidate-source-unbound'),_,Result='candidate-source-unbound'),!.
wz_disk_bound(R,Id,C,Result) :- catch(((wz_verify(R,D),C=['executable-candidate',Id,Files,_],
 ww_state(D.workshop_root,Id,S),
 forall(member(['candidate-file',Rel,Text,H],Files),
  (ww_candidate_path(D.workshop_root,S,Rel,P),read_file_to_string(P,Text,[]),crypto_file_hash(P,H,[algorithm(sha256),encoding(octet)])))
 ->Result='candidate-disk-bound';Result='candidate-disk-unbound'),_,Result='candidate-disk-unbound'),!.
wz_request(R,Label,Operation,Id,Fields,Result) :- catch((wz_verify(R,D),ww_grant(D.workshop_root,G),
 ww_id(Id,Candidate),ww_id(Label,L),ww_id(Operation,Op),format(atom(RId),'~w-~w',[Candidate,L]),
 maplist(wz_field,Fields,Pairs),dict_create(Extra,_,Pairs),
 Base=_{schema:"miter-workshop-request-v1",request_id:RId,idempotency_key:RId,grant_id:G.grant_id,operation:Op,candidate_id:Candidate},
 put_dict(Extra,Base,Request),format(atom(File),'request-~w.json',[RId]),ww_path(D.workshop_root,File,P),
 (exists_file(P)->rv_json(P,Old),miter_store_canonical_json(Old,J),miter_store_canonical_json(Request,J);tv_durable_json(P,Request)),
 ww_request(D.workshop_root,File,Result)),_,Result=['executable-workshop-unavailable']),!.
wz_field([Key,Value],Key-Value) :- atom(Key),memberchk(Key,[path,contents,test_id,message,lineage,proposal,commit]).
wz_event(R,Receipt,Event) :- wz_verify(R,D),Receipt=['workshop-result',_,_,Id,Hash],format(atom(File),'events/~w.json',[Id]),ww_path(D.workshop_root,File,P),rv_json(P,Event),
 miter_store_canonical_json(Event.payload,J),crypto_data_hash(J,Hash,[algorithm(sha256),encoding(utf8)]).
wz_observe(R,Id,Receipt,Observation) :- catch((wz_event(R,Receipt,E),E.payload.request.operation=="run_declared_test",atom_string(Id,E.payload.request.test_id),
 Details=E.payload.details,miter_store_nonempty_atom(Details.exit,Exit),
 re_matchsub('^exit[(]([0-9]+)[)]$',Exit,M,[]),number_string(Code,M.1),Details.truncated==false,
 string_codes(Details.stdout,Chars),phrase(utf8_codes(Chars),Bytes),Observation=['io-observation',Id,Code,Bytes]),_,fail),!.
wz_observe(_,Id,Receipt,['io-incomplete',Id,Receipt]).
wz_test_observation(R,Id,Receipt,Observation) :- catch((wz_event(R,Receipt,E),
 E.payload.request.operation=="run_declared_test",atom_string(Id,E.payload.request.test_id),D=E.payload.details,
 miter_store_nonempty_atom(D.exit,Exit),re_matchsub('^exit[(]([0-9]+)[)]$',Exit,M,[]),number_string(Code,M.1),
 Observation=['process-observation',Id,Code,D.stdout,D.stderr,D.truncated,Receipt]),_,fail),!.
wz_test_observation(_,Id,Receipt,['process-incomplete',Id,Receipt]).
wz_environment(R,['runtime-dependencies','posix-shell','workshop-contract-v1',Hash,Text]) :- wz_verify(R,_),
 P='/Users/claritymiter/miter/config/workshop-contract-v1.json',crypto_file_hash(P,Hash,[algorithm(sha256),encoding(octet)]),
 read_file_to_string(P,Text,[]).
wz_details(R,commit,Receipt,Commit) :- wz_event(R,Receipt,E),E.payload.status=="candidate-committed",Commit=E.payload.details.commit,!.
wz_details(R,lineage,Q,Text) :- wz_verify(R,_),Q=['executable-generation',Id|_],
 findall(_{file:Name,sha256:H},(member(Name,[generation,wire,request,observation,timing]),wz_named(R,Id,Name,P),crypto_file_hash(P,H,[algorithm(sha256),encoding(octet)])),Files),
 wz_prior(R,Prior),with_output_to(string(Text),json_write_dict(current_output,_{generation:Q,files:Files,prior:Prior,standing:"Miter-origin partial candidate, retained files preserve original model ancestry; trial is not promotion"},[width(0)])),!.
wz_details(R,proposal,P,Text) :- wz_verify(R,_),with_output_to(string(Text),json_write_dict(current_output,_{native:P,standing:"awaiting-explicit-human-approval"},[width(0)])),!.
