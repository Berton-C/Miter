% Voice file/event mechanics. All intention, audit and certificate decisions
% belong to native MeTTa. This module never treats a model verdict as authority.
:- ensure_loaded('miter_llm.pl').
:- ensure_loaded('miter_store.pl').
:- use_module(library(pcre)).
:- use_module(library(time)).
miter_voice_id(Id0,Id) :- miter_store_nonempty_atom(Id0,Id),
 re_match('^[a-z][a-z0-9-]{0,63}$',Id).
miter_voice_path(Root,Id0,File,Path) :-
 miter_voice_id(Id0,Id),directory_file_path(Root,Id,Dir),
 directory_file_path(Dir,File,Path).
miter_voice_input_path(Root,Id0,Path) :-
 miter_voice_id(Id0,Id),directory_file_path(Root,inputs,Dir),
 atom_concat(Id,'.json',File),directory_file_path(Dir,File,Path).
miter_voice_attempt_path(Root,Id,N,Suffix,Path) :-
 integer(N),N>=0,format(atom(File),'attempt-~d.~w',[N,Suffix]),
 miter_voice_path(Root,Id,File,Path).
miter_voice_read_input(Root,Id,Q) :-
 miter_voice_input_path(Root,Id,Path),miter_store_read_json(Path,Q).
miter_voice_input(Root,Id,Key,Value) :-
 catch((miter_voice_read_input(Root,Id,Q),get_dict(Key,Q,V),
        miter_store_nonempty_atom(V,A)->Value=A;Value='missing-voice-input'),
       _,Value='missing-voice-input'),!.
miter_voice_source(Root,Id,Result) :-
 catch((miter_voice_read_input(Root,Id,Q),
        directory_file_path(Root,store,Store),
        miter_store_load_ledger(Store,Lines),miter_store_analyze(Store,Lines,A,Events),
        A.status==valid,member(E,Events),E.event_id==Q.source_event_id,
        E.provenance_kind=="direct-contact",E.source_principal=="principal:g16-human",
        E.audience_scope=="scope:g16-private",E.project_scope=="g16-voice",
        miter_store_payload_path(Store,E.payload_hash,P),
        miter_store_read_json(P,Payload),Payload.text==Q.text,Payload.kind==Q.kind
        ->Result='voice-source-verified';Result='voice-source-invalid'),
       _,Result='voice-source-invalid'),!.
miter_voice_pairs([Name,Value],Name-Value) :- atom(Name),ground(Value).
miter_voice_write_intention(Root,Id,Product,Result) :-
 catch((Product=['communicative-intention'|Fields],
        maplist(miter_voice_pairs,Fields,Pairs),dict_create(D,intention,Pairs),
        miter_voice_id(Id,I),D.intention_id==I,
        miter_voice_path(Root,Id,'intention.json',Path),\+exists_file(Path),
        miter_store_write_json_atomic(Path,D)
        ->Result='voice-intention-stored';Result='voice-intention-error'),
       _,Result='voice-intention-error'),!.
miter_voice_candidate(Root,Id,N,C) :-
 miter_voice_attempt_path(Root,Id,N,'candidate.json',P),miter_store_read_json(P,C).
miter_voice_schema(Root,Id,N,Result) :-
 catch((miter_voice_candidate(Root,Id,N,C),C.schema_status=="valid"
       ->Result='voice-schema-valid';Result='voice-schema-invalid'),
       _,Result='voice-schema-invalid'),!.
miter_voice_clause_count(Root,Id,N,Result) :-
 catch((miter_voice_candidate(Root,Id,N,C),is_list(C.clauses),
        length(C.clauses,Count)->Result=Count;Result= -1),_,Result= -1),!.
miter_voice_clause(Root,Id,N,I,Result) :-
 catch((miter_voice_candidate(Root,Id,N,C),nth0(I,C.clauses,Text),string(Text)
        ->Result=Text;Result="missing-clause"),_,Result="missing-clause"),!.
miter_voice_contains(Root,Id,N,Pattern,Result) :-
 catch((miter_voice_candidate(Root,Id,N,C),string_lower(C.text,Lower),
        string_lower(Pattern,Needle),sub_string(Lower,_,_,_,Needle)
        ->Result=true;Result=false),_,Result=false),!.
miter_voice_length(Root,Id,N,Result) :-
 catch((miter_voice_candidate(Root,Id,N,C),string_length(C.text,Length)
        ->Result=Length;Result= -1),_,Result= -1),!.
miter_voice_append(Root,Id,N,Kind,Provenance,Payload,EventId) :-
 format(string(EventId),'g16-~w-~w-~d',[Kind,Id,N]),
 directory_file_path(Root,store,Store),
 get_time(Now),stamp_date_time(Now,Date,'UTC'),format_time(string(Time),'%FT%TZ',Date),
 miter_voice_read_input(Root,Id,Q),
 Intent=_{schema:"miter-event-intent-v1",event_id:EventId,event_kind:Kind,
 occurred_at:Time,recorded_at:Time,source_surface:"native-VoiceRNA",
 source_principal:"miter:voice",audience_scope:"scope:g16-private",
 project_scope:"g16-voice",provenance_kind:Provenance,
 parent_event_ids:[Q.source_event_id],correlation_id:Id,payload:Payload},
 format(atom(Suffix),'~w-intent.json',[Kind]),
 miter_voice_attempt_path(Root,Id,N,Suffix,Path),
 miter_store_write_json_atomic(Path,Intent),
 miter_store_append_event(Store,'runtime/g07/libmiter_store_posix.dylib',Path,R),
 R=='event-appended'.
miter_voice_vad_request(Root,Id,N,Result) :-
 catch((miter_voice_candidate(Root,Id,N,C),
        miter_voice_append(Root,Id,N,'rendering-contact',"rendering",
          _{text:C.text,origin:C.origin,raw_ref:C.raw_ref},Event),
        format(string(Cue),'~w-attempt-~d',[Id,N]),
        directory_file_path(Root,store,Store),
        Q=_{cue_id:Cue,source_event_id:Event,text:C.text,store_root:Store},
        miter_voice_attempt_path(Root,Id,N,'vad-input.json',Path),
        miter_store_write_json_atomic(Path,Q)
        ->Result='voice-vad-request-ready';Result='voice-vad-request-error'),
       _,Result='voice-vad-request-error'),!.
miter_voice_stage_path(Root,Id,N,Suffix,Result) :-
 catch((miter_voice_attempt_path(Root,Id,N,Suffix,Path)->Result=Path;
        Result='invalid-voice-path'),_,Result='invalid-voice-path'),!.
miter_voice_cue_id(Id,N,Result) :-
 catch((miter_voice_id(Id,I),integer(N),N>=0,
        format(atom(R),'~w-attempt-~d',[I,N])->Result=R;Result=invalid),
       _,Result=invalid),!.
miter_voice_vad_high(Root,Id,N,Result) :-
 catch((miter_voice_attempt_path(Root,Id,N,'vad.json',P),miter_store_read_json(P,D),
        member("high",D.dominance_profile)->Result=true;Result=false),_,Result=false),!.
miter_voice_vad_ready(Root,Id,N,Result) :-
 catch((miter_voice_attempt_path(Root,Id,N,'vad.json',P),miter_store_read_json(P,D),
        D.label=="affective-language-cue",D.permission_effect=="none",
        D.source_provenance=="rendering"
        ->Result='voice-vad-ready';Result='voice-vad-missing'),
       _,Result='voice-vad-missing'),!.
miter_voice_hash(Path,Hash) :- crypto_file_hash(Path,A,[algorithm(sha256),encoding(octet)]),atom_string(A,Hash).
miter_voice_audit_write(Root,Id,N,Product,Result) :-
 catch((Product=['voice-audit'|Fields],maplist(miter_voice_pairs,Fields,Pairs),dict_create(A,audit,Pairs),
        miter_voice_path(Root,Id,'intention.json',IP),miter_voice_hash(IP,IH),
        miter_voice_attempt_path(Root,Id,N,'candidate.json',CP),miter_voice_hash(CP,CH),
        miter_voice_attempt_path(Root,Id,N,'vad.json',VP),miter_voice_hash(VP,VH),
        D=A.put(_{intention_hash:IH,candidate_hash:CH,vad_hash:VH,attempt:N}),
        miter_voice_attempt_path(Root,Id,N,'audit.json',AP),\+exists_file(AP),
        miter_store_write_json_atomic(AP,D),
        miter_voice_append(Root,Id,N,'voice-audit',"native-audit",D,_)
        ->Result='voice-audit-stored';Result='voice-audit-error'),_,Result='voice-audit-error'),!.
miter_voice_audit_status(Root,Id,N,Result) :-
 catch((miter_voice_attempt_path(Root,Id,N,'audit.json',AP),miter_store_read_json(AP,A),
        miter_voice_path(Root,Id,'intention.json',IP),miter_voice_hash(IP,A.intention_hash),
        miter_voice_attempt_path(Root,Id,N,'candidate.json',CP),miter_voice_hash(CP,A.candidate_hash),
        miter_voice_attempt_path(Root,Id,N,'vad.json',VP),miter_voice_hash(VP,A.vad_hash),
        miter_store_nonempty_atom(A.status,S)->Result=S;Result='voice-audit-stale'),
       _,Result='voice-audit-stale'),!.
miter_voice_budget(Path,Result) :-
 catch((miter_store_read_json(Path,D),D.schema=="miter-voice-budget-v1",
        integer(D.max_attempts),D.max_attempts>=1,D.max_attempts=<4
        ->Result=D.max_attempts;Result= -1),_,Result= -1),!.
miter_voice_withhold(Root,Id,Attempts,Budget,Reason,Result) :-
 catch((integer(Attempts),Attempts>=0,integer(Budget),atom(Reason),
        D=_{status:"withheld",reason:Reason,attempts:Attempts,attempt_budget:Budget,
            emission:false,fallback_text:null},
        miter_voice_path(Root,Id,'outcome.json',P),\+exists_file(P),
        miter_store_write_json_atomic(P,D),
        miter_voice_append(Root,Id,Attempts,'voice-termination',"native-control",D,_)
        ->Result='voice-withheld';Result='voice-withhold-storage-error'),
       _,Result='voice-withhold-storage-error'),!.
