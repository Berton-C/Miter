% Exact local Git/storage/process mechanics. Admission is native MeTTa.
:- ensure_loaded('miter_executable_development_v3.pl').
wp_root(R,A) :- miter_store_nonempty_atom(R,A),re_match('^/Users/claritymiter/miter/evidence/G28-R3/attempt-[0-9]+$',A),exists_directory(A),\+read_link(A,_,_).
wp_path(R,N,P) :- wp_root(R,A),ww_id(N,I),atom_concat(I,'.json',F),directory_file_path(A,F,P),\+read_link(P,_,_).
wp_verify(R,G) :- wp_path(R,manifest,MP),rv_json(MP,M),
 forall(member(F,M.files),(crypto_file_hash(F.path,H,[algorithm(sha256),encoding(octet)]),atom_string(H,F.sha256))),
 forall(member(Rel,['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','config/workshop-promotion-v1.json',
 'src/executable_promotion_v1.metta','src/bootstrap_executable_promotion_v1.metta','effect_membranes/miter_workshop_promotion_v1.pl']),
  (atom_concat('/Users/claritymiter/miter/',Rel,P),member(E,M.files),atom_string(P,E.path))),
 wp_path(R,input,IP),member(IE,M.files),atom_string(IP,IE.path),
 rv_json('/Users/claritymiter/miter/config/workshop-promotion-v1.json',G),
 G.schema=="miter-workshop-promotion-v1",G.workshop_root=="/Users/claritymiter/miter/runtime/g27/attempt-28204",
 G.evidence_root=="/Users/claritymiter/miter/evidence/G28-R2/attempt-004",ww_root(G.workshop_root,_),
 directory_file_path(G.workshop_root,'grant.json',GP),rv_json(GP,Old),
 forall(member(F,Old.integrity),(crypto_file_hash(F.path,H,[algorithm(sha256),encoding(octet)]),atom_string(H,F.sha256))),
 forall(member(Name,['candidate-1.json','final.json','trial-1.json','fresh-1-wire.json','fresh-1-timing.json']),
  (directory_file_path(G.evidence_root,Name,P),member(E,M.files),atom_string(P,E.path))).
wp_input(R,I) :- catch((wp_verify(R,_),wp_path(R,input,P),rv_json(P,D),rv_native(D.native,I)),_,fail),!.
wp_input(_,['promotion-input-unavailable']).
wp_save(R,N,V,Result) :- catch((wp_verify(R,_),wp_path(R,N,P),
 (exists_file(P)->rv_json(P,D),tv_document_native(D,V);tv_encode(V,E),tv_durable_json(P,_{native:V,term:E}))
 ->Result=stored;Result='promotion-storage-incomplete'),_,Result='promotion-storage-incomplete'),!.
wp_saved(R,N,V) :- catch((wp_verify(R,_),wp_path(R,N,P),rv_json(P,D),tv_document_native(D,V)),_,fail),!.
wp_saved(_,_,['no-saved-promotion']).
wp_git(G,Args,Status,Out,Err) :- directory_file_path(G.workshop_root,seed,Seed),directory_file_path(Seed,'.git',GD),
 ww_git(G.workshop_root,GD,Seed,Args,Status,Out,Err).
wp_head(G,Ref,H) :- wp_git(G,['rev-parse',Ref],exit(0),Out,_),normalize_space(atom(H),Out).
wp_packet(G,O,C,T) :- directory_file_path(G.evidence_root,'final.json',F),rv_json(F,D),
 tv_document_native(D,['executable-awaiting-approval',['executable-promotion-proposal',O,C,T,_,_],_]).
wp_snapshot(R,['promotion-snapshot',O,C,T,Target,Parent,Digest,Current,CH,MainClean,CandidateClean,Bound]) :-
 wp_verify(R,G),wp_packet(G,O,C,T),atom_string(Target,G.target),atom_string(Parent,G.parent),
 directory_file_path(G.evidence_root,'candidate-1.json',CP),crypto_file_hash(CP,Digest,[algorithm(sha256),encoding(octet)]),
 wp_head(G,main,Current),atom_concat('candidate-',G.candidate,Branch),wp_head(G,Branch,CH),
 wp_git(G,['status','--porcelain'],exit(0),MS,_),(MS==""->MainClean=true;MainClean=false),
 ww_state(G.workshop_root,G.candidate,S),ww_git(G.workshop_root,S.gitdir,S.path,['status','--porcelain'],exit(0),CS,_),
 (CS==""->CandidateClean=true;CandidateClean=false),
 C=['executable-candidate',_,Files,_],
 (forall(member(['candidate-file',Rel,Text,H],Files),(ww_candidate_path(G.workshop_root,S,Rel,P),read_file_to_string(P,Text,[]),crypto_file_hash(P,H,[algorithm(sha256),encoding(octet)])))
  ->Bound=true;Bound=false),!.
wp_snapshot(_,['promotion-snapshot-unavailable']).
wp_state_path(G,N,P) :- ww_id(N,I),directory_file_path(G.workshop_root,promotion,Dir),make_directory_path(Dir),
 atom_concat(I,'.json',F),directory_file_path(Dir,F,P),ww_no_links(P).
wp_store(P,V) :- tv_encode(V,E),(exists_file(P)->rv_json(P,D),tv_document_native(D,V);tv_durable_json(P,_{native:V,term:E})).
wp_read(P,V) :- rv_json(P,D),tv_document_native(D,V).
wp_cert(R,G,C) :- wp_verify(R,G),wp_saved(R,decision,['promotion-admitted',C,_]),
 C=['promotion-certificate',Target,Parent,_,_,_],atom_string(Target,G.target),atom_string(Parent,G.parent).
wp_effect(G,Id,Operation,Payload,Status,Details,Receipt) :-
 D=_{schema:"miter-promotion-effect-v1",request_id:Id,idempotency_key:Id,operation:Operation,payload:Payload},
 miter_store_canonical_json(D,J),crypto_data_hash(J,H,[algorithm(sha256),encoding(utf8)]),ww_finish(G.workshop_root,D,H,Status,Details,none,Receipt).
wp_merge(R,C,Out) :- catch((ground(C),clause('&derived'('executable-promotion-pending',R,C),true),wp_cert(R,G,C),
 with_mutex(miter_promotion,wp_merge_checked(G,C,Out)))->true;Out=['promotion-denied'],E,(term_string(E,S),Out=['promotion-incomplete',S])),!.
wp_merge_checked(G,C,Out) :- wp_state_path(G,'merge-result',RP),
 (exists_file(RP)->wp_read(RP,Out),Out=['promotion-committed',Merge,Parent,Target,_],wp_head(G,main,Merge),atom_string(Parent,G.parent),atom_string(Target,G.target);
  wp_state_path(G,prepared,PP),directory_file_path(G.workshop_root,'promotion/merge.claim',Lock),
  wp_head(G,main,Current),atom_string(Base,G.parent),
  (Current==Base->
    (exists_directory(Lock)->Out=['promotion-recovery-required','prepared-with-unchanged-parent'];
     wp_git(G,['status','--porcelain'],exit(0),"",_),wp_head(G,G.target,Target),
     wp_git(G,['merge-base','--is-ancestor',G.parent,G.target],exit(0),_,_),
     make_directory(Lock),wp_store(PP,['prepared-promotion',C]),
     wp_git(G,['-c','user.name=Miter approved laboratory promotion','-c','user.email=miter-lab@example.invalid',
       'merge','--no-ff','--no-edit','-m','Promote independently tested G28 candidate under explicit human approval',Target],Status,Stdout,Stderr),
     term_string(Status,StatusText),wp_state_path(G,'git-operation',GP),tv_durable_json(GP,_{exit:StatusText,stdout:Stdout,stderr:Stderr}),
     (Status==exit(0)->
       (G.test_interrupt_after_git==true->Out=['promotion-incomplete','injected-after-git-before-receipt'];wp_merged(G,C,Out),wp_store(RP,Out))
      ;Out=['promotion-incomplete','git-observation-retained']))
   ;exists_file(PP),wp_read(PP,['prepared-promotion',C]),wp_merged(G,C,Out),wp_store(RP,Out))).
wp_merged(G,C,['promotion-committed',Merge,Parent,Target,Receipt]) :-
 wp_head(G,main,Merge),atom_string(Parent,G.parent),atom_string(Target,G.target),
 wp_git(G,['show','-s','--format=%P',Merge],exit(0),PText,_),normalize_space(atom(Ps),PText),atomic_list_concat([Parent,Target],' ',Ps),
 wp_git(G,['diff','--quiet',Target,Merge],exit(0),_,_),wp_git(G,['status','--porcelain'],exit(0),"",_),
 wp_effect(G,'g28-r3-merge','promote_candidate',C,'candidate-merged',_{merge:Merge,parent:Parent,target:Target},Receipt).
wp_projection(R,Projection) :- wp_verify(R,G),wp_state_path(G,active,P),
 (exists_file(P)->wp_read(P,Projection);Projection=['no-active-projection']),!.
wp_project(R,Q,Out) :- catch((ground(Q),clause('&derived'('executable-projection-pending',R,Q),true),
 Q=['projection-movement',Id,Desired,Expected,C],ww_id(Id,_),wp_cert(R,G,C),
 wp_state_path(G,'merge-result',MP),wp_read(MP,['promotion-committed',Merge,Parent,Target,_]),wp_head(G,main,Merge),memberchk(Desired,[Parent,Target]),
 atom_concat('projection-',Id,Key),wp_state_path(G,Key,RP),
 (exists_file(RP)->wp_read(RP,['projection-result',Q,Out]);
  atom_concat('prepared-',Key,PK),wp_state_path(G,PK,PP),wp_projection(R,Current),New=['active-projection',Desired,Id],
  (exists_file(PP)->wp_read(PP,['prepared-projection',Q,Previous]);
   (Current=['no-active-projection']->Actual=none;Current=['active-projection',Actual,_]),Actual==Expected,
   Previous=Current,wp_store(PP,['prepared-projection',Q,Previous])),
  (Current==New->Wrote=false;
   Current==Previous,wp_state_path(G,active,AP),tv_encode(New,Enc),tv_durable_json(AP,_{native:New,term:Enc}),Wrote=true),
  (Wrote==true,G.test_interrupt_after_projection_write==true->Out=['projection-incomplete','injected-after-projection-before-receipt'];
   wp_effect(G,Key,'select_active_revision',Q,'projection-selected',_{previous:Previous,current:New},Receipt),
   Out=['projection-selected',New,Receipt],wp_store(RP,['projection-result',Q,Out])))
 ->true;Out=['projection-denied']),E,(term_string(E,S),Out=['projection-incomplete',S])),!.
wp_use(R,Q,Out) :- catch((ground(Q),clause('&derived'('executable-uptake-pending',R,Q),true),wp_verify(R,G),
 Q=['uptake-movement',Id,Test,Active],ww_id(Id,_),ww_id(Test,_),wp_projection(R,Active),Active=['active-projection',Rev,_],
 atom_concat('uptake-',Id,Key),wp_state_path(G,Key,RP),
 (exists_file(RP)->wp_read(RP,['uptake-result',Q,Out]);
  directory_file_path(G.workshop_root,'grant.json',OldP),rv_json(OldP,Old),member(T,Old.tests),atom_string(Test,T.id),
  directory_file_path(G.workshop_root,uptake,UD),make_directory_path(UD),directory_file_path(UD,Id,Tree),ww_no_links(Tree),\+exists_directory(Tree),
  wp_git(G,['worktree','add','--detach',Tree,Rev],exit(0),_,_),
  ww_container(G.workshop_root,_{path:Tree},Old,Test,Status,Details),
  wp_effect(G,Key,'later_use',Q,Status,Details,Receipt),
  miter_store_nonempty_atom(Details.exit,Exit),re_matchsub('^exit[(]([0-9]+)[)]$',Exit,M,[]),number_string(Code,M.1),Details.truncated==false,
  string_codes(Details.stdout,Chars),phrase(utf8_codes(Chars),Bytes),Out=['io-observation',Test,Code,Bytes],
  wp_store(RP,['uptake-result',Q,Out]),wp_state_path(G,Id,Log),wp_store(Log,['uptake-receipt',Receipt]))
 ->true;Out=['uptake-incomplete']),E,(term_string(E,S),Out=['uptake-incomplete',S])),!.
