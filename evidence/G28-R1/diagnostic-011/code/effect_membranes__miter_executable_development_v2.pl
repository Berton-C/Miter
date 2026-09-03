% G28 mechanics only: source identity, local model transport, inert projection,
% exact workshop requests and observed bytes. Admission/comparison is MeTTa.
:- ensure_loaded('miter_workshop_v1.pl').
:- use_module(library(utf8)).
:- ensure_loaded('miter_model_stream_v1.pl').
wy_root(R,A) :- miter_store_nonempty_atom(R,A),re_match('^/Users/claritymiter/miter/evidence/G28-R1/attempt-[0-9]+$',A),exists_directory(A),wy_no_links(A).
wy_no_links('/Users/claritymiter/miter/evidence/G28-R1') :- !.
wy_no_links(P) :- \+read_link(P,_,_),file_directory_name(P,D),D\==P,wy_no_links(D).
wy_path(R,F0,P) :- wy_root(R,A),miter_store_nonempty_atom(F0,F),re_match('^[a-zA-Z0-9_.-]+$',F),\+sub_atom(F,_,_,_,'..'),directory_file_path(A,F,P),\+read_link(P,_,_).
wy_verify(R,D) :- wy_path(R,'context.json',CP),rv_json(CP,D),D.schema=="miter-executable-context-v2",
 re_match('^/Users/claritymiter/miter/runtime/g27/attempt-281[0-9]{2}$',D.workshop_root),ww_grant(D.workshop_root,_),
 wy_path(R,'manifest.json',MP),rv_json(MP,M),forall(member(F,M.files),(crypto_file_hash(F.path,H,[algorithm(sha256),encoding(octet)]),atom_string(H,F.sha256))),
 forall(member(Rel,['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','src/executable_development_v2.metta','src/bootstrap_executable_development_v2.metta',
 'src/development_continuation_v1.metta','effect_membranes/miter_model_stream_v1.pl','src/participation.metta','src/participation_support.metta','constitution/soul_compass_v02.metta','src/bootstrap_grounded_language.metta',
 'effect_membranes/miter_executable_development_v2.pl','effect_membranes/miter_workshop_v1.pl','effect_membranes/miter_llm.pl',
 'config/executable-candidate-schema-v2.json','config/local/g03-model-profiles.json']),
  (atom_concat('/Users/claritymiter/miter/',Rel,P),member(E,M.files),atom_string(P,E.path))),
 forall(member(Name,['input.json','context.json']),(wy_path(R,Name,P),member(E,M.files),atom_string(P,E.path))).
wy_input(R,N) :- catch((wy_verify(R,_),wy_path(R,'input.json',P),rv_json(P,D),rv_native(D.native,N)),_,fail),!.
wy_input(_,['executable-input-unavailable']).
wy_grant_id(R,Id) :- wy_verify(R,D),ww_grant(D.workshop_root,G),atom_string(Id,G.grant_id).
wy_save(R,Name0,N,Result) :- catch(
 ((wy_verify(R,_),miter_store_nonempty_atom(Name0,Name),atom_concat(Name,'.json',F),wy_path(R,F,P),
   (exists_file(P)->rv_json(P,Old),tv_document_native(Old,N);tv_encode(N,Enc),tv_durable_json(P,_{native:N,term:Enc})))
  ->Result=stored;Result='executable-storage-incomplete'),_,Result='executable-storage-incomplete'),!.
wy_name(Prefix,N,Name) :- atom(Prefix),integer(N),N>=0,N=<1024,format(atom(Name),'~w-~d',[Prefix,N]).
wy_key(Prefix,Value,Name) :- atom(Prefix),tv_encode(Value,T),miter_store_canonical_json(T,J),
 crypto_data_hash(J,H,[algorithm(sha256),encoding(utf8)]),atomic_list_concat([Prefix,H],'-',Name).
wy_string(S,true) :- string(S),string_length(S,N),N>0,N=<131072,!.
wy_string(_,false).
wy_named(R,Id,Suffix,P) :- ww_id(Id,A),format(atom(F),'~w-~w.json',[A,Suffix]),wy_path(R,F,P).
wy_model(R,Q,Observation) :- catch((wy_model_checked(R,Q,Observation)->true;Observation=['model-unavailable',unstaged_or_invalid]),E,
 (term_string(E,S),Observation=['model-unavailable',S])),!.
wy_model_checked(R,Q,Observation) :- wy_verify(R,_),ground(Q),clause('&derived'('executable-generation-pending',R,Q),true),
 Q=['executable-generation',Id,O,Attempt,'qwen-local',Instructions,Feedback],
 integer(Attempt),Attempt>=1,string(Instructions),
 O=['executable-opportunity',_,_,Contract,_,['executable-grant',_,_,Calls,Tokens,Seconds],_],
 integer(Calls),Calls>=1,Calls=<2,Attempt=<Calls,integer(Tokens),Tokens>0,Tokens=<2048,integer(Seconds),Seconds>0,Seconds=<300,
 wy_path(R,'opportunity.json',OP),rv_json(OP,OD),tv_document_native(OD,O),
 wy_named(R,Id,generation,GP),(exists_file(GP)->rv_json(GP,G),tv_document_native(G,Q);tv_encode(Q,Enc),tv_durable_json(GP,_{native:Q,term:Enc})),
 wy_named(R,Id,observation,ObsPath),
 (exists_file(ObsPath)->rv_json(ObsPath,Stored),tv_document_native(Stored,Observation);
  wy_named(R,Id,request,RP),wy_named(R,Id,wire,Wire),wy_named(R,Id,header,Header),wy_named(R,Id,timing,Timing),
  (exists_file(RP)->
    (exists_file(Timing)->rv_json(Timing,TimingRecord);
     (exists_file(Wire)->size_file(Wire,Size);Size=0),
     (exists_file(Header)->rv_json(Header,HD),Http=HD.http_status;Http=0),
     TimingRecord=_{transport:unknown_after_preparation,http_status:Http,elapsed_ms:unknown,bytes:Size}),
    wy_observation(Id,Wire,TimingRecord,Observation);
   % mkdir is an exclusive inter-process spending claim, never removed/reused.
   wy_named(R,Id,claim,Claim),make_directory(Claim),wy_spend_claim(R,Id),
   rv_json('/Users/claritymiter/miter/config/executable-candidate-schema-v2.json',Schema),
   Contract=['executable-contract',_,_,_,_,Description,_],
   with_output_to(string(User),json_write_dict(current_output,_{contract:Description,diagnostics:Feedback},[width(0)])),
   Template=_{schema:"miter-schema-request-v1",request_id:Id,endpoint:"http://127.0.0.1:1234/v1/chat/completions",
    body:_{messages:[_{role:"system",content:Instructions},_{role:"user",content:User}],
     response_format:_{type:"json_schema",json_schema:_{name:"miter_executable_files",strict:true,schema:Schema}},
     temperature:0,top_p:1,reasoning_effort:"none",max_tokens:Tokens,seed:2801,stream:true,ttl:300}},
   wy_named(R,Id,template,TP),tv_durable_json(TP,Template),
   miter_lm_prepare_request('/Users/claritymiter/miter/config/local/g03-model-profiles.json','qwen-local',TP,RP,'model-request-prepared'),
   ms_capture(RP,Wire,Header,Seconds,2097152,TimingRecord),tv_durable_json(Timing,TimingRecord),
   wy_observation(Id,Wire,TimingRecord,Observation)),
  tv_encode(Observation,Encoded),tv_durable_json(ObsPath,_{native:Observation,term:Encoded})).

% This renewed experiment has two slots in total, not two per new directory.
% An uncertain claim is retained and counted, including a crash before send.
wy_spend_claim(R,Id) :-
 once((member(Slot,[1,2]),format(atom(P),'/Users/claritymiter/miter/evidence/G28-R1/call-~d.claim',[Slot]),
  \+exists_directory(P),catch(make_directory(P),_,fail))),
 directory_file_path(P,'owner.json',Owner),tv_durable_json(Owner,_{root:R,request:Id,slot:Slot}).

wy_observation(Id,Wire,T,['model-observation',Id,Transport,T.http_status,T.elapsed_ms,Done,Finish,Parse,T.bytes,Content,Files]) :-
 miter_store_nonempty_atom(T.transport,Transport),
 (exists_file(Wire)->ms_decode(Wire,Done,Finish,Parse,Content,Files,_);
  Done=false,Finish=unknown,Parse='missing-response',Content="",Files=[]).
wy_candidate_bound(R,Id,C,Result) :- catch((wy_verify(R,_),
 C=['executable-candidate',Id,Files,_],
 wy_named(R,Id,wire,Wire),wy_named(R,Id,timing,Timing),rv_json(Timing,T),
 crypto_file_hash(Wire,H,[algorithm(sha256),encoding(octet)]),atom_string(H,T.wire_sha256),
 wy_observation(Id,Wire,T,O),O=['model-observation',Id,eof,200,_,true,stop,'artifact-shaped',_,_,Files],
 wy_named(R,Id,observation,OP),rv_json(OP,D),tv_document_native(D,O)
 ->Result='candidate-source-bound';Result='candidate-source-unbound'),_,Result='candidate-source-unbound'),!.
wy_request(R,Label,Operation,Id,Fields,Result) :- catch((wy_verify(R,D),ww_grant(D.workshop_root,G),
 ww_id(Id,Candidate),ww_id(Label,L),ww_id(Operation,Op),format(atom(RId),'~w-~w',[Candidate,L]),
 maplist(wy_field,Fields,Pairs),dict_create(Extra,_,Pairs),
 Base=_{schema:"miter-workshop-request-v1",request_id:RId,idempotency_key:RId,grant_id:G.grant_id,operation:Op,candidate_id:Candidate},
 put_dict(Extra,Base,Request),format(atom(File),'request-~w.json',[RId]),ww_path(D.workshop_root,File,P),
 (exists_file(P)->rv_json(P,Old),miter_store_canonical_json(Old,J),miter_store_canonical_json(Request,J);tv_durable_json(P,Request)),
 ww_request(D.workshop_root,File,Result)),_,Result=['executable-workshop-unavailable']),!.
wy_field([Key,Value],Key-Value) :- atom(Key),memberchk(Key,[path,contents,test_id,message,lineage,proposal,commit]).
wy_event(R,Receipt,Event) :- wy_verify(R,D),Receipt=['workshop-result',_,_,Id,Hash],format(atom(File),'events/~w.json',[Id]),ww_path(D.workshop_root,File,P),rv_json(P,Event),
 miter_store_canonical_json(Event.payload,J),crypto_data_hash(J,Hash,[algorithm(sha256),encoding(utf8)]).
wy_observe(R,Id,Receipt,Observation) :- catch((wy_event(R,Receipt,E),E.payload.request.operation=="run_declared_test",atom_string(Id,E.payload.request.test_id),
 Details=E.payload.details,miter_store_nonempty_atom(Details.exit,Exit),
 re_matchsub('^exit[(]([0-9]+)[)]$',Exit,M,[]),number_string(Code,M.1),Details.truncated==false,
 string_codes(Details.stdout,Chars),phrase(utf8_codes(Chars),Bytes),Observation=['io-observation',Id,Code,Bytes]),_,fail),!.
wy_observe(_,Id,Receipt,['io-incomplete',Id,Receipt]).
wy_details(R,commit,Receipt,Commit) :- wy_event(R,Receipt,E),E.payload.status=="candidate-committed",Commit=E.payload.details.commit,!.
wy_details(R,lineage,Q,Text) :- wy_verify(R,_),Q=['executable-generation',Id|_],
 findall(_{file:Name,sha256:H},(member(Name,[generation,wire,request,observation,timing]),wy_named(R,Id,Name,P),crypto_file_hash(P,H,[algorithm(sha256),encoding(octet)])),Files),
 with_output_to(string(Text),json_write_dict(current_output,_{generation:Q,files:Files,standing:"Miter-origin candidate, trial is not promotion"},[width(0)])),!.
wy_details(R,proposal,P,Text) :- wy_verify(R,_),with_output_to(string(Text),json_write_dict(current_output,_{native:P,standing:"awaiting-explicit-human-approval"},[width(0)])),!.
