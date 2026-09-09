% Operator-owned, non-cognitive Docker broker for Miter's executable workshop.
%
% The dedicated runtime identity never receives Docker authority.  It can ask
% this loopback service to observe one exact source bundle under one fixed
% image and resource envelope.  The broker reconstructs every Docker argument;
% no request can select a mount, network, image, capability, or Docker verb.

:- ensure_loaded('process.pl').
:- use_module(library(base64)).
:- use_module(library(crypto)).
:- use_module(library(filesex)).
:- use_module(library(http/http_client)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/json)).
:- use_module(library(lists)).
:- use_module(library(pcre)).
:- use_module(library(process)).
:- use_module(library(readutil)).

:- dynamic wb_config/1.
:- dynamic wb_token/1.

:- http_handler(root(health),wb_health,[method(get)]).
:- http_handler(root('v1/observe'),wb_observe,[method(post)]).

wb_main :-
    current_prolog_flag(argv,Argv),
    ( Argv=[Action,'--config',ConfigPath] ->
        wb_action(Action,ConfigPath)
    ; wb_emit(_{schema:"miter-workshop-broker-result-v1",
        status:"usage-error",usage:"workshop_broker <start|serve|status|stop> --config ABSOLUTE_PATH"}),
      halt(64) ).

wb_action(start,ConfigPath) :- !,wb_start(ConfigPath).
wb_action(serve,ConfigPath) :- !,wb_serve(ConfigPath).
wb_action(status,ConfigPath) :- !,wb_status(ConfigPath).
wb_action(stop,ConfigPath) :- !,wb_stop(ConfigPath).
wb_action(_,_) :-
    wb_emit(_{schema:"miter-workshop-broker-result-v1",status:"usage-error"}),
    halt(64).

wb_read_config(Path,Config) :-
    atom(Path),is_absolute_file_name(Path),exists_file(Path),
    setup_call_cleanup(open(Path,read,In,[encoding(utf8)]),
      json_read_dict(In,Config,[value_string_as(string)]),close(In)),
    is_dict(Config),Config.schema=="miter-workshop-broker-config-v1",
    wb_exact_keys(Config,
      [cpus,docker_path,image,log_path,maximum_request_bytes,memory_megabytes,
       network,origin,pid_path,pids_limit,platform,port,root,root_filesystem,
       schema,standing,token_path]),
    Config.origin=="http://127.0.0.1:17891",Config.port=:=17891,
    Config.image=="python:3.11-slim@sha256:a3ab0b966bc4e91546a033e22093cb840908979487a9fc0e6e38295747e49ac0",
    Config.platform=="linux/arm64",Config.network=="none",
    Config.root_filesystem=="read-only",
    Config.memory_megabytes=:=128,Config.cpus=:=0.5,
    Config.pids_limit=:=32,Config.maximum_request_bytes=:=4194304,
    Config.standing=="non-cognitive-exact-workshop-observer",
    maplist(wb_absolute_config_path,
      [Config.root,Config.token_path,Config.pid_path,Config.log_path]),
    string(Config.docker_path),atom_string(Docker,Config.docker_path),
    is_absolute_file_name(Docker),access_file(Docker,execute).

wb_absolute_config_path(String) :-
    string(String),atom_string(Path,String),is_absolute_file_name(Path).

wb_read_token(Config,Token) :-
    atom_string(Path,Config.token_path),
    setup_call_cleanup(open(Path,read,In,[encoding(octet)]),
      read_string(In,4097,Raw),close(In)),
    normalize_space(string(Token),Raw),string_length(Token,Length),
    Length>=32,Length=<4096.

wb_probe(Config) :-
    wb_read_token(Config,Token),string_concat(Config.origin,"/v1/observe",URL),
    Request=_{schema:"miter-workshop-broker-request-v1",action:"probe",
      bearer:Token,request_id:"operator-probe"},
    catch(http_post(URL,json(Request),Reply,
      [json_object(dict),timeout(0.5)]),_,fail),
    Reply.schema=="miter-workshop-broker-observation-v1",
    Reply.standing=="ready",Reply.failure=="none".

wb_start(ConfigPath) :-
    wb_read_config(ConfigPath,Config),
    ( wb_probe(Config) -> Status="already-running"
    ; atom_string(LogPath,Config.log_path),
      file_directory_name(LogPath,LogDirectory),make_directory_path(LogDirectory),
      open(LogPath,append,Log,[encoding(utf8)]),chmod(LogPath,0o600),
      current_prolog_flag(executable,Swipl),
      source_file(wb_main,Source),
      process_create(Swipl,
        ['-q','-f','none','-s',Source,'--','serve','--config',ConfigPath],
        [stdin(null),stdout(stream(Log)),stderr(stream(Log)),detached(true),
         process(_Pid)]),
      close(Log),
      wb_wait_probe(Config,100),Status="started" ),
    wb_emit(_{schema:"miter-workshop-broker-result-v1",status:Status,
      origin:Config.origin}).

wb_wait_probe(Config,Attempts) :-
    Attempts>0,
    ( wb_probe(Config) -> true
    ; sleep(0.05),Next is Attempts-1,wb_wait_probe(Config,Next) ),!.
wb_wait_probe(_,_) :- throw(error(workshop_broker_start_timeout,_)).

wb_serve(ConfigPath) :-
    wb_read_config(ConfigPath,Config),wb_read_token(Config,Token),
    atom_string(Root,Config.root),make_directory_path(Root),chmod(Root,0o700),
    wb_cleanup_request_directories(Root),
    retractall(wb_config(_)),retractall(wb_token(_)),
    assertz(wb_config(Config)),assertz(wb_token(Token)),
    current_prolog_flag(pid,Pid),
    wb_write_json_file(Config.pid_path,
      _{schema:"miter-workshop-broker-pid-v1",pid:Pid,status:"serving"},0o600),
    http_server(http_dispatch,[port('127.0.0.1':Config.port),workers(2),
      timeout(130),keep_alive_timeout(1)]),
    thread_get_message(_).

wb_status(ConfigPath) :-
    wb_read_config(ConfigPath,Config),
    ( wb_probe(Config) -> Status="running",Exit=0 ; Status="stopped",Exit=3 ),
    wb_emit(_{schema:"miter-workshop-broker-result-v1",status:Status,
      origin:Config.origin}),halt(Exit).

wb_stop(ConfigPath) :-
    wb_read_config(ConfigPath,Config),
    ( wb_probe(Config) ->
        wb_read_pid(Config.pid_path,Pid),catch(process_kill(Pid,term),_,true),
        wb_wait_stopped(Config,100),Status="stopped"
    ; Status="already-stopped" ),
    atom_string(PidPath,Config.pid_path),catch(delete_file(PidPath),_,true),
    wb_emit(_{schema:"miter-workshop-broker-result-v1",status:Status,
      origin:Config.origin}).

wb_read_pid(PathString,Pid) :-
    atom_string(Path,PathString),
    setup_call_cleanup(open(Path,read,In,[encoding(utf8)]),
      json_read_dict(In,Document,[value_string_as(string)]),close(In)),
    Document.schema=="miter-workshop-broker-pid-v1",
    Pid=Document.pid,integer(Pid),Pid>1.

wb_wait_stopped(Config,Attempts) :-
    ( \+ wb_probe(Config) -> true
    ; Attempts>0,sleep(0.05),Next is Attempts-1,wb_wait_stopped(Config,Next) ),!.
wb_wait_stopped(_,_) :- throw(error(workshop_broker_stop_timeout,_)).

wb_health(_Request) :-
    reply_json_dict(_{schema:"miter-workshop-broker-health-v1",status:"ready"}).

wb_observe(Request) :-
    catch((http_read_json_dict(Request,Document,[value_string_as(string)]),
      ( wb_observe_document(Document,Reply) -> true
      ; throw(error(broker_request_rejected,_)) )),
      Error,wb_error_reply(Error,Reply)),
    reply_json_dict(Reply).

wb_error_reply(Error,_{schema:"miter-workshop-broker-observation-v1",
    standing:"failed",transport:"failed",exit_code:"unknown",stdout:"",
    stderr:"",failure:Failure}) :-
    wb_error_label(Error,Failure).

wb_error_label(error(broker_request_rejected,_),"request-rejected") :- !.
wb_error_label(_,"request-invalid-or-unavailable").

wb_observe_document(Document,Reply) :-
    is_dict(Document),Document.schema=="miter-workshop-broker-request-v1",
    wb_token(Token),Document.bearer==Token,
    ( Document.action=="container-observe" ->
        with_mutex(miter_workshop_broker,wb_container_request(Document,Reply))
    ; Document.action=="cleanup" ->
        with_mutex(miter_workshop_broker,wb_cleanup_request(Document,Reply))
    ; Document.action=="probe" -> wb_probe_request(Document,Reply)
    ; throw(error(unsupported_broker_action,_)) ).

wb_probe_request(Request,
    _{schema:"miter-workshop-broker-observation-v1",standing:"ready",
      transport:"eof",exit_code:0,stdout:"",stderr:"",failure:"none"}) :-
    wb_exact_keys(Request,[action,bearer,request_id,schema]),
    wb_request_id(Request.request_id,_).

wb_container_request(Request,Reply) :-
    wb_config(Config),
    wb_exact_keys(Request,
      [action,arguments,bearer,deadline_seconds,files,maximum_output_bytes,
       program,request_id,schema]),
    wb_request_id(Request.request_id,RequestId),
    wb_program(Request.program,Program),
    is_list(Request.arguments),length(Request.arguments,ArgumentCount),
    ArgumentCount=<96,maplist(wb_argument,Request.arguments,Arguments),
    integer(Request.deadline_seconds),Request.deadline_seconds>=1,
    Request.deadline_seconds=<120,
    integer(Request.maximum_output_bytes),Request.maximum_output_bytes>=1,
    Request.maximum_output_bytes=<1048576,
    is_list(Request.files),Request.files=[_|_],length(Request.files,FileCount),
    FileCount=<64,
    atom_string(BrokerRoot,Config.root),
    directory_file_path(BrokerRoot,requests,RequestsRoot),
    make_directory_path(RequestsRoot),chmod(RequestsRoot,0o700),
    crypto_data_hash(RequestId,RequestHash,[algorithm(sha256),encoding(utf8)]),
    sub_atom(RequestHash,0,24,_,ShortHash),
    atom_concat('miter-workshop-',ShortHash,Container),
    directory_file_path(RequestsRoot,ShortHash,SourceRoot),
    \+ exists_file(SourceRoot),\+ exists_directory(SourceRoot),
    make_directory(SourceRoot),chmod(SourceRoot,0o700),
    setup_call_cleanup(true,
      ( wb_materialize_files(Request.files,SourceRoot,Config.maximum_request_bytes),
        wb_container_observe(Config,Container,SourceRoot,Program,Arguments,
          Request.deadline_seconds,Request.maximum_output_bytes,Reply) ),
      wb_remove_request(Config,Container,SourceRoot)).

wb_request_id(String,String) :-
    string(String),string_length(String,Length),Length>=1,Length=<256,
    re_match('^[A-Za-z0-9][A-Za-z0-9_.:-]*$',String).

wb_program(String,Atom) :-
    string(String),string_length(String,Length),Length>=2,Length=<512,
    re_match('^/[A-Za-z0-9._/+:-]+$',String),atom_string(Atom,String).

wb_argument(String,Atom) :-
    string(String),string_length(String,Length),Length=<4096,
    \+ sub_string(String,_,1,_,"\u0000"),atom_string(Atom,String).

wb_materialize_files(Files,Root,MaximumBytes) :-
    maplist(wb_file_path,Files,Paths),sort(Paths,Unique),same_length(Paths,Unique),
    maplist(wb_file_size,Files,Sizes),sum_list(Sizes,Total),Total=<MaximumBytes,
    maplist(wb_materialize_file(Root),Files).

wb_file_path(File,Path) :-
    is_dict(File),File.schema=="miter-workshop-source-v1",
    wb_exact_keys(File,[content_base64,executable,path,schema,sha256]),
    wb_relative(File.path,Path),string(File.sha256),
    re_match('^[a-f0-9]{64}$',File.sha256),string(File.content_base64),
    ( File.executable==true ; File.executable==false ).

wb_file_size(File,Size) :-
    string_length(File.content_base64,Encoded),Size is (Encoded*3)//4.

wb_relative(String,Atom) :-
    string(String),string_length(String,Length),Length>=1,Length=<512,
    atom_string(Atom,String),\+ is_absolute_file_name(Atom),
    atomic_list_concat(Parts,'/',Atom),Parts=[_|_],
    forall(member(Part,Parts),
      ( Part\=='',Part\=='.',Part\=='..',
        re_match('^[A-Za-z0-9][A-Za-z0-9._+-]*$',Part) )).

wb_materialize_file(Root,File) :-
    wb_relative(File.path,Relative),
    string_codes(File.content_base64,EncodedCodes),
    phrase(base64(Bytes),EncodedCodes),
    crypto_data_hash(Bytes,Observed,[algorithm(sha256),encoding(octet)]),
    atom_string(Observed,File.sha256),
    directory_file_path(Root,Relative,Path),file_directory_name(Path,Directory),
    make_directory_path(Directory),chmod(Directory,0o700),
    setup_call_cleanup(open(Path,write,Out,[type(binary),encoding(octet)]),
      format(Out,'~s',[Bytes]),close(Out)),
    ( File.executable==true -> chmod(Path,0o700) ; chmod(Path,0o600) ).

wb_container_observe(Config,Container,SourceRoot,Program,Arguments,Deadline,
    Maximum,Reply) :-
    atom_string(Docker,Config.docker_path),atom_string(ProcessRoot,Config.root),
    format(atom(Memory),'~dm',[Config.memory_megabytes]),
    format(atom(Cpus),'~w',[Config.cpus]),
    format(atom(Pids),'~d',[Config.pids_limit]),
    format(atom(Mount),'type=bind,src=~w,dst=/workspace/extension,readonly',
      [SourceRoot]),
    maplist(atom_string,Arguments,ArgumentStrings),
    append([
      ['create','--name',Container,'--platform',Config.platform,
       '--label','io.singularitynet.miter.workshop=true',
       '--network','none','--read-only','--cap-drop','ALL','--security-opt',
       'no-new-privileges','--memory',Memory,'--cpus',Cpus,
       '--pids-limit',Pids,'--tmpfs','/tmp:rw,noexec,nosuid,size=16m',
       '--tmpfs','/workspace/state:rw,noexec,nosuid,size=16m',
       '--mount',Mount,'--workdir','/workspace/extension',
       '--entrypoint',Program,Config.image],ArgumentStrings],CreateArguments),
    miter_process_observe(Docker,CreateArguments,ProcessRoot,Deadline,Maximum,
      CreateTransport,CreateExit,_CreateOut,CreateErr,CreateFailure),
    ( CreateTransport==eof,CreateExit==0 ->
        miter_process_observe(Docker,['start','--attach',Container],ProcessRoot,
          Deadline,Maximum,Transport,ExitCode,Stdout,Stderr,Failure)
    ; Transport=failed,ExitCode=CreateExit,Stdout="",Stderr=CreateErr,
      Failure=CreateFailure ),
    wb_json_atom(Transport,TransportString),wb_json_exit(ExitCode,JsonExit),
    wb_json_atom(Failure,FailureString),
    Reply=_{schema:"miter-workshop-broker-observation-v1",standing:"observed",
      transport:TransportString,exit_code:JsonExit,stdout:Stdout,stderr:Stderr,
      failure:FailureString}.

wb_json_atom(Value,String) :-
    ( atom(Value) -> atom_string(Value,String)
    ; term_string(Value,String,[quoted(true),ignore_ops(true)]) ).
wb_json_exit(Value,Value) :- integer(Value),!.
wb_json_exit(Value,String) :- wb_json_atom(Value,String).

wb_remove_request(Config,Container,SourceRoot) :-
    atom_string(Docker,Config.docker_path),atom_string(ProcessRoot,Config.root),
    catch(miter_process_observe(Docker,['rm','--force',Container],ProcessRoot,
      10,4096,_Transport,_Exit,_Out,_Err,_Failure),_,true),
    catch(delete_directory_and_contents(SourceRoot),_,true).

wb_cleanup_request(Request,Reply) :-
    wb_exact_keys(Request,[action,bearer,request_id,schema]),
    wb_request_id(Request.request_id,_),wb_config(Config),
    atom_string(Docker,Config.docker_path),atom_string(Root,Config.root),
    wb_docker_objects(Docker,Root,containers,Containers),
    wb_docker_objects(Docker,Root,volumes,Volumes),
    maplist(wb_remove_container(Docker,Root),Containers),
    maplist(wb_remove_volume(Docker,Root),Volumes),
    wb_cleanup_request_directories(Root),
    length(Containers,ContainerCount),length(Volumes,VolumeCount),
    Reply=_{schema:"miter-workshop-broker-observation-v1",standing:"clean",
      transport:"eof",exit_code:0,stdout:"",stderr:"",failure:"none",
      removed_containers:ContainerCount,removed_volumes:VolumeCount}.

wb_docker_objects(Docker,Root,containers,Objects) :-
    miter_process_observe(Docker,
      ['ps','-aq','--filter','label=io.singularitynet.miter.workshop=true'],
      Root,10,65536,eof,0,Output,_Error,none),wb_object_lines(Output,Objects).
wb_docker_objects(Docker,Root,volumes,Objects) :-
    miter_process_observe(Docker,
      ['volume','ls','-q','--filter','label=io.singularitynet.miter.workshop=true'],
      Root,10,65536,eof,0,Output,_Error,none),wb_object_lines(Output,Objects).

wb_object_lines(Output,Objects) :-
    normalize_space(string(Normalized),Output),
    ( Normalized=="" -> Objects=[]
    ; split_string(Normalized,"\n"," \t\r\n",Values),
      maplist(wb_object_atom,Values,Objects) ).

wb_object_atom(String,Atom) :-
    string(String),string_length(String,Length),Length>=1,Length=<128,
    re_match('^[A-Za-z0-9][A-Za-z0-9_.:-]*$',String),atom_string(Atom,String).

wb_remove_container(Docker,Root,Object) :-
    miter_process_observe(Docker,['rm','--force',Object],Root,10,4096,
      eof,0,_Output,_Error,none).
wb_remove_volume(Docker,Root,Object) :-
    miter_process_observe(Docker,['volume','rm','--force',Object],Root,10,4096,
      eof,0,_Output,_Error,none).

wb_cleanup_request_directories(Root) :-
    directory_file_path(Root,requests,Requests),
    ( exists_directory(Requests),\+ read_link(Requests,_,_) ->
        delete_directory_and_contents(Requests)
    ; \+ exists_file(Requests) ),
    make_directory_path(Requests),chmod(Requests,0o700).

wb_write_json_file(PathString,Document,Mode) :-
    atom_string(Path,PathString),file_directory_name(Path,Directory),
    make_directory_path(Directory),
    atom_concat(Path,'.tmp',Temporary),
    setup_call_cleanup(open(Temporary,write,Out,[encoding(utf8)]),
      json_write_dict(Out,Document,[width(0)]),close(Out)),
    chmod(Temporary,Mode),rename_file(Temporary,Path).

wb_exact_keys(Dict,Expected) :-
    dict_keys(Dict,Keys),sort(Keys,Sorted),sort(Expected,Sorted).

wb_emit(Document) :-
    json_write_dict(current_output,Document,[width(0)]),nl.

:- initialization(wb_main,main).
