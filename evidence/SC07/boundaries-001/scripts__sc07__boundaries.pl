% Isolated offline mechanical probes, never part of the runtime bootstrap.
:- ensure_loaded('../../effect_membranes/miter_voice_construction.pl').
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- http_handler(root('v1/chat/completions'),sc07_slow,[]).
sc07_slow(Request) :- http_read_json_dict(Request,_),sleep(1),reply_json_dict(_{choices:[]}).
sc07_state(R,State,ready) :- assertz(vc_result(R,State)).
sc07_legacy_absent(true) :- \+current_predicate('DApplyRules'/4),\+current_predicate('DTrialPlan'/3),\+current_predicate('DGeneration'/3),!.
sc07_legacy_absent(false).
sc07_http(R,Mode,ready) :- http_server(http_dispatch,[port(Port),workers(1)]),
 format(string(E),'http://127.0.0.1:~d/v1/chat/completions',[Port]),
 vc_write(R,'mechanical-request.json',_{schema:"miter-prepared-model-request-v1",request_id:"offline-http-probe",alias:"qwen-local",endpoint:E,body:_{model:"not-a-model-mechanical-fixture",messages:[]}}),
 vc_path(R,'mechanical-request.json',RP),
 (Mode==unavailable->http_stop_server(Port,[]),Deadline=1;Mode==timeout->Deadline=0.05;Deadline=2),
 thread_create(vc_worker(R,RP,Deadline),Thread,[]),assertz(vc_thread(R,Thread)),
 (Mode==cancel->thread_create(sc07_stop(R),_,[detached(true)]);true).
sc07_stop(R) :- sleep(0.05),vc_path(R,'generation-intention.json',P),rv_json(P,D),D.native=[_,Id,Scope|_],
 get_time(T),vc_write(R,'stop-sent.json',_{sent_at:T}),vc_write(R,'control.json',_{event:[control,Id,Scope,stop]}).
sc07_parse_probe(R,done) :-
 vc_parse_product(_{choices:[_{finish_reason:"length",message:_{content:"{}"}}]},_,T),
 vc_parse_product(_{choices:[_{finish_reason:"stop",message:_{refusal:"No",content:""}}]},_,Ref),
 vc_parse_product(_{choices:[]},_,M),vc_write(R,'parse-results.json',_{truncated:T,refusal:Ref,malformed:M}).
