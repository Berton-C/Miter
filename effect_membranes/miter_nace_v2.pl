% NACE transport and persistence only. Frequency, confidence, outcome meaning,
% family independence and revision are exclusively native MeTTa computations.
:- ensure_loaded('miter_voice_trials_v2.pl').
nn_number(N,Kind,true) :- catch((number(N),N>=0,
 (Kind==frequency->N=<1;Kind==confidence,N<1)),_,fail),!.
nn_number(_,_,false).
nn_root(R,A) :- miter_store_nonempty_atom(R,A),sub_atom(A,0,_,_,'/Users/claritymiter/miter/evidence/G24/'),
 \+sub_atom(A,_,_,_,'..'),\+sub_atom(A,_,_,_,'//'),exists_directory(A),nn_no_links(A).
nn_no_links('/Users/claritymiter/miter/evidence/G24') :- !.
nn_no_links(A) :- \+read_link(A,_,_),file_directory_name(A,P),P\==A,nn_no_links(P).
nn_path(R,F,P) :- nn_root(R,A),atom(F),\+sub_atom(F,_,_,_,'/'),\+sub_atom(F,_,_,_,'..'),
 directory_file_path(A,F,P),\+read_link(P,_,_).
nn_verify(R) :- nn_path(R,'manifest.json',MP),rv_json(MP,M),
 forall(member(F,M.files),(crypto_file_hash(F.path,H,[algorithm(sha256),encoding(octet)]),atom_string(H,F.sha256))),
 forall(member(Rel,['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','src/nal_revision_v1.metta','src/nace_v2.metta','src/bootstrap_nace_v2.metta',
 'src/voice_construction.metta','src/development_evidence.metta','src/relational_voice.metta','src/grounded_language.metta','src/participation_support.metta','src/participation.metta',
 'src/bootstrap_voice_construction.metta','src/bootstrap_relational_voice.metta','src/bootstrap_grounded_language.metta','constitution/soul_compass_v02.metta',
 'effect_membranes/miter_nace_v2.pl','effect_membranes/miter_voice_trials_v2.pl','effect_membranes/miter_voice_construction.pl','effect_membranes/miter_relational_voice.pl','effect_membranes/miter_language.pl','effect_membranes/miter_store.pl']),
  (atom_concat('/Users/claritymiter/miter/',Rel,P),member(F,M.files),atom_string(P,F.path))),
 nn_path(R,'input.json',IP),member(F,M.files),atom_string(IP,F.path).
nn_input(R,N) :- catch((nn_verify(R),nn_path(R,'input.json',P),rv_json(P,D),maplist(nn_invocation(R),D.invocations,Rows),N=['nace-input',Rows]),_,fail),!.
nn_input(_,['nace-input-unavailable']).
nn_invocation(R,D,Inv) :- miter_store_nonempty_atom(D.module_file,F),nn_path(R,F,P),crypto_file_hash(P,H,[algorithm(sha256),encoding(octet)]),atom_string(H,D.module_pin),
 rv_json(P,Actual),miter_store_canonical_json(Actual,J),miter_store_canonical_json(D.module,J),
 nn_path(R,'manifest.json',MP),rv_json(MP,Manifest),member(Entry,Manifest.files),atom_string(P,Entry.path),Entry.sha256==D.module_pin,
 vc_project(D.module,M),rv_native(D.frame,Frame),rv_native(D.roots,Roots),rv_native(D.scope,Scope),
 rv_native([D.id,D.question,D.context,D.module_pin],[Id,Q,Context,Pin]),
 Inv=['efficacy-invocation',Id,Scope,Roots,Frame,Q,Context,Pin,M,D.fuel].
nn_save(R,Name,N,Result) :- memberchk(Name,[observations,results,scalars,revision,restored,validation]),atom_concat(Name,'.json',F),
 catch((nn_verify(R),nn_path(R,F,P),\+exists_file(P),tv_encode(N,T),tv_durable_json(P,_{native:N,term:T})->Result=stored;Result='nace-storage-incomplete'),_,Result='nace-storage-incomplete'),!.
nn_key(['efficacy-belief',Scope,Context,Pin,Id,_,_,_],Key) :- miter_store_canonical_json([Scope,Context,Pin,Id],S),crypto_data_hash(S,Key,[algorithm(sha256),encoding(utf8)]).
nn_store(R,Store) :- nn_root(R,A),directory_file_path(A,store,Store).
nn_current(R,Key,Current) :- nn_store(R,Store),miter_store_load_ledger(Store,Lines),miter_store_analyze(Store,Lines,Analysis,Events),Analysis.status==valid,
 findall(New,(member(E,Events),miter_store_nonempty_atom(E.payload_hash,H),miter_store_payload_path(Store,H,P),rv_json(P,D),miter_store_nonempty_atom(D.key,Key),
  tv_document_native(D,['efficacy-transition',_,New,_,_])),States),
 atom_concat('efficacy-',Key,Stem),atom_concat(Stem,'.json',F),nn_path(R,F,Projection),
 (States=[]-> \+exists_file(Projection),Current=none
 ; last(States,Expected),exists_file(Projection),rv_json(Projection,D),tv_document_native(D,Expected),Current=Expected).
nn_restore(R,Seed,Result) :- catch((nn_verify(R),nn_key(Seed,Key),nn_current(R,Key,C)->
 (C==none->Result='efficacy-never-stored';Result=C);Result=['efficacy-recovery-required','projection-or-integrity']),_,Result=['efficacy-recovery-required','projection-or-integrity']),!.
nn_commit(R,T,Result) :- catch((nn_commit_checked(R,T)->Result='efficacy-durable';Result='efficacy-commit-incomplete'),_,Result='efficacy-commit-incomplete'),!.
nn_commit_checked(R,T) :- nn_verify(R),ground(T),clause('&derived'('nace-pending',R,T),true),
 T=['efficacy-transition',Old,New,Obs,_],Obs=['efficacy-observation',Inv,_,_,_],nn_input(R,['nace-input',Inputs]),memberchk(Inv,Inputs),
 nn_key(Old,Key),nn_key(New,Key),nn_store(R,Store),make_directory_path(Store),
 with_mutex(miter_nace_commit,nn_commit_locked(R,Store,Key,T,Old,New)).
nn_commit_locked(R,Store,Key,T,Old,New) :-
 nn_current(R,Key,C),miter_store_canonical_json(T,S),crypto_data_hash(S,H,[algorithm(sha256),encoding(utf8)]),atom_concat('nace-',H,Id),
 miter_store_load_ledger(Store,Lines),miter_store_analyze(Store,Lines,A,Events),A.status==valid,
 (member(E,Events),miter_store_nonempty_atom(E.event_id,Id)->C==New
 ; (C==none;C==Old),
  (Events=[]->Parents=[];last(Events,Last),Parents=[Last.event_id]),tv_encode(T,Encoded),
  get_time(Now),stamp_date_time(Now,UTC,'UTC'),format_time(string(Time),'%FT%TZ',UTC),
  Intent=_{schema:"miter-event-intent-v1",event_id:Id,event_kind:"efficacy-consequence",occurred_at:Time,recorded_at:Time,
   source_surface:"native-nace-trial",source_principal:"miter-laboratory",audience_scope:"isolated-builder-lab",project_scope:"G24",
   provenance_kind:"native-outcome-and-NAL-revision",correlation_id:H,parent_event_ids:Parents,payload:_{key:Key,native:T,term:Encoded}},
  atom_concat(Id,'.json',IF),nn_path(R,IF,IP),\+exists_file(IP),tv_durable_json(IP,Intent),
  miter_store_append_event(Store,'/Users/claritymiter/miter/runtime/g07/libmiter_store_posix.dylib',IP,'event-appended'),
  atom_concat('efficacy-',Key,Stem),atom_concat(Stem,'.json',F),nn_path(R,F,P),tv_encode(New,EncNew),tv_durable_json(P,_{native:New,term:EncNew,event_id:Id})).
nn_snapshot(R,Name,stored) :- memberchk(Name,[before,after,restart]),atom_concat(Name,'-spaces.json',F),nn_path(R,F,P),\+exists_file(P),
 vc_space('&soul',S),vc_space('&compass',C),vc_space('&derived',D),vc_space('&history',H),tv_durable_json(P,_{soul:S,compass:C,derived:D,history:H}).
