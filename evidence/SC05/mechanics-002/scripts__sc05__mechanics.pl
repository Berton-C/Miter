% Isolated real HTTP/worker probes, not tests of Soul meaning.
:- ensure_loaded('../../effect_membranes/miter_relational_voice.pl').
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- http_handler(root('v1/chat/completions'),slow_reply,[]).
:- initialization(main,main).
slow_reply(Request) :- http_read_json_dict(Request,_),sleep(0.3),reply_json_dict(_{choices:[]}).
must(Goal) :- (call(Goal)->true;throw(error(failed_assertion,Goal))).
path(R,F,P) :- directory_file_path(R,F,P).
raw(R,Name,D,P) :- path(R,Name,P),miter_store_write_json_atomic(P,D).
product(Content,Finish,_{choices:[_{finish_reason:Finish,message:_{content:Content}}]}).
test_parse(R) :-
 product("{\"request_id\":\"voice\",\"clauses\":[\"You requested revision of ledger.\"]}","stop",D),
 raw(R,'valid.json',D,P),rv_parse(R,voice,[scope,cut,p,project,surface],P,A),must(A=[rendered,voice,_,_,_]),
 product("{}","length",T),raw(R,'truncated.json',T,TP),rv_parse(R,voice,[],TP,TO),must(TO=='model-truncated'),
 raw(R,'refusal.json',_{choices:[_{finish_reason:"stop",message:_{refusal:"Unavailable",content:""}}]},RP),rv_parse(R,voice,[],RP,RO),must(RO=='model-refusal'),
 product("{\"request_id\":\"wrong\",\"clauses\":[\"x\"]}","stop",M),raw(R,'wrong-id.json',M,MP),rv_parse(R,voice,[],MP,MO),must(MO=='malformed-model-output'),
 product("{broken","stop",B),raw(R,'malformed.json',B,BP),rv_parse(R,voice,[],BP,BO),must(BO=='malformed-model-output'),
 product("{\"request_id\":\"voice\",\"clauses\":[]}","stop",Empty),raw(R,'empty.json',Empty,EP),rv_parse(R,voice,[],EP,EO),must(EO=='malformed-model-output'),
 rv_write(R,'parse-results.json',_{valid:A,truncated:TO,refusal:RO,wrong_id:MO,malformed:BO,empty:EO}).
request(R,Port,P) :- format(string(E),'http://127.0.0.1:~d/v1/chat/completions',[Port]),
 raw(R,'request.json',_{schema:"miter-prepared-model-request-v1",request_id:"probe",alias:"qwen-local",endpoint:E,body:_{model:"mechanical-fake-endpoint",messages:[]}},P).
subdir(R,N,S) :- path(R,N,S),make_directory(S).
main([R]) :- catch(run(R),E,(print_message(error,E),halt(1))).
run(R) :- test_parse(R),http_server(http_dispatch,[port(Port),workers(1)]),
 subdir(R,timeout,T),request(T,Port,TP),rv_worker_body(T,probe,[],TP,0.05),rv_poll(T,TO),must(TO=='model-timeout'),
 http_stop_server(Port,[]),subdir(R,unavailable,U),request(U,Port,UP),rv_worker_body(U,probe,[],UP,1),rv_poll(U,UO),must(UO=='provider-unavailable'),
 subdir(R,integrity,I),raw(I,'manifest.json',_{files:[]},_),must(\+rv_verified(I)),
 rv_save_intention(I,['voice-intention',voice,[],a,[],[],incomplete],IO),must(IO=='intention-storage-or-integrity-failed'),
 rv_write(R,'verdict.json',_{status:"PASS-BOUNDED",checks:10,timeout:TO,unavailable:UO,integrity:IO,qualification:"Real local HTTP timeout/disconnection and schema mechanics; fake endpoint is not model semantics."}),
 writeln('SC05 mechanics PASS (10 checks)').
