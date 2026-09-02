% Typed source reads, byte/ledger verification and serialization. Native MeTTa
% interprets evidence, Soul grounding, admissibility and opportunity selection.
:- ensure_loaded('miter_voice.pl').
:- ensure_loaded('miter_reactor.pl').
miter_interest_proposals(Root,Ids) :-
 catch((directory_file_path(Root,'interest-proposals.json',P),miter_store_read_json(P,D),
  D.schema=="miter-interest-proposals-v1",is_list(D.proposals),length(D.proposals,N),N=<16,
  maplist(miter_interest_proposal_shape,D.proposals),
  findall(Id,(member(Q,D.proposals),atom_string(Id,Q.proposal_id),
     re_match('^[a-z][a-z0-9-]{0,31}$',Id)),Ids0),length(Ids0,N),sort(Ids0,ValidIds),length(ValidIds,N)
   ->Ids=ValidIds;Ids=['invalid-interest-proposals']),_,Ids=['invalid-interest-proposals']),!.
miter_interest_proposal_shape(Q) :-
 forall(member(K,[proposal_id,source_class,soul_ground,target_surface,living_question,purpose,
                   task_authority,interruptibility,progress_witness,stop_condition]),
   (get_dict(K,Q,V),string(V),string_length(V,N),N>0,N=<1000)),
 forall(member(K,[minimum_witnesses,model_calls,trial_runs]),(get_dict(K,Q,N),integer(N))),
 is_list(Q.allowed_effects),maplist(string,Q.allowed_effects),memberchk(Q.open_question,[true,false]).
miter_interest_field(Root,Id,Key,Value) :-
 catch((directory_file_path(Root,'interest-proposals.json',P),miter_store_read_json(P,D),
  findall(Q,(member(Q,D.proposals),atom_string(Id,Q.proposal_id)),[One]),
  get_dict(Key,One,V),miter_interest_atom_data(V,Valid)->Value=Valid;Value='invalid-field'),_,Value='invalid-field'),!.
miter_interest_atom_data(S,A) :- string(S),!,atom_string(A,S).
miter_interest_atom_data(L,As) :- is_list(L),!,maplist(miter_interest_atom_data,L,As).
miter_interest_atom_data(N,N) :- number(N),!.
miter_interest_atom_data(A,A) :- memberchk(A,[true,false,null]).
miter_interest_observations(Root,Facts) :-
 catch((directory_file_path(Root,'source-context.json',CP),miter_store_read_json(CP,C),
  directory_file_path(Root,store,Store),miter_store_load_ledger(Store,Lines),
  miter_store_analyze(Store,Lines,A,Events),A.status==valid,
  findall([observation,Id,Class,Provenance,Standing],
   (member(E,Events),miter_store_payload_path(Store,E.payload_hash,P),miter_store_read_json(P,D),
    get_dict(defects,D,Defs),is_list(Defs),
    member(["defect",Cl|_],Defs),atom_string(Class,Cl),atom_string(Id,E.event_id),
    atom_string(Provenance,E.provenance_kind),
    (catch((E.audience_scope=="scope:g16-private",E.project_scope=="g16-voice",
      atom_string(VoiceId,E.correlation_id),N=D.attempt,
      miter_voice_audit_status(C.voice_root,VoiceId,N,'audit-repair-required'),
      miter_voice_attempt_path(C.voice_root,VoiceId,N,'audit.json',AP),
      miter_store_read_json(AP,Actual),miter_store_canonical_json(D,Text),
      miter_store_canonical_json(Actual,Text)),_,fail)
     ->Standing='hashes-verified';Standing='unverified-assertion')),Raw),sort(Raw,ValidFacts)
   ->Facts=ValidFacts;Facts=[source-integrity-failed]),
  _,Facts=[source-integrity-failed]),!.
miter_interest_cut(Root,Cut) :-
 miter_interest_observations(Root,Facts),miter_store_canonical_json(Facts,S),
 crypto_data_hash(S,Cut,[algorithm(sha256),encoding(utf8)]).
miter_interest_id(Root,Proposal,Cut,Id) :-
 directory_file_path(Root,'interest-proposals.json',P),miter_store_read_json(P,D),
 findall(Q,(member(Q,D.proposals),atom_string(Proposal,Q.proposal_id)),[One]),
 miter_store_canonical_json([Cut,One],Context),
 crypto_data_hash(Context,H,[algorithm(sha256),encoding(utf8)]),sub_atom(H,0,12,_,Prefix),
 atomic_list_concat([interest,Proposal,Prefix],'-',Id).
miter_interest_seen(Root,Id,Result) :-
 directory_file_path(Root,store,S),miter_store_load_ledger(S,Lines),
 miter_store_analyze(S,Lines,A,Events),
 (A.status==valid,member(E,Events),E.event_kind=="interest-considered",
  atom_string(Id,E.correlation_id)->Result=true;Result=false),!.
miter_interest_event(Root,Id,Kind,Parents,Payload,Result) :-
 catch((get_time(Now),stamp_date_time(Now,DT,'UTC'),format_time(string(T),'%FT%TZ',DT),
  atomic_list_concat([Id,Kind],'-',Event),
  D=_{schema:"miter-event-intent-v1",event_id:Event,event_kind:Kind,
     occurred_at:T,recorded_at:T,source_surface:"native-InterestRNA",source_principal:"miter:interests",
     audience_scope:"scope:g16-private",project_scope:"g16-voice",provenance_kind:"native-control",
     parent_event_ids:Parents,correlation_id:Id,payload:Payload},
  format(atom(File),'interests/~w/~w-intent.json',[Id,Kind]),directory_file_path(Root,File,P),
  miter_store_write_json_atomic(P,D),directory_file_path(Root,store,S),
  miter_store_append_event(S,'runtime/g07/libmiter_store_posix.dylib',P,R),
  (R=='event-appended'->Result='interest-event-stored';Result='interest-storage-failed')),
  _,Result='interest-storage-failed'),!.
miter_interest_note(Root,Id,Decision,Sources,Reason,Result) :-
 miter_interest_event(Root,Id,'interest-considered',Sources,
  _{decision:Decision,reason:Reason,source_event_ids:Sources,
    reading_standing:"bounded-native-reading-not-improvement-proof"},Result).
miter_interest_write(Root,Id,Product,Result) :-
 catch((Product=['development-opportunity'|Fields],maplist(miter_voice_pairs,Fields,Pairs),
  dict_create(D,opportunity,Pairs),D.opportunity_id==Id,
  format(atom(F),'interests/~w/opportunity.json',[Id]),directory_file_path(Root,F,P),\+exists_file(P),
  miter_interest_event(Root,Id,'development-opportunity',D.source_event_ids,D,R),
  R=='interest-event-stored',miter_store_write_json_atomic(P,D)
  ->Result='opportunity-stored';Result='interest-storage-failed'),_,Result='interest-storage-failed'),!.
miter_interest_opportunity_field(Root,Id,Key,Value) :-
 catch((format(atom(F),'interests/~w/opportunity.json',[Id]),directory_file_path(Root,F,P),
  miter_store_read_json(P,D),get_dict(Key,D,V),miter_interest_atom_data(V,Valid)
  ->Value=Valid;Value='invalid-field'),_,Value='invalid-field'),!.
miter_interest_request(Root,Id,Product,Result) :-
 catch((Product=['candidate-request'|Fields],maplist(miter_voice_pairs,Fields,Pairs),dict_create(D,request,Pairs),
  atomic_list_concat([Id,'development-opportunity'],'-',Parent),
  miter_interest_event(Root,Id,'candidate-request',[Parent],D,R),R=='interest-event-stored',
  format(atom(F),'interests/~w/candidate-request.json',[Id]),directory_file_path(Root,F,P),
  miter_store_write_json_atomic(P,D)->Result='candidate-request-stored';Result='interest-storage-failed'),
  _,Result='interest-storage-failed'),!.
miter_interest_rna(Root,Id,Status,Result) :-
 atomic_list_concat([Id,'development-opportunity'],'-',Source),
 miter_interest_opportunity_field(Root,Id,resource_budget,['model-calls',Budget,'trial-runs',_]),
 D=_{rna_id:Id,species:"DevelopRNA",source_event:Source,current_locus:"Inquire",
 scope:"scope:g16-private",budget:Budget,provenance:"native-opportunity",
 dependencies:["candidate-generator"],authority:"candidate-storage-and-isolated-trial-only",
 status:Status,termination_condition:"one-candidate-or-budget-exhausted-or-ground-withdrawn"},
 format(atom(F),'rna/~w.json',[Id]),directory_file_path(Root,F,P),
 miter_store_write_json_atomic(P,D),miter_reactor_record(Root,'RNA-state',D,Result).
