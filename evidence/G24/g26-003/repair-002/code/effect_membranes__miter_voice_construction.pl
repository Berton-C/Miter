% SC07 mechanics only: exact lexical/type transport, not semantic decisions.
:- ensure_loaded('miter_relational_voice.pl').
:- dynamic vc_thread/2,vc_result/2.
vc_word(W,true) :- atom(W),atom_length(W,N),N>0,N=<64,atom_codes(W,C),maplist(vc_word_char,C),!.
vc_word(_,false).
vc_budget(N,true) :- integer(N),N>=0,N=<4096,!.
vc_budget(_,false).
vc_word_char(C) :- code_type(C,alnum);memberchk(C,[0'_,0'-]).
vc_sentence(W,S) :- is_list(W),W\=[],maplist(atom,W),atomic_list_concat(W,' ',A),atom_concat(A,'.',B),atom_string(B,S).
vc_module(P,N) :- catch((miter_store_nonempty_atom(P,A),\+sub_atom(A,_,_,_,'..'),
 (vc_evidence_root(A);A=='/Users/claritymiter/miter/derived/voice-realization-seed-v2.json'),
 rv_json(A,D),vc_project(D,N)),_,fail),!.
vc_module(_,['malformed-candidate']).
vc_project(D,N) :- dict_pairs(D,_,Pairs),pairs_keys(Pairs,[allowed_effects,allowed_writes,candidate_id,constructions,purpose,schema]),
 string(D.schema),string(D.candidate_id),string_length(D.candidate_id,I),I>0,I=<100,
 string(D.purpose),string_length(D.purpose,L),L>0,L=<500,
 is_list(D.constructions),maplist(vc_construction,D.constructions,Cs),
 is_list(D.allowed_writes),maplist(string,D.allowed_writes),is_list(D.allowed_effects),maplist(string,D.allowed_effects),
 rv_native(['voice-realization',D.schema,D.candidate_id,D.purpose,Cs,D.allowed_writes,D.allowed_effects],N).
vc_construction(D,[construction,D.id,D.meaning,Tokens]) :- dict_pairs(D,_,Pairs),pairs_keys(Pairs,[id,meaning,tokens]),
 string(D.id),string_length(D.id,N),N>0,N=<100,string(D.meaning),is_list(D.tokens),maplist(vc_token,D.tokens,Tokens).
vc_token(S,[slot,Name]) :- string(S),sub_string(S,0,1,_,"@"),!,sub_string(S,1,_,0,Name).
vc_token(S,[literal,S]) :- string(S).
% SC08 explicitly extends only the laboratory evidence scope, not arbitrary paths.
vc_evidence_root(A) :- sub_atom(A,0,_,_,'/Users/claritymiter/miter/evidence/SC07/');sub_atom(A,0,_,_,'/Users/claritymiter/miter/evidence/SC08/').
vc_path(R,F,P) :- miter_store_nonempty_atom(R,A),vc_evidence_root(A),\+sub_atom(A,_,_,_,'..'),atom(F),\+sub_atom(F,_,_,_,'/'),directory_file_path(A,F,P).
vc_write(R,F,D) :- vc_path(R,F,P),\+exists_file(P),miter_store_write_json_atomic(P,D).
vc_verify(R) :- vc_path(R,'manifest.json',P),rv_json(P,M),
 forall(member(F,M.files),(crypto_file_hash(F.path,H,[algorithm(sha256),encoding(octet)]),atom_string(H,F.sha256))),
 forall(member(Rel,['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','src/voice_construction.metta','src/development_evidence.metta',
  'src/relational_voice.metta','src/grounded_language.metta','src/participation_support.metta','src/participation.metta','constitution/soul_compass_v02.metta',
  'src/bootstrap_voice_construction.metta','src/bootstrap_relational_voice.metta','src/bootstrap_grounded_language.metta',
  'effect_membranes/miter_voice_construction.pl','effect_membranes/miter_relational_voice.pl','effect_membranes/miter_llm.pl',
  'effect_membranes/miter_language.pl','effect_membranes/miter_store.pl','derived/voice-realization-seed-v2.json','config/voice-realization-schema-v2.json','config/local/g03-model-profiles.json']),
  (atom_concat('/Users/claritymiter/miter/',Rel,A),member(F,M.files),atom_string(A,F.path))),
 forall(member(Input,['receipts.json','grant.json','frame.json']),
  (vc_path(R,Input,IP),member(F,M.files),atom_string(IP,F.path))).
vc_record_receipts(R,Rows,'receipts-stored') :- vc_write(R,'receipts.json',_{records:Rows,standing:"synthetic-fixture-native-audits-not-natural-incidents"}).
vc_receipts(R,Rows) :- vc_verify(R),vc_path(R,'receipts.json',P),rv_json(P,D),rv_native(D.records,Rows).
vc_frame(R,F) :- vc_verify(R),vc_path(R,'frame.json',P),rv_json(P,D),rv_native(D.native,F).
vc_save(R,Kind,N,Result) :- memberchk(Kind,[opportunity,develop,result,cancellation]),
 catch((vc_verify(R),atom_concat(Kind,'.json',F),get_time(T),vc_write(R,F,_{native:N,stored_at:T})->Result=stored;Result='storage-or-integrity-failed'),_,Result='storage-or-integrity-failed'),!.
vc_start(R,Q,Result) :- catch((vc_start_checked(R,Q)->Result='worker-started';Result='request-preparation-failed'),E,(term_string(E,S),Result=['request-preparation-error',S])),!.
vc_start_checked(R,Q) :- vc_verify(R),
 Q=['expression-generation',Id,Scope,Alias,Grant,[opportunity,O],[parent,Parent],['constructive-context',Intention,Joints],[instruction,Instructions],['allowed-writes',Writes],['allowed-effects',Effects]],
 Alias=='qwen-local',Parent=='voice-realization-seed-v2',Grant=['development-grant',Scope,Calls,Tokens,Deadline],integer(Calls),Calls>0,Calls=<2,integer(Tokens),Tokens>0,Tokens=<1024,number(Deadline),Deadline>0,Deadline=<120,
 Writes==['trial-expression'],Effects==[],vc_path(R,'opportunity.json',OP),rv_json(OP,Stored),rv_native(Stored.native,O),
 vc_path(R,'develop.json',DP),rv_json(DP,DR),rv_native(DR.native,['develop-rna',Id,Scope,[opportunity,O],[next,'generate-quarantined-candidate']]),
 vc_receipts(R,Receipts),nth0(6,O,[basis,Basis]),forall(member(['repeated-relation',_,A,B],Basis),(nth0(4,A,AR),nth0(4,B,BR),memberchk(AR,Receipts),memberchk(BR,Receipts))),
 vc_path(R,'grant.json',GP),rv_json(GP,G),rv_native(G.native,Grant),
 vc_write(R,'generation-intention.json',_{native:Q}),miter_store_read_json('/Users/claritymiter/miter/config/voice-realization-schema-v2.json',Schema),atom_string(Id,IdS),
 with_output_to(string(User),json_write_dict(current_output,_{candidate_id:IdS,parent_module:Parent,intended_relations:Intention,joint_relations:Joints,allowed_writes:Writes,allowed_effects:Effects},[width(0)])),
 Template=_{schema:"miter-schema-request-v1",request_id:IdS,endpoint:"http://127.0.0.1:1234/v1/chat/completions",body:_{messages:[_{role:"system",content:Instructions},_{role:"user",content:User}],response_format:_{type:"json_schema",json_schema:_{name:"miter_voice_realization",strict:true,schema:Schema}},temperature:0,top_p:1,reasoning_effort:"none",max_tokens:Tokens,seed:7070,stream:false,ttl:300}},
 vc_write(R,'template.json',Template),vc_path(R,'template.json',TP),vc_path(R,'request.json',RP),miter_lm_prepare_request('/Users/claritymiter/miter/config/local/g03-model-profiles.json',Alias,TP,RP,'model-request-prepared'),
 get_time(T),vc_write(R,'worker-started.json',_{request_id:Id,started_at:T,deadline:Deadline}),thread_create(vc_worker(R,RP,Deadline),Thread,[]),assertz(vc_thread(R,Thread)).
vc_worker(R,RP,Deadline) :- catch(call_with_time_limit(Deadline,vc_fetch(R,RP,Result)),E,rv_error(E,Result)),
 assertz(vc_result(R,Result)),get_time(T),catch(vc_write(R,'transport-result.json',_{result:Result,finished_at:T}),_,true).
vc_fetch(R,RP,Result) :- vc_path(R,'raw.json',Raw),vc_path(R,'timing.json',Timing),miter_lm_execute_request_checked(RP,Raw,Timing,Status),
 (Status=='raw-model-response-stored'->
  (catch(rv_json(Raw,D),_,fail)->vc_parse_product(D,C,Parsed),(Parsed=='candidate-available'->vc_write(R,'candidate.json',C);true),Result=Parsed;Result='malformed-model-output')
 ;Result=['provider-incomplete',Status]).
vc_parse_product(D,_, 'model-truncated') :- catch((D.choices=[C|_],C.finish_reason=="length"),_,fail),!.
vc_parse_product(D,_, 'model-refusal') :- catch((D.choices=[C|_],get_dict(refusal,C.message,R),R\==null,R\==""),_,fail),!.
vc_parse_product(D,C,Result) :- (catch(miter_lm_provider_product(D,C),_,fail)->Result='candidate-available';Result='malformed-model-output').
vc_poll(R,X) :- (vc_result(R,V)->X=V;X=pending).
vc_pace(S,waited) :- S>=0,S=<0.1,sleep(S).
vc_control(R,E) :- (vc_path(R,'control.json',P),exists_file(P),catch(rv_json(P,D),_,fail),rv_native(D.event,E)->true;E=none).
vc_cancel(R,Result) :- get_time(T),vc_write(R,'stop-observed.json',_{observed_at:T}),
 (retract(vc_thread(R,Thread))->catch(thread_signal(Thread,throw(cancelled)),_,true),catch(thread_detach(Thread),_,true),Result='worker-cancel-requested';Result='no-active-worker').
vc_candidate(R,N) :- vc_path(R,'candidate.json',P),vc_module(P,N).
vc_binding(R,Result) :- catch((vc_verify(R),vc_path(R,'candidate.json',CP),rv_json(CP,C),vc_path(R,'raw.json',RP),rv_json(RP,Raw),miter_lm_provider_product(Raw,Actual),
 miter_store_canonical_json(C,J),miter_store_canonical_json(Actual,J),vc_path(R,'request.json',QP),rv_json(QP,Q),Q.request_id==C.candidate_id,
 vc_path(R,'timing.json',TP),rv_json(TP,T),T.http_status=:=200,vc_path(R,'generation-intention.json',IP),rv_json(IP,I),
 I.native=[_,Id,Scope,_,_,[_,O]|_],Id==C.candidate_id,vc_path(R,'opportunity.json',OP),rv_json(OP,S),S.native==O,O=[_,_,Scope|_],
 findall(_{file:F,sha256:H},(member(F,['receipts.json','grant.json','frame.json','candidate.json','raw.json','request.json','generation-intention.json','opportunity.json','develop.json']),vc_path(R,F,P),crypto_file_hash(P,H,[algorithm(sha256),encoding(octet)])),Files),
 crypto_file_hash('/Users/claritymiter/miter/derived/voice-realization-seed-v2.json',Parent,[algorithm(sha256),encoding(octet)]),
 vc_lineage(R,_{files:Files,parent_hash:Parent,standing:"candidate-not-accepted-development"})
 ->Result='model-candidate-bound';Result='unproven-model-candidate'),_,Result='unproven-model-candidate'),!.
% Recovery can re-check exactly the same lineage; different bytes never overwrite it.
vc_lineage(R,D) :- vc_path(R,'lineage.json',P),
 (exists_file(P)->rv_json(P,Old),miter_store_canonical_json(Old,J),miter_store_canonical_json(D,J);vc_write(R,'lineage.json',D)).
vc_space(Space,Atoms) :- findall(A,(current_predicate(Space/N),functor(H,Space,N),clause(H,true),H=..[_|A],ground(A)),Rows),msort(Rows,Atoms).
vc_snapshot(R,Name,Result) :- memberchk(Name,[before,after]),vc_space('&soul',S),vc_space('&history',H),vc_space('&derived',D),vc_space('&trial',T),vc_space('&compass',C),
 atom_concat(Name,'-spaces.json',F),vc_write(R,F,_{soul:S,history:H,derived:D,trial:T,compass:C}),Result='snapshot-stored'.
