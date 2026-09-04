% G33 R12 transport, exact-source projection and durable commit mechanics.
% Selection, semantic validation, trial adjudication, NAL revision and later
% ranking remain in PeTTa/MeTTa.
:- ensure_loaded('miter_development_reactor_v1.pl').
:- ensure_loaded('miter_openrouter.pl').
:- ensure_loaded('miter_voice_construction.pl').
:- ensure_loaded('miter_voice_trials_v2.pl').

nn_number(N,Kind,true) :- catch((number(N),N>=0,
 (Kind==frequency->N=<1;Kind==confidence,N<1)),_,fail),!.
nn_number(_,_,false).

dh_root(R,A) :- miter_store_nonempty_atom(R,A),
 (sub_atom(A,0,_,_,'/Users/claritymiter/miter/evidence/G33/R12/');
  sub_atom(A,0,_,_,'/Users/claritymiter/miter/evidence/G33/R13/')),
 \+sub_atom(A,_,_,_,'..'),\+sub_atom(A,_,_,_,'//'),exists_directory(A),dh_no_links(A).
dh_no_links('/Users/claritymiter/miter/evidence/G33/R12') :- !.
dh_no_links('/Users/claritymiter/miter/evidence/G33/R13') :- !.
dh_no_links(A) :- \+read_link(A,_,_),file_directory_name(A,P),P\==A,dh_no_links(P).
dh_path(R,F,P) :- dh_root(R,A),atom(F),\+sub_atom(F,_,_,_,'/'),\+sub_atom(F,_,_,_,'..'),
 directory_file_path(A,F,P),\+read_link(P,_,_).
dh_json(P,D) :- setup_call_cleanup(open(P,read,S,[encoding(utf8)]),json_read_dict(S,D),close(S)).
dh_sha(P,S) :- crypto_file_hash(P,H,[algorithm(sha256),encoding(octet)]),atom_string(H,S).
dh_document_native(D,N) :- (is_dict(D),get_dict(term,D,T)->tv_decode(T,N),
 miter_store_canonical_json(N,J),miter_store_canonical_json(D.native,J)
 ;is_dict(D),get_dict(native,D,N0)->vc_native(N0,N);vc_native(D,N)).
dh_entry(Files,P,S) :- member(E,Files),get_dict(path,E,P),get_dict(sha256,E,S),dh_sha(P,S).
dh_verify(R) :- dh_path(R,'manifest.json',MP),dh_json(MP,M),
 get_dict(schema,M,Schema),memberchk(Schema,["miter-g33-r12-manifest-v1","miter-g33-r13-manifest-v1"]),
 get_dict(files,M,Files),is_list(Files),
 forall(member(E,Files),(get_dict(path,E,P),get_dict(sha256,E,S),string(P),string(S),dh_entry(Files,P,S))),
 dh_path(R,'input.json',IP),dh_path(R,'authorization.json',AP),
 member(EI,Files),get_dict(path,EI,IPS),atom_string(IP,IPS),
 member(EA,Files),get_dict(path,EA,APS),atom_string(AP,APS).

dh_source_file(D,Key,Path,Hash) :- get_dict(Key,D,S),Path=S.path,Hash=S.sha256,dh_sha(Path,Hash).
dh_source(D,Key,Path,Native,Hash) :- dh_source_file(D,Key,Path,Hash),dh_json(Path,J),dh_document_native(J,Native).
dh_waiting(D,['waiting-checkpoint',Id,Scope,Old,Grant,Parent,Context,Instruction,Writes,Effects,
 pending,'awaiting-model-result',StateHash,RequestHash]) :-
 dh_source(D,r11_state,_,State,StateHash),
 State=['development-life',Id,Scope,pending,_,Grant,_,_,_, 'awaiting-model-result'],
 dh_source(D,r11_request,_,Request,RequestHash),
 Request=['unapplied-effects',Dispatches,'authority-awaiting-separate-authorization'],
 member(Dispatch,Dispatches),Dispatch=['dispatch',Generation|_],
 Generation=['expression-generation',Id,Scope,Old,Grant,_,['parent',Parent],
  ['constructive-context'|ContextTail],['instruction',Instruction],Writes,Effects],
 Context=['constructive-context'|ContextTail],
 Writes=['allowed-writes',['trial-expression']],Effects=['allowed-effects',[]].

dh_limit(D,['resource-limits',Max,Deadline,Capture]) :-
 (get_dict(limits,D,L)->Max=L.max_output_tokens,Deadline=L.deadline_seconds,Capture=L.capture_bytes
 ; Max=unspecified,Deadline=unspecified,Capture=unspecified).
dh_credential(D,Standing) :-
 (get_dict(credential_reference,D,C),is_dict(C)->Standing=['credential-reference',C.source,C.account,C.service]
 ; Standing='no-credential').
dh_resource(D,['model-resource',Id,Kind,Model,Enabled,Roles,Adapter,Limits,Credential]) :-
 miter_store_nonempty_atom(D.id,Id),miter_store_nonempty_atom(D.kind,Kind),
 (get_dict(model,D,M)->miter_store_nonempty_atom(M,Model);Model=none),
 Enabled=D.enabled,maplist(miter_store_nonempty_atom,D.roles,Roles),
 miter_store_nonempty_atom(D.adapter,Adapter),dh_limit(D,Limits),dh_credential(D,Credential).
dh_registry(Resources,['operator-preference',Preference,Standing,Fallback,Silent]) :-
 or_profile_path(P),dh_json(P,D),D.schema=="miter-model-resource-registry-v1",
 maplist(dh_resource,D.resources,Resources),miter_store_nonempty_atom(D.selection.operator_preference,Preference),
 miter_store_nonempty_atom(D.selection.preference_standing,Standing),
 miter_store_nonempty_atom(D.selection.fallback_policy,Fallback),Silent=D.selection.silent_model_substitution.
dh_authorization(R,['provider-authorization',Resource,Model,Request,Calls,Tokens,Deadline,Disclosure,Standing]) :-
 dh_path(R,'authorization.json',P),dh_json(P,D),D.schema=="miter-provider-authorization-v1",
 miter_store_nonempty_atom(D.resource_id,Resource),miter_store_nonempty_atom(D.model,Model),
 miter_store_nonempty_atom(D.request_id,Request),Calls=D.max_calls,Tokens=D.max_output_tokens,
 Deadline=D.deadline_seconds,maplist(miter_store_nonempty_atom,D.disclosure,Disclosure),
 miter_store_nonempty_atom(D.standing,Standing).
dh_input(R,N) :- catch((dh_verify(R),dh_path(R,'input.json',P),dh_json(P,D),
 dh_waiting(D,Waiting),dh_registry(Resources,Preference),dh_authorization(R,Authorization),
 N=['development-helix-input',Waiting,['model-resources',Resources],Preference,Authorization]),_,fail),!.
dh_input(_,['development-helix-input-unavailable']).
dh_outcome(R,State) :- catch(((dh_path(R,'final.json',P),exists_file(P),dh_json(P,D),
 dh_document_native(D,Final),State=['development-helix-closed',Final])
 -> true ; State='development-helix-open'),_,State='development-helix-open'),!.

dh_save(R,Name,N,Result) :- memberchk(Name,[selection,generation,product,quarantine,trial,'efficacy-before',
 'efficacy-after',final,restart,'severed-selection','neutral-selection']),atom_concat(Name,'.json',F),
 catch((dh_verify(R),dh_path(R,F,P),(exists_file(P)->dh_json(P,D),dh_document_native(D,N)
  ;tv_encode(N,T),tv_durable_json(P,_{native:N,term:T}))->Result=stored;Result='helix-storage-incomplete'),
  _,Result='helix-storage-incomplete'),!.

dh_request_valid(R,Q) :-
 dh_input(R,['development-helix-input',Checkpoint,_,_,Authorization]),
 Checkpoint=['waiting-checkpoint',Candidate,Scope,Old,Grant,Parent,Context,Instruction,Writes,Effects,
  pending,'awaiting-model-result',StateHash,RequestHash],
 Q=['development-generation-call','g33-r12-generation-2',Candidate,Scope,Old,Selection,Grant,
  Parent,Context,Instruction,Writes,Effects,StateHash,RequestHash],
 Selection=['resource-selected','openrouter-glm53','z-ai/glm-5.3',_,
  ['preference-basis','operator-preference','evidence-not-authority']],
 Authorization=['provider-authorization','openrouter-glm53','z-ai/glm-5.3','g33-r12-generation-2',1,4096,120,
  ['public-synthetic-fixture','no-secrets','no-mattermost-credential','no-private-memory','no-personal-content'],
  'operator-authorized'],Grant=['development-grant',Scope,1,1024,120].

dh_truth(Goal,true) :- call(Goal),!.
dh_truth(_,false).
dh_generation_names(R,Id,[Request,Raw,Timing,Observation]) :-
 or_named(R,Id,request,Request),or_named(R,Id,raw,Raw),
 or_named(R,Id,timing,Timing),or_named(R,Id,observation,Observation).
dh_generation_fresh([Request,Raw,Timing,Observation]) :-
 \+exists_file(Request),\+exists_file(Raw),\+exists_file(Timing),\+exists_file(Observation).
dh_generation_payload(Q,Id,Profile,Body) :-
 Q=['development-generation-call',Id,Candidate,Scope,Old,Selection,Grant,Parent,Context,Instruction,
  Writes,Effects,_,_],miter_store_canonical_json(Context,ContextJSON),
 dh_json('/Users/claritymiter/miter/config/voice-realization-schema-v2.json',Schema),
 dh_sha('/Users/claritymiter/miter/config/voice-realization-schema-v2.json',SchemaHash),
 SchemaHash="38bb7ccc1ce2e5d35db256114a7c1772817308d53be06d6090d69a1f26608427",
 with_output_to(string(User),json_write_dict(current_output,_{
  candidate_id:Candidate,parent_id:Parent,prior_resource:Old,selected_resource:Selection,
  scope:Scope,grant:Grant,constructive_context:ContextJSON,
  required_schema:Schema,required_schema_sha256:SchemaHash,
  allowed_writes:["trial-expression"],allowed_effects:[],
  source_instruction:Instruction,transport_note:"Return only the JSON object; no markdown or explanation."
 },[width(0)])),
 System="Render one reusable grammar candidate from the supplied source-grounded context. You provide a candidate only: do not choose behavior, judge quality, claim authority, invoke effects, or alter the acceptance standard. Return strict JSON and nothing else.",
 or_profile(Profile),or_body(Profile,System,User,4096,Body),
 Writes=['allowed-writes',['trial-expression']],Effects=['allowed-effects',[]].
dh_generation_audit(R,Q,['generation-preflight',Verified,Grounded,Staged,Contract,Payload,Names,Fresh,Spend]) :-
 dh_truth(dh_verify(R),Verified),dh_truth(ground(Q),Grounded),
 dh_truth(clause('&derived'('development-generation-pending',R,Q),true),Staged),
 dh_truth(dh_request_valid(R,Q),Contract),dh_truth(dh_generation_payload(Q,Id,_,_),Payload),
 dh_truth(dh_generation_names(R,Id,Paths),Names),
 (Names==true->dh_truth(dh_generation_fresh(Paths),Fresh);Fresh=false),
 dh_truth(clause(or_spend(R,development,Id),_),Spend),!.

dh_generate(R,Q,Observation) :- catch((dh_generate_checked(R,Q,Observation)->true;
 Observation=['openrouter-observation-unavailable','unstaged-or-invalid']),_,
 Observation=['openrouter-observation-unavailable','transport-exception']),!.
dh_generate_checked(R,Q,Observation) :- dh_verify(R),ground(Q),
 clause('&derived'('development-generation-pending',R,Q),true),dh_request_valid(R,Q),
 dh_generation_payload(Q,Id,Profile,Body),
 or_execute(R,Id,development,Profile,Body,120,2097152,Observation).

dh_observation_product(['openrouter-observation','g33-r12-generation-2',development,eof,200,_,true,_,
 'provider-response',_,Content,'z-ai/glm-5.3',_,_],Content).
dh_candidate(R,Q,Observation,Product) :- catch(((dh_request_valid(R,Q),dh_observation_product(Observation,Content),
 atom_json_dict(Content,D,[]),is_dict(D),vc_project(D,Module),
 Q=['development-generation-call',_,Candidate|_],Module=['voice-realization','miter-voice-realization-v2',Candidate|_],
 dh_path(R,'candidate.json',CP),(exists_file(CP)->dh_json(CP,Existing),miter_store_canonical_json(Existing,J),miter_store_canonical_json(D,J)
  ;tv_durable_json(CP,D)),dh_path(R,'candidate-lineage.json',LP),
 (exists_file(LP)->true;dh_path(R,'g33-r12-generation-2-request.json',Req),dh_path(R,'g33-r12-generation-2-raw.json',Raw),
  dh_sha(Req,ReqHash),dh_sha(Raw,RawHash),dh_sha(CP,CandidateHash),
  tv_durable_json(LP,_{schema:"miter-model-candidate-lineage-v1",standing:"model-candidate-bound",
   request_id:"g33-r12-generation-2",model:"z-ai/glm-5.3",request_sha256:ReqHash,
   raw_sha256:RawHash,candidate_sha256:CandidateHash})),
 Product=['model-candidate',Module,'model-candidate-bound',['generation-lineage','g33-r12-generation-2','z-ai/glm-5.3']])
 -> true ; Product=['model-candidate-unavailable']),_,Product=['model-candidate-unavailable']),!.

dh_trial_material(R,N) :- catch((dh_verify(R),dh_path(R,'input.json',IP),dh_json(IP,D),
 dh_source_file(D,parent_module,ParentPath,ParentHash),dh_json(ParentPath,ParentJSON),vc_project(ParentJSON,Parent),
 dh_source(D,trial_cases,_,TrialInput,CaseHash),TrialInput=['trial-input',Cases,_],
 N=['trial-material',Parent,Cases,['trial-pins',ParentHash,CaseHash,'v2-native-construction','candidate-independent']]),_,fail),!.
dh_trial_material(_,['trial-material-unavailable']).
dh_module_hash(R,Kind,Hash) :- memberchk(Kind,[parent,candidate]),
 (Kind==parent->dh_path(R,'input.json',IP),dh_json(IP,D),D.parent_module.sha256=Hash
 ;dh_path(R,'candidate.json',P),dh_sha(P,Hash)).

dh_development_commit(R,Intent,Result) :- catch((dh_development_commit_checked(R,Intent)->Result='helix-development-durable';
 Result='helix-development-incomplete'),_,Result='helix-development-incomplete'),!.
dh_development_commit_checked(R,Intent) :- dh_verify(R),ground(Intent),
 clause('&derived'('pending-helix-development',R,Intent),true),
 Intent=['helix-development-intent',R,Parent,Candidate,Pins,Decision,Selection,Generation],
 Decision=['trial-admissible'|_],Selection=['resource-selected'|_],Generation=['openrouter-observation'|_],
 dh_trial_material(R,['trial-material',Parent,_,Pins]),dh_path(R,'candidate.json',CP),dh_json(CP,CJ),vc_project(CJ,Candidate),
 dh_path(R,'development-intent.json',IP),dh_path(R,'active.json',AP),
 (exists_file(IP)->dh_json(IP,Old),dh_document_native(Old,Intent)
 ;tv_encode(Intent,T),tv_durable_json(IP,_{native:Intent,term:T})),
 (exists_file(AP)->dh_json(AP,A),dh_document_native(A,Intent)
 ;tv_encode(Intent,AT),tv_durable_json(AP,_{native:Intent,term:AT})),
 dh_append(R,'accepted-development',Intent).
dh_restore(R,Result) :- catch((dh_verify(R),dh_path(R,'active.json',P),dh_json(P,D),dh_document_native(D,I),
 I=['helix-development-intent',R|_],Result=['durable-helix-development',I]),_,Result='helix-development-recovery-incomplete'),!.

dh_efficacy_fixture(R,N) :- catch((dh_verify(R),dh_path(R,'input.json',IP),dh_json(IP,D),
 dh_source_file(D,efficacy_fixture,Path,_),dh_json(Path,E),member(I,E.invocations),I.id=="matched-parent",
 vc_native(I.scope,Scope),vc_native(I.frame,Frame),vc_native(I.question,Question),vc_native(I.context,Context),
 N=['efficacy-fixture',Scope,Frame,Question,Context,I.fuel]),_,fail),!.
dh_efficacy_fixture(_,['efficacy-fixture-unavailable']).
dh_existing_candidate(R,Product) :- catch((dh_verify(R),dh_path(R,'input.json',IP),dh_json(IP,D),
 dh_source_file(D,candidate_source,CP,CandidateHash),dh_json(CP,CJ),vc_project(CJ,Module),
 D.candidate_source.standing=="model-candidate-bound",D.candidate_source.model=="z-ai/glm-5.3",
 dh_source_file(D,candidate_lineage,LP,LineageHash),dh_json(LP,L),
 L.standing=="model-candidate-bound",L.candidate_sha256==CandidateHash,L.model=="z-ai/glm-5.3",
 Product=['model-candidate',Module,'model-candidate-bound',
  ['replayed-generation-lineage',CandidateHash,LineageHash]]),_,Product=['model-candidate-unavailable']),!.
dh_n_key(['efficacy-belief',Scope,Context,Pin,Id,_,_,_],Key) :-
 miter_store_canonical_json([Scope,Context,Pin,Id],S),crypto_data_hash(S,Key,[algorithm(sha256),encoding(utf8)]).
dh_n_restore(R,Seed,Result) :- catch((dh_verify(R),dh_n_key(Seed,K),atom_concat('efficacy-',K,Stem),
 atom_concat(Stem,'.json',F),dh_path(R,F,P),(exists_file(P)->dh_json(P,D),dh_document_native(D,Result)
 ;Result='efficacy-never-stored')),_,Result=['efficacy-recovery-required','projection-or-integrity']),!.
dh_n_commit(R,T,Result) :- catch((dh_n_commit_checked(R,T)->Result='efficacy-durable';
 Result='efficacy-commit-incomplete'),_,Result='efficacy-commit-incomplete'),!.
dh_n_commit_checked(R,T) :- dh_verify(R),ground(T),clause('&derived'('nace-pending',R,T),true),
 T=['efficacy-transition',Old,New,Obs,_],Obs=['efficacy-observation',_|_],dh_n_key(Old,K),dh_n_key(New,K),
 atom_concat('efficacy-',K,Stem),atom_concat(Stem,'.json',F),dh_path(R,F,P),
 (exists_file(P)->dh_json(P,D),dh_document_native(D,Current),Current==Old;true),
 tv_encode(New,N),tv_durable_json(P,_{native:New,term:N}),dh_append(R,'efficacy-consequence',T).

dh_append(R,Kind,Payload) :- dh_root(R,A),directory_file_path(A,store,Store),make_directory_path(Store),
 miter_store_canonical_json(Payload,S),crypto_data_hash(S,H,[algorithm(sha256),encoding(utf8)]),
 atomic_list_concat([Kind,H],'-',Id),atom_concat(Id,'.json',F),dh_path(R,F,IP),
 (exists_file(IP)->true;tv_encode(Payload,T),get_time(Now),stamp_date_time(Now,UTC,'UTC'),
  format_time(string(Time),'%FT%TZ',UTC),tv_durable_json(IP,_{schema:"miter-event-intent-v1",event_id:Id,
  event_kind:Kind,occurred_at:Time,recorded_at:Time,source_surface:"native-development-helix",
  source_principal:"miter-laboratory",audience_scope:"isolated-builder-lab",project_scope:"G33-R12",
  provenance_kind:"native-staged-development",correlation_id:H,parent_event_ids:[],payload:_{native:Payload,term:T}})),
 miter_store_append_event(Store,'/Users/claritymiter/miter/runtime/g07/libmiter_store_posix.dylib',IP,Append),
 memberchk(Append,['event-appended','duplicate-event-id']).
