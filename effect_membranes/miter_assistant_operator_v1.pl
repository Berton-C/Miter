% AMA-1.1 supported local operator.
% This file may create explicit runtime directories, compile pinned mechanics,
% supervise a verified process and carry strict JSON. It does not inspect
% contact meaning, select movement, diagnose the Soul or grant network effects.

:- ensure_loaded('miter_assistant_service_v1.pl').
:- use_module(library(process)).
:- use_module(library(readutil)).
:- use_module(library(uuid)).

:- initialization(miter_assistant_main, main).

miter_assistant_main :-
    current_prolog_flag(argv, Argv),
    catch(as_dispatch(Argv, Reply0, Code0), Error,
      as_cli_error(Error, Reply0, Code0)),
    json_write_dict(current_output, Reply0, [width(0)]), nl,
    halt(Code0).

as_cli_error(Error,
             _{schema:"miter-assistant-operator-result-v1",status:"error",
               error:Message}, 1) :-
    message_to_string(Error, Message).

as_dispatch([Command0|Args], Reply, Code) :-
    miter_store_nonempty_atom(Command0, Command),
    as_command(Command, Args, Reply, Code), !.
as_dispatch(_, _{schema:"miter-assistant-operator-result-v1",status:"usage-error",
  usage:"miter <bootstrap|start|status|submit|stop|panic|evidence-bundle> --runtime-root ABSOLUTE_PATH [--event FILE|--output FILE]"}, 64).

as_command(bootstrap, Args, Reply, Code) :-
    !,
    as_exact_options(Args, ['--runtime-root']),
    as_required_option(Args, '--runtime-root', Root0),
    as_runtime_path(Root0, Root), as_bootstrap(Root, Reply), as_reply_code(Reply, Code).
as_command(start, Args, Reply, Code) :-
    !,
    as_exact_options(Args, ['--runtime-root']),
    as_required_option(Args, '--runtime-root', Root0),
    as_runtime_path(Root0, Root), as_start(Root, Reply), as_reply_code(Reply, Code).
as_command(status, Args, Reply, Code) :-
    !,
    as_exact_options(Args, ['--runtime-root']),
    as_required_option(Args, '--runtime-root', Root0),
    as_runtime_path(Root0, Root), as_status(Root, Reply), as_reply_code(Reply, Code).
as_command(submit, Args, Reply, Code) :-
    !,
    as_exact_options(Args, ['--runtime-root','--event']),
    as_required_option(Args, '--runtime-root', Root0),
    as_required_option(Args, '--event', Event0),
    as_runtime_path(Root0, Root), as_existing_file(Event0, Event),
    as_submit(Root, Event, Reply), as_reply_code(Reply, Code).
as_command(stop, Args, Reply, Code) :-
    !,
    as_exact_options(Args, ['--runtime-root']),
    as_required_option(Args, '--runtime-root', Root0),
    as_runtime_path(Root0, Root), as_stop(Root, Reply), as_reply_code(Reply, Code).
as_command(panic, Args, Reply, Code) :-
    !,
    as_exact_options(Args, ['--runtime-root']),
    as_required_option(Args, '--runtime-root', Root0),
    as_runtime_path(Root0, Root), as_panic(Root, Reply), as_reply_code(Reply, Code).
as_command('evidence-bundle', Args, Reply, Code) :-
    !,
    as_exact_options(Args, ['--runtime-root','--output']),
    as_required_option(Args, '--runtime-root', Root0),
    as_required_option(Args, '--output', Output0),
    as_runtime_path(Root0, Root), as_output_path(Output0, Output),
    as_evidence_bundle(Root, Output, Reply), as_reply_code(Reply, Code).
as_command(Command, _, _, _) :- throw(error(unknown_operator_command(Command),_)).

as_reply_code(Reply, 0) :- get_dict(status, Reply, Status),
    memberchk(Status, [bootstrapped,'already-bootstrapped',started,running,stopped,
      panicked,queued,duplicate,'evidence-stored']), !.
as_reply_code(_, 1).

as_exact_options(Args, Allowed) :-
    as_option_pairs(Args, Pairs), pairs_keys(Pairs, Keys), msort(Keys, Sorted),
    msort(Allowed, Expected), Sorted==Expected.

as_option_pairs([], []).
as_option_pairs([Key0,Value0|Rest], [Key-Value|Pairs]) :-
    miter_store_nonempty_atom(Key0, Key), atom_concat('--',_,Key),
    miter_store_nonempty_atom(Value0, Value),
    as_option_pairs(Rest, Pairs).

as_required_option(Args, Key, Value) :-
    as_option_pairs(Args, Pairs), memberchk(Key-Value, Pairs).

as_runtime_path(Value, Root) :-
    miter_store_nonempty_atom(Value, Raw), is_absolute_file_name(Raw),
    absolute_file_name(Raw, Root,
      [access(none),file_errors(fail),solutions(first),expand(true)]),
    as_operator_repo_root(Repo), as_path_not_within(Repo, Root),
    Root \== '/',
    ( getenv('HOME', Home0) ->
        absolute_file_name(Home0, Home,[access(none),file_errors(fail),solutions(first)]),
        directory_file_path(Home,'.miter',Forbidden), Root \== Forbidden
    ; true ).

as_path_not_within(Parent, Path) :-
    Path \== Parent, atom_concat(Parent,'/',Prefix), \+ atom_concat(Prefix,_,Path).

as_existing_file(Value, Path) :-
    miter_store_nonempty_atom(Value, Raw), is_absolute_file_name(Raw),
    absolute_file_name(Raw, Path,
      [access(read),file_type(regular),file_errors(fail),solutions(first)]),
    \+ read_link(Path,_,_).

as_output_path(Value, Path) :-
    miter_store_nonempty_atom(Value, Raw), is_absolute_file_name(Raw),
    absolute_file_name(Raw, Path,
      [access(none),file_errors(fail),solutions(first),expand(true)]),
    \+ exists_file(Path), file_directory_name(Path, Parent), exists_directory(Parent).

as_operator_repo_root(Repo) :-
    source_file(as_operator_repo_root(_), File), file_directory_name(File, Effects),
    file_directory_name(Effects, Repo).

as_petta_main('/private/tmp/miter-g06-petta-ae66fa8/src/main.pl').
as_petta_pin('ae66fa8e41dcd5539d614706bd4e5cfb34f9608d').

as_runtime_directories([inbox,leased,consumed,rejected,store,checkpoints,
  receipts,outbox,intents,lib,logs]).

as_bootstrap(Root, Reply) :-
    ( exists_directory(Root) ->
        ( as_existing_runtime(Root) ->
            Reply=_{schema:"miter-assistant-operator-result-v1",
              status:'already-bootstrapped',runtime_root:Root}
        ; as_directory_empty(Root), as_bootstrap_new(Root, Reply) )
    ; make_directory_path(Root), chmod(Root,0o700), as_bootstrap_new(Root, Reply) ).

as_existing_runtime(Root) :-
    catch((as_root(Root,_), as_verify_lkg(Root, verified)), _, fail).

as_directory_empty(Path) :-
    directory_files(Path, Entries), exclude(as_dot_entry, Entries, []).
as_dot_entry('.').
as_dot_entry('..').

as_bootstrap_new(Root, Reply) :-
    as_runtime_directories(Directories), maplist(as_make_runtime_directory(Root),Directories),
    as_compile_extension(Root),
    as_operator_repo_root(Repo),
    directory_file_path(Repo,'config/miter-assistant-v1.json',ConfigSource),
    miter_store_read_json(ConfigSource,Config), as_validate_config(Config),
    directory_file_path(Root,'config.json',ConfigTarget),
    miter_store_write_json_atomic(ConfigTarget,Config),
    directory_file_path(Repo,'config/miter-assistant-continuity-v1.json',BindingsSource),
    miter_store_read_json(BindingsSource,Bindings),
    directory_file_path(Root,'scope-bindings.json',BindingsTarget),
    miter_store_write_json_atomic(BindingsTarget,Bindings),
    uuid(BootId),
    directory_file_path(Root,'runtime.json',Marker),
    miter_store_write_json_atomic(Marker,_{schema:"miter-assistant-runtime-v1",
      runtime_id:BootId,external_effects:"none",network_access:"none"}),
    as_root(Root,_),
    as_write_service_entry(Root),
    as_write_lkg(Root,LkgHash),
    as_write_json_durable(Marker,_{schema:"miter-assistant-runtime-v1",
      runtime_id:BootId,lkg_sha256:LkgHash,external_effects:"none",network_access:"none"}),
    as_write_control(Root,continue,'bootstrap'),
    Reply=_{schema:"miter-assistant-operator-result-v1",status:bootstrapped,
      runtime_root:Root,lkg_sha256:LkgHash,network_access:"none",external_effects:"none"}.

as_make_runtime_directory(Root, Relative) :-
    directory_file_path(Root,Relative,Path), make_directory_path(Path), chmod(Path,0o700).

as_validate_config(Config) :-
    is_dict(Config), as_dict_atom(Config,schema,'miter-assistant-config-v1'),
    forall(member(Key,[idle_base_seconds,idle_cap_seconds,max_input_batch,max_input_bytes]),
      (get_dict(Key,Config,Value),as_config_value(Key,Value))),
    Config.idle_base_seconds =< Config.idle_cap_seconds,
    as_dict_atom(Config,external_effects,none),
    as_dict_atom(Config,network_access,none),
    as_dict_atom(Config,runtime_root,'explicit-required').

as_compile_extension(Root) :-
    as_operator_repo_root(Repo),
    directory_file_path(Repo,'effect_membranes/runtime_extensions/miter_store_posix.c',Source),
    directory_file_path(Root,'lib/libmiter_store_posix.dylib',Output),
    directory_file_path(Root,'logs/extension-build.stdout',Stdout),
    directory_file_path(Root,'logs/extension-build.stderr',Stderr),
    setup_call_cleanup(open(Stdout,write,Out,[encoding(utf8)]),
      setup_call_cleanup(open(Stderr,write,Err,[encoding(utf8)]),
        process_create('/opt/homebrew/bin/swipl-ld',['-shared','-O2','-o',Output,Source],
          [cwd(Repo),stdin(null),stdout(stream(Out)),stderr(stream(Err)),process(Pid)]),
        close(Err)),close(Out)),
    process_wait(Pid,Status), Status==exit(0), exists_file(Output), chmod(Output,0o700).

as_write_service_entry(Root) :-
    as_operator_repo_root(Repo),
    directory_file_path(Repo,'src/bootstrap_assistant_v1.metta',Bootstrap),
    directory_file_path(Root,'service-entry.metta',Entry),
    atom_string(Bootstrap,BootstrapString),atom_string(Root,RootString),
    with_output_to(string(BootstrapLiteral),json_write(current_output,BootstrapString)),
    with_output_to(string(RootLiteral),json_write(current_output,RootString)),
    with_output_to(string(Text),
      (format('!(import! &self ~s)~n',[BootstrapLiteral]),
       format('!(AssistantServiceStart ~s)~n',[RootLiteral]))),
    as_write_text_durable(Entry,Text).

as_lkg_relative_paths([
  'CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','BUILD_FIDELITY_PROTOCOL.md',
  'constitution/authority-manifest.json','constitution/soul.metta',
  'constitution/soul_compass_v02.metta','constitution/fact9_projection_v1.metta',
  'src/soul.metta','src/constitutive_participation_v1.metta',
  'src/assistant_reactor_v1.metta','src/assistant_scope_continuity_v1.metta',
  'src/assistant_semantic_participation_v1.metta',
  'src/bootstrap_assistant_v1.metta',
  'effect_membranes/miter_integrity.pl','effect_membranes/miter_store.pl',
  'effect_membranes/miter_assistant_service_v1.pl',
  'effect_membranes/miter_assistant_continuity_v1.pl',
  'effect_membranes/miter_assistant_semantic_v1.pl',
  'effect_membranes/miter_assistant_operator_v1.pl',
  'effect_membranes/runtime_extensions/miter_store_posix.c',
  'config/constitutive-projection-v1.json','config/miter-assistant-v1.json',
  'config/miter-assistant-continuity-v1.json',
  'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/plan.json',
  'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.1/R1/plan.json',
  'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R1/plan.json'
]).

as_write_lkg(Root, LkgHash) :-
    as_operator_repo_root(Repo), as_lkg_relative_paths(Paths),
    maplist(as_file_identity(Repo),Paths,Files),
    as_petta_main(Petta), as_file_identity_absolute(Petta,PettaIdentity),
    as_petta_pin(Pin),
    directory_file_path(Root,'service-entry.metta',Entry),
    as_file_identity_absolute(Entry,EntryIdentity),
    directory_file_path(Root,'lib/libmiter_store_posix.dylib',Extension),
    as_file_identity_absolute(Extension,ExtensionIdentity),
    Lkg=_{schema:"miter-assistant-lkg-v1",petta_pin:Pin,files:Files,
      petta:PettaIdentity,entry:EntryIdentity,extension:ExtensionIdentity},
    directory_file_path(Root,'lkg.json',Path), as_write_json_durable(Path,Lkg),
    crypto_file_hash(Path,LkgHash,[algorithm(sha256),encoding(octet)]).

as_file_identity(Root, Relative, _{path:Relative,sha256:HashString}) :-
    directory_file_path(Root,Relative,Path),
    crypto_file_hash(Path,Hash,[algorithm(sha256),encoding(octet)]), atom_string(Hash,HashString).
as_file_identity_absolute(Path, _{path:Path,sha256:HashString}) :-
    crypto_file_hash(Path,Hash,[algorithm(sha256),encoding(octet)]), atom_string(Hash,HashString).

as_verify_lkg(Root, Standing) :-
    ( catch((as_root(Root,_),directory_file_path(Root,'lkg.json',Path),
      miter_store_read_json(Path,Lkg),as_dict_atom(Lkg,schema,'miter-assistant-lkg-v1'),
      as_operator_repo_root(Repo),as_lkg_relative_paths(ExpectedPaths),
      get_dict(files,Lkg,Files),maplist(as_verify_relative_identity(Repo),Files,SeenPaths),
      SeenPaths==ExpectedPaths,
      get_dict(petta,Lkg,Petta),as_verify_absolute_identity(Petta,_),
      get_dict(entry,Lkg,Entry),as_verify_absolute_identity(Entry,_),
      get_dict(extension,Lkg,Extension),as_verify_absolute_identity(Extension,_),
      as_petta_pin(Pin),as_dict_atom(Lkg,petta_pin,Pin)),_,fail)
    -> Standing=verified ; Standing=mismatch ), !.

as_verify_relative_identity(Root, Dict, Relative) :-
    is_dict(Dict),get_dict(path,Dict,Relative0),miter_store_nonempty_atom(Relative0,Relative),
    directory_file_path(Root,Relative,Path),
    as_verify_hash(Dict,Path).
as_verify_absolute_identity(Dict, Path) :-
    is_dict(Dict),get_dict(path,Dict,Path0),miter_store_nonempty_atom(Path0,Path),
    is_absolute_file_name(Path),as_verify_hash(Dict,Path).
as_verify_hash(Dict, Path) :-
    get_dict(sha256,Dict,Expected0),miter_store_nonempty_atom(Expected0,Expected),
    as_sha256(Expected,Expected),crypto_file_hash(Path,Actual,[algorithm(sha256),encoding(octet)]),
    Actual==Expected.

as_start(Root, Reply) :-
    as_root(Root,_), as_verify_lkg(Root,Lkg),
    ( Lkg \== verified ->
        Reply=_{schema:"miter-assistant-operator-result-v1",status:'lkg-mismatch'}
    ; as_process_state(Root,alive,Pid) ->
        Reply=_{schema:"miter-assistant-operator-result-v1",status:running,pid:Pid,
          semantic_health:"not-claimed"}
    ; as_crash_admit(Root,CrashStanding),
      ( CrashStanding == blocked ->
          Reply=_{schema:"miter-assistant-operator-result-v1",
            status:'crash-loop-contained',semantic_health:"not-claimed"}
      ; as_write_control(Root,continue,start), as_spawn(Root,Pid,StartedAt),
        ( as_wait_started(Root,Pid,StartedAt,5) ->
            Reply=_{schema:"miter-assistant-operator-result-v1",status:started,pid:Pid,
              semantic_health:"not-claimed"}
        ; Reply=_{schema:"miter-assistant-operator-result-v1",status:'start-failed',pid:Pid} ) ) ).

as_crash_admit(Root, Standing) :-
    ( as_process_state(Root,dead,PriorPid), \+ as_clean_exit(Root,PriorPid)
    -> as_note_crash(Root,PriorPid,Count), (Count>=3->Standing=blocked;Standing=allowed)
    ; Standing=allowed ).

as_clean_exit(Root, Pid) :-
    directory_file_path(Root,'last-exit.json',Path),exists_file(Path),
    catch(miter_store_read_json(Path,Dict),_,fail),
    as_dict_atom(Dict,schema,'miter-assistant-exit-v1'),get_dict(pid,Dict,Pid),
    as_dict_atom(Dict,kind,Kind),memberchk(Kind,['clean-stop',panic]).
as_clean_exit(Root, Pid) :-
    as_pid_started(Root,Pid,Started),
    directory_file_path(Root,'heartbeat.json',Path),exists_file(Path),
    catch(miter_store_read_json(Path,Dict),_,fail),
    as_dict_atom(Dict,schema,'miter-assistant-heartbeat-v1'),
    as_dict_atom(Dict,state,State),memberchk(State,['assistant-stopped','assistant-panicked']),
    get_dict(observed_at_epoch,Dict,Observed),number(Observed),Observed>=Started.

as_pid_started(Root,Pid,Started) :-
    directory_file_path(Root,'pid.json',Path),exists_file(Path),
    miter_store_read_json(Path,Dict),get_dict(pid,Dict,Pid),
    get_dict(started_at_epoch,Dict,Started),number(Started).

as_note_crash(Root, Pid, Count) :-
    get_time(Now),as_read_crashes(Root,Entries0),
    include(as_recent_crash(Now),Entries0,Recent0),
    (member(Entry,Recent0),get_dict(pid,Entry,Pid)->Recent=Recent0
    ;append(Recent0,[_{pid:Pid,observed_at_epoch:Now}],Recent)),
    length(Recent,Count),directory_file_path(Root,'crash-history.json',Path),
    as_write_json_durable(Path,_{schema:"miter-assistant-crash-history-v1",
      window_seconds:60,max_crashes:3,crashes:Recent}).

as_read_crashes(Root, Entries) :-
    directory_file_path(Root,'crash-history.json',Path),
    ( exists_file(Path),catch(miter_store_read_json(Path,Dict),_,fail),
      as_dict_atom(Dict,schema,'miter-assistant-crash-history-v1'),
      get_dict(crashes,Dict,Entries0),is_list(Entries0)
    -> Entries=Entries0 ; Entries=[] ).

as_recent_crash(Now, Entry) :-
    is_dict(Entry),get_dict(observed_at_epoch,Entry,Observed),number(Observed),
    Observed=<Now,Now-Observed=<60,get_dict(pid,Entry,Pid),integer(Pid),Pid>1.

as_spawn(Root, Pid, StartedAt) :-
    as_operator_repo_root(Repo),as_petta_main(Petta),
    directory_file_path(Root,'service-entry.metta',Entry),uuid(RunId),
    atomic_list_concat(['logs/service-',RunId,'.stdout'],StdoutRelative),
    atomic_list_concat(['logs/service-',RunId,'.stderr'],StderrRelative),
    directory_file_path(Root,StdoutRelative,Stdout),directory_file_path(Root,StderrRelative,Stderr),
    setup_call_cleanup(open(Stdout,write,Out,[encoding(utf8)]),
      setup_call_cleanup(open(Stderr,write,Err,[encoding(utf8)]),
        process_create('/opt/homebrew/bin/swipl',
          ['--stack_limit=2g','-q','-s',Petta,'--',Entry,silent],
          [cwd(Repo),stdin(null),stdout(stream(Out)),stderr(stream(Err)),detached(true),process(Pid)]),
        close(Err)),close(Out)),
    get_time(StartedAt),directory_file_path(Root,'pid.json',PidPath),
    as_write_json_durable(PidPath,_{schema:"miter-assistant-pid-v1",pid:Pid,
      run_id:RunId,started_at_epoch:StartedAt,stdout:StdoutRelative,stderr:StderrRelative}).

as_wait_started(Root, Pid, StartedAt, Seconds) :-
    End is StartedAt+Seconds,as_wait_started_until(Root,Pid,StartedAt,End).
as_wait_started_until(Root,Pid,StartedAt,End) :-
    as_pid_alive(Pid),
    ( directory_file_path(Root,'heartbeat.json',Heartbeat),exists_file(Heartbeat),
      miter_store_read_json(Heartbeat,Dict),as_dict_atom(Dict,schema,'miter-assistant-heartbeat-v1'),
      get_dict(observed_at_epoch,Dict,Observed),number(Observed),Observed>=StartedAt
    -> true
    ; get_time(Now),Now<End,sleep(0.05),as_wait_started_until(Root,Pid,StartedAt,End) ).

as_process_state(Root, State, Pid) :-
    directory_file_path(Root,'pid.json',Path),exists_file(Path),
    miter_store_read_json(Path,Dict),as_dict_atom(Dict,schema,'miter-assistant-pid-v1'),
    get_dict(pid,Dict,Pid),integer(Pid),Pid>1,
    (as_pid_alive(Pid)->State=alive;State=dead).

as_pid_alive(Pid) :-
    process_create('/bin/kill',['-0',Pid],[stdin(null),stdout(null),stderr(null),process(Check)]),
    process_wait(Check,exit(0)).

as_status(Root, Reply) :-
    ( catch(as_root(Root,_),_,fail) ->
        as_verify_lkg(Root,Lkg),
        (as_process_state(Root,alive,Pid)->State=running
        ;(as_process_state(Root,dead,Pid)->State=stopped;Pid=0,State=stopped)),
        as_status_heartbeat(Root,Heartbeat),
        Reply=_{schema:"miter-assistant-operator-result-v1",status:State,pid:Pid,
          lkg:Lkg,heartbeat:Heartbeat,semantic_health:"not-claimed"}
    ; Reply=_{schema:"miter-assistant-operator-result-v1",status:'not-bootstrapped'} ).

as_status_heartbeat(Root, Heartbeat) :-
    directory_file_path(Root,'heartbeat.json',Path),
    (exists_file(Path)->miter_store_read_json(Path,Heartbeat);Heartbeat=null).

as_submit(Root, Event, Reply) :-
    ( catch((as_root(Root,_),as_verify_lkg(Root,verified),
        size_file(Event,Size),as_config(Root,max_input_bytes,Max),Size=<Max,
        miter_store_read_json(Event,Dict),as_input_dict(Root,Dict,_,InputId)),_,fail)
    -> atom_concat(InputId,'.json',Name),
       ( as_existing_input(Root,Name,Existing) ->
           miter_store_read_json(Existing,Prior),
           (Prior=Dict -> Status=duplicate ; throw(error(input_id_content_conflict(InputId),_)))
       ; directory_file_path(Root,inbox,Inbox),directory_file_path(Inbox,Name,Target),
         as_write_json_durable(Target,Dict),as_receipt(Root,InputId,queued,Name),Status=queued ),
       Reply=_{schema:"miter-assistant-operator-result-v1",status:Status,input_id:InputId}
    ; Reply=_{schema:"miter-assistant-operator-result-v1",status:rejected,
        reason:"strict-input-schema-runtime-or-size-boundary"} ).

as_existing_input(Root, Name, Path) :-
    member(Directory,[inbox,leased,consumed,rejected]),
    directory_file_path(Root,Directory,Dir),directory_file_path(Dir,Name,Path),exists_file(Path),!.

as_stop(Root, Reply) :-
    as_root(Root,_),as_verify_lkg(Root,verified),
    ( as_process_state(Root,alive,Pid) ->
        as_write_control(Root,stop,operator),
        (as_wait_dead(Pid,5)->Status=stopped,as_write_exit(Root,Pid,'clean-stop')
        ;Status='stop-timeout')
    ; Pid=0,Status=stopped ),
    Reply=_{schema:"miter-assistant-operator-result-v1",status:Status,pid:Pid}.

as_panic(Root, Reply) :-
    as_root(Root,_),
    ( as_process_state(Root,alive,Pid) ->
        as_write_control(Root,panic,operator),
        ( as_wait_dead(Pid,2) -> true
        ; as_signal(Pid,'-TERM'),(as_wait_dead(Pid,1)->true;as_signal(Pid,'-KILL'),as_wait_dead(Pid,1)) )
    ; Pid=0 ),
    as_write_exit(Root,Pid,panic),
    Reply=_{schema:"miter-assistant-operator-result-v1",status:panicked,pid:Pid,
      history_deleted:false}.

as_wait_dead(Pid, Seconds) :-
    get_time(Start),End is Start+Seconds,as_wait_dead_until(Pid,End).
as_wait_dead_until(Pid, _) :- \+ as_pid_alive(Pid),!.
as_wait_dead_until(Pid, End) :- get_time(Now),Now<End,sleep(0.05),as_wait_dead_until(Pid,End).

as_signal(Pid, Signal) :-
    process_create('/bin/kill',[Signal,Pid],[stdin(null),stdout(null),stderr(null),process(Check)]),
    process_wait(Check,_).

as_write_exit(Root, Pid, Kind) :-
    get_time(Now),directory_file_path(Root,'last-exit.json',Path),
    as_write_json_durable(Path,_{schema:"miter-assistant-exit-v1",pid:Pid,
      kind:Kind,observed_at_epoch:Now}).

as_write_control(Root, Command, Source) :-
    uuid(Uuid),atomic_list_concat([command,Uuid],'-',Id),
    get_time(Now),directory_file_path(Root,'control.json',Path),
    as_write_json_durable(Path,_{schema:"miter-assistant-control-v1",command:Command,
      command_id:Id,source:Source,observed_at_epoch:Now}).

as_evidence_bundle(Root, Output, Reply) :-
    as_root(Root,_),as_verify_lkg(Root,Lkg),as_status(Root,Status),
    as_directory_count(Root,receipts,ReceiptCount),as_directory_count(Root,consumed,ConsumedCount),
    as_directory_count(Root,rejected,RejectedCount),as_directory_count(Root,outbox,OutboxCount),
    as_optional_hash(Root,'checkpoints/active.term',CheckpointHash),
    as_trajectory_standing(Root,Trajectory),
    directory_file_path(Root,'lkg.json',LkgPath),
    crypto_file_hash(LkgPath,LkgHash,[algorithm(sha256),encoding(octet)]),
    get_time(Now),Bundle=_{schema:"miter-assistant-evidence-bundle-v1",
      recorded_at_epoch:Now,lkg:Lkg,lkg_sha256:LkgHash,status:Status,
      counts:_{receipts:ReceiptCount,consumed:ConsumedCount,rejected:RejectedCount,
        outbox:OutboxCount},checkpoint_sha256:CheckpointHash,trajectory:Trajectory,
      network_access:"none",external_effects:"none",private_content_included:false,
      semantic_health_claimed:false},
    as_write_json_durable(Output,Bundle),
    Reply=_{schema:"miter-assistant-operator-result-v1",status:'evidence-stored',output:Output}.

as_directory_count(Root, Relative, Count) :-
    directory_file_path(Root,Relative,Path),directory_files(Path,Entries),
    exclude(as_dot_entry,Entries,Items),length(Items,Count).

as_optional_hash(Root, Relative, HashString) :-
    directory_file_path(Root,Relative,Path),
    (exists_file(Path)->crypto_file_hash(Path,Hash,[algorithm(sha256),encoding(octet)]),
      atom_string(Hash,HashString);HashString=null).

as_trajectory_standing(Root, Standing) :-
    directory_file_path(Root,store,Store),
    catch((miter_store_load_ledger(Store,Lines),miter_store_analyze(Store,Lines,Analysis,_),
      Standing=Analysis),_,Standing=_{status:"unavailable"}).

as_write_text_durable(Path, Text) :-
    file_directory_name(Path,Directory),make_directory_path(Directory),
    current_prolog_flag(pid,Pid),format(atom(Suffix),'.tmp.~d',[Pid]),atom_concat(Path,Suffix,Temporary),
    setup_call_cleanup(true,
      (setup_call_cleanup(open(Temporary,write,Stream,[encoding(utf8)]),
        (chmod(Temporary,0o600),format(Stream,'~s',[Text]),flush_output(Stream),
         miter_store_fsync_stream(Stream)),close(Stream)),rename_file(Temporary,Path)),
      (exists_file(Temporary)->delete_file(Temporary);true)).
