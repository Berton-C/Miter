% Offline laboratory driver. Never imported by the Miter runtime bootstrap.
:- ensure_loaded('../../effect_membranes/miter_voice_development.pl').
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- http_handler(root('v1/chat/completions'),sc06_slow,[]).
sc06_slow(Request) :- http_read_json_dict(Request,_),sleep(1),reply_json_dict(_{choices:[]}).
sc06_state(R,State,ready) :- assertz(vd_result(R,State)).
sc06_http(R,Mode,ready) :-
 http_server(http_dispatch,[port(Port),workers(1)]),
 format(string(E),'http://127.0.0.1:~d/v1/chat/completions',[Port]),
 vd_write(R,'mechanical-request.json',_{schema:"miter-prepared-model-request-v1",request_id:"offline-http-probe",alias:"qwen-local",endpoint:E,body:_{model:"not-a-model-mechanical-fixture",messages:[]}}),
 vd_path(R,'mechanical-request.json',RP),
 (Mode==unavailable->http_stop_server(Port,[]),Deadline=1;Mode==timeout->Deadline=0.05;Deadline=2),
 thread_create(vd_worker(R,RP,Deadline),Thread,[]),assertz(vd_thread(R,Thread)),
 (Mode==cancel->thread_create(sc06_stop(R),_,[detached(true)]);true).
sc06_stop(R) :- sleep(0.05),vd_path(R,'generation-intention.json',P),rv_json(P,D),
 D.native=[_,Id,Scope|_],get_time(T),vd_write(R,'stop-sent.json',_{sent_at:T}),
 vd_write(R,'control.json',_{event:[control,Id,Scope,stop]}).
sc06_parse_probe(R,done) :-
 vd_parse_product(_{choices:[_{finish_reason:"length",message:_{content:"{}"}}]},_,T),
 vd_parse_product(_{choices:[_{finish_reason:"stop",message:_{refusal:"No",content:""}}]},_,Ref),
 vd_parse_product(_{choices:[]},_,M),
 vd_write(R,'parse-results.json',_{truncated:T,refusal:Ref,malformed:M}).
