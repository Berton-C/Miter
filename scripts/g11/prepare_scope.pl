:- ensure_loaded('../../effect_membranes/miter_resume.pl').
:- initialization(main,main).
main :-
    Root='runtime/g11-scope/base-store',Capsules='runtime/g11-scope/base-continuity',
    miter_chroma_read_json('tests/fixtures/g08_capsule_current.json',Old),
    crypto_file_hash('tests/fixtures/g11_scope_essay.md',EH,[algorithm(sha256),encoding(octet)]),
    Essay0=Old.put(_{project_id:"project-g11-essay",project_name:"observatory-essay-fixture",
       capsule_id:"essay-capsule-001",previous_capsule_id:"none",supersedes_capsule_id:"none",status:"active",
       current_artifact_ref:"tests/fixtures/g11_scope_essay.md",current_artifact_hash:EH,
       exact_location:"Essay section 1",current_goal:"Research observatory imagery.",
       relevant_event_ids:["source-g11-scope-essay"],created_at:"2026-09-02T06:15:00Z"}),
    write_capsule(Capsules,Essay0),
    Essay=Essay0.put(_{capsule_id:"essay-capsule-002",previous_capsule_id:"essay-capsule-001",
       supersedes_capsule_id:"essay-capsule-001",status:"current",exact_location:"Essay section 2",
       last_completed_work:"Compared historical telescope rooms.",
       open_questions:["Which source documents the brass stair?"],
       next_intended_movement:"Add the brass-stair source citation.",created_at:"2026-09-02T06:30:00Z"}),
    write_capsule(Capsules,Essay),select_capsule(Capsules,Essay),
    append_event(Root,"source-g11-scope-essay","essay-checkpoint","2026-09-02T06:30:00Z",
       "project-g11-essay",_{capsule_id:Essay.capsule_id,artifact_hash:EH}),
    Book=Old.put(_{project_name:"book-continuity-fixture",capsule_id:"capsule-g11-scope-003",
       previous_capsule_id:"capsule-g08-002",supersedes_capsule_id:"capsule-g08-002",
       relevant_event_ids:["evt-g07-witnessed-result-0003","evt-g07-fork-0004","source-g11-scope-book-pause"],
       created_at:"2026-09-02T07:00:00Z"}),
    append_event(Root,"source-g11-scope-book-pause","project-checkpoint","2026-09-02T07:00:00Z",
       Book.project_id,_{capsule_id:Book.capsule_id,project_id:Book.project_id,
                       artifact_hash:Book.current_artifact_hash,exact_location:Book.exact_location}),
    write_capsule(Capsules,Book),select_capsule(Capsules,Book),
    miter_cs_write('runtime/g11-scope/book-capsule.json',Book),
    forall(member(Id-Time,["scope-unrelated-15"-"2026-09-17T07:00:00Z",
       "scope-unrelated-50"-"2026-10-22T07:00:00Z","scope-unrelated-89"-"2026-11-30T07:00:00Z",
       "scope-unrelated-90"-"2026-12-01T06:59:00Z"]),
       append_event(Root,Id,"unrelated-contact",Time,"unrelated-project",_{topic:"Synthetic non-writing work."})),
    Registry=_{schema:"miter-project-registry-v1",projects:[
       _{kind:"book",project_id:Book.project_id,principal_scope:Book.principal_scope,audience_scope:Book.audience_scope},
       _{kind:"essay",project_id:Essay.project_id,principal_scope:Essay.principal_scope,audience_scope:Essay.audience_scope}]},
    miter_cs_write('runtime/g11-scope/project-registry.json',Registry),
    crypto_file_hash('runtime/g11-scope/project-registry.json',Hash,[algorithm(sha256),encoding(octet)]),
    forall(member(Arm,[canonical,'chroma-off','capsule-off']),context(Arm,Hash)).
write_capsule(Root,C) :-
    format(atom(Path),'runtime/g11-scope/input-~s.json',[C.capsule_id]),miter_cs_write(Path,C),
    miter_continuity_write_capsule(Root,'runtime/g07/libmiter_store_posix.dylib',Path,R),
    writeln(R),R=='capsule-appended'.
select_capsule(Root,C) :-
    miter_continuity_set_current(Root,'runtime/g07/libmiter_store_posix.dylib',C.project_id,C.capsule_id,R),
    writeln(R),R=='current-capsule-selected'.
append_event(Root,Id,Kind,Time,Project,Payload) :-
    I=_{schema:"miter-event-intent-v1",event_id:Id,event_kind:Kind,occurred_at:Time,recorded_at:Time,
      source_surface:"g11-scope-fixture",source_principal:"principal:g08-human",
      audience_scope:"scope:g08-private-project",project_scope:Project,provenance_kind:"direct-contact",
      parent_event_ids:[],correlation_id:"g11-scope-timeline",payload:Payload},
    format(atom(Path),'runtime/g11-scope/events/~s.json',[Id]),miter_cs_write(Path,I),
    miter_store_append_event(Root,'runtime/g07/libmiter_store_posix.dylib',Path,R),writeln(R),R=='event-appended'.
context(Arm,Hash) :-
    format(atom(Old),'runtime/g11/~w/context.json',[Arm]),miter_chroma_read_json(Old,C),
    format(atom(Store),'runtime/g11-scope/~w/store',[Arm]),format(atom(Out),'runtime/g11-scope/~w/outputs',[Arm]),
    directory_file_path(Out,'capsule.json',CapOut),format(atom(Path),'runtime/g11-scope/~w/context.json',[Arm]),
    format(string(Id),'g11-scope-~w',[Arm]),
    New=C.put(_{request_id:Id,query_tag:Id,registry_ref:"runtime/g11-scope/project-registry.json",
      registry_sha256:Hash,memory_store:Store,capsule_store:"runtime/g11-scope/base-continuity",
      output_dir:Out,capsule_output:CapOut}),miter_cs_write(Path,New).
