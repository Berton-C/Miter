% G33 R13 compact development-proof mechanics. Native PeTTa/MeTTa selects
% every semantic field; this membrane only validates the exact staged record,
% hashes canonical native terms, writes/fsyncs JSON, and appends trajectory.
:- ensure_loaded('miter_development_helix_v1.pl').

dh2_hash_native(N,H) :- ground(N),miter_store_canonical_json(N,S),
 crypto_data_hash(S,A,[algorithm(sha256),encoding(utf8)]),atom_string(A,H).

dh2_root_probe(R,Result) :- catch((dh_root(R,_)->Result='qualified-development-root';
 Result='rejected-development-root'),_,Result='rejected-development-root'),!.

dh2_input(R,N) :- catch(((dh_verify(R),dh_path(R,'input.json',P),dh_json(P,D),
 dh_waiting(D,Waiting),dh_existing_candidate(R,Product),
 N=['development-helix-v2-input',Waiting,Product])->true;
 N=['development-helix-v2-input-unavailable']),_,
 N=['development-helix-v2-input-unavailable']),!.

dh2_append(R,Kind,Payload) :- dh_root(R,A),directory_file_path(A,store,Store),
 make_directory_path(Store),miter_store_canonical_json(Payload,S),
 crypto_data_hash(S,H,[algorithm(sha256),encoding(utf8)]),
 atomic_list_concat([Kind,H],'-',Id),atom_concat(Id,'.json',F),dh_path(R,F,IP),
 (exists_file(IP)->true;
  tv_encode(Payload,T),get_time(Now),stamp_date_time(Now,UTC,'UTC'),
  format_time(string(Time),'%FT%TZ',UTC),
  tv_durable_json(IP,_{schema:"miter-event-intent-v1",event_id:Id,
   event_kind:Kind,occurred_at:Time,recorded_at:Time,
   source_surface:"native-development-helix-v2",
   source_principal:"miter-laboratory",audience_scope:"isolated-builder-lab",
   project_scope:"G33-R13",provenance_kind:"native-staged-development-proof",
   correlation_id:H,parent_event_ids:[],payload:_{native:Payload,term:T}})),
 miter_store_append_event(Store,
  '/Users/claritymiter/miter/runtime/g07/libmiter_store_posix.dylib',IP,Append),
 memberchk(Append,['event-appended','duplicate-event-id']).

dh2_development_commit(R,Intent,Result) :-
 catch((dh2_development_commit_checked(R,Intent)->Result='helix-v2-development-durable';
 Result='helix-v2-development-incomplete'),_,Result='helix-v2-development-incomplete'),!.
dh2_development_commit_checked(R,Intent) :- dh_verify(R),ground(Intent),
 clause('&derived'('pending-helix-v2-development',R,Intent),true),
 Intent=['helix-v2-development-intent',R,Parent,Candidate,Pins,Decision,Lineage],
 Decision=['trial-admissible'|_],
 Lineage=['existing-model-candidate',CandidateHash,LineageHash],
 dh_trial_material(R,['trial-material',Parent,_,Pins]),
 dh_existing_candidate(R,['model-candidate',Candidate,'model-candidate-bound',
  ['replayed-generation-lineage',CandidateHash,LineageHash]]),
 dh_path(R,'development-intent-v2.json',IP),dh_path(R,'active-v2.json',AP),
 (exists_file(IP)->dh_json(IP,Old),dh_document_native(Old,Intent);
  tv_encode(Intent,T),tv_durable_json(IP,_{native:Intent,term:T})),
 (exists_file(AP)->dh_json(AP,A),dh_document_native(A,Intent);
  tv_encode(Intent,AT),tv_durable_json(AP,_{native:Intent,term:AT})),
 dh2_append(R,'accepted-development-v2',Intent).

dh2_restore(R,Result) :- catch((dh_verify(R),
 dh_path(R,'active-v2.json',P),dh_json(P,D),dh_document_native(D,I),
 I=['helix-v2-development-intent',R|_],
 Result=['durable-helix-v2-development',I]),_,
 Result='helix-v2-development-recovery-incomplete'),!.

dh2_n_commit(R,T,Result) :-
 catch((dh2_n_commit_checked(R,T)->Result='efficacy-durable';
 Result='efficacy-commit-incomplete'),_,Result='efficacy-commit-incomplete'),!.
dh2_n_commit_checked(R,T) :- dh_verify(R),ground(T),
 clause('&derived'('nace-v2-pending',R,T),true),
 T=['efficacy-transition',Old,New,Obs,Reason],Obs=['efficacy-observation',_|_],
 dh_n_key(Old,K),dh_n_key(New,K),atom_concat('efficacy-',K,Stem),
 atom_concat(Stem,'.json',F),dh_path(R,F,P),
 (exists_file(P)->dh_json(P,D),dh_document_native(D,Current),Current==Old;true),
 tv_encode(New,N),tv_durable_json(P,_{native:New,term:N}),
 dh2_hash_native(Old,OldHash),dh2_hash_native(New,NewHash),
 dh2_hash_native(Obs,ObservationHash),
 dh2_append(R,'efficacy-consequence-v2',
  ['efficacy-transition-proof',OldHash,NewHash,ObservationHash,Reason]).
