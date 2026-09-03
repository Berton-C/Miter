% Isolated fault injection; not loaded by the production-shaped native bootstrap.
:- ensure_loaded('/private/tmp/miter-g06-petta-ae66fa8/src/metta.pl').
:- ensure_loaded('../../effect_membranes/miter_development_cycle.pl').
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- http_handler(root('v1/chat/completions'),sc08_slow,[]).
:- initialization(main,main).
sc08_slow(Request) :- http_read_json_dict(Request,_),sleep(1),reply_json_dict(_{choices:[]}).
sc08_pending(R) :- dc_manifest(R,M),file_directory_name(M.bootstrap,B),assertz(working_dir(B)),load_metta_file(M.bootstrap,_),
 dc_path(R,'seed.json',SP),dc_read(SP,Seed),dc_contact(R,M,C,Fp),
 Obs=['cycle-observation',Fp,C.frame,C.receipts,C.surfaces,C.grant,none,none],
 once('CStep'(Seed.native,Obs,['cycle-step',Pending,Effects,Reason])),nth0(3,Pending,pending),
 dc_persist(R,Seed.native,Pending,Obs,Reason,0,genesis,_,_),
 dc_write(R,'synthetic-dispatch.json',_{effects_not_sent:Effects,standing:"Native pending derivation, no actual model request; offline crash/failure fixture"}).
sc08_fake(R,Mode) :- http_server(http_dispatch,[port(Port),workers(1)]),
 format(string(E),'http://127.0.0.1:~d/v1/chat/completions',[Port]),dc_job(R,J),make_directory_path(J),
 vc_write(J,'mechanical-request.json',_{schema:"miter-prepared-model-request-v1",request_id:"offline-cycle-http-probe",alias:"qwen-local",endpoint:E,body:_{model:"not-a-model-mechanical-fixture",messages:[]}}),vc_path(J,'mechanical-request.json',RP),
 (Mode==unavailable->http_stop_server(Port,[]),Deadline=1;Mode==timeout->Deadline=0.05;Deadline=2),
 thread_create(vc_worker(J,RP,Deadline),T,[]),assertz(vc_thread(J,T)),
 dc_log(R,_{kind:fake_http_worker,mode:Mode,actual_model_request:false}),dc_run(R).
main([Root,Mode,silent]) :- miter_store_ensure_extension('/Users/claritymiter/miter/runtime/g07/libmiter_store_posix.dylib'),
 catch((Mode==prepare->sc08_pending(Root);sc08_fake(Root,Mode)),E,
 (term_string(E,S),dc_write(Root,'runtime-fault.json',_{error:S}),print_message(error,E),halt(1))).
