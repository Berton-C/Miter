% SC06 mechanics only: exact serialization, integrity, HTTP and inert schema
% projection. MeTTa owns opportunity, validation, quarantine and interpretation.
:- ensure_loaded('miter_relational_voice.pl').
:- dynamic vd_thread/2,vd_result/2.
vd_path(R,F,P) :- miter_store_nonempty_atom(R,A),sub_atom(A,0,_,_,'/Users/claritymiter/miter/evidence/SC06/'),\+sub_atom(A,_,_,_,'..'),directory_file_path(A,F,P).
vd_write(R,F,D) :- vd_path(R,F,P),\+exists_file(P),miter_store_write_json_atomic(P,D).
vd_verify(R) :- vd_path(R,'manifest.json',P),rv_json(P,M),
 forall(member(F,M.files),(crypto_file_hash(F.path,H,[algorithm(sha256),encoding(octet)]),atom_string(H,F.sha256))),
 forall(member(Rel,['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','src/voice_development.metta','src/relational_voice.metta',
  'src/grounded_language.metta','src/participation_support.metta','src/participation.metta','constitution/soul_compass_v02.metta',
  'src/bootstrap_voice_development.metta','src/bootstrap_relational_voice.metta','src/bootstrap_grounded_language.metta',
  'effect_membranes/miter_voice_development.pl','effect_membranes/miter_relational_voice.pl','effect_membranes/miter_llm.pl',
  'effect_membranes/miter_language.pl','effect_membranes/miter_store.pl','derived/voice-policy-seed.json','config/module-schema.json','config/local/g03-model-profiles.json']),
  (atom_concat('/Users/claritymiter/miter/',Rel,A),member(F,M.files),atom_string(A,F.path))),
 forall(member(Input,['receipts.json','grant.json']),
  (vd_path(R,Input,IP),member(F,M.files),atom_string(IP,F.path))).
vd_sentence(W,S) :- is_list(W),W\=[],maplist(atom,W),atomic_list_concat(W,' ',A),atom_concat(A,'.',B),atom_string(B,S).
% Laboratory input preparation stores actual native audit executions. It does
% not assert their semantic suitability; DRead recomputes that on consumption.
vd_record_receipts(R,Rows,'receipts-stored') :- vd_write(R,'receipts.json',_{records:Rows,standing:"synthetic-fixture-native-audits-not-natural-incidents"}).
vd_read_receipts(R,Rows) :- vd_verify(R),vd_path(R,'receipts.json',P),rv_json(P,D),rv_native(D.records,Rows).
vd_save(R,Kind,Native,Result) :- memberchk(Kind,[opportunity,develop,result,cancellation]),
 catch((vd_verify(R),atom_concat(Kind,'.json',F),get_time(T),vd_write(R,F,_{native:Native,stored_at:T})->Result=stored;Result='storage-or-integrity-failed'),_,Result='storage-or-integrity-failed'),!.
vd_start(R,Q,Result) :- catch((vd_start_checked(R,Q)->Result='worker-started';Result='request-preparation-failed'),E,(term_string(E,S),Result=['request-preparation-error',S])),!.
vd_start_checked(R,Q) :- vd_verify(R),
 Q=['module-generation',Id,Scope,Alias,Grant,[opportunity,O],[parent,Parent],[instruction,Instructions],[ 'allowed-writes',Writes],['allowed-effects',Effects]],
 Alias=='qwen-local',Parent=='voice-policy-seed-v1',Grant=['development-grant',Scope,Calls,Tokens,Deadline],Calls>0,Calls=<2,Tokens>0,Tokens=<1024,Deadline>0,Deadline=<120,
 Writes==['trial-guidance'],Effects==[],vd_path(R,'opportunity.json',OP),rv_json(OP,Stored),rv_native(Stored.native,O),
 vd_path(R,'develop.json',DP),rv_json(DP,DR),rv_native(DR.native,['develop-rna',Id,Scope,[opportunity,O],[next,'generate-quarantined-candidate']]),
 % This checks exact source references, not whether they justify development.
 vd_path(R,'receipts.json',EP),rv_json(EP,ED),rv_native(ED.records,Receipts),
 nth0(6,O,[basis,Basis]),forall(member([ 'repeated-relation',_,A,B],Basis),
  (nth0(4,A,AR),nth0(4,B,BR),memberchk(AR,Receipts),memberchk(BR,Receipts))),
 vd_path(R,'grant.json',GP),rv_json(GP,G),rv_native(G.native,Grant),
 vd_write(R,'generation-intention.json',_{native:Q}),
 miter_store_read_json('/Users/claritymiter/miter/config/module-schema.json',Schema),atom_string(Id,IdS),
 % Minimum context: source event identities and grounded repair class/values.
 O=['development-opportunity',_,Scope,[target,Target],['soul-ground',Ground],['source-events',Events]|_],
 with_output_to(string(User),json_write_dict(current_output,_{candidate_id:IdS,target:Target,soul_ground:Ground,source_events:Events,parent_module:Parent,allowed_writes:Writes,allowed_effects:Effects},[width(0)])),
 Template=_{schema:"miter-schema-request-v1",request_id:IdS,endpoint:"http://127.0.0.1:1234/v1/chat/completions",body:_{messages:[_{role:"system",content:Instructions},_{role:"user",content:User}],response_format:_{type:"json_schema",json_schema:_{name:"miter_voice_policy",strict:true,schema:Schema}},temperature:0,top_p:1,reasoning_effort:"none",max_tokens:Tokens,seed:6060,stream:false,ttl:300}},
 vd_write(R,'template.json',Template),vd_path(R,'template.json',TP),vd_path(R,'request.json',RP),
 miter_lm_prepare_request('/Users/claritymiter/miter/config/local/g03-model-profiles.json',Alias,TP,RP,'model-request-prepared'),
 get_time(T),vd_write(R,'worker-started.json',_{request_id:Id,started_at:T,deadline:Deadline}),
 thread_create(vd_worker(R,RP,Deadline),Thread,[]),assertz(vd_thread(R,Thread)).
vd_worker(R,RP,Deadline) :- catch(call_with_time_limit(Deadline,vd_fetch(R,RP,Result)),E,rv_error(E,Result)),
 assertz(vd_result(R,Result)),get_time(T),catch(vd_write(R,'transport-result.json',_{result:Result,finished_at:T}),_,true).
vd_fetch(R,RP,Result) :- vd_path(R,'raw.json',Raw),vd_path(R,'timing.json',Timing),
 miter_lm_execute_request_checked(RP,Raw,Timing,Status),
 (Status=='raw-model-response-stored'->
  (catch(rv_json(Raw,D),_,fail)->vd_parse_product(D,C,Parsed),
   (Parsed=='candidate-available'->vd_write(R,'candidate.json',C);true),Result=Parsed;Result='malformed-model-output')
 ;Result=['provider-incomplete',Status]).
vd_parse_product(D,_, 'model-truncated') :- catch((D.choices=[C|_],C.finish_reason=="length"),_,fail),!.
vd_parse_product(D,_, 'model-refusal') :- catch((D.choices=[C|_],get_dict(refusal,C.message,R),R\==null,R\==""),_,fail),!.
vd_parse_product(D,C,Result) :- (catch(miter_lm_provider_product(D,C),_,fail)->Result='candidate-available';Result='malformed-model-output').
vd_poll(R,Result) :- (vd_result(R,X)->Result=X;Result=pending).
vd_pace(S,waited) :- S>=0,S=<0.1,sleep(S).
vd_control(R,Event) :- (vd_path(R,'control.json',P),exists_file(P),catch(rv_json(P,D),_,fail),rv_native(D.event,Event)->true;Event=none).
vd_cancel(R,Result) :- get_time(T),vd_write(R,'stop-observed.json',_{observed_at:T}),
 (retract(vd_thread(R,Thread))->catch(thread_signal(Thread,throw(cancelled)),_,true),catch(thread_detach(Thread),_,true),Result='worker-cancel-requested';Result='no-active-worker').
vd_candidate(R,Native) :- catch((vd_path(R,'candidate.json',P),rv_json(P,D),
 dict_pairs(D,_,Pairs),pairs_keys(Pairs,[allowed_effects,allowed_writes,candidate_id,purpose,rules,schema]),
 string(D.schema),string(D.candidate_id),string(D.purpose),string_length(D.purpose,L),L>0,L=<500,
 is_list(D.rules),is_list(D.allowed_writes),maplist(string,D.allowed_writes),is_list(D.allowed_effects),maplist(string,D.allowed_effects),
 maplist(vd_rule,D.rules,Rules),rv_native([ 'voice-policy',D.schema,D.candidate_id,D.purpose,Rules,D.allowed_writes,D.allowed_effects],Native)),_,fail),!.
vd_candidate(_,['malformed-candidate']).
vd_rule(D,[rule,C,V,A,N]) :- dict_pairs(D,_,Pairs),pairs_keys(Pairs,[action,condition,value,variant]),
 string(D.condition),string(D.value),string(D.action),integer(D.variant),rv_native([D.condition,D.value,D.action,D.variant],[C,V,A,N]).
vd_binding(R,Result) :- catch((vd_verify(R),vd_path(R,'candidate.json',CP),rv_json(CP,C),
 vd_path(R,'raw.json',RP),rv_json(RP,Raw),miter_lm_provider_product(Raw,Actual),
 miter_store_canonical_json(C,J),miter_store_canonical_json(Actual,J),
 vd_path(R,'request.json',QP),rv_json(QP,Q),Q.request_id==C.candidate_id,
 vd_path(R,'timing.json',TP),rv_json(TP,T),T.http_status=:=200,
 vd_path(R,'generation-intention.json',IP),rv_json(IP,I),I.native=[_,Id,Scope,_,_,[_,O]|_],atom_string(IdA,Id),atom_string(IdA,C.candidate_id),
 vd_path(R,'opportunity.json',OP),rv_json(OP,S),S.native==O,O=[_,_,Scope|_],
 findall(_{file:F,sha256:H},(member(F,['receipts.json','grant.json','candidate.json','raw.json','request.json','generation-intention.json','opportunity.json','develop.json']),vd_path(R,F,P),crypto_file_hash(P,H,[algorithm(sha256),encoding(octet)])),Files),
 crypto_file_hash('/Users/claritymiter/miter/derived/voice-policy-seed.json',Parent,[algorithm(sha256),encoding(octet)]),
 vd_write(R,'lineage.json',_{files:Files,parent_hash:Parent,standing:"candidate-not-accepted-development"})
 ->Result='model-candidate-bound';Result='unproven-model-candidate'),_,Result='unproven-model-candidate'),!.
vd_space(Space,Atoms) :- findall(A,(current_predicate(Space/N),functor(H,Space,N),clause(H,true),H=..[_|A],ground(A)),Rows),msort(Rows,Atoms).
vd_snapshot(R,Name,Result) :- memberchk(Name,[before,after]),vd_space('&soul',S),vd_space('&history',H),vd_space('&derived',D),vd_space('&trial',T),
 vd_space('&compass',C),atom_concat(Name,'-spaces.json',F),vd_write(R,F,_{soul:S,history:H,derived:D,trial:T,compass:C}),Result='snapshot-stored'.
