% Typed byte/identity binder and restart journal. Native MeTTa composes meaning.
:- ensure_loaded('miter_nace_v2.pl').
:- ensure_loaded('miter_continuity.pl').
dr_root(R,A) :- nn_root(R,A),sub_atom(A,_,_,_,'/G24/g26-').
dr_file(R,F,P) :- dr_root(R,_),nn_path(R,F,P).
dr_verify(R,D) :- dr_file(R,'resume.json',P),rv_json(P,D),D.schema=="miter-development-resume-v1",
 dr_file(R,'resume-manifest.json',MP),rv_json(MP,M),
 forall(member(F,M.files),(crypto_file_hash(F.path,H,[algorithm(sha256),encoding(octet)]),atom_string(H,F.sha256))),
 member(F,M.files),atom_string(P,F.path),
 forall(member(Rel,['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','src/nace_selection_v1.metta','src/bootstrap_nace_selection_v1.metta',
 'src/development_resume_v1.metta','src/bootstrap_development_resume_v1.metta','effect_membranes/miter_development_resume_v1.pl','effect_membranes/miter_continuity.pl']),
  (atom_concat('/Users/claritymiter/miter/',Rel,RP),member(E,M.files),atom_string(RP,E.path))),
 nn_verify(D.efficacy_root),tv_verify_checked(D.accepted_root).
dr_history(References,Rows) :- maplist(dr_history_ref,References,Nested),append(Nested,Rows).
dr_history_ref(D,Rows) :- miter_store_load_ledger(D.store,Lines),miter_store_analyze(D.store,Lines,A,Events),A.status==valid,
 findall(['history-reference',Id,Kind,Payload,Hash],
  (member(E,Events),Id=E.event_id,Kind=E.event_kind,Payload=E.payload_hash,Hash=E.event_hash),Rows),
 forall(member(Id,D.event_ids),(member(E,Events),E.event_id==Id)).
dr_input(R,N) :- catch(dr_input_checked(R,N),_,fail),!.
dr_input(_,['restart-input-recovery-required']).
dr_input_checked(R,N) :- dr_verify(R,D),dr_root(R,A),
 directory_file_path(A,continuity,CS),atom_string(CS,D.capsule_store),
 miter_store_nonempty_atom(D.project_id,Project),
 miter_continuity_current_path(CS,Project,IndexPath),exists_file(IndexPath),
 miter_continuity_load_capsules(CS,Project,Capsules),
 miter_continuity_reconstruct_current(Project,IndexPath,Capsules,'continuity-reconstructed',C),
 miter_continuity_load_capsule(CS,Project,C.current_capsule_id,Full),
 dr_file(R,'frame.json',FP),atom_string(FP,Full.current_artifact_ref),rv_json(FP,FrameD),rv_native(FrameD.native,Frame),
 nn_input(D.efficacy_root,['nace-input',Inputs]),maplist(dr_index(Inputs),D.invocation_indices,Invs),
 dr_history(D.history,History),forall(member(Id,Full.relevant_event_ids),member(['history-reference',Id,_,_,_],History)),
 rv_native([Project,Full.principal_scope,Full.audience_scope,Full.capsule_id,Full.exact_location,Full.current_goal,
  Full.last_completed_work,Full.open_questions,Full.next_intended_movement,Full.previous_capsule_id,Full.relevant_event_ids,Full.current_artifact_hash],
 [ProjectN,Principal,Audience,CID,Location,Goal,Done,Questions,Next,Prior,EventIDs,ArtifactHash]),
 dr_file(R,'resume.json',CP),crypto_file_hash(CP,CH,[algorithm(sha256),encoding(octet)]),
 dr_bindings(D,Bindings),
 N=['resume-input',D.accepted_root,D.efficacy_root,Invs,
  ['resume-capsule',ProjectN,Principal,Audience,CID,Frame,Location,Goal,Done,Questions,Next,Prior,EventIDs,ArtifactHash],D.chat_context,History,CH,Bindings].
dr_index(Inputs,I,Inv) :- integer(I),I>=0,nth0(I,Inputs,Inv).
% Raw JSON formatting differs between the admitted artifact and efficacy input.
% Preserve both byte hashes; establish exact parsed-JSON identity, not a guessed
% hash equivalence or semantic similarity. Native module equality is also tested.
dr_bindings(D,Bindings) :- nn_path(D.efficacy_root,'input.json',P),rv_json(P,ND),
 findall(['module-byte-binding',AcceptedHash,EfficacyHash],
  (member(I,D.invocation_indices),nth0(I,ND.invocations,Row),member(Kind,[parent,candidate]),
   atom_concat(Kind,'.json',F),tv_path(D.accepted_root,F,AP),rv_json(AP,Original),
   miter_store_canonical_json(Original,J),miter_store_canonical_json(Row.module,J),
   crypto_file_hash(AP,AcceptedHash,[algorithm(sha256),encoding(octet)]),atom_string(EfficacyHash,Row.module_pin)),Bindings).
dr_record(R,T,Result) :- catch((dr_record_checked(R,T)->Result='restart-recorded';Result='restart-record-incomplete'),_,Result='restart-record-incomplete'),!.
dr_record_checked(R,T) :- dr_input_checked(R,Input),ground(T),clause('&derived'('resume-pending',R,T),true),
 Input=['resume-input',_,_,_,Capsule,_,History,H,Bindings],T=['resumed-development',H,Capsule,History,Bindings],
 dr_root(R,A),directory_file_path(A,'restart-store',Store),make_directory_path(Store),current_prolog_flag(pid,Pid),
 format(atom(Id),'restart-~d-~w',[Pid,H]),atom_concat(Id,'.json',F),dr_file(R,F,P),
 (exists_file(P)->rv_json(P,Existing),tv_document_native(Existing.payload,T)
 ;miter_store_load_ledger(Store,Lines),miter_store_analyze(Store,Lines,Analysis,Events),Analysis.status==valid,
  (Events=[]->Parents=[];last(Events,E),Parents=[E.event_id]),
  get_time(Now),stamp_date_time(Now,UTC,'UTC'),format_time(string(Time),'%FT%TZ',UTC),tv_encode(T,Enc),
  Event=_{schema:"miter-event-intent-v1",event_id:Id,event_kind:"development-restart",occurred_at:Time,recorded_at:Time,
   source_surface:"native-restart",source_principal:"miter-laboratory",audience_scope:"isolated-builder-lab",project_scope:Capsule,
   provenance_kind:"native-rehydration",correlation_id:H,parent_event_ids:Parents,payload:_{native:T,term:Enc}},
  Capsule=['resume-capsule',Project|_],Correct=Event.put(project_scope,Project),tv_durable_json(P,Correct)),
 miter_store_append_event(Store,'/Users/claritymiter/miter/runtime/g07/libmiter_store_posix.dylib',P,Status),memberchk(Status,['event-appended','duplicate-event-id']).
dr_snapshot(R,Name,stored) :- memberchk(Name,[before,after]),dr_file(R,Name,P0),atom_concat(P0,'-spaces.json',P),\+exists_file(P),
 vc_space('&soul',S),vc_space('&compass',C),vc_space('&derived',D),vc_space('&history',H),tv_durable_json(P,_{soul:S,compass:C,derived:D,history:H}).
dr_capture(R,Name0,N,N) :- miter_store_nonempty_atom(Name0,Name),atom_concat(Name,'-native.json',F),
 dr_file(R,F,P),\+exists_file(P),tv_encode(N,Enc),tv_durable_json(P,_{native:N,term:Enc}).
