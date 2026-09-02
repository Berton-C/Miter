% Bounded local provider transport and structural parsing only.
:- ensure_loaded('miter_voice.pl').
:- ensure_loaded('miter_process.pl').
miter_voice_render(Root,Id,N,Alias,Result) :-
 get_time(Start),
 catch((miter_voice_render_checked(Root,Id,N,Alias)->Outcome='voice-candidate-ready';
        Outcome='voice-render-error'),Error,(miter_voice_error_code(Error,Outcome))),
 get_time(End),Ms is round((End-Start)*1000),
 catch((miter_voice_attempt_path(Root,Id,N,'transport-status.json',Path),
        miter_store_write_json_atomic(Path,_{status:Outcome,duration_ms:Ms,timeout_seconds:120})),_,true),
 Result=Outcome,!.
miter_voice_error_code(voice_stage_error(Stage,Code),Code) :- atom(Stage),atom(Code),!.
miter_voice_error_code(time_limit_exceeded,'voice-timeout') :- !.
miter_voice_error_code(_,'voice-render-error').
miter_voice_render_checked(Root,Id,N,Alias) :-
 miter_voice_path(Root,Id,'intention.json',IP),miter_store_read_json(IP,I),
 (N=:=0 -> Role="voice rendering",Previous=none
 ; Prior is N-1,miter_voice_attempt_path(Root,Id,Prior,'audit.json',AP),
   miter_store_read_json(AP,Previous),Role="voice repair"),
 Prompt=_{bounded_role:Role,intention:I,previous_defects:Previous,
 instruction:"Return exactly three clauses: one from each required group, copied verbatim from rendering_options. Choose the variants and ordering that best fit this contact. No additions, no task verdict, no authority claim. Repair every named defect."},
 with_output_to(string(User),json_write_dict(current_output,Prompt,[width(0)])),
 atom_string(Id,IdS),
 Schema=_{type:"object",properties:_{request_id:_{type:"string",const:IdS},
 clauses:_{type:"array",minItems:3,maxItems:3,items:_{type:"string",minLength:1,maxLength:400}}},
 required:["request_id","clauses"],additionalProperties:false},
 T=_{schema:"miter-schema-request-v1",request_id:IdS,
 endpoint:"http://127.0.0.1:1234/v1/chat/completions",
 body:_{messages:[_{role:"system",content:"You render a native Miter intention. You do not decide its meaning or permission. Return only the supplied JSON schema."},
                  _{role:"user",content:User}],
 response_format:_{type:"json_schema",json_schema:_{name:"miter_voice_candidate",strict:true,schema:Schema}},
 temperature:0,top_p:1,reasoning_effort:"none",max_tokens:1024,seed:1600,stream:false,ttl:300}},
 miter_voice_attempt_path(Root,Id,N,'template.json',TP),
 miter_voice_attempt_path(Root,Id,N,'request.json',RP),
 miter_voice_attempt_path(Root,Id,N,'raw.json',Raw),
 miter_voice_attempt_path(Root,Id,N,'timing.json',Time),
 miter_store_write_json_atomic(TP,T),
 miter_lm_prepare_request('config/local/g03-model-profiles.json',Alias,TP,RP,Ready),
 (Ready=='model-request-prepared'->true;throw(voice_stage_error(prepare,Ready))),
 miter_voice_attempt_path(Root,Id,N,'worker.json',Observation),
 process_create('/opt/homebrew/bin/swipl',
   ['-q','-s','/Users/claritymiter/miter/effect_membranes/miter_voice_worker.pl',
    '--',RP,Raw,Time,Observation],
   [stdin(null),stdout(null),stderr(null),process(Pid)]),
 miter_process_wait_deadline(Pid,120,Exit),
 (Exit==deadline_exceeded -> throw(voice_stage_error(execute,'voice-timeout'));true),
 miter_store_read_json(Observation,Observed),miter_store_nonempty_atom(Observed.result,Executed),
 (Executed=='raw-model-response-stored'->true;throw(voice_stage_error(execute,Executed))),
 miter_store_read_json(Raw,Response),
 (catch(miter_lm_provider_product(Response,P),_,fail),
  miter_voice_structural(P,IdS)
  -> Clauses=P.clauses,Status="valid"
  ; Clauses=[],Status="invalid"),
 atomics_to_string(Clauses,"\n\n",Text),
 C=_{request_id:IdS,clauses:Clauses,text:Text,schema_status:Status,
      origin:"local-model-rendering",raw_ref:Raw},
 miter_voice_attempt_path(Root,Id,N,'candidate.json',CP),
 \+exists_file(CP),miter_store_write_json_atomic(CP,C).
miter_voice_structural(P,Id) :-
 is_dict(P),dict_pairs(P,_,Pairs),pairs_keys(Pairs,[clauses,request_id]),
 P.request_id==Id,is_list(P.clauses),length(P.clauses,L),L>=1,L=<8,
 forall(member(C,P.clauses),(string(C),string_length(C,N),N>0,N=<700)).
