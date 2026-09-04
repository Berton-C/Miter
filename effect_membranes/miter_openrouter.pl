% Credential-isolating OpenRouter transport for an LLM renderer.
% This grounding performs mechanics only. It never decides whether a request
% should occur and never grants provider text contact, authority, or action.
:- ensure_loaded('miter_surface_design_v1.pl').
:- use_module(library(http/http_open)).
:- use_module(library(http/http_json)).
:- use_module(library(http/json)).
:- use_module(library(process)).
:- use_module(library(readutil)).
:- use_module(library(time)).
:- use_module(library(pcre)).
:- use_module(library(filesex)).

or_profile_path('/Users/claritymiter/miter/config/model-resources-v1.json').
or_exact_endpoint("https://openrouter.ai/api/v1/chat/completions").
or_exact_model("z-ai/glm-5.3").

or_profile(Profile) :- or_profile_path(Path),sd_json(Path,Registry),is_dict(Registry),
 Registry.schema=="miter-model-resource-registry-v1",Registry.human_editable==true,
 is_dict(Registry.selection),Registry.selection.mode=="native-relational",
 Registry.selection.operator_preference=="openrouter-glm53",Registry.selection.preference_standing=="evidence-not-authority",
 Registry.selection.fallback_policy=="explicit-native-comparison-only",Registry.selection.silent_model_substitution==false,
 is_list(Registry.resources),or_registry_secret_free(Registry),
 findall(P,(member(P,Registry.resources),is_dict(P),P.id=="openrouter-glm53"),[Profile]),
 Profile.kind=="remote",Profile.enabled==true,Profile.adapter=="openrouter-chat-completions",
 or_exact_endpoint(Profile.endpoint),or_exact_model(Profile.model),Profile.reasoning_effort=="high",
 is_dict(Profile.provider),Profile.provider.zdr==true,Profile.provider.data_collection=="deny",
 Profile.provider.require_parameters==true,Profile.provider.allow_fallbacks==true,
 is_dict(Profile.limits),Profile.limits.max_output_tokens==8192,Profile.limits.deadline_seconds==300,Profile.limits.capture_bytes==2097152,
 is_dict(Profile.credential_reference),Profile.credential_reference.source=="macos-keychain",
 Profile.credential_reference.account=="bcb",Profile.credential_reference.service=="ai.bgi.miter.openrouter".

or_registry_secret_free(D) :- is_dict(D),!,dict_pairs(D,_,Pairs),forall(member(K-V,Pairs),
 (\+memberchk(K,[api_key,token,secret,password,authorization]),or_registry_secret_free(V))).
or_registry_secret_free(L) :- is_list(L),!,maplist(or_registry_secret_free,L).
or_registry_secret_free(S) :- string(S),!,\+re_match('(?i)sk-or-v1-[a-z0-9._-]+',S).
or_registry_secret_free(_).

or_message(Role,Content,_{role:RoleString,content:Content}) :- memberchk(Role,[system,user]),atom_string(Role,RoleString),
 string(Content),string_length(Content,N),N>0,N=<524288.
or_body(Profile,System,User,Tokens,Body) :- or_message(system,System,S),or_message(user,User,U),
 integer(Tokens),Tokens>=1,Tokens=<8192,
 Body=_{model:Profile.model,messages:[S,U],temperature:0,top_p:1,max_tokens:Tokens,
  reasoning_effort:Profile.reasoning_effort,stream:false,provider:Profile.provider},or_body_valid(Body).
or_body_valid(Body) :- is_dict(Body),dict_pairs(Body,_,Pairs),pairs_keys(Pairs,Keys),
 Keys==[max_tokens,messages,model,provider,reasoning_effort,stream,temperature,top_p],
 or_exact_model(Body.model),Body.temperature=:=0,Body.top_p=:=1,integer(Body.max_tokens),
 Body.max_tokens>=1,Body.max_tokens=<8192,Body.reasoning_effort=="high",Body.stream==false,
 Body.messages=[S,U],is_dict(S),is_dict(U),S.role=="system",U.role=="user",
 string(S.content),string(U.content),\+get_dict(response_format,Body,_),
 is_dict(Body.provider),Body.provider.zdr==true,Body.provider.data_collection=="deny",
 Body.provider.require_parameters==true,Body.provider.allow_fallbacks==true.

or_keychain(Profile,Key) :- process_create('/usr/bin/security',
 ['find-generic-password','-a',Profile.credential_reference.account,'-s',Profile.credential_reference.service,'-w'],
 [stdin(null),stdout(pipe(Out)),stderr(null),process(Pid)]),read_string(Out,1024,Raw),close(Out),
 process_wait(Pid,exit(0),[timeout(15)]),normalize_space(string(Key),Raw),
 string_length(Key,N),N>=16,N=<512,re_match('^[A-Za-z0-9._-]+$',Key).
or_keychain_available(Result) :- (or_profile(P),or_keychain(P,_)->Result=true;Result=false),!.
or_missing_keychain_rejected :- or_profile(P),put_dict(credential_reference,P,_{source:"macos-keychain",account:"bcb",service:"ai.bgi.miter.absent-test-only"},Bad),\+or_keychain(Bad,_).

or_r7_spend(R,diagnostic,Id) :- or_r7_spend_slot(R,diagnostic,Id,1).
or_r7_spend(R,bridge,Id) :- or_r7_spend_slot(R,bridge,Id,2).
or_r7_spend(R,tests,Id) :- or_r7_spend_slot(R,tests,Id,3).
or_r7_spend_slot(R,Kind,Id,Slot) :- format(atom(P),'/Users/claritymiter/miter/evidence/G29/R7-call-~d.claim',[Slot]),
 \+exists_directory(P),make_directory(P),directory_file_path(P,'owner.json',Owner),
 sd_durable_json(Owner,_{root:R,request:Id,kind:Kind,slot:Slot,grant:"G29-R7",model:"z-ai/glm-5.3"}).
or_r8_spend(R,diagnostic,Id) :- or_r8_spend_slot(R,diagnostic,Id,1).
or_r8_spend(R,bridge,Id) :- or_r8_spend_slot(R,bridge,Id,2).
or_r8_spend(R,tests,Id) :- or_r8_spend_slot(R,tests,Id,3).
or_r8_spend_slot(R,Kind,Id,Slot) :- format(atom(P),'/Users/claritymiter/miter/evidence/G29/R8-call-~d.claim',[Slot]),
 \+exists_directory(P),make_directory(P),directory_file_path(P,'owner.json',Owner),
 sd_durable_json(Owner,_{root:R,request:Id,kind:Kind,slot:Slot,grant:"G29-R8",model:"z-ai/glm-5.3"}).
or_r9_spend(R,bridge,Id) :- or_r9_spend_slot(R,bridge,Id,1).
or_r9_spend(R,tests,Id) :- or_r9_spend_slot(R,tests,Id,2).
or_r9_spend_slot(R,Kind,Id,Slot) :- format(atom(P),'/Users/claritymiter/miter/evidence/G29/R9-call-~d.claim',[Slot]),
 \+exists_directory(P),make_directory(P),directory_file_path(P,'owner.json',Owner),
 sd_durable_json(Owner,_{root:R,request:Id,kind:Kind,slot:Slot,grant:"G29-R9",model:"z-ai/glm-5.3"}).
or_spend(R,diagnostic,'openrouter-probe-r7-1') :- or_r7_spend(R,diagnostic,'openrouter-probe-r7-1').
or_spend(R,bridge,'openrouter-bridge-r7-2') :- or_r7_spend(R,bridge,'openrouter-bridge-r7-2').
or_spend(R,tests,'openrouter-tests-r7-3') :- or_r7_spend(R,tests,'openrouter-tests-r7-3').
or_spend(R,diagnostic,'openrouter-probe-r8-1') :- or_r8_spend(R,diagnostic,'openrouter-probe-r8-1').
or_spend(R,bridge,'openrouter-bridge-r8-2') :- or_r8_spend(R,bridge,'openrouter-bridge-r8-2').
or_spend(R,tests,'openrouter-tests-r8-3') :- or_r8_spend(R,tests,'openrouter-tests-r8-3').
or_spend(R,bridge,'openrouter-bridge-r9-1') :- or_r9_spend(R,bridge,'openrouter-bridge-r9-1').
or_spend(R,tests,'openrouter-tests-r9-2') :- or_r9_spend(R,tests,'openrouter-tests-r9-2').
% G33 R12 owns one separately frozen development-rendering slot.  This clause
% widens transport mechanics only; the native helix module must stage and
% authorize the exact request before or_execute/8 can be reached.
or_spend(R,development,'g33-r12-generation-1') :-
 format(atom(P),'/Users/claritymiter/miter/evidence/G33/R12/openrouter-call-1.claim',[]),
 \+exists_directory(P),make_directory(P),directory_file_path(P,'owner.json',Owner),
 sd_durable_json(Owner,_{root:R,request:"g33-r12-generation-1",kind:"development",slot:1,
  grant:"G33-R12-R1",model:"z-ai/glm-5.3",max_output_tokens:1024,deadline_seconds:120}).

or_root(R) :- sd_root(R,_),!.
or_root(R) :- current_predicate(dh_root/2),dh_root(R,_).
or_path(R,F,P) :- sd_path(R,F,P),!.
or_path(R,F,P) :- current_predicate(dh_path/3),dh_path(R,F,P).
or_named(R,Id,Suffix,Path) :- or_root(R),miter_store_nonempty_atom(Id,A),re_match('^[a-zA-Z0-9_-]+$',A),
 format(atom(File),'~w-~w.json',[A,Suffix]),or_path(R,File,Path).
or_durable_text(Path,Text) :- miter_store_ensure_extension('/Users/claritymiter/miter/runtime/g07/libmiter_store_posix.dylib'),
 atom_concat(Path,'.tmp',Tmp),\+exists_file(Tmp),setup_call_cleanup(open(Tmp,write,S,[encoding(utf8)]),
 (chmod(Tmp,0o600),format(S,'~s',[Text]),flush_output(S),miter_store_fsync_stream(S)),close(S)),rename_file(Tmp,Path).

or_diagnostic(R,Q,Observation) :- catch((or_diagnostic_checked(R,Q,Observation)->true;
 Observation=['openrouter-observation-unavailable',unstaged_or_invalid]),_,Observation=['openrouter-observation-unavailable',transport_exception]),!.
or_diagnostic_checked(R,Q,Observation) :- sd_verify(R),ground(Q),clause('&derived'('openrouter-diagnostic-pending',R,Q),true),
 Q=['openrouter-diagnostic',Id,Prompt,Tokens,Deadline],atom(Id),string(Prompt),Prompt=="MITER_OPENROUTER_READY",or_diagnostic_grant(Id,Tokens,Deadline),
 or_profile(Profile),or_body(Profile,"Return only the exact text requested by the user. Do not explain, quote, punctuate, or use a code fence.",Prompt,Tokens,Body),
 or_execute(R,Id,diagnostic,Profile,Body,Deadline,262144,Observation).

or_source(R,Q,Observation) :- catch((or_source_checked(R,Q,Observation)->true;
 Observation=['openrouter-observation-unavailable',unstaged_or_invalid]),_,Observation=['openrouter-observation-unavailable',transport_exception]),!.
or_source_checked(R,Q,Observation) :- sd_verify(R),ground(Q),clause('&derived'('openrouter-source-pending',R,Q),true),
 Q=['openrouter-source',Id,DesignId,CandidateId,Part,Instructions,OldFile,Observations,Tokens,Deadline],
 atom(Id),atom(DesignId),atom(CandidateId),memberchk(Part,[bridge,tests]),string(Instructions),or_source_grant(Id,Part,Tokens,Deadline),
 OldFile=['surface-candidate-file',Path0,Source0,Hash],miter_store_nonempty_atom(Path0,PathAtom),atom_string(PathAtom,Path),
 miter_store_nonempty_atom(Source0,SourceAtom),atom_string(SourceAtom,Source),is_list(Observations),
 sd_encode(['surface-candidate-file',Path,Source,Hash],OldDoc),sd_encode(Observations,ObservationDoc),
 with_output_to(string(User),json_write_dict(current_output,_{design_id:DesignId,candidate_id:CandidateId,target:Part,
  prior_file:OldDoc,observed_consequences:ObservationDoc,unchanged_contract:_{module:"miter_mattermost_bridge",
  exports:["surface_ingest/5","surface_effect/5","surface_reconnect/4","surface_panic/2"],network:"none",credentials:[]}},[width(0)])),
 or_profile(Profile),or_body(Profile,Instructions,User,Tokens,Body),or_execute(R,Id,Part,Profile,Body,Deadline,2097152,Observation).

or_execute(R,Id,Purpose,Profile,Body,Deadline,MaxBytes,Observation) :-
 or_named(R,Id,request,RequestPath),or_named(R,Id,raw,RawPath),or_named(R,Id,timing,TimingPath),or_named(R,Id,observation,ObservationPath),
 (exists_file(ObservationPath)->sd_json(ObservationPath,D),sd_document_native(D,Observation);
  \+exists_file(RequestPath),\+exists_file(RawPath),\+exists_file(TimingPath),or_spend(R,Purpose,Id),
  sd_durable_json(RequestPath,_{schema:"miter-openrouter-request-v1",request_id:Id,endpoint:Profile.endpoint,body:Body,authorization:"keychain-redacted"}),
  or_keychain(Profile,Key),string_concat("Bearer ",Key,Authorization),get_time(Start),
  catch(call_with_time_limit(Deadline,setup_call_cleanup(
   http_open(Profile.endpoint,In,[method(post),post(json(Body)),status_code(Status),timeout(Deadline),redirect(false),
    request_header('Authorization'=Authorization),request_header('Content-Type'='application/json'),request_header('Accept'='application/json')]),
   (Capture is MaxBytes+1,read_string(In,Capture,Captured)),close(In))),Error,true),get_time(End),Elapsed is round((End-Start)*1000),
  (var(Error)->Transport=eof,ErrorClass=none,string_length(Captured,CapturedBytes),
    (CapturedBytes>MaxBytes->Truncated=true,sub_string(Captured,0,MaxBytes,_,Raw);Truncated=false,Raw=Captured),string_length(Raw,Bytes)
   ;or_error_class(Error,Transport,ErrorClass),Status=0,Raw="",Bytes=0,Truncated=false),
  or_durable_text(RawPath,Raw),sd_durable_json(TimingPath,_{transport:Transport,error:ErrorClass,http_status:Status,elapsed_ms:Elapsed,bytes:Bytes,truncated:Truncated}),
  or_observation(Id,Purpose,Transport,Status,Elapsed,Truncated,Bytes,Raw,Observation),sd_encode(Observation,Encoded),sd_durable_json(ObservationPath,_{native:Observation,term:Encoded})).
or_error_class(time_limit_exceeded,timeout,"deadline-exceeded") :- !.
or_error_class(error(timeout_error(_,_),_),timeout,"deadline-exceeded") :- !.
or_error_class(_,transport_error,"redacted-transport-error").

or_observation(Id,Purpose,Transport,Status,Elapsed,Truncated,Bytes,Raw,
 ['openrouter-observation',Id,Purpose,Transport,Status,Elapsed,Complete,Finish,Parse,Bytes,Content,ReturnedModel,Provider,Usage]) :-
 (Truncated==true->Complete=false,Finish=unknown,Parse='capture-limit',Content="",ReturnedModel=unknown,Provider=unknown,Usage=['usage',0,0,0,0];
  catch(atom_json_dict(Raw,D,[]),_,fail),is_dict(D)->or_response(D,Status,Complete,Finish,Parse,Content,ReturnedModel,Provider,Usage);
  Complete=false,Finish=unknown,Parse='malformed-provider-response',Content="",ReturnedModel=unknown,Provider=unknown,Usage=['usage',0,0,0,0]).
or_response(D,Status,true,Finish,'provider-response',Content,ReturnedModel,Provider,Usage) :- Status=:=200,
 D.choices=[Choice|_],is_dict(Choice),miter_store_nonempty_atom(Choice.finish_reason,Finish),is_dict(Choice.message),string(Choice.message.content),Content=Choice.message.content,
 miter_store_nonempty_atom(D.model,ReturnedModel),ReturnedModel=='z-ai/glm-5.3',
 (get_dict(provider,D,P0),miter_store_nonempty_atom(P0,Provider)->true;Provider=unknown),or_usage(D,Usage),!.
or_response(_,_,false,unknown,'provider-rejected',"",unknown,unknown,['usage',0,0,0,0]).
or_usage(D,['usage',Prompt,Completion,Total,Cost]) :- get_dict(usage,D,U),is_dict(U),
 or_number(U,prompt_tokens,Prompt),or_number(U,completion_tokens,Completion),or_number(U,total_tokens,Total),or_number(U,cost,Cost),!.
or_usage(_,['usage',0,0,0,0]).
or_number(D,K,V) :- (get_dict(K,D,X),number(X)->V=X;V=0).

or_diagnostic_grant('openrouter-probe-r7-1',64,120).
or_diagnostic_grant('openrouter-probe-r8-1',256,120).
or_source_grant('openrouter-bridge-r7-2',bridge,2048,300).
or_source_grant('openrouter-tests-r7-3',tests,2048,300).
or_source_grant('openrouter-bridge-r8-2',bridge,4096,300).
or_source_grant('openrouter-tests-r8-3',tests,4096,300).
or_source_grant('openrouter-bridge-r9-1',bridge,8192,300).
or_source_grant('openrouter-tests-r9-2',tests,4096,300).

or_offline_audit(['openrouter-membrane-audit',true,true,true,true,true,true,true,true]) :- or_profile(P),
 or_body(P,"system","user",64,Good),or_body_valid(Good),
 put_dict(endpoint,P,"https://example.com/v1/chat/completions",BadEndpoint),\+or_profile_contract(BadEndpoint),
 put_dict(model,P,"z-ai/glm-5.3:free",BadModel),\+or_profile_contract(BadModel),
 put_dict(response_format,Good,_{type:"json_object"},BadFormat),\+or_body_valid(BadFormat),
 put_dict(authorization,Good,"supplied",BadCredential),\+or_body_valid(BadCredential),
 put_dict(max_tokens,Good,8193,BadTokens),\+or_body_valid(BadTokens),or_missing_keychain_rejected,
 with_output_to(string(Rendered),json_write_dict(current_output,_{body:Good,authorization:"keychain-redacted"},[width(0)])),\+sub_string(Rendered,_,_,_,"sk-or-v1-").
or_profile_contract(P) :- is_dict(P),or_exact_endpoint(P.endpoint),or_exact_model(P.model).

% The secret is compared in memory and only a boolean leaves this audit.
% The candidate identifier and evidence root remain under exact bounded roots.
or_secret_absent(R,CandidateId,Result) :- catch((or_secret_absent_checked(R,CandidateId)->Result=true;Result=false),_,Result=false),!.
or_secret_absent_checked(R,CandidateId) :- sd_root(R,_),miter_store_nonempty_atom(CandidateId,Id),memberchk(Id,['mattermost-r7','mattermost-r8','mattermost-r9']),
 or_profile(P),or_keychain(P,Key),or_tree_secret_absent(R,Key),
 atom_concat('/Users/claritymiter/miter/runtime/g29/candidates/',Id,Candidate),
 (exists_directory(Candidate)->or_tree_secret_absent(Candidate,Key);true),
 (Id=='mattermost-r7'->Round='R7';Id=='mattermost-r8'->Round='R8';Round='R9'),
 forall(between(1,3,Slot),(format(atom(Claim),'/Users/claritymiter/miter/evidence/G29/~w-call-~d.claim',[Round,Slot]),
  (exists_directory(Claim)->or_tree_secret_absent(Claim,Key);true))).
or_tree_secret_absent(Root,Key) :- forall(directory_member(Root,Path,[recursive(true),follow_links(false),file_type(regular)]),
 catch((read_file_to_string(Path,Text,[encoding(octet)]),\+sub_string(Text,_,_,_,Key)),_,fail)).
