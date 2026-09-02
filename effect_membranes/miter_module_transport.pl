% Fixed localhost worker and JSON serialization. Meaning is supplied in the
% native generation intention. Candidate content never becomes executable code.
:- ensure_loaded('miter_modules.pl').
:- ensure_loaded('miter_process.pl').
miter_module_generate(Root,Id,Alias,Result) :-
 catch((miter_module_source(Root,'module-source-verified'),
  miter_module_path(Root,Id,'intention.json',IP),miter_store_read_json(IP,I),
  miter_store_read_json('config/module-schema.json',Schema),
  miter_store_canonical_json(I,Prompt),
  T=_{schema:"miter-schema-request-v1",request_id:Id,
    endpoint:"http://127.0.0.1:1234/v1/chat/completions",
    body:_{messages:[_{role:"system",content:"Produce a declarative JSON candidate for the supplied native Miter intention. Your output is untrusted data, not approval or executable code."},
                     _{role:"user",content:Prompt}],
      response_format:_{type:"json_schema",json_schema:_{name:"miter_module",strict:true,schema:Schema}},
      temperature:0,top_p:1,reasoning_effort:"none",max_tokens:2048,seed:2100,stream:false,ttl:300}},
  miter_module_path(Root,Id,'template.json',TP),miter_module_path(Root,Id,'request.json',RP),
  miter_module_path(Root,Id,'raw.json',Raw),miter_module_path(Root,Id,'timing.json',Time),
  miter_module_path(Root,Id,'worker.json',WP),\+exists_file(Raw),\+exists_file(RP),
  miter_store_write_json_atomic(TP,T),
  miter_lm_prepare_request('config/local/g03-model-profiles.json',Alias,TP,RP,'model-request-prepared'),
  miter_voice_hash(RP,RequestHash),miter_module_record(Root,Id,'model-request',
     _{request_hash:RequestHash,role:"declarative-module-generation",model_alias:Alias},'module-event-stored'),
  process_create('/opt/homebrew/bin/swipl',
    ['-q','-s','/Users/claritymiter/miter/effect_membranes/miter_voice_worker.pl','--',RP,Raw,Time,WP],
    [stdin(null),stdout(null),stderr(null),process(P)]),
  miter_process_wait_deadline(P,120,Exit),Exit==exit(0),
  miter_store_read_json(WP,W),W.result=="raw-model-response-stored",
  miter_store_read_json(Raw,Response),miter_lm_provider_product(Response,Candidate),
  miter_module_path(Root,Id,'candidate.json',CP),\+exists_file(CP),miter_store_write_json_atomic(CP,Candidate),
  miter_voice_hash(CP,CH),miter_voice_hash(Raw,RH),
  miter_module_record(Root,Id,'module-candidate',_{candidate_hash:CH,raw_response_hash:RH,standing:"untrusted-model-data"},'module-event-stored')
  ->Result='module-candidate-generated';Result='module-generation-failed'),_,Result='module-generation-failed'),!.
