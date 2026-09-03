% G22 byte projection, integrity and durable transport only. No quality scoring,
% semantic interpretation or promotion decision is implemented in this membrane.
:- ensure_loaded('miter_voice_construction.pl').

tv_root(R,A) :- miter_store_nonempty_atom(R,A),
 sub_atom(A,0,_,_,'/Users/claritymiter/miter/evidence/G22/'),
 \+sub_atom(A,_,_,_,'..'),\+sub_atom(A,_,_,_,'//'),exists_directory(A),tv_no_links(A).
tv_no_links('/Users/claritymiter/miter/evidence/G22') :- !.
tv_no_links(A) :- \+read_link(A,_,_),file_directory_name(A,Parent),Parent\==A,tv_no_links(Parent).
tv_path(R,F,P) :- tv_root(R,A),atom(F),\+sub_atom(F,_,_,_,'/'),\+sub_atom(F,_,_,_,'..'),
 directory_file_path(A,F,P),\+read_link(P,_,_).
tv_input(R,Kind,N) :- memberchk(Kind,[input,'parent-report','candidate-report']),atom_concat(Kind,'.json',F),
 catch((tv_path(R,F,P),rv_json(P,D),tv_document_native(D,N)),_,fail),!.
tv_input(_,_,['trial-input-unavailable']).
tv_module(R,Kind,N) :- memberchk(Kind,[parent,candidate]),atom_concat(Kind,'.json',F),
 catch((tv_path(R,F,P),rv_json(P,D),vc_project(D,N)),_,fail),!.
tv_module(_,_,['malformed-candidate']).
tv_save(R,Kind,N,Result) :- memberchk(Kind,['parent-report','candidate-report',decision]),
 atom_concat(Kind,'.json',F),catch((tv_path(R,F,P),\+exists_file(P),
 tv_encode(N,Encoded),tv_durable_json(P,_{native:N,term:Encoded})->Result='trial-observation-stored';Result='trial-storage-failed'),_,Result='trial-storage-failed'),!.
% JSON alone conflates Prolog atoms and strings. Preserve the exact inert term
% types in evidence, without ever reading/evaluating serialized source code.
tv_encode(N,_{list:Encoded}) :- is_list(N),!,maplist(tv_encode,N,Encoded).
tv_encode(N,_{string:N}) :- string(N),!.
tv_encode(N,_{atom:S}) :- atom(N),!,atom_string(N,S).
tv_encode(N,_{number:N}) :- number(N).
tv_decode(D,N) :- dict_pairs(D,_,[list-Items]),!,is_list(Items),maplist(tv_decode,Items,N).
tv_decode(D,N) :- dict_pairs(D,_,[string-N]),!,string(N).
tv_decode(D,N) :- dict_pairs(D,_,[atom-S]),!,string(S),atom_string(N,S).
tv_decode(D,N) :- dict_pairs(D,_,[number-N]),number(N).
tv_document_native(D,N) :- (get_dict(term,D,Encoded)->tv_decode(Encoded,N),
 miter_store_canonical_json(N,J),miter_store_canonical_json(D.native,J);rv_native(D.native,N)).
tv_durable_json(P,D) :- miter_store_ensure_extension('/Users/claritymiter/miter/runtime/g07/libmiter_store_posix.dylib'),
 atom_concat(P,'.tmp',Tmp),\+exists_file(Tmp),\+read_link(Tmp,_,_),
 setup_call_cleanup(open(Tmp,write,S,[encoding(utf8)]),
  (chmod(Tmp,0o600),json_write_dict(S,D,[width(0)]),nl(S),flush_output(S),miter_store_fsync_stream(S)),close(S)),rename_file(Tmp,P).

tv_required('CONSTITUTION.md').
tv_required('MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md').
tv_required('ACCEPTANCE.md').
tv_required('constitution/soul_compass_v02.metta').
tv_required('src/participation.metta').
tv_required('src/participation_support.metta').
tv_required('src/grounded_language.metta').
tv_required('src/relational_voice.metta').
tv_required('src/development_evidence.metta').
tv_required('src/voice_construction.metta').
tv_required('src/voice_trials_v2.metta').
tv_required('src/bootstrap_voice_trials_v2.metta').
tv_required('effect_membranes/miter_voice_trials_v2.pl').
tv_required('effect_membranes/miter_voice_construction.pl').
tv_required('effect_membranes/miter_relational_voice.pl').
tv_required('effect_membranes/miter_language.pl').
tv_required('effect_membranes/miter_store.pl').
tv_required('config/voice-realization-schema-v2.json').
tv_verify(R,Result) :- catch((tv_verify_checked(R)->Result='trial-inputs-bound';Result='trial-integrity-failed'),_,Result='trial-integrity-failed'),!.
tv_verify_checked(R) :- tv_path(R,'manifest.json',MP),rv_json(MP,M),
 forall(member(F,M.files),(crypto_file_hash(F.path,H,[algorithm(sha256),encoding(octet)]),atom_string(H,F.sha256))),
 forall(tv_required(Rel),(atom_concat('/Users/claritymiter/miter/',Rel,P),member(F,M.files),atom_string(P,F.path))),
 forall(member(FN,['input.json','parent.json','candidate.json','parent-report.json','candidate-report.json','lineage.json']),
  (tv_path(R,FN,P),member(F,M.files),atom_string(P,F.path))),
 tv_input(R,input,['trial-input',_,Pins]),rv_native(M.pins,Pins),
 tv_path(R,'parent.json',PP),crypto_file_hash(PP,PH,[algorithm(sha256),encoding(octet)]),
 tv_path(R,'candidate.json',CP),crypto_file_hash(CP,CH,[algorithm(sha256),encoding(octet)]),
 Pins=['trial-pins',PH,CH,_,_],
 tv_path(R,'lineage.json',LP),rv_json(LP,L),
 atom_string(PH,L.parent_hash),atom_string(CH,L.candidate_hash),
 forall(member(F,L.files),(crypto_file_hash(F.path,H,[algorithm(sha256),encoding(octet)]),atom_string(H,F.sha256))),
 (L.standing=="model-candidate-bound"->
  rv_json('/Users/claritymiter/miter/evidence/SC08/live-001/cycle/request/raw.json',Raw),miter_lm_provider_product(Raw,Actual),
  rv_json(CP,C),miter_store_canonical_json(Actual,J),miter_store_canonical_json(C,J)
 ; L.standing=="builder-synthetic-record-only").
tv_identity(R,H) :- tv_verify_checked(R),tv_path(R,'manifest.json',P),crypto_file_hash(P,H,[algorithm(sha256),encoding(octet)]).
tv_authority(R,['trial-authority',Authority]) :- tv_verify_checked(R),tv_path(R,'lineage.json',P),rv_json(P,D),
 (D.standing=="model-candidate-bound"->Authority='record-and-activate';Authority='record-only').

% The native writer must already have staged this exact ground intent. Candidates
% cannot invoke this broker: their only input form is the inert v2 grammar.
tv_commit(R,Intent,Result) :- catch((tv_commit_checked(R,Intent)->Result='development-durable';Result='development-not-committed'),_,Result='development-not-committed'),!.
tv_commit_checked(R,Intent) :- tv_verify_checked(R),ground(Intent),
 clause('&derived'('pending-trial-commit',R,Intent),true),
 Intent=['development-intent',R,Parent,Candidate,Pins,Decision,['trial-evidence',ManifestHash]],tv_identity(R,ManifestHash),
 tv_module(R,parent,Parent),tv_module(R,candidate,Candidate),tv_input(R,input,['trial-input',_,Pins]),
 Decision=[DecisionTag|_],memberchk(DecisionTag,['trial-admissible','trial-not-admitted']),
 tv_root(R,A),directory_file_path(A,store,Store),make_directory_path(Store),
 with_mutex(miter_voice_trial_commit,tv_commit_locked(R,Store,Intent,DecisionTag)).
tv_commit_locked(R,Store,Intent,Tag) :-
 miter_store_canonical_json(Intent,Text),crypto_data_hash(Text,Hash,[algorithm(sha256),encoding(utf8)]),
 atom_concat('voice-development-',Hash,EventId),
 miter_store_load_ledger(Store,Lines),miter_store_analyze(Store,Lines,Analysis,Events),Analysis.status==valid,
 (Events=[]->true;Events=[E],miter_store_nonempty_atom(E.event_id,EventId)),
 tv_path(R,'development-intent.json',IP),
 (exists_file(IP)->rv_json(IP,Old),tv_document_native(Old.payload,Intent)
 ; tv_encode(Intent,Encoded),get_time(Now),format_time(string(T),'%FT%TZ',Now),Event=_{schema:"miter-event-intent-v1",event_id:EventId,event_kind:Tag,occurred_at:T,recorded_at:T,
 source_surface:"native-voice-trial",source_principal:"miter-laboratory",audience_scope:"isolated-builder-lab",project_scope:"G22",
 provenance_kind:"native-trial-consequence",correlation_id:Hash,parent_event_ids:[],payload:_{native:Intent,term:Encoded}},tv_durable_json(IP,Event)),
 miter_store_append_event(Store,'/Users/claritymiter/miter/runtime/g07/libmiter_store_posix.dylib',IP,Result),memberchk(Result,['event-appended','duplicate-event-id']),
 tv_path(R,'active.json',AP),
 (Tag=='trial-admissible'->
  (exists_file(AP)->rv_json(AP,Active),tv_document_native(Active,Intent);tv_encode(Intent,EncodedActive),tv_durable_json(AP,_{native:Intent,term:EncodedActive,event_id:EventId}))
 ; \+exists_file(AP)).
tv_restore(R,Result) :- catch((tv_restore_checked(R,I)->Result=['durable-development',I];Result='development-recovery-incomplete'),_,Result='development-recovery-incomplete'),!.
tv_restore_checked(R,Intent) :- tv_verify_checked(R),tv_root(R,A),directory_file_path(A,store,Store),
 miter_store_load_ledger(Store,Lines),miter_store_analyze(Store,Lines,Analysis,[E]),Analysis.status==valid,
 tv_path(R,'development-intent.json',IP),rv_json(IP,D),tv_document_native(D.payload,Intent),
 miter_store_canonical_json(Intent,Text),crypto_data_hash(Text,H,[algorithm(sha256),encoding(utf8)]),atom_concat('voice-development-',H,Id),
 miter_store_nonempty_atom(E.event_id,Id),miter_store_canonical_json(D.payload,PText),crypto_data_hash(PText,PH,[algorithm(sha256),encoding(utf8)]),miter_store_nonempty_atom(E.payload_hash,PH),
 Intent=['development-intent',R,_,_,_,Decision,['trial-evidence',ManifestHash]],tv_identity(R,ManifestHash),
 (Decision=['trial-admissible'|_]->tv_path(R,'active.json',AP),rv_json(AP,Active),tv_document_native(Active,Intent);true).
tv_snapshot(R,Name,stored) :- memberchk(Name,[before,after,restart]),tv_path(R,Name,P0),atom_concat(P0,'-spaces.json',P),\+exists_file(P),
 vc_space('&soul',S),vc_space('&history',H),vc_space('&compass',C),vc_space('&derived',D),vc_space('&trial',T),
 tv_durable_json(P,_{soul:S,history:H,compass:C,derived:D,trial:T}).
