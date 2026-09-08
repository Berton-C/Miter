% Shared non-cognitive operator mechanics. This file has no standalone entry.
% It may create explicit runtime directories, compile pinned mechanics,
% supervise a verified process and carry strict JSON. It does not inspect
% contact meaning, select movement, diagnose the Soul or grant network effects.

:- ensure_loaded('assistant_service.pl').
:- ensure_loaded('model.pl').
:- use_module(library(process)).
:- use_module(library(readutil)).
:- use_module(library(uuid)).

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
  usage:"miter <install|bootstrap|prepare-service|register-service|unregister-service|evaluation-disclosure|activate-evaluation|start|status|submit|stop|panic|evidence-bundle> --runtime-root ABSOLUTE_PATH [--haley-affirmation-post-id ID|--event FILE|--output FILE]"}, 64).

as_command(install, Args, Reply, Code) :-
    !,
    as_exact_options(Args, ['--runtime-root']),
    as_required_option(Args, '--runtime-root', Root0),
    as_runtime_path(Root0, Root), as_install(Root, Reply), as_reply_code(Reply, Code).

as_command(bootstrap, Args, Reply, Code) :-
    !,
    as_exact_options(Args, ['--runtime-root']),
    as_required_option(Args, '--runtime-root', Root0),
    as_runtime_path(Root0, Root), as_bootstrap(Root, Reply), as_reply_code(Reply, Code).
as_command('evaluation-disclosure', Args, Reply, Code) :-
    !,
    as_exact_options(Args, ['--runtime-root']),
    as_required_option(Args, '--runtime-root', Root0),
    as_runtime_path(Root0, Root),as_evaluation_disclosure(Root,Reply),
    as_reply_code(Reply,Code).
as_command('activate-evaluation', Args, Reply, Code) :-
    !,
    as_exact_options(Args,
      ['--runtime-root','--haley-affirmation-post-id']),
    as_required_option(Args,'--runtime-root',Root0),
    as_required_option(Args,'--haley-affirmation-post-id',PostId0),
    as_runtime_path(Root0,Root),
    as_activate_evaluation(Root,PostId0,Reply),as_reply_code(Reply,Code).
as_command('prepare-service', Args, Reply, Code) :-
    !,
    as_exact_options(Args,['--runtime-root']),
    as_required_option(Args,'--runtime-root',Root0),
    as_runtime_path(Root0,Root),as_prepare_host_service(Root,Reply),
    as_reply_code(Reply,Code).
as_command('register-service', Args, Reply, Code) :-
    !,
    as_exact_options(Args,['--runtime-root']),
    as_required_option(Args,'--runtime-root',Root0),
    as_runtime_path(Root0,Root),as_register_host_service(Root,Reply),
    as_reply_code(Reply,Code).
as_command('unregister-service', Args, Reply, Code) :-
    !,
    as_exact_options(Args,['--runtime-root']),
    as_required_option(Args,'--runtime-root',Root0),
    as_runtime_path(Root0,Root),as_unregister_host_service(Root,Reply),
    as_reply_code(Reply,Code).
as_command('run-supervised', Args, Reply, Code) :-
    !,
    as_exact_options(Args,['--runtime-root']),
    as_required_option(Args,'--runtime-root',Root0),
    as_runtime_path(Root0,Root),as_supervised_run(Root,Reply),
    as_reply_code(Reply,Code).
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
    memberchk(Status, [installed,'already-installed',bootstrapped,'already-bootstrapped',started,starting,running,stopped,
      panicked,'stop-pending','panic-pending','processing-unconfirmed',
      'liveness-unconfirmed','existing-process-unconfirmed',queued,duplicate,
      'evidence-stored','evaluation-disclosure','evaluation-activated',
      'evaluation-already-active','service-profile-ready','service-registered',
      'service-unregistered','supervised-clean-exit','crash-loop-contained']), !.
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

as_petta_main(Path) :-
    ( getenv('MITER_PETTA_MAIN', Raw) -> true
    ; throw(error(missing_environment_variable('MITER_PETTA_MAIN'), _))
    ),
    absolute_file_name(Raw, Path,
      [access(read),file_type(regular),file_errors(fail),solutions(first),expand(true)]).
as_petta_pin('ae66fa8e41dcd5539d614706bd4e5cfb34f9608d').

as_swipl_ld(Path) :-
    ( getenv('MITER_SWIPL_LD', Raw) ->
        absolute_file_name(Raw, Path,
          [access(execute),file_errors(fail),solutions(first),expand(true)])
    ; absolute_file_name(path('swipl-ld'), Path,
        [access(execute),file_errors(fail),solutions(first)])
    ).

as_runtime_directories([inbox,leased,consumed,rejected,store,checkpoints,
  receipts,outbox,proofs,intents,lib,logs,model,surface,continuity,semantic,lkg,
  service,
  'model/claims','model/requests','model/raw','model/observations','surface/raw',
  'surface/events','surface/effects','checkpoints/objects','continuity/native',
  'continuity/native/manifests','continuity/native/scopes','semantic/queries',
  'semantic/projections','lkg/source']).

as_lkg_source_relative('lkg/source').

as_lkg_source_root(Root, SourceRoot) :-
    as_lkg_source_relative(Relative),directory_file_path(Root,Relative,SourceRoot).

as_bootstrap(Root, Reply) :-
    ( exists_directory(Root) ->
        ( as_existing_runtime(Root) ->
            Reply=_{schema:"miter-assistant-operator-result-v1",
              status:'already-bootstrapped',runtime_root:Root}
        ; as_directory_empty(Root), as_bootstrap_new(Root, Reply) )
    ; make_directory_path(Root), chmod(Root,0o700), as_bootstrap_new(Root, Reply) ).

as_install(Root, Reply) :-
    as_bootstrap(Root,Bootstrap),
    ( Bootstrap.status==bootstrapped -> put_dict(status,Bootstrap,installed,Reply)
    ; Bootstrap.status=='already-bootstrapped' ->
        put_dict(status,Bootstrap,'already-installed',Reply)
    ; Reply=Bootstrap ).

as_existing_runtime(Root) :-
    catch((as_root(Root,_), as_verify_lkg(Root, verified)), _, fail).

as_directory_empty(Path) :-
    directory_files(Path, Entries), exclude(as_dot_entry, Entries, []).
as_dot_entry('.').
as_dot_entry('..').

as_bootstrap_new(Root, Reply) :-
    chmod(Root,0o700),
    as_runtime_directories(Directories), maplist(as_make_runtime_directory(Root),Directories),
    as_compile_extension(Root),
    as_operator_repo_root(Repo),
    directory_file_path(Repo,'config/miter.json',ConfigSource),
    miter_store_read_json(ConfigSource,HumanConfig),
    as_human_config_sections(HumanConfig,Config,Mattermost,Memory,Models,Grants,
      EvaluationGrants),
    directory_file_path(Root,'config.json',ConfigTarget),
    miter_store_write_json_atomic(ConfigTarget,Config),
    directory_file_path(Repo,'config/continuity.json',BindingsSource),
    miter_store_read_json(BindingsSource,Bindings),
    directory_file_path(Root,'scope-bindings.json',BindingsTarget),
    miter_store_write_json_atomic(BindingsTarget,Bindings),
    directory_file_path(Root,'model-resources.json',ModelsTarget),
    miter_store_write_json_atomic(ModelsTarget,Models),
    directory_file_path(Root,'model-grants.json',GrantsTarget),
    miter_store_write_json_atomic(GrantsTarget,Grants),
    directory_file_path(Root,'evaluation-grants.json',EvaluationGrantsTarget),
    miter_store_write_json_atomic(EvaluationGrantsTarget,EvaluationGrants),
    directory_file_path(Root,'semantic-memory.json',MemoryTarget),
    miter_store_write_json_atomic(MemoryTarget,Memory),
    directory_file_path(Root,'mattermost.json',MattermostTarget),
    miter_store_write_json_atomic(MattermostTarget,Mattermost),
    as_dict_atom(Config,network_access,NetworkAccess),
    as_dict_atom(Config,external_effects,ExternalEffects),
    uuid(BootId),
    directory_file_path(Root,'runtime.json',Marker),
    miter_store_write_json_atomic(Marker,_{schema:"miter-assistant-runtime-v1",
      runtime_id:BootId,external_effects:ExternalEffects,
      network_access:NetworkAccess}),
    as_root(Root,_),
    as_snapshot_lkg_source(Root),
    as_write_service_entry(Root),
    as_write_lkg(Root,LkgHash),
    as_write_json_durable(Marker,_{schema:"miter-assistant-runtime-v1",
      runtime_id:BootId,lkg_sha256:LkgHash,external_effects:ExternalEffects,
      network_access:NetworkAccess}),
    as_write_control(Root,continue,'bootstrap'),
    as_secure_runtime_tree(Root),
    Reply=_{schema:"miter-assistant-operator-result-v1",status:bootstrapped,
      runtime_root:Root,lkg_sha256:LkgHash,network_access:NetworkAccess,
      external_effects:ExternalEffects}.

as_make_runtime_directory(Root, Relative) :-
    directory_file_path(Root,Relative,Path), make_directory_path(Path), chmod(Path,0o700).

as_secure_runtime_tree(Root) :-
    chmod(Root,0o700),as_secure_runtime_directory(Root).

as_secure_runtime_directory(Directory) :-
    directory_files(Directory,Entries),
    forall((member(Name,Entries),Name\=='.',Name\=='..'),
      (directory_file_path(Directory,Name,Path),\+ read_link(Path,_,_),
       ( exists_directory(Path) ->
           chmod(Path,0o700),as_secure_runtime_directory(Path)
       ; exists_file(Path) ->
           ( sub_atom(Path,_,_,0,'libmiter_store_posix.dylib') ->
               chmod(Path,0o700)
           ; chmod(Path,0o600) )
       ; fail ))).

% The service executes from an immutable runtime-local copy of the verified
% source closure. Repository edits therefore cannot silently change a running
% or restarted organism. This is a mechanical last-known-good carrier, not a
% second cognitive runtime and not authority to choose an upgrade.
as_snapshot_lkg_source(Root) :-
    as_operator_repo_root(Repo),as_lkg_source_root(Root,SourceRoot),
    as_lkg_relative_paths(Paths),
    maplist(as_copy_lkg_source_file(Repo,SourceRoot),Paths).

as_copy_lkg_source_file(Repo, SourceRoot, Relative) :-
    as_safe_lkg_relative_path(Relative),
    directory_file_path(Repo,Relative,Source),exists_file(Source),
    \+ read_link(Source,_,_),
    directory_file_path(SourceRoot,Relative,Target),
    file_directory_name(Target,Parent),make_directory_path(Parent),
    \+ exists_file(Target),copy_file(Source,Target),chmod(Target,0o600).

as_safe_lkg_relative_path(Relative) :-
    miter_store_nonempty_atom(Relative,Path),\+ is_absolute_file_name(Path),
    \+ sub_atom(Path,_,_,_,'..'),\+ sub_atom(Path,_,_,_,'\\'),
    re_match('^[A-Za-z0-9_.:/-]+$',Path).

as_validate_config(Config) :-
    is_dict(Config), as_dict_atom(Config,schema,'miter-assistant-config-v1'),
    forall(member(Key,[idle_base_seconds,idle_cap_seconds,max_input_batch,max_input_bytes]),
      (get_dict(Key,Config,Value),as_config_value(Key,Value))),
    Config.idle_base_seconds =< Config.idle_cap_seconds,
    as_dict_atom(Config,external_effects,none),
    as_dict_atom(Config,network_access,'explicit-model-grant-only'),
    as_dict_atom(Config,runtime_root,'explicit-required').

% Humans edit one repository surface. Installation validates and materializes
% narrow private runtime views so individual membranes need no authority over
% the repository configuration or unrelated settings.
as_human_config_sections(Human, Runtime, Mattermost, Memory, Models, Grants,
    EvaluationGrants) :-
    is_dict(Human),
    as_mattermost_exact_keys(Human,
      [external_effects,human_editable,idle_base_seconds,idle_cap_seconds,
       initial_evaluation_grants,initial_model_grants,mattermost,max_input_batch,
       max_input_bytes,memory,models,network_access,operator_notes,runtime_root,
       schema]),
    as_dict_atom(Human,schema,'miter-assistant-config-v1'),
    Human.human_editable==true,
    is_list(Human.operator_notes),maplist(string,Human.operator_notes),
    Runtime=_{schema:Human.schema,idle_base_seconds:Human.idle_base_seconds,
      idle_cap_seconds:Human.idle_cap_seconds,max_input_batch:Human.max_input_batch,
      max_input_bytes:Human.max_input_bytes,external_effects:Human.external_effects,
      network_access:Human.network_access,runtime_root:Human.runtime_root},
    as_validate_config(Runtime),
    Mattermost=Human.mattermost,is_dict(Mattermost),
    as_dict_atom(Mattermost,schema,'miter-mattermost-surface-v1'),
    Memory=Human.memory,is_dict(Memory),
    as_dict_atom(Memory,schema,'miter-semantic-memory-config-v1'),
    Models=Human.models,is_dict(Models),
    as_dict_atom(Models,schema,'miter-model-resource-registry-v1'),
    Grants=Human.initial_model_grants,is_dict(Grants),
    as_dict_atom(Grants,schema,'miter-model-grants-v1'),
    EvaluationGrants=Human.initial_evaluation_grants,
    as_evaluation_grants_inactive_valid(EvaluationGrants),
    as_mattermost_secret_free(Human).

as_evaluation_grants_inactive_valid(Document) :-
    is_dict(Document),
    as_mattermost_exact_keys(Document,
      [authority,authority_separation,bounds,grants,haley_disclosure,
       required_affirmations,schema,standing]),
    as_dict_atom(Document,schema,'miter-evaluation-grants-v1'),
    as_dict_atom(Document,standing,'inactive-awaiting-participant-disclosure'),
    as_dict_atom(Document,authority,'AMA-1.2-ratified-by-berton'),
    get_dict(grants,Document,[]),
    Document.bounds=_{first_segment_hours:72,maximum_hours:168,
      admitted_events:1000,outbound_posts:500,outbound_per_hour:60,
      remote_calls:50},
    Document.required_affirmations=_{
      berton_c:"affirmed-by-ratification",
      haley:"required-before-payload-cognition-memory-model-or-egress"},
    is_dict(Document.haley_disclosure),
    as_mattermost_exact_keys(Document.haley_disclosure,
      [exact_text,required_author,required_surface]),
    string(Document.haley_disclosure.exact_text),
    string_length(Document.haley_disclosure.exact_text,DisclosureLength),
    DisclosureLength>=200,DisclosureLength=<1200,
    Document.haley_disclosure.required_author=="haley",
    Document.haley_disclosure.required_surface==
      "exact-berton-haley-miter-group",
    as_dict_atom(Document,authority_separation,
      'grant-bounds-reach-not-meaning-or-movement').

as_evaluation_disclosure(Root,Reply) :-
    as_root(Root,_),directory_file_path(Root,'evaluation-grants.json',Path),
    miter_store_read_json(Path,Document),is_dict(Document),
    get_dict(haley_disclosure,Document,Disclosure),is_dict(Disclosure),
    get_dict(exact_text,Disclosure,Text),string(Text),
    Reply=_{schema:"miter-assistant-operator-result-v1",
      status:'evaluation-disclosure',required_author:"haley",
      exact_text:Text,
      next:"Have Haley post this exact text in the bound three-person Mattermost group, then activate using that post ID."}.

as_activate_evaluation(Root,PostId0,Reply) :-
    ( catch(as_activate_evaluation_checked(Root,PostId0,Reply0),_,fail) ->
        Reply=Reply0
    ; Reply=_{schema:"miter-assistant-operator-result-v1",
        status:'evaluation-activation-held',
        reason:"exact-affirmation-or-complete-preflight-not-established"} ), !.

as_activate_evaluation_checked(Root,PostId0,Reply) :-
    as_root(Root,_),as_verify_lkg(Root,verified),
    as_mattermost_id(PostId0,PostId),
    ( as_evaluation_already_active(Root,PostId,Grant) ->
        Reply=_{schema:"miter-assistant-operator-result-v1",
          status:'evaluation-already-active',grant_id:Grant.id,
          segment_expires_at_epoch:Grant.segment_expires_at_epoch}
    ; as_evaluation_activation_preflight(Root,PostId,Inactive,Config,Binding,
        Affirmation,BindingHash),
      as_write_evaluation_activation(Root,Inactive,Config,Binding,Affirmation,
        BindingHash,Reply) ).

as_evaluation_already_active(Root,PostId,Grant) :-
    directory_file_path(Root,'evaluation-grants.json',Path),
    miter_store_read_json(Path,Document),is_dict(Document),
    Document.schema=="miter-evaluation-grants-v1",
    Document.standing=="active-explicit-grants",
    get_dict(grants,Document,[Grant]),
    as_mattermost_id(Grant.disclosure_witness.post_id,PostId).

as_evaluation_activation_preflight(Root,PostId,Inactive,Config,Binding,
    Affirmation,BindingHash) :-
    \+ (as_process_state(Root,State,_),State\==dead),
    directory_file_path(Root,'evaluation-grants.json',GrantPath),
    miter_store_read_json(GrantPath,Inactive),
    as_evaluation_grants_inactive_valid(Inactive),
    as_mattermost_config(Root,Config),Config.enabled==true,
    as_mattermost_resolve_live(Root,Config,Binding),
    as_mattermost_binding_sha256(Root,BindingHash),
    as_evaluation_affirmation(Config,Binding,Inactive,PostId,Affirmation),
    as_evaluation_private_modes(Root),
    as_evaluation_no_unresolved_effect(Root),
    as_evaluation_memory_health(Root),
    as_evaluation_model_health(Root),
    as_write_control(Root,continue,'evaluation-activation-preflight'),
    as_evaluation_control_allows(Root).

as_evaluation_affirmation(Config,Binding,Inactive,PostId,Affirmation) :-
    as_mattermost_token(Config,Token),
    format(atom(Path),'/api/v4/posts/~w',[PostId]),
    as_mattermost_get(Config,Token,Path,Post,200),is_dict(Post),
    as_mattermost_id(Post.id,PostId),
    as_mattermost_id(Post.channel_id,ChannelId),
    as_mattermost_id(Binding.channel_id,ChannelId),
    as_mattermost_id(Post.user_id,UserId),
    member(Principal,Binding.principals),Principal.username=="haley",
    as_mattermost_id(Principal.id,UserId),
    Post.message==Inactive.haley_disclosure.exact_text,
    as_mattermost_post_version(Post,Version),
    crypto_data_hash(Post.message,Hash,[algorithm(sha256),encoding(utf8)]),
    atom_string(HashString,Hash),
    Affirmation=_{post_id:Post.id,event_version:Version,
      author_username:"haley",content_sha256:HashString,
      standing:"exact-current-disclosure-affirmed"}.

as_evaluation_private_modes(Root) :-
    as_evaluation_private_mode(Root,700),
    as_evaluation_private_directory(Root).

as_evaluation_private_directory(Directory) :-
    directory_files(Directory,Entries),
    forall((member(Name,Entries),Name\=='.',Name\=='..'),
      (directory_file_path(Directory,Name,Path),\+ read_link(Path,_,_),
       ( exists_directory(Path) ->
           as_evaluation_private_mode(Path,700),
           as_evaluation_private_directory(Path)
       ; exists_file(Path) ->
           ( sub_atom(Path,_,_,0,'libmiter_store_posix.dylib') ->
               as_evaluation_private_mode(Path,700)
           ; as_evaluation_private_mode(Path,600) )
       ; fail ))).

as_evaluation_private_mode(Path,Expected) :-
    setup_call_cleanup(
      process_create('/usr/bin/stat',['-f','%Lp',Path],
        [stdin(null),stdout(pipe(Stream)),stderr(null),process(Pid)]),
      read_string(Stream,64,Raw),close(Stream)),
    process_wait(Pid,exit(0)),normalize_space(string(Text),Raw),
    number_string(Expected,Text).

as_evaluation_no_unresolved_effect(Root) :-
    directory_file_path(Root,'surface/effects',Directory),
    directory_files(Directory,Names),
    \+ (member(Name,Names),as_mattermost_json_name(Name),
      directory_file_path(Directory,Name,Path),
      catch(miter_store_read_json(Path,State),_,fail),is_dict(State),
      memberchk(State.standing,
        ["transmission-started-outcome-unknown","outcome-unknown-held"])).

as_evaluation_memory_health(Root) :-
    miter_chroma_config(Root,Config),Config.enabled==true,
    miter_chroma_collection(Config,_),
    miter_chroma_embedding(Config,"Miter AMA-1.2 local activation health probe",Embedding),
    length(Embedding,Config.embedding.dimension).

as_evaluation_model_health(Root) :-
    as_model_profile(Root,'openrouter-glm53',Profile),
    as_model_keychain(Profile,Key),string_length(Key,Length),Length>=16.

as_write_evaluation_activation(Root,Inactive,Config,_Binding,Affirmation,
    BindingHash,Reply) :-
    get_time(Now),SegmentExpiry is Now+72*3600,MaximumExpiry is Now+168*3600,
    term_string([ama12,Now,BindingHash,Affirmation],WitnessText,
      [quoted(true),ignore_ops(true)]),
    crypto_data_hash(WitnessText,WitnessHash,[algorithm(sha256),encoding(utf8)]),
    atom_string(BindingHashString,BindingHash),
    atom_string(WitnessHashString,WitnessHash),
    Grant=_{id:"ama-1.2",standing:"active",scope:Config.scope,
      principals:Config.authorized_humans,
      required_group_members:Config.required_group_members,
      capabilities:["mattermost-new-event","mattermost-create-post",
        "shared-continuity","scoped-semantic-memory","authorized-model-participation"],
      limits:Inactive.bounds,binding_sha256:BindingHashString,
      activated_at_epoch:Now,segment_expires_at_epoch:SegmentExpiry,
      maximum_expires_at_epoch:MaximumExpiry,
      disclosure_witness:Affirmation,activation_witness_sha256:WitnessHashString,
      authority_separation:"grant-bounds-reach-not-meaning-or-movement"},
    as_evaluation_model_grants(Config,Now,SegmentExpiry,ModelGrants),
    directory_file_path(Root,'mattermost.json',MattermostPath),
    put_dict(enabled,Config.outbound,true,Outbound),
    put_dict(outbound,Config,Outbound,ActiveMattermost),
    as_write_json_durable(MattermostPath,ActiveMattermost),
    directory_file_path(Root,'model-grants.json',ModelGrantPath),
    as_write_json_durable(ModelGrantPath,ModelGrants),
    directory_file_path(Root,'runtime.json',RuntimePath),
    miter_store_read_json(RuntimePath,Runtime),
    put_dict(_{external_effects:"evaluation-grant-only",
      evaluation_grant_id:"ama-1.2"},Runtime,ActiveRuntime),
    as_write_json_durable(RuntimePath,ActiveRuntime),
    directory_file_path(Root,'evaluation-grants.json',GrantPath),
    Active=_{schema:"miter-evaluation-grants-v1",
      standing:"active-explicit-grants",authority:Inactive.authority,
      authority_separation:Inactive.authority_separation,
      haley_disclosure:Inactive.haley_disclosure,
      required_affirmations:_{berton_c:"affirmed-by-ratification",
        haley:"affirmed-by-exact-mattermost-disclosure"},
      bounds:Inactive.bounds,grants:[Grant]},
    as_write_json_durable(GrantPath,Active),
    Reply=_{schema:"miter-assistant-operator-result-v1",
      status:'evaluation-activated',grant_id:"ama-1.2",
      activated_at_epoch:Now,segment_expires_at_epoch:SegmentExpiry,
      maximum_expires_at_epoch:MaximumExpiry,
      disclosure_post_id:Affirmation.post_id,
      activation_witness_sha256:WitnessHashString}.

as_evaluation_model_grants(Config,Now,Expiry,Document) :-
    findall(Grant,
      (member(Principal,Config.authorized_humans),
       format(string(Id),'ama-1.2-openrouter-~s',[Principal]),
       Grant=_{id:Id,standing:"active",resource_id:"openrouter-glm53",
         purposes:["general-contact-semantics","language-rendering",
           "partial-alignment-inquiry"],
         scope:_{principal:Principal,audience:Config.scope.audience,
           project:Config.scope.project},max_calls:50,max_output_tokens:2048,
         deadline_seconds:120,public_safe_only:true,
         activated_at_epoch:Now,expires_at_epoch:Expiry,
         evaluation_grant_id:"ama-1.2"}),Grants),
    Document=_{schema:"miter-model-grants-v2",
      standing:"active-explicit-grants",grants:Grants}.

as_compile_extension(Root) :-
    as_operator_repo_root(Repo),
    directory_file_path(Repo,'effect_membranes/runtime_extensions/store_posix.c',Source),
    directory_file_path(Root,'lib/build',Build),
    make_directory_path(Build), chmod(Build,0o700),
    directory_file_path(Build,'store_posix.c',BuildSource),
    copy_file(Source,BuildSource), chmod(BuildSource,0o600),
    directory_file_path(Root,'lib/libmiter_store_posix.dylib',Output),
    directory_file_path(Root,'logs/extension-build.stdout',Stdout),
    directory_file_path(Root,'logs/extension-build.stderr',Stderr),
    setup_call_cleanup(open(Stdout,write,Out,[encoding(utf8)]),
      setup_call_cleanup(open(Stderr,write,Err,[encoding(utf8)]),
        (as_swipl_ld(SwiplLd),
         process_create(SwiplLd,['-shared','-O2','-o',Output,BuildSource],
          [cwd(Build),stdin(null),stdout(stream(Out)),stderr(stream(Err)),process(Pid)]),
         process_wait(Pid,Status)),
        close(Err)),close(Out)),
    Status==exit(0), exists_file(Output), chmod(Output,0o700).

as_file_identity(Root, Relative, _{path:Relative,sha256:HashString}) :-
    directory_file_path(Root,Relative,Path),
    crypto_file_hash(Path,Hash,[algorithm(sha256),encoding(octet)]), atom_string(Hash,HashString).
as_file_identity_absolute(Path, _{path:Path,sha256:HashString}) :-
    crypto_file_hash(Path,Hash,[algorithm(sha256),encoding(octet)]), atom_string(Hash,HashString).

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

% macOS launchd supervises this non-cognitive wrapper.  The wrapper owns no
% recurrence of its own: it runs exactly one frozen PeTTa service process and
% waits for that process to end.  Failed exits may be relaunched by launchd;
% the existing three-crashes-in-sixty-seconds ledger ends that sequence with a
% successful containment exit so KeepAlive does not become perpetual thrash.
as_prepare_host_service(Root,Reply) :-
    as_root(Root,_),as_verify_lkg(Root,verified),
    as_host_service_material(Root,Label,PlistPath,Target),
    Reply=_{schema:"miter-assistant-operator-result-v1",
      status:'service-profile-ready',label:Label,profile:PlistPath,
      launchd_target:Target,registered:false}.

as_host_service_material(Root,Label,PlistPath,Target) :-
    directory_file_path(Root,'runtime.json',RuntimePath),
    miter_store_read_json(RuntimePath,Runtime),
    miter_store_nonempty_atom(Runtime.runtime_id,RuntimeId),
    format(atom(Label),'io.singularitynet.miter.~w',[RuntimeId]),
    as_host_uid(Uid),format(atom(Target),'gui/~d',[Uid]),
    as_lkg_source_root(Root,SourceRoot),
    directory_file_path(SourceRoot,
      'effect_membranes/assistant_operator.pl',Operator),
    current_prolog_flag(executable,Swipl),
    directory_file_path(Root,'lkg.json',LkgPath),
    miter_store_read_json(LkgPath,Lkg),
    miter_store_nonempty_atom(Lkg.petta.path,Petta),
    directory_file_path(Root,'logs/launchd.stdout',Stdout),
    directory_file_path(Root,'logs/launchd.stderr',Stderr),
    maplist(as_xml_text,[Label,Swipl,Operator,Root,Petta,SourceRoot,Stdout,Stderr],
      [LabelX,SwiplX,OperatorX,RootX,PettaX,SourceRootX,StdoutX,StderrX]),
    format(string(Text),
      '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0">\n<dict>\n  <key>Label</key><string>~s</string>\n  <key>ProgramArguments</key>\n  <array>\n    <string>~s</string><string>-q</string><string>-f</string><string>none</string>\n    <string>-s</string><string>~s</string><string>--</string>\n    <string>run-supervised</string><string>--runtime-root</string><string>~s</string>\n  </array>\n  <key>EnvironmentVariables</key><dict>\n    <key>MITER_PETTA_MAIN</key><string>~s</string>\n  </dict>\n  <key>WorkingDirectory</key><string>~s</string>\n  <key>RunAtLoad</key><true/>\n  <key>KeepAlive</key><dict><key>SuccessfulExit</key><false/></dict>\n  <key>ThrottleInterval</key><integer>5</integer>\n  <key>ProcessType</key><string>Background</string>\n  <key>StandardOutPath</key><string>~s</string>\n  <key>StandardErrorPath</key><string>~s</string>\n</dict>\n</plist>\n',
      [LabelX,SwiplX,OperatorX,RootX,PettaX,SourceRootX,StdoutX,StderrX]),
    directory_file_path(Root,'service/launchd.plist',PlistPath),
    as_write_text_durable(PlistPath,Text),
    as_plist_valid(PlistPath),chmod(PlistPath,0o600).

as_xml_text(Value,Escaped) :-
    miter_store_nonempty_atom(Value,Atom),atom_codes(Atom,Codes),
    as_xml_codes(Codes,EscapedCodes),string_codes(Escaped,EscapedCodes).

as_xml_codes([],[]).
as_xml_codes([0'&|Rest],[0'&,0'a,0'm,0'p,0';|Tail]) :- !,
    as_xml_codes(Rest,Tail).
as_xml_codes([0'<|Rest],[0'&,0'l,0't,0';|Tail]) :- !,
    as_xml_codes(Rest,Tail).
as_xml_codes([0'>|Rest],[0'&,0'g,0't,0';|Tail]) :- !,
    as_xml_codes(Rest,Tail).
as_xml_codes([0'\"|Rest],[0'&,0'q,0'u,0'o,0't,0';|Tail]) :- !,
    as_xml_codes(Rest,Tail).
as_xml_codes([Code|Rest],[Code|Tail]) :- as_xml_codes(Rest,Tail).

as_plist_valid(Path) :-
    process_create('/usr/bin/plutil',['-lint',Path],
      [stdin(null),stdout(null),stderr(null),process(Pid)]),
    process_wait(Pid,exit(0)).

as_host_uid(Uid) :-
    setup_call_cleanup(
      process_create('/usr/bin/id',['-u'],
        [stdin(null),stdout(pipe(Stream)),stderr(null),process(Pid)]),
      read_string(Stream,64,Raw),close(Stream)),
    process_wait(Pid,exit(0)),normalize_space(string(Text),Raw),
    number_string(Uid,Text),integer(Uid),Uid>=0.

as_register_host_service(Root,Reply) :-
    as_host_service_material(Root,Label,PlistPath,Target),
    ( as_launchd_registered(Target,Label) -> true
    ; process_create('/bin/launchctl',['bootstrap',Target,PlistPath],
        [stdin(null),stdout(null),stderr(null),process(Pid)]),
      process_wait(Pid,exit(0)) ),
    get_time(Now),directory_file_path(Root,'service/registration.json',StatePath),
    as_write_json_durable(StatePath,_{schema:"miter-host-service-v1",
      label:Label,launchd_target:Target,profile:PlistPath,
      standing:"registered",registered_at_epoch:Now}),
    Reply=_{schema:"miter-assistant-operator-result-v1",
      status:'service-registered',label:Label,launchd_target:Target}.

as_unregister_host_service(Root,Reply) :-
    as_host_service_material(Root,Label,_PlistPath,Target),
    ( as_launchd_registered(Target,Label) ->
        format(atom(ServiceTarget),'~w/~w',[Target,Label]),
        process_create('/bin/launchctl',['bootout',ServiceTarget],
          [stdin(null),stdout(null),stderr(null),process(Pid)]),
        process_wait(Pid,exit(0))
    ; true ),
    get_time(Now),directory_file_path(Root,'service/registration.json',StatePath),
    as_write_json_durable(StatePath,_{schema:"miter-host-service-v1",
      label:Label,launchd_target:Target,standing:"unregistered",
      unregistered_at_epoch:Now}),
    Reply=_{schema:"miter-assistant-operator-result-v1",
      status:'service-unregistered',label:Label,launchd_target:Target}.

as_launchd_registered(Target,Label) :-
    format(atom(ServiceTarget),'~w/~w',[Target,Label]),
    process_create('/bin/launchctl',['print',ServiceTarget],
      [stdin(null),stdout(null),stderr(null),process(Pid)]),
    process_wait(Pid,exit(0)).

as_supervised_run(Root,Reply) :-
    as_root(Root,_),as_verify_lkg(Root,verified),
    ( as_process_state(Root,State,Pid),State\==dead ->
        Reply=_{schema:"miter-assistant-operator-result-v1",
          status:'supervised-clean-exit',reason:"service-already-running",pid:Pid}
    ; as_mattermost_prepare(Root,MattermostStanding),MattermostStanding\==held,
      as_crash_admit(Root,CrashStanding),
      ( CrashStanding==blocked ->
          Reply=_{schema:"miter-assistant-operator-result-v1",
            status:'crash-loop-contained'}
      ; as_write_control(Root,continue,'launchd-supervisor'),
        as_spawn_foreground(Root,ChildPid,ProcessStatus),
        as_supervised_outcome(Root,ChildPid,ProcessStatus,Reply) ) ), !.

as_spawn_foreground(Root,Pid,ProcessStatus) :-
    as_lkg_source_root(Root,SourceRoot),as_petta_main(Petta),
    directory_file_path(Root,'service-entry.metta',Entry),uuid(RunId),
    atomic_list_concat(['logs/service-',RunId,'.stdout'],StdoutRelative),
    atomic_list_concat(['logs/service-',RunId,'.stderr'],StderrRelative),
    directory_file_path(Root,StdoutRelative,Stdout),
    directory_file_path(Root,StderrRelative,Stderr),
    setup_call_cleanup(open(Stdout,write,Out,[encoding(utf8)]),
      setup_call_cleanup(open(Stderr,write,Err,[encoding(utf8)]),
        (current_prolog_flag(executable,Swipl),
         process_create(Swipl,
           ['--stack_limit=2g','-q','-s',Petta,'--',Entry,silent],
           [cwd(SourceRoot),stdin(null),stdout(stream(Out)),stderr(stream(Err)),
            process(Pid)]),
         get_time(StartedAt),directory_file_path(Root,'pid.json',PidPath),
         as_write_json_durable(PidPath,_{schema:"miter-assistant-pid-v1",
           pid:Pid,run_id:RunId,started_at_epoch:StartedAt,
           stdout:StdoutRelative,stderr:StderrRelative}),
         process_wait(Pid,ProcessStatus)),close(Err)),close(Out)).

as_supervised_outcome(Root,Pid,_ProcessStatus,Reply) :-
    as_clean_exit(Root,Pid),!,
    Reply=_{schema:"miter-assistant-operator-result-v1",
      status:'supervised-clean-exit',pid:Pid}.
as_supervised_outcome(Root,Pid,ProcessStatus,Reply) :-
    as_note_crash(Root,Pid,Count),
    ( Count>=3 -> Status='crash-loop-contained'
    ; Status='supervised-crash' ),
    term_string(ProcessStatus,ProcessStanding,[quoted(true),ignore_ops(true)]),
    Reply=_{schema:"miter-assistant-operator-result-v1",status:Status,pid:Pid,
      crash_count_in_window:Count,process_standing:ProcessStanding}.

as_start(Root, Reply) :-
    as_root(Root,_), as_verify_lkg(Root,Lkg),
    ( Lkg \== verified ->
        Reply=_{schema:"miter-assistant-operator-result-v1",status:'lkg-mismatch'}
    ; as_process_state(Root,alive,Pid) ->
        Reply=_{schema:"miter-assistant-operator-result-v1",status:running,pid:Pid,
          semantic_health:"not-claimed"}
    ; as_process_state(Root,unconfirmed,Pid) ->
        Reply=_{schema:"miter-assistant-operator-result-v1",
          status:'existing-process-unconfirmed',pid:Pid,
          semantic_health:"not-claimed"}
    ; as_mattermost_prepare(Root,MattermostStanding),
      MattermostStanding == held ->
        Reply=_{schema:"miter-assistant-operator-result-v1",
          status:'surface-preflight-held',surface:mattermost}
    ; as_crash_admit(Root,CrashStanding),
      ( CrashStanding == blocked ->
          Reply=_{schema:"miter-assistant-operator-result-v1",
            status:'crash-loop-contained',semantic_health:"not-claimed"}
      ; as_write_control(Root,continue,start), as_spawn(Root,Pid,StartedAt),
        ( as_wait_started(Root,Pid,StartedAt,5) ->
            Reply=_{schema:"miter-assistant-operator-result-v1",status:started,pid:Pid,
              semantic_health:"not-claimed"}
        ; as_process_state(Root,alive,Pid) ->
            Reply=_{schema:"miter-assistant-operator-result-v1",status:starting,pid:Pid,
              semantic_health:"readiness-pending"}
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
    as_lkg_source_root(Root,SourceRoot),as_petta_main(Petta),
    directory_file_path(Root,'service-entry.metta',Entry),uuid(RunId),
    atomic_list_concat(['logs/service-',RunId,'.stdout'],StdoutRelative),
    atomic_list_concat(['logs/service-',RunId,'.stderr'],StderrRelative),
    directory_file_path(Root,StdoutRelative,Stdout),directory_file_path(Root,StderrRelative,Stderr),
    setup_call_cleanup(open(Stdout,write,Out,[encoding(utf8)]),
      setup_call_cleanup(open(Stderr,write,Err,[encoding(utf8)]),
        (current_prolog_flag(executable,Swipl),
         process_create(Swipl,
           ['--stack_limit=2g','-q','-s',Petta,'--',Entry,silent],
           [cwd(SourceRoot),stdin(null),stdout(stream(Out)),stderr(stream(Err)),detached(true),process(Pid)])),
        close(Err)),close(Out)),
    get_time(StartedAt),directory_file_path(Root,'pid.json',PidPath),
    as_write_json_durable(PidPath,_{schema:"miter-assistant-pid-v1",pid:Pid,
      run_id:RunId,started_at_epoch:StartedAt,stdout:StdoutRelative,stderr:StderrRelative}).

as_wait_started(Root, Pid, StartedAt, Seconds) :-
    End is StartedAt+Seconds,as_wait_started_until(Root,Pid,StartedAt,End).
as_wait_started_until(Root,Pid,StartedAt,End) :-
    ( directory_file_path(Root,'heartbeat.json',Heartbeat),exists_file(Heartbeat),
      miter_store_read_json(Heartbeat,Dict),as_dict_atom(Dict,schema,'miter-assistant-heartbeat-v1'),
      get_dict(observed_at_epoch,Dict,Observed),number(Observed),Observed>=StartedAt
    -> true
    ; as_pid_probe(Pid,dead) -> fail
    ; get_time(Now),Now<End,sleep(0.05),
      as_wait_started_until(Root,Pid,StartedAt,End) ).

as_process_state(Root, State, Pid) :-
    directory_file_path(Root,'pid.json',Path),exists_file(Path),
    miter_store_read_json(Path,Dict),as_dict_atom(Dict,schema,'miter-assistant-pid-v1'),
    get_dict(pid,Dict,Pid),integer(Pid),Pid>1,
    as_pid_probe(Pid,Probe),
    ( Probe==alive -> State=alive
    ; Probe==dead -> State=dead
    ; as_heartbeat_active(Root,Pid) -> State=alive
    ; State=unconfirmed ).

% Some supervised or sandboxed hosts permit the service to continue while
% denying a later process signal probe. A fresh heartbeat recorded after this
% exact PID's start is a second, run-bound liveness witness. It never drives
% cognition; it only prevents the operator from reporting a live organism as
% stopped when kill(0) is unavailable.
as_heartbeat_active(Root, Pid) :-
    as_pid_started(Root,Pid,Started),
    directory_file_path(Root,'heartbeat.json',Path),exists_file(Path),
    catch(miter_store_read_json(Path,Dict),_,fail),
    as_dict_atom(Dict,schema,'miter-assistant-heartbeat-v1'),
    as_dict_atom(Dict,state,State),
    \+ memberchk(State,['assistant-stopped','assistant-panicked']),
    get_dict(observed_at_epoch,Dict,Observed),number(Observed),Observed>=Started,
    get_time(Now),Now>=Observed,
    as_config(Root,idle_cap_seconds,Cap),Freshness is max(5,Cap*4+1),
    Now-Observed=<Freshness.

as_pid_alive(Pid) :-
    as_pid_probe(Pid,alive).

% A denied signal probe is not evidence of process death. Some managed hosts
% permit the detached service to run but reject a later kill(0). Preserve the
% uncertainty so status/start/stop do not invent a crash or spawn a duplicate.
as_pid_probe(Pid, Standing) :-
    catch(as_pid_probe_checked(Pid,Standing0),_,Standing0=unconfirmed),
    Standing=Standing0, !.

as_pid_probe_checked(Pid, Standing) :-
    process_create('/bin/kill',['-0',Pid],
      [stdin(null),stdout(null),stderr(pipe(ErrorStream)),process(Check)]),
    setup_call_cleanup(true,read_string(ErrorStream,4096,Message),
      close(ErrorStream)),
    process_wait(Check,Status),string_lower(Message,Lower),
    ( Status==exit(0) -> Standing=alive
    ; sub_string(Lower,_,_,_,"no such process") -> Standing=dead
    ; Standing=unconfirmed ).

as_status(Root, Reply) :-
    ( catch(as_root(Root,_),_,fail) ->
        as_verify_lkg(Root,Lkg),
        (as_process_state(Root,Observed,Pid)->
          (Observed==alive->State=running
          ;Observed==dead->State=stopped
          ;as_unconfirmed_status(Root,State))
        ;Pid=0,State=stopped),
        as_status_heartbeat(Root,Heartbeat),
        as_evaluation_status(Root,Evaluation),
        as_host_service_status(Root,HostService),
        Reply=_{schema:"miter-assistant-operator-result-v1",status:State,pid:Pid,
          lkg:Lkg,heartbeat:Heartbeat,evaluation:Evaluation,
          host_service:HostService,
          semantic_health:"not-claimed"}
    ; Reply=_{schema:"miter-assistant-operator-result-v1",status:'not-bootstrapped'} ).

as_status_heartbeat(Root, Heartbeat) :-
    directory_file_path(Root,'heartbeat.json',Path),
    (exists_file(Path)->miter_store_read_json(Path,Heartbeat);Heartbeat=null).

as_host_service_status(Root,Standing) :-
    directory_file_path(Root,'service/registration.json',RegistrationPath),
    directory_file_path(Root,'service/launchd.plist',ProfilePath),
    ( exists_file(RegistrationPath),
      catch(miter_store_read_json(RegistrationPath,Registration),_,fail),
      is_dict(Registration),Registration.schema=="miter-host-service-v1" ->
        miter_store_nonempty_atom(Registration.label,Label),
        miter_store_nonempty_atom(Registration.launchd_target,Target),
        ( as_launchd_registered(Target,Label) -> State="registered"
        ; State="not-loaded" ),
        Standing=_{standing:State,label:Registration.label,
          launchd_target:Registration.launchd_target}
    ; exists_file(ProfilePath) ->
        Standing=_{standing:"profile-ready-not-registered"}
    ; Standing=_{standing:"not-prepared"} ).

as_evaluation_status(Root,Standing) :-
    directory_file_path(Root,'evaluation-grants.json',Path),
    ( catch(miter_store_read_json(Path,Document),_,fail),is_dict(Document),
      Document.schema=="miter-evaluation-grants-v1",
      Document.standing=="active-explicit-grants",
      get_dict(grants,Document,[Grant]),is_dict(Grant) ->
        get_time(Now),
        ( Now>Grant.segment_expires_at_epoch -> State="paused-segment-expired"
        ; State="active" ),
        as_evaluation_json_count(Root,'surface/events',Events),
        as_evaluation_effect_counts(Root,Grant,Posts,PostsLastHour),
        as_evaluation_model_claim_count(Root,RemoteCalls),
        Standing=_{grant_id:Grant.id,standing:State,
          activated_at_epoch:Grant.activated_at_epoch,
          segment_expires_at_epoch:Grant.segment_expires_at_epoch,
          maximum_expires_at_epoch:Grant.maximum_expires_at_epoch,
          counts:_{admitted_events:Events,outbound_posts:Posts,
            outbound_last_hour:PostsLastHour,remote_calls:RemoteCalls},
          limits:Grant.limits}
    ; Standing=_{standing:"inactive-awaiting-participant-disclosure"} ).

as_unconfirmed_status(Root, Status) :-
    ( as_pending_control(Root,panic) -> Status='panic-pending'
    ; as_pending_control(Root,stop) -> Status='stop-pending'
    ; as_has_leased_input(Root) -> Status='processing-unconfirmed'
    ; Status='liveness-unconfirmed' ).

as_pending_control(Root, Command) :-
    directory_file_path(Root,'control.json',Path),
    catch((miter_store_read_json(Path,Dict),
      as_dict_atom(Dict,schema,'miter-assistant-control-v1'),
      as_dict_atom(Dict,command,Command)),_,fail).

as_has_leased_input(Root) :-
    directory_file_path(Root,leased,Directory),directory_files(Directory,Files),
    member(Name,Files),as_json_name(Name),!.

as_submit(Root, Event, Reply) :-
    ( catch((as_root(Root,_),as_verify_lkg(Root,verified),
        size_file(Event,Size),as_config(Root,max_input_bytes,Max),Size=<Max,
        miter_store_read_json(Event,Dict),as_input_dict(Root,Dict,Input,InputId),
        Input=['assistant-input',consequence,_,_]),_,fail)
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
    as_root(Root,_),
    ( as_process_state(Root,State,Pid),State\==dead ->
        as_write_control(Root,stop,operator),
        (as_wait_dead(Root,Pid,5)->Status=stopped,as_write_exit(Root,Pid,'clean-stop')
        ;Status='stop-pending')
    ; Pid=0,Status=stopped ),
    as_verify_lkg(Root,Lkg),
    Reply=_{schema:"miter-assistant-operator-result-v1",status:Status,pid:Pid,
      lkg:Lkg}.

as_panic(Root, Reply) :-
    as_root(Root,_),
    ( as_process_state(Root,State,Pid),State\==dead ->
        as_panic_active_process(Root,Pid,Standing)
    ; Pid=0,Standing=panicked ),
    (Standing==panicked->as_write_exit(Root,Pid,panic);true),
    Reply=_{schema:"miter-assistant-operator-result-v1",status:Standing,pid:Pid,
      history_deleted:false}.

as_panic_active_process(Root, Pid, Standing) :-
    as_write_control(Root,panic,operator),
    ( as_wait_dead(Root,Pid,2) -> Standing=panicked
    ; as_signal(Pid,'-TERM'),
      ( as_wait_dead(Root,Pid,1) -> Standing=panicked
      ; as_signal(Pid,'-KILL'),
        (as_wait_dead(Root,Pid,1)->Standing=panicked
        ;Standing='panic-pending') ) ).

as_wait_dead(Root, Pid, Seconds) :-
    get_time(Start),End is Start+Seconds,as_wait_dead_until(Root,Pid,End).
as_wait_dead_until(Root, Pid, _) :- as_process_state(Root,dead,Pid),!.
as_wait_dead_until(Root, Pid, End) :-
    get_time(Now),Now<End,sleep(0.05),as_wait_dead_until(Root,Pid,End).

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
    as_checkpoint_identity(Root,CheckpointHash),
    as_trajectory_standing(Root,Trajectory),
    as_evaluation_status(Root,Evaluation),
    directory_file_path(Root,'lkg.json',LkgPath),
    crypto_file_hash(LkgPath,LkgHash,[algorithm(sha256),encoding(octet)]),
    directory_file_path(Root,'runtime.json',RuntimePath),
    miter_store_read_json(RuntimePath,Runtime),
    get_dict(network_access,Runtime,NetworkAccess),
    get_dict(external_effects,Runtime,ExternalEffects),
    get_time(Now),Bundle=_{schema:"miter-assistant-evidence-bundle-v1",
      recorded_at_epoch:Now,lkg:Lkg,lkg_sha256:LkgHash,status:Status,
      counts:_{receipts:ReceiptCount,consumed:ConsumedCount,rejected:RejectedCount,
        outbox:OutboxCount},checkpoint_sha256:CheckpointHash,trajectory:Trajectory,
      evaluation:Evaluation,
      network_access:NetworkAccess,external_effects:ExternalEffects,
      private_content_included:false,
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

as_checkpoint_identity(Root, HashString) :-
    directory_file_path(Root,'checkpoints/active.json',MetaPath),
    ( exists_file(MetaPath), catch(miter_store_read_json(MetaPath,Meta),_,fail),
      get_dict(schema,Meta,"miter-assistant-checkpoint-v3"),
      get_dict(snapshot_sha256,Meta,Hash0),
      miter_store_nonempty_atom(Hash0,Hash), as_sha256(Hash,Hash)
    -> atom_string(Hash,HashString)
    ; as_optional_hash(Root,'checkpoints/active.term',HashString) ).

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
