% Hash-bound local test surface. No network, credentials or model decisions.
:- ensure_loaded('miter_voice.pl').
miter_voice_store_root(Root,Store) :- directory_file_path(Root,store,Store).
miter_voice_witness_id(Id,Kind,Ref) :-
 miter_voice_id(Id,I),miter_voice_id(Kind,K),atomic_list_concat([I,K],'-witness-',Ref).
miter_voice_issue(Root,Id,N,Standing,Result) :-
 catch((Standing=='certified-utterance',miter_voice_audit_status(Root,Id,N,'audit-pass'),
        miter_voice_attempt_path(Root,Id,N,'movement.json',MP),miter_store_read_json(MP,M),
        M.status=="certified",atom_string(Id,M.certificate.movement_id),
        miter_voice_path(Root,Id,'intention.json',IP),miter_store_read_json(IP,I),
        I.source_event_id==M.certificate.source_cut,
        miter_voice_candidate(Root,Id,N,C),
        miter_voice_attempt_path(Root,Id,N,'candidate.json',CP),miter_voice_hash(CP,CH),
        miter_voice_attempt_path(Root,Id,N,'audit.json',AP),miter_voice_hash(AP,AH),
        miter_voice_hash(IP,IH),miter_voice_hash(MP,MH),
        crypto_data_hash(C.text,TH,[algorithm(sha256),encoding(utf8)]),
        format(string(Effect),'g16-~w-~d',[Id,N]),
        Certificate=_{schema:"CertifiedUtterance",standing:Standing,effect_id:Effect,
          intention_id:Id,intention_hash:IH,candidate_hash:CH,audit_hash:AH,
          movement_hash:MH,text_hash:TH,text:C.text,surface:"local-test-cli"},
        miter_voice_attempt_path(Root,Id,N,'certificate.json',Path),\+exists_file(Path),
        miter_store_write_json_atomic(Path,Certificate),
        miter_voice_append(Root,Id,N,'voice-certification',"native-certification",Certificate,_)
        ->Result='certified-utterance-stored';Result='voice-certificate-error'),
       _,Result='voice-certificate-error'),!.
miter_voice_emit(Root,Id,N,Result) :-
 catch((miter_voice_emission_checked(Root,Id,N,Status)->Result=Status;Result='voice-emission-blocked'),
       _,Result='voice-emission-blocked'),!.
miter_voice_emission_checked(Root,Id,N,Status) :-
 miter_voice_audit_status(Root,Id,N,'audit-pass'),
 miter_voice_attempt_path(Root,Id,N,'certificate.json',P),miter_store_read_json(P,C),
 C.schema=="CertifiedUtterance",C.standing=="certified-utterance",C.surface=="local-test-cli",
 miter_voice_path(Root,Id,'intention.json',IP),miter_voice_hash(IP,C.intention_hash),
 miter_voice_attempt_path(Root,Id,N,'candidate.json',CP),miter_voice_hash(CP,C.candidate_hash),
 miter_voice_attempt_path(Root,Id,N,'audit.json',AP),miter_voice_hash(AP,C.audit_hash),
 miter_voice_attempt_path(Root,Id,N,'movement.json',MP),miter_voice_hash(MP,C.movement_hash),
 miter_store_read_json(MP,M),M.status=="certified",
 crypto_data_hash(C.text,TH,[algorithm(sha256),encoding(utf8)]),atom_string(TH,C.text_hash),
 directory_file_path(Root,surface,Dir),make_directory_path(Dir),
 atom_string(Effect,C.effect_id),atom_concat(Effect,'.txt',File),directory_file_path(Dir,File,Out),
 (exists_file(Out) ->
   miter_voice_hash(Out,C.text_hash),Status='voice-already-emitted'
 ; miter_lm_write_text_atomic(Out,C.text),miter_voice_hash(Out,C.text_hash),
   miter_voice_append(Root,Id,N,'voice-emission',"action-result",
     _{effect_id:C.effect_id,surface:C.surface,text_hash:C.text_hash,observed_file:Out},_),
   Status='voice-emitted').
