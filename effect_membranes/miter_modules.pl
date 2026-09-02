% Candidate data, immutable provenance and fixed-space snapshots. No generated
% text is consulted as Prolog/MeTTa source and no candidate chooses a predicate.
:- ensure_loaded('miter_interests.pl').
miter_module_path(Root,Id,File,P) :- miter_voice_id(Id,I),
 directory_file_path(Root,modules,M),directory_file_path(M,I,D),directory_file_path(D,File,P).
miter_module_source_data(Root,File,D) :- directory_file_path(Root,File,P),miter_store_read_json(P,D).
miter_module_source(Root,Result) :-
 catch((miter_module_source_data(Root,'source-request.json',Q),
  miter_module_source_data(Root,'source-opportunity.json',O),Q.opportunity_id==O.opportunity_id,
  directory_file_path(Root,store,S),miter_store_load_ledger(S,L),miter_store_analyze(S,L,A,Events),A.status==valid,
  forall(member(Kind-D,["candidate-request"-Q,"development-opportunity"-O]),
   (member(E,Events),E.event_kind==Kind,E.correlation_id==O.opportunity_id,
    miter_store_payload_path(S,E.payload_hash,P),miter_store_read_json(P,Actual),
    miter_store_canonical_json(D,J),miter_store_canonical_json(Actual,J))),
  Q.authority=="quarantined-candidate-only",O.target_surface=="VoicePolicy"
  ->Result='module-source-verified';Result='module-source-invalid'),_,Result='module-source-invalid'),!.
miter_module_source_field(Root,Key,Result) :-
 catch((miter_module_source_data(Root,'source-opportunity.json',D),get_dict(Key,D,V),
  miter_interest_atom_data(V,A)->Result=A;Result='invalid-source-field'),_,Result='invalid-source-field'),!.
miter_module_requests_used(Root,Count) :-
 catch((miter_module_source_field(Root,opportunity_id,Opp),
  atomic_list_concat([Opp,'candidate-request'],'-',Parent),atom_string(Parent,PS),
  directory_file_path(Root,store,S),miter_store_load_ledger(S,L),miter_store_analyze(S,L,A,Events),A.status==valid,
  findall(E,(member(E,Events),E.event_kind=="model-request",memberchk(PS,E.parent_event_ids)),Requests),
  length(Requests,N)->Count=N;Count= -1),_,Count= -1),!.
miter_module_prior_rejections(Root,Rejections) :-
 directory_file_path(Root,store,S),miter_store_load_ledger(S,L),miter_store_analyze(S,L,A,Events),A.status==valid,
 findall([rejected,Id,Reason],
  (member(E,Events),E.event_kind=="candidate-rejected",member(C,Events),
   C.event_kind=="module-candidate",C.correlation_id==E.correlation_id,
   miter_store_payload_path(S,E.payload_hash,P),miter_store_read_json(P,D),
   atom_string(Id,E.correlation_id),atom_string(Reason,D.reason)),Rejections).
miter_module_candidate(Root,Id,D) :- miter_module_path(Root,Id,'candidate.json',P),miter_store_read_json(P,D).
miter_module_field(Root,Id,Key,Result) :-
 catch((miter_module_candidate(Root,Id,D),get_dict(Key,D,V),miter_interest_atom_data(V,A)
  ->Result=A;Result='invalid-module-field'),_,Result='invalid-module-field'),!.
miter_module_rule(Root,Id,N,Key,Result) :-
 catch((miter_module_candidate(Root,Id,D),nth0(N,D.rules,R),get_dict(Key,R,V),miter_interest_atom_data(V,A)
  ->Result=A;Result='invalid-rule-field'),_,Result='invalid-rule-field'),!.
miter_module_count(Root,Id,Count) :-
 catch((miter_module_candidate(Root,Id,D),is_list(D.rules),length(D.rules,N)->Count=N;Count= -1),_,Count= -1),!.
miter_module_shape(Root,Id,Result) :-
 catch((miter_module_candidate(Root,Id,D),dict_pairs(D,_,Ps),pairs_keys(Ps,Keys),
  Keys==[allowed_effects,allowed_writes,candidate_id,purpose,rules,schema],
  string(D.schema),string(D.candidate_id),atom_string(Id,D.candidate_id),
  string(D.purpose),string_length(D.purpose,Len),Len>0,Len=<500,
  is_list(D.allowed_writes),maplist(string,D.allowed_writes),
  is_list(D.allowed_effects),maplist(string,D.allowed_effects),
  is_list(D.rules),length(D.rules,N),N>=1,N=<8,
  forall(member(R,D.rules),(dict_pairs(R,_,RP),pairs_keys(RP,[action,condition,value,variant]),
    string(R.action),string(R.condition),string(R.value),integer(R.variant)))
  ->Result='module-shape-valid';Result='module-shape-invalid'),_,Result='module-shape-invalid'),!.
miter_module_intention(Root,Id,Product,Result) :-
 catch((Product=['module-generation-intention'|Fields],maplist(miter_voice_pairs,Fields,Pairs),dict_create(D,intention,Pairs),
  miter_module_path(Root,Id,'intention.json',P),\+exists_file(P),miter_store_write_json_atomic(P,D)
  ->Result='module-intention-stored';Result='module-intention-failed'),_,Result='module-intention-failed'),!.
miter_module_provenance(Root,Id,Result) :-
 catch((miter_module_source(Root,'module-source-verified'),miter_module_candidate(Root,Id,D),
  miter_module_path(Root,Id,'raw.json',P),miter_store_read_json(P,Raw),miter_lm_provider_product(Raw,Actual),
  miter_store_canonical_json(D,J),miter_store_canonical_json(Actual,J),
  miter_module_path(Root,Id,'timing.json',TP),miter_store_read_json(TP,T),T.http_status=:=200
  ->Result='model-candidate-bound';Result='candidate-provenance-unverified'),_,Result='candidate-provenance-unverified'),!.
miter_module_record(Root,Id,Kind,D,Result) :-
 catch((miter_module_source_field(Root,opportunity_id,Opp),
  atomic_list_concat([Opp,'candidate-request'],'-',Parent),
  get_time(Now),stamp_date_time(Now,DT,'UTC'),format_time(string(T),'%FT%TZ',DT),
  atomic_list_concat([Id,Kind],'-',Event),
  I=_{schema:"miter-event-intent-v1",event_id:Event,event_kind:Kind,
   occurred_at:T,recorded_at:T,source_surface:"native-ModuleRNA",source_principal:"miter:modules",
   audience_scope:"scope:g16-private",project_scope:"g16-voice",provenance_kind:"native-control",
   parent_event_ids:[Parent],correlation_id:Id,payload:D},
  atom_concat(Kind,'-intent.json',F),miter_module_path(Root,Id,F,P),miter_store_write_json_atomic(P,I),
  directory_file_path(Root,store,S),miter_store_append_event(S,'runtime/g07/libmiter_store_posix.dylib',P,R),
  (R=='event-appended'->Result='module-event-stored';Result='module-storage-failed')),
  _,Result='module-storage-failed'),!.
miter_module_reject(Root,Id,Reason,Result) :-
 miter_module_path(Root,Id,'candidate.json',CP),miter_voice_hash(CP,Hash),
 D=_{status:"rejected",reason:Reason,candidate_hash:Hash,executed:false},
 miter_module_record(Root,Id,'candidate-rejected',D,R),
 miter_module_path(Root,Id,'decision.json',P),miter_store_write_json_atomic(P,D),
 (R=='module-event-stored'->Result='candidate-rejected';Result='module-storage-failed').
miter_module_manifest(Root,Id,Product,Result) :-
 catch((Product=['capability-module'|Fields],maplist(miter_voice_pairs,Fields,Pairs),dict_create(Native,module,Pairs),
  miter_module_candidate(Root,Id,C),miter_module_path(Root,Id,'candidate.json',CP),miter_voice_hash(CP,CH),
  miter_module_path(Root,Id,'raw.json',RP),miter_voice_hash(RP,RH),
  miter_module_path(Root,Id,'request.json',QP),miter_voice_hash(QP,QH),
  miter_voice_hash('derived/voice-policy-seed.json',PH),
  D=Native.put(_{rules:C.rules,provenance:_{proposer:"Miter",generator:"local-model",
     candidate_hash:CH,raw_response_hash:RH,request_hash:QH,parent_hash:PH}}),
  miter_module_record(Root,Id,'module-quarantined',D,'module-event-stored'),
  miter_module_path(Root,Id,'manifest.json',MP),miter_store_write_json_atomic(MP,D)
  ->Result='module-manifest-stored';Result='module-storage-failed'),_,Result='module-storage-failed'),!.
miter_module_space(Space,Atoms) :-
 findall(Atom,(current_predicate(Space/Arity),functor(Head,Space,Arity),clause(Head,true),
   Head=..[_|Atom],ground(Atom)),Raw),msort(Raw,Atoms).
miter_module_snapshot(Root,Name,Result) :-
 catch((miter_voice_id(Name,_),miter_module_space('&soul',Soul),miter_module_space('&trial',Trial),
  miter_module_space('&history',History),miter_module_space('&derived',Derived),
  atom_concat(Name,'.json',F),directory_file_path(Root,F,P),
  miter_store_write_json_atomic(P,_{soul:Soul,trial:Trial,history:History,derived:Derived})
  ->Result='module-snapshot-stored';Result='module-snapshot-failed'),_,Result='module-snapshot-failed'),!.
miter_module_dump(Root,Id,Result) :-
 catch((miter_module_space('&trial',All),include(miter_module_owned(Id),All,Atoms),
  miter_module_path(Root,Id,'module.metta',P),
  setup_call_cleanup(open(P,write,S,[encoding(utf8)]),forall(member(A,Atoms),
    (miter_module_atom_text(S,A),nl(S))),close(S))
  ->Result='module-data-dumped';Result='module-dump-failed'),_,Result='module-dump-failed'),!.
miter_module_owned(Id,[_Kind,Id|_]).
miter_module_atom_text(S,List) :- is_list(List),!,write(S,'('),
 forall(nth0(I,List,A),(I>0->write(S,' '),miter_module_atom_text(S,A);miter_module_atom_text(S,A))),write(S,')').
miter_module_atom_text(S,A) :- (number(A)->write(S,A);atom(A),re_match('^[A-Za-z0-9_*:-]+$',A)->write(S,A);json_write(S,A)).
