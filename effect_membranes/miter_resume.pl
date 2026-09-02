% G11 transport, source verification, and deterministic answer serialization.
% Intent, project cardinality, severing, and exactness are MeTTa decisions.
:- ensure_loaded('miter_memory.pl').

miter_resume_field(Context, Key0, Value) :-
    catch((miter_chroma_read_json(Context,C),miter_chroma_nonempty_atom(Key0,K),
           get_dict(K,C,V),string(V) -> Value=V ; Value="missing-field"),
          _,Value="malformed-context"),!.

miter_resume_registry_count(Context,Kind,Count) :-
    catch((miter_resume_matches(Context,Kind,Matches),length(Matches,N)->Count=N;Count= -1),
          _,Count= -1),!.
miter_resume_registry_project(Context,Kind,Project) :-
    catch((miter_resume_matches(Context,Kind,[Match])->Project=Match.project_id;
           Project="project-not-unique"),_,Project="registry-invalid"),!.
miter_resume_matches(Context,Kind0,Matches) :-
    miter_chroma_read_json(Context,C),miter_chroma_nonempty_string(Kind0,Kind),
    crypto_file_hash(C.registry_ref,H,[algorithm(sha256),encoding(octet)]),
    atom_string(H,C.registry_sha256),miter_chroma_read_json(C.registry_ref,Registry),
    findall(P,(member(P,Registry.projects),P.kind==Kind,
               P.principal_scope==C.principal_scope,P.audience_scope==C.audience_scope),Matches).

miter_resume_begin(Context,Result) :-
    miter_mem_total(miter_resume_begin_checked(Context),'restart-contact-recorded',Result).
miter_resume_begin_checked(Context) :-
    miter_chroma_read_json(Context,C),C.chat_context==[],
    current_prolog_flag(pid,Pid),
    miter_store_load_ledger(C.memory_store,Lines),
    miter_store_analyze(C.memory_store,Lines,Analysis,_),Analysis.status==valid,
    miter_resume_event(C,"restart","process-restarted",_{pid:Pid,chat_context:[],
      bounded_runtime:"G11-ContinuityRNA-RecallRNA",simulated_time:true},RestartId),
    miter_resume_event(C,"request","external-message",_{text:C.text,parent_restart:RestartId},_),
    directory_file_path(C.output_dir,'startup.json',Startup),
    miter_cs_write(Startup,_{schema:"miter-g11-empty-context-v1",pid:Pid,
      chat_context:[],chat_model_requests:0,pre_start_trajectory:Analysis,
      request:C.text,scope:C.audience_scope,simulated_time:C.occurred_at}).
miter_resume_event(C,Suffix,Kind,Payload,Id) :-
    format(string(Id),'~s-~s',[C.request_id,Suffix]),
    Intent=_{schema:"miter-event-intent-v1",event_id:Id,event_kind:Kind,
      occurred_at:C.occurred_at,recorded_at:C.occurred_at,source_surface:"g11-native-restart",
      source_principal:C.principal_scope,audience_scope:C.audience_scope,
      % The vague input has not selected a project yet. Selection happens
      % later in native ContinuityRNA; never bake a fixture project into IO.
      project_scope:"unresolved-project",provenance_kind:"direct-contact",
      parent_event_ids:[],correlation_id:C.request_id,payload:Payload},
    format(atom(Name),'~s-intent.json',[Suffix]),directory_file_path(C.output_dir,Name,Path),
    miter_cs_write(Path,Intent),
    miter_store_append_event(C.memory_store,'runtime/g07/libmiter_store_posix.dylib',Path,R),
    miter_cs_require(R=='event-appended',R).

miter_resume_witness(Context,Result) :-
    miter_mem_total(miter_resume_witness_checked(Context),'capsule-event-verified',Result).
miter_resume_witness_checked(Context) :-
    miter_chroma_read_json(Context,C),miter_chroma_read_json(C.capsule_output,D),
    D.status=="reconstructed",
    miter_store_load_ledger(C.memory_store,Lines),miter_store_analyze(C.memory_store,Lines,A,Events),
    A.status==valid,
    forall(member(Id,D.relevant_event_ids),(member(E,Events),E.event_id==Id)),
    member(E,Events),memberchk(E.event_id,D.relevant_event_ids),
    miter_chroma_nonempty_atom(E.payload_hash,Hash),
    miter_store_payload_path(C.memory_store,Hash,PayloadPath),miter_chroma_read_json(PayloadPath,P),
    get_dict(capsule_id,P,D.current_capsule_id),
    get_dict(project_id,P,D.project_id),get_dict(artifact_hash,P,D.current_artifact_hash),
    get_dict(exact_location,P,D.exact_location),!,
    directory_file_path(C.output_dir,'capsule-event-witness.json',Path),
    miter_cs_write(Path,_{event_id:E.event_id,event_hash:E.event_hash,
       capsule_id:D.current_capsule_id,artifact_hash:D.current_artifact_hash,ledger:A}).

miter_resume_answer(Context,Certificate0,Semantic0,Result) :-
    miter_mem_total(miter_resume_answer_checked(Context,Certificate0,Semantic0),
                   'continuity-answer-stored',Result).
miter_resume_answer_checked(Context,Certificate0,Semantic0) :-
    miter_chroma_read_json(Context,C),
    miter_chroma_nonempty_string(Certificate0,Certificate),
    miter_chroma_nonempty_string(Semantic0,Semantic),
    ( Certificate == "exact-continuity" ->
      miter_chroma_read_json(C.capsule_output,D),
      miter_chroma_nonempty_atom(D.project_id,Project),
      miter_chroma_nonempty_atom(D.current_capsule_id,Id),
      miter_continuity_load_capsule(C.capsule_store,Project,Id,Capsule),
      Fields=_{project_id:D.project_id,project_name:Capsule.project_name,
        artifact_ref:D.current_artifact_ref,artifact_hash:D.current_artifact_hash,
        anchor:D.exact_location,last_completed_work:D.last_completed_work,
        unresolved_question:D.unresolved_question,live_tensions:D.live_tensions,
        next_move:D.next_intended_movement,capsule_id:D.current_capsule_id,
        capsule_hash:D.current_capsule_hash,source_event_ids:D.relevant_event_ids},
      Uncertainty=[]
    ; Certificate == "non-authoritative-recall",
      Fields=null,Uncertainty=["Exact continuity cannot be certified without the capsule resolver and trajectory witness."] ),
    ( Semantic == "memory-query-verified" -> SemAvailable=true ; SemAvailable=false ),
    Answer=_{schema:"miter-continuity-answer-v1",question:C.text,
      certificate:Certificate,exact_state:Fields,uncertainty:Uncertainty,
      semantic_result:Semantic,semantic_available:SemAvailable,
      chat_model_context:[],authority:"native-capsule-and-trajectory-certificate"},
    directory_file_path(C.output_dir,'answer.json',Path),miter_cs_write(Path,Answer).
