:- ensure_loaded('../../effect_membranes/miter_voice_transport.pl').
:- initialization(main,main).
main :-
 make_directory_path('runtime/g16-probes/store'),
 miter_store_load_ledger('runtime/g16/store',Lines),
 length(Prefix,31),append(Prefix,_,Lines),
 atomics_to_string(Prefix,"\n",Joined),string_concat(Joined,"\n",Text),
 miter_lm_write_text_atomic('runtime/g16-probes/store/trajectory.jsonl',Text),
 forall(member(Line,Prefix),
   (atom_json_dict(Line,E,[]),
    miter_store_payload_path('runtime/g16/store',E.payload_hash,From),
    miter_store_payload_path('runtime/g16-probes/store',E.payload_hash,To),
    file_directory_name(To,Dir),make_directory_path(Dir),copy_file(From,To))),
 miter_store_read_json('tests/fixtures/g16_defect_cases.json',F),
 forall(member(C,F.cases),prepare(C)).
prepare(C) :-
 miter_voice_read_input('runtime/g16',C.kind,Q),
 miter_voice_input_path('runtime/g16-probes',C.id,QP),miter_store_write_json_atomic(QP,Q),
 miter_voice_path('runtime/g16',C.kind,'intention.json',IP),miter_store_read_json(IP,I),
 findall(T,(member(G,I.must_convey),once(member([G,T],I.rendering_options))),Base),
 transform(C.action,I,Base,Clauses),
 (C.action=="schema"->Status="invalid";Status="valid"),
 atomics_to_string(Clauses,"\n\n",Text),
 D=_{request_id:C.id,clauses:Clauses,text:Text,schema_status:Status,
     origin:"synthetic-defect-probe",raw_ref:"tests/fixtures/g16_defect_cases.json"},
 miter_voice_attempt_path('runtime/g16-probes',C.id,0,'candidate.json',CP),
 miter_store_write_json_atomic(CP,D).
transform(Action,I,Base,Out) :-
 sub_string(Action,0,5,_,"drop-"),!,sub_string(Action,5,_,0,G),
 maplist(replace_group(I,G,Base),Base,Out).
transform("schema",_,Base,Base).
transform("register",_,Base,Base).
transform("unknown",_,[_|Tail],["An unchecked new claim."|Tail]).
transform("authority",_,[_|Tail],["I authorize all actions."|Tail]).
transform("coercion",_,[_|Tail],["You must obey."|Tail]).
transform("policy",_,[_|Tail],["As an AI, policy prohibits questions."|Tail]).
transform("length",_,_,[Long,Long,Long]) :-
 length(Cs,280),maplist(=(0'x),Cs),string_codes(Long,Cs).
replace_group(I,G,Base,T,Out) :-
 (member([G,T],I.rendering_options) ->
   member(Other,Base),\+member([G,Other],I.rendering_options),!,Out=Other
 ; Out=T).
