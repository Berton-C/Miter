% SC05 exact native request transport, typed parsing, bounded asynchronous worker.
% No intention formation, source interpretation, voice audit or repair judgment.
:- ensure_loaded('miter_store.pl').
:- ensure_loaded('miter_llm.pl').
:- use_module(library(time)).
:- dynamic rv_worker/2, rv_result/2.
rv_path(R,F,P) :- miter_store_nonempty_atom(R,A),sub_atom(A,0,_,_,'/Users/claritymiter/miter/evidence/SC05/'),
 \+sub_atom(A,_,_,_,'..'),directory_file_path(A,F,P).
rv_json(P,D) :- miter_store_read_json(P,D).
rv_native(X,Y) :- (string(X)->atom_string(Y,X);is_list(X)->maplist(rv_native,X,Y);Y=X).
rv_write(R,F,D) :- rv_path(R,F,P),\+exists_file(P),miter_store_write_json_atomic(P,D).
rv_verified(R) :- rv_path(R,'manifest.json',P),rv_json(P,M),
 forall(member(F,M.files),(crypto_file_hash(F.path,H,[algorithm(sha256),encoding(octet)]),atom_string(H,F.sha256))),
 forall(member(Required,['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md',
   'constitution/soul_compass_v02.metta','src/participation.metta','src/participation_support.metta',
   'src/grounded_language.metta','src/bootstrap_grounded_language.metta','src/relational_voice.metta',
   'src/bootstrap_relational_voice.metta','effect_membranes/miter_language.pl',
   'effect_membranes/miter_relational_voice.pl','effect_membranes/miter_store.pl',
   'effect_membranes/miter_llm.pl','config/local/g03-model-profiles.json']),
   (atom_concat('/Users/claritymiter/miter/',Required,Absolute),member(E,M.files),atom_string(Absolute,E.path))).
rv_save_intention(R,I,Result) :-
 catch((rv_verified(R),I=['voice-intention',Id,Scope,_,_,_,_],
  get_time(T),rv_write(R,'intention.json',_{native:I,request_id:Id,scope:Scope,stored_at:T})
  ->Result='intention-stored';Result='intention-storage-or-integrity-failed'),_,Result='intention-storage-or-integrity-failed'),!.
rv_start(R,Q,Result) :-
 catch((rv_start_checked(R,Q)->Result='worker-started';Result='request-preparation-failed'),E,
   (term_string(E,T),Result=['request-preparation-error',T])),!.
rv_start_checked(R,Q) :-
 rv_verified(R),Q=['render-request',Id,Scope,Alias,Tokens,Deadline,Instructions,Claims,Names,Standing],
 Alias=='qwen-local',integer(Tokens),Tokens>0,Tokens=<1024,Deadline>0,Deadline=<120,
 rv_path(R,'intention.json',IP),rv_json(IP,I),rv_native(I.native,Native),Native=['voice-intention',Id,Scope|_],
 rv_path(R,'grant.json',GP),rv_json(GP,G),rv_native(G.scope,GrantedScope),GrantedScope==Scope,
 G.max_calls>=1,G.max_calls=<2,\+rv_worker(R,_),
 rv_write(R,'native-request.json',_{native:Q}),
 atom_string(Id,IdS),Schema=_{type:"object",properties:_{request_id:_{type:"string",const:IdS},clauses:_{type:"array",minItems:1,maxItems:8,items:_{type:"string",minLength:1,maxLength:512}}},required:["request_id","clauses"],additionalProperties:false},
 with_output_to(string(User),json_write_dict(current_output,_{request_id:IdS,intended_relations:Claims,names:Names,standing:Standing},[width(0)])),
 Template=_{schema:"miter-schema-request-v1",request_id:IdS,endpoint:"http://127.0.0.1:1234/v1/chat/completions",body:_{messages:[_{role:"system",content:Instructions},_{role:"user",content:User}],response_format:_{type:"json_schema",json_schema:_{name:"miter_relational_expression",strict:true,schema:Schema}},temperature:0,top_p:1,reasoning_effort:"none",max_tokens:Tokens,seed:5050,stream:false,ttl:300}},
 rv_write(R,'template.json',Template),rv_path(R,'template.json',TP),rv_path(R,'request.json',RP),
 miter_lm_prepare_request('/Users/claritymiter/miter/config/local/g03-model-profiles.json',Alias,TP,RP,'model-request-prepared'),
 thread_create(rv_worker_body(R,Id,Scope,RP,Deadline),Thread,[]),assertz(rv_worker(R,Thread)),
 get_time(T),rv_write(R,'worker-started.json',_{request_id:Id,started_at:T,deadline_seconds:Deadline}).
rv_worker_body(R,Id,Scope,RP,Deadline) :-
 catch(call_with_time_limit(Deadline,rv_fetch(R,Id,Scope,RP,Outcome)),Error,rv_error(Error,Outcome)),
 retractall(rv_result(R,_)),assertz(rv_result(R,Outcome)),
 get_time(T),catch(rv_write(R,'transport-result.json',_{result:Outcome,finished_at:T}),_,true).
rv_error(time_limit_exceeded,'model-timeout') :- !.
rv_error(cancelled,cancelled) :- !.
rv_error(error(socket_error(_,_),_),'provider-unavailable') :- !.
rv_error(error(timeout_error(_,_),_),'model-timeout') :- !.
rv_error(E,['transport-error',T]) :- term_string(E,T).
rv_fetch(R,Id,Scope,RP,Outcome) :-
 rv_path(R,'raw.json',Raw),rv_path(R,'timing.json',Timing),
 % The checked transport lets cancellation/deadline exceptions reach this
 % worker instead of collapsing them in the legacy broad exception wrapper.
 miter_lm_execute_request_checked(RP,Raw,Timing,Status),
 (Status=='raw-model-response-stored'->rv_parse(R,Id,Scope,Raw,Outcome)
 ;Outcome=['provider-incomplete',Status]).
rv_parse(R,Id,Scope,Raw,Outcome) :-
 (catch(rv_json(Raw,D),_,fail)->rv_parse_document(R,Id,Scope,Raw,D,Outcome)
 ;Outcome='malformed-provider-envelope').
rv_parse_document(_R,_Id,_Scope,_Raw,D,'model-truncated') :-
 get_dict(choices,D,[C|_]),get_dict(finish_reason,C,"length"),!.
rv_parse_document(_R,_Id,_Scope,_Raw,D,'model-refusal') :-
 get_dict(choices,D,[C|_]),get_dict(message,C,M),get_dict(refusal,M,Refusal),
 string(Refusal),string_length(Refusal,N),N>0,!.
rv_parse_document(R,Id,Scope,Raw,D,Outcome) :-
 (catch((miter_lm_provider_product(D,P),
   dict_pairs(P,_,Pairs),pairs_keys(Pairs,[clauses,request_id]),
   atom_string(Id,P.request_id),is_list(P.clauses),length(P.clauses,N),N>0,N=<8,
   forall(member(C,P.clauses),(string(C),string_length(C,L),L>0,L=<512))),_,fail)
 ->Outcome=[rendered,Id,Scope,P.clauses,Raw],rv_write(R,'candidate.json',_{request_id:Id,scope:Scope,clauses:P.clauses,raw_ref:Raw,origin:"model-rendering"})
 ;Outcome='malformed-model-output').
rv_control(R,Event) :-
 (rv_path(R,'control.json',P),exists_file(P),catch(rv_json(P,D),_,fail),rv_native(D.event,E)->Event=E;Event=none).
rv_poll(R,Result) :- (rv_result(R,R0)->Result=R0;Result=pending).
rv_pace(Seconds,waited) :- number(Seconds),Seconds>=0,Seconds=<0.1,sleep(Seconds).
rv_cancel(R,Result) :-
 get_time(T),rv_write(R,'stop-observed.json',_{observed_at:T}),
 (retract(rv_worker(R,Thread))->catch(thread_signal(Thread,throw(cancelled)),_,true),
   catch(thread_join(Thread,_),_,true),Result='worker-cancelled';Result='no-active-worker').
rv_save_result(R,Native,Result) :-
 catch((get_time(T),rv_write(R,'native-result.json',_{native:Native,stored_at:T})->Result='native-result-stored';Result='result-storage-failed'),_,Result='result-storage-failed'),!.
