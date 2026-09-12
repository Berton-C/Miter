% Shared non-cognitive operator mechanics. This file has no standalone entry.
% It may create explicit runtime directories, compile pinned mechanics,
% supervise a verified process and carry strict JSON. It does not inspect
% contact meaning, select movement, diagnose the Soul or grant network effects.

:- ensure_loaded('assistant_service.pl').
:- ensure_loaded('model.pl').
:- ensure_loaded('capability_environment.pl').
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
  usage:"miter <install|bootstrap|model-selection|select-model|evaluation-disclosure|activate-evaluation|activate-evaluation-admin|continue-evaluation-admin|start|status|submit|stop|panic|evidence-bundle> --runtime-root ABSOLUTE_PATH [--resource ID --duration-seconds N --max-calls N|--haley-affirmation-post-id ID|--event FILE|--output FILE]"}, 64).

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
as_command('model-selection',Args,Reply,Code) :-
    !,
    as_exact_options(Args,['--runtime-root']),
    as_required_option(Args,'--runtime-root',Root0),
    as_runtime_path(Root0,Root),as_model_selection(Root,Reply),
    as_reply_code(Reply,Code).
as_command('select-model',Args,Reply,Code) :-
    !,
    as_exact_options(Args,
      ['--runtime-root','--resource','--duration-seconds','--max-calls']),
    as_required_option(Args,'--runtime-root',Root0),
    as_required_option(Args,'--resource',Resource0),
    as_required_option(Args,'--duration-seconds',Duration0),
    as_required_option(Args,'--max-calls',MaxCalls0),
    as_runtime_path(Root0,Root),
    as_select_model(Root,Resource0,Duration0,MaxCalls0,Reply),
    as_reply_code(Reply,Code).
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
as_command('activate-evaluation-admin', Args, Reply, Code) :-
    !,
    as_exact_options(Args,['--runtime-root']),
    as_required_option(Args,'--runtime-root',Root0),
    as_runtime_path(Root0,Root),
    as_activate_evaluation_admin(Root,Reply),as_reply_code(Reply,Code).
as_command('continue-evaluation-admin', Args, Reply, Code) :-
    !,
    as_exact_options(Args,['--runtime-root']),
    as_required_option(Args,'--runtime-root',Root0),
    as_runtime_path(Root0,Root),
    as_continue_evaluation_admin(Root,Reply),as_reply_code(Reply,Code).
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
      'evaluation-already-active','evaluation-segment-already-current',
      'evaluation-segment-continued','supervised-clean-exit','crash-loop-contained',
      'model-selection','model-selected']), !.
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
  service,workspace,capabilities,secrets,'private-assets',
  'model/claims','model/requests','model/raw','model/observations','surface/raw',
  'surface/events','surface/effects','checkpoints/objects','continuity/native',
  'continuity/native/manifests','continuity/native/scopes','semantic/queries',
  'semantic/projections','lkg/source','workshop','workshop/repository',
  'workshop/candidates','workshop/staged','workshop/trials',
  'workshop/active','workshop/prepared','workshop/exports']).

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
    as_human_config_sections(Root,HumanConfig,Config,Mattermost,Memory,Vad,
      Models,Grants,EvaluationGrants,GrowthEnvironment),
    directory_file_path(Root,'config.json',ConfigTarget),
    miter_store_write_json_atomic(ConfigTarget,Config),
    directory_file_path(Repo,'config/continuity.json',BindingsSource),
    miter_store_read_json(BindingsSource,Bindings),
    directory_file_path(Root,'scope-bindings.json',BindingsTarget),
    miter_store_write_json_atomic(BindingsTarget,Bindings),
    directory_file_path(Root,'model-resources.json',ModelsTarget),
    miter_store_write_json_atomic(ModelsTarget,Models),
    as_initial_model_direction(Models,ModelDirection),
    directory_file_path(Root,'model-direction.json',DirectionTarget),
    miter_store_write_json_atomic(DirectionTarget,ModelDirection),
    directory_file_path(Root,'model-grants.json',GrantsTarget),
    miter_store_write_json_atomic(GrantsTarget,Grants),
    directory_file_path(Root,'evaluation-grants.json',EvaluationGrantsTarget),
    miter_store_write_json_atomic(EvaluationGrantsTarget,EvaluationGrants),
    directory_file_path(Root,'semantic-memory.json',MemoryTarget),
    miter_store_write_json_atomic(MemoryTarget,Memory),
    directory_file_path(Root,'vad.json',VadTarget),
    miter_store_write_json_atomic(VadTarget,Vad),
    directory_file_path(Root,'mattermost.json',MattermostTarget),
    miter_store_write_json_atomic(MattermostTarget,Mattermost),
    directory_file_path(Root,'growth-environment.json',GrowthTarget),
    miter_store_write_json_atomic(GrowthTarget,GrowthEnvironment),
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

as_initial_model_direction(Models,Direction) :-
    get_dict(selection,Models,Selection),is_dict(Selection),
    as_dict_atom(Selection,mode,'human-operator-direction'),
    as_dict_atom(Selection,operator_preference,ResourceId),
    get_dict(authorized_directions,Selection,AuthorizedStrings),
    maplist(as_symbol,AuthorizedStrings,Authorized),memberchk(ResourceId,Authorized),
    Direction=_{schema:"miter-model-direction-v1",
      standing:"active-human-direction",direction_id:"installed-default",
      resource_id:ResourceId,
      purposes:["semantic-reading","language-rendering"],
      activated_at_epoch:0,expires_at_epoch:0,max_calls:0,
      authority:"human-edited-install-configuration",
      authority_boundary:"resource-only-no-meaning-movement-or-effect-authority"}.

as_model_selection(Root,Reply) :-
    as_root(Root,_),as_verify_lkg(Root,verified),
    directory_file_path(Root,'model-direction.json',Path),
    miter_store_read_json(Path,Direction),
    as_dict_atom(Direction,schema,'miter-model-direction-v1'),
    as_dict_atom(Direction,resource_id,ResourceId),
    get_dict(activated_at_epoch,Direction,Activated),number(Activated),
    as_model_direction_claim_count(Root,ResourceId,Activated,Used),
    get_dict(max_calls,Direction,MaxCalls),
    get_dict(expires_at_epoch,Direction,Expiry),get_time(Now),
    ( Expiry=:=0 -> TimeStanding='until-replaced'
    ; Now=<Expiry -> TimeStanding='active-bounded-duration'
    ; TimeStanding=expired ),
    ( MaxCalls=:=0 -> CallStanding='unbounded-until-replaced',CallAvailable=true
    ; Remaining is max(0,MaxCalls-Used),
      format(atom(CallStanding),'~d-model-calls-remaining',[Remaining]),
      (Remaining>0->CallAvailable=true;CallAvailable=false) ),
    ( TimeStanding==expired -> EffectiveStanding='expired-no-model-call'
    ; CallAvailable==false -> EffectiveStanding='exhausted-no-model-call'
    ; EffectiveStanding='active-resource-direction' ),
    Reply=_{schema:"miter-assistant-operator-result-v1",
      status:'model-selection',resource_id:ResourceId,
      direction_id:Direction.direction_id,standing:Direction.standing,
      effective_standing:EffectiveStanding,
      time_standing:TimeStanding,call_standing:CallStanding,
      used_model_calls:Used,max_calls:MaxCalls,
      activated_at_epoch:Activated,expires_at_epoch:Expiry,
      authority_boundary:Direction.authority_boundary}.

as_select_model(Root,Resource0,Duration0,MaxCalls0,Reply) :-
    as_root(Root,_),as_verify_lkg(Root,verified),
    miter_store_nonempty_atom(Resource0,ResourceId),
    miter_store_nonempty_atom(Duration0,DurationAtom),
    miter_store_nonempty_atom(MaxCalls0,MaxCallsAtom),
    atom_number(DurationAtom,Duration),integer(Duration),Duration>=0,
    atom_number(MaxCallsAtom,MaxCalls),integer(MaxCalls),MaxCalls>=0,
    as_path(Root,'model-resources.json',RegistryPath),
    miter_store_read_json(RegistryPath,Registry),
    get_dict(selection,Registry,Selection),
    get_dict(authorized_directions,Selection,AuthorizedStrings),
    maplist(as_symbol,AuthorizedStrings,Authorized),memberchk(ResourceId,Authorized),
    as_model_profile(Root,ResourceId,Profile),
    as_model_resource_health(Root,Profile,Health),
    get_time(Now),(Duration=:=0->Expiry=0;Expiry is Now+Duration),
    uuid(DirectionId),atom_string(DirectionId,DirectionIdString),
    atom_string(ResourceId,ResourceString),
    Direction=_{schema:"miter-model-direction-v1",
      standing:"active-human-direction",direction_id:DirectionIdString,
      resource_id:ResourceString,
      purposes:["semantic-reading","language-rendering"],
      activated_at_epoch:Now,expires_at_epoch:Expiry,max_calls:MaxCalls,
      authority:"explicit-human-operator-direction",
      authority_boundary:"resource-only-no-meaning-movement-or-effect-authority"},
    directory_file_path(Root,'model-direction.json',Path),
    as_write_json_durable(Path,Direction),as_secure_runtime_tree(Root),
    Reply=_{schema:"miter-assistant-operator-result-v1",status:'model-selected',
      resource_id:ResourceString,direction_id:DirectionIdString,
      activated_at_epoch:Now,expires_at_epoch:Expiry,max_calls:MaxCalls,
      health:Health,
      authority_boundary:"resource-only-no-meaning-movement-or-effect-authority"}.

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
    forall(member(Key,[idle_base_seconds,idle_cap_seconds,max_input_batch,
        max_input_bytes,supervision]),
      (get_dict(Key,Config,Value),as_config_value(Key,Value))),
    Config.idle_base_seconds =< Config.idle_cap_seconds,
    as_dict_atom(Config,external_effects,none),
    as_dict_atom(Config,network_access,'dedicated-user-open-growth-environment'),
    as_dict_atom(Config,runtime_root,'explicit-required').

% Humans edit one repository surface. Installation validates and materializes
% narrow private runtime views so individual membranes need no authority over
% the repository configuration or unrelated settings.
as_human_config_sections(Root, Human, Runtime, Mattermost, Memory, Vad, Models,
    Grants, EvaluationGrants, GrowthEnvironment) :-
    is_dict(Human),
    as_mattermost_exact_keys(Human,
      [deployment,external_effects,human_editable,idle_base_seconds,idle_cap_seconds,
       growth_environment,initial_evaluation_grants,initial_model_grants,mattermost,max_input_batch,
       max_input_bytes,memory,models,network_access,operator_notes,runtime_root,vad,
       schema,supervision]),
    as_dict_atom(Human,schema,'miter-assistant-config-v1'),
    Human.human_editable==true,
    is_list(Human.operator_notes),maplist(string,Human.operator_notes),
    Runtime=_{schema:Human.schema,idle_base_seconds:Human.idle_base_seconds,
      idle_cap_seconds:Human.idle_cap_seconds,max_input_batch:Human.max_input_batch,
      max_input_bytes:Human.max_input_bytes,external_effects:Human.external_effects,
      network_access:Human.network_access,runtime_root:Human.runtime_root,
      supervision:Human.supervision},
    as_validate_config(Runtime),
    as_deployment_config_valid(Human.deployment),
    as_materialize_credential_profiles(Root,Human.mattermost,Human.models,
      Mattermost,Models),
    is_dict(Mattermost),
    as_dict_atom(Mattermost,schema,'miter-mattermost-surface-v1'),
    Memory=Human.memory,is_dict(Memory),
    as_dict_atom(Memory,schema,'miter-semantic-memory-config-v1'),
    as_materialize_vad_config(Root,Human.vad,Vad),
    is_dict(Models),
    as_dict_atom(Models,schema,'miter-model-resource-registry-v1'),
    Grants=Human.initial_model_grants,is_dict(Grants),
    as_dict_atom(Grants,schema,'miter-model-grants-v1'),
    EvaluationGrants=Human.initial_evaluation_grants,
    as_evaluation_grants_inactive_valid(EvaluationGrants),
    as_materialize_growth_environment(Root,Human.growth_environment,
      GrowthEnvironment),
    as_growth_environment_config_valid(GrowthEnvironment),
    as_mattermost_secret_free(Human).

as_materialize_vad_config(Root,Vad0,Vad) :-
    is_dict(Vad0),
    as_mattermost_exact_keys(Vad0,
      [asset,enabled,human_editable,limits,matching,operator_notes,schema]),
    Vad0.schema=="miter-vad-language-cue-config-v1",
    Vad0.human_editable==true,Vad0.enabled==true,
    Vad0.matching=="longest-exact-only",
    is_dict(Vad0.asset),
    as_mattermost_exact_keys(Vad0.asset,
      [redistribution,relative_path,sha256,source,version]),
    Vad0.asset.version=="NRC-VAD-2.1",
    Vad0.asset.sha256==
      "42c718817fc91d5c133581b24b0bb31d2b14a0b16edb19bc6ce6ab70343e5a45",
    Vad0.asset.source=="private-runtime-file",
    Vad0.asset.redistribution==
      "prohibited-no-lexicon-rows-in-public-repository",
    string(Vad0.asset.relative_path),
    atom_string(Relative,Vad0.asset.relative_path),
    as_safe_lkg_relative_path(Relative),
    sub_atom(Relative,0,15,_,'private-assets/'),
    directory_file_path(Root,Relative,AssetPath),
    atom_string(AssetPath,AssetPathString),
    put_dict(_{path:AssetPathString},Vad0.asset,Asset),
    del_dict(relative_path,Asset,_,MaterializedAsset),
    is_dict(Vad0.limits),
    as_mattermost_exact_keys(Vad0.limits,
      [maximum_clauses,maximum_ngram_tokens,maximum_text_characters,
       maximum_tokens]),
    Vad0.limits.maximum_clauses=:=32,
    Vad0.limits.maximum_ngram_tokens=:=3,
    Vad0.limits.maximum_text_characters=:=32768,
    Vad0.limits.maximum_tokens=:=4096,
    is_list(Vad0.operator_notes),maplist(string,Vad0.operator_notes),
    put_dict(asset,Vad0,MaterializedAsset,Vad).

as_deployment_config_valid(Deployment) :-
    is_dict(Deployment),
    as_mattermost_exact_keys(Deployment,
      [credential_imports,docker_project,human_editable,images,install_root,
       operator_notes,petta,runtime_user,schema,service_mode]),
    Deployment.schema=="miter-installation-v1",
    Deployment.human_editable==true,
    Deployment.runtime_user=="claritymiter",
    Deployment.service_mode=="isolated-docker-compose",
    Deployment.docker_project=="miter",
    Deployment.install_root=="/Users/claritymiter/Miter",
    Deployment.petta.commit==
      "ae66fa8e41dcd5539d614706bd4e5cfb34f9608d",
    Deployment.petta.archive_sha256==
      "de1e2474b902895f5373fc833ed45341f16e0d283ae957ccb323df42200ce397",
    string(Deployment.petta.archive_url),
    Deployment.images.chroma==
      "docker.io/chromadb/chroma:1.5.9@sha256:1e0b73a187a28757c572acba508c46f48c9e8b0acaf5c20e6d95cdedce1acdf6",
    Deployment.images.mattermost==
      "mattermost/mattermost-team-edition:11.7.7@sha256:3ecc659553b14335e382a3d4b673afe84f4368ea1ed4cccdb44805add8dedbd7",
    Deployment.images.postgres==
      "postgres:16-alpine@sha256:57c72fd2a128e416c7fcc499958864df5301e940bca0a56f58fddf30ffc07777",
    Deployment.images.workshop==
      "python:3.11-slim@sha256:a3ab0b966bc4e91546a033e22093cb840908979487a9fc0e6e38295747e49ac0",
    is_list(Deployment.credential_imports),
    maplist(as_deployment_credential_import_valid,Deployment.credential_imports),
    is_list(Deployment.operator_notes),maplist(string,Deployment.operator_notes).

as_deployment_credential_import_valid(Import) :-
    is_dict(Import),
    as_mattermost_exact_keys(Import,[account,relative_path,service,source]),
    Import.source=="macos-keychain",as_credential_name(Import.account),
    as_credential_name(Import.service),string(Import.relative_path),
    atom_string(Relative,Import.relative_path),as_safe_lkg_relative_path(Relative),
    sub_atom(Relative,0,8,_,'secrets/').

as_materialize_credential_profiles(Root,Mattermost0,Models0,Mattermost,Models) :-
    as_materialize_credential_reference(Root,Mattermost0.credential_reference,
      MattermostReference),
    put_dict(credential_reference,Mattermost0,MattermostReference,Mattermost),
    maplist(as_materialize_model_profile(Root),Models0.resources,Resources),
    put_dict(resources,Models0,Resources,Models).

as_materialize_model_profile(Root,Profile0,Profile) :-
    ( Profile0.credential_reference==null -> Profile=Profile0
    ; as_materialize_credential_reference(Root,Profile0.credential_reference,
        Reference),
      put_dict(credential_reference,Profile0,Reference,Profile) ).

as_materialize_credential_reference(Root,
    _{source:"private-runtime-file",relative_path:RelativeString},Reference) :-
    string(RelativeString),atom_string(Relative,RelativeString),
    as_safe_lkg_relative_path(Relative),sub_atom(Relative,0,8,_,'secrets/'),
    directory_file_path(Root,Relative,Path),atom_string(Path,PathString),
    Reference=_{source:"private-runtime-file",path:PathString}.
as_materialize_credential_reference(_Root,Reference,Reference) :-
    is_dict(Reference),Reference.source=="macos-keychain".

as_materialize_growth_environment(Root,Environment0,Environment) :-
    is_dict(Environment0),is_dict(Environment0.workshop),
    is_dict(Environment0.workshop.broker),
    as_materialize_credential_reference(Root,
      Environment0.workshop.broker.credential_reference,BrokerReference),
    put_dict(credential_reference,Environment0.workshop.broker,
      BrokerReference,Broker),
    put_dict(broker,Environment0.workshop,Broker,Workshop),
    put_dict(workshop,Environment0,Workshop,Environment).

as_growth_environment_config_valid(Config) :-
    is_dict(Config),
    as_mattermost_exact_keys(Config,
      [credential_access,enabled,expected_runtime_user,human_authority_boundaries,
       human_editable,informational_network,operator_notes,reversible_writes,
       schema,terminal,workshop,workspace_relative]),
    as_dict_atom(Config,schema,'miter-open-growth-environment-v1'),
    Config.human_editable==true,Config.enabled==true,
    as_dict_atom(Config,expected_runtime_user,claritymiter),
    as_dict_atom(Config,workspace_relative,workspace),
    as_dict_atom(Config,informational_network,'open-http-https'),
    as_dict_atom(Config,terminal,'typed-direct-argv-broker'),
    as_dict_atom(Config,credential_access,'named-reference-only'),
    as_dict_atom(Config,reversible_writes,'versioned-owned-workspace'),
    is_dict(Config.workshop),
    as_mattermost_exact_keys(Config.workshop,
      [broker,cpus,image,memory_megabytes,network,operator_notes,pids_limit,platform,
       root_filesystem,runner]),
    Config.workshop.runner=="docker-isolated-v1",
    Config.workshop.image==
      "python:3.11-slim@sha256:a3ab0b966bc4e91546a033e22093cb840908979487a9fc0e6e38295747e49ac0",
    Config.workshop.platform=="linux/arm64",
    Config.workshop.network=="none",
    Config.workshop.root_filesystem=="read-only",
    Config.workshop.memory_megabytes=:=128,Config.workshop.cpus=:=0.5,
    Config.workshop.pids_limit=:=32,
    is_dict(Config.workshop.broker),
    as_mattermost_exact_keys(Config.workshop.broker,
      [credential_reference,maximum_request_bytes,origin,schema]),
    Config.workshop.broker.schema=="miter-workshop-broker-client-v1",
    Config.workshop.broker.origin=="http://127.0.0.1:17891",
    Config.workshop.broker.maximum_request_bytes=:=4194304,
    is_dict(Config.workshop.broker.credential_reference),
    Config.workshop.broker.credential_reference.source=="private-runtime-file",
    string(Config.workshop.broker.credential_reference.path),
    is_list(Config.workshop.operator_notes),
    maplist(string,Config.workshop.operator_notes),
    Config.human_authority_boundaries==[
      "bind-other-principal","cross-user-private-material",
      "use-named-credential","spend-or-transfer-value",
      "external-publication-or-message",
      "difficult-to-reverse-external-commitment"],
    is_list(Config.operator_notes),maplist(string,Config.operator_notes).

as_evaluation_grants_inactive_valid(Document) :-
    is_dict(Document),
    as_mattermost_exact_keys(Document,
      [administrator_attestation,authority,authority_separation,bounds,grants,
       haley_disclosure,required_affirmations,schema,standing]),
    as_dict_atom(Document,schema,'miter-evaluation-grants-v1'),
    as_dict_atom(Document,standing,'inactive-awaiting-authorized-activation'),
    as_dict_atom(Document,authority,'AMA-1.2-ratified-by-berton'),
    get_dict(grants,Document,[]),
    Document.bounds=_{first_segment_hours:72,maximum_hours:168,
      admitted_events:1000,outbound_posts:500,outbound_per_hour:60,
      remote_calls:50},
    Document.required_affirmations=_{
      berton_c:"affirmed-by-ratification-and-current-system-administrator-attestation",
      haley:"consent-attested-by-berton-current-system-administrator"},
    Document.administrator_attestation=_{
      activation_authority:"system-administrator-and-evaluation-owner",
      attested_participant:"haley",attestor:"berton_c",
      scope:"AMA-1.2-only",
      standing:"ratified-participant-consent-attestation"},
    is_dict(Document.haley_disclosure),
    as_mattermost_exact_keys(Document.haley_disclosure,
      [exact_text,required_author,required_surface,standing]),
    string(Document.haley_disclosure.exact_text),
    string_length(Document.haley_disclosure.exact_text,DisclosureLength),
    DisclosureLength>=200,DisclosureLength=<1200,
    Document.haley_disclosure.required_author=="haley",
    Document.haley_disclosure.required_surface==
      "exact-berton-haley-miter-group",
    Document.haley_disclosure.standing==
      "recommended-direct-confirmation-not-activation-precondition",
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
      direct_confirmation_standing:
        "recommended-direct-confirmation-not-activation-precondition",
      authorized_activation_paths:[
        "ratified-administrator-attestation",
        "exact-Haley-authored-Mattermost-disclosure"],
      next:"Activate with the ratified administrator attestation now; Haley may later add the exact direct confirmation in the bound three-person Mattermost group."}.

as_activate_evaluation(Root,PostId0,Reply) :-
    ( catch(as_activate_evaluation_checked(Root,PostId0,Reply0),_,fail) ->
        Reply=Reply0
    ; Reply=_{schema:"miter-assistant-operator-result-v1",
        status:'evaluation-activation-held',
        reason:"exact-affirmation-or-complete-preflight-not-established"} ), !.

as_activate_evaluation_admin(Root,Reply) :-
    ( catch(as_activate_evaluation_admin_checked(Root,Reply0),_,fail) ->
        Reply=Reply0
    ; Reply=_{schema:"miter-assistant-operator-result-v1",
        status:'evaluation-activation-held',
        reason:"ratified-administrator-attestation-or-complete-preflight-not-established"} ), !.

as_continue_evaluation_admin(Root,Reply) :-
    ( catch(as_continue_evaluation_admin_checked(Root,Reply0),_,fail) ->
        Reply=Reply0
    ; Reply=_{schema:"miter-assistant-operator-result-v1",
        status:'evaluation-continuation-held',
        reason:"current-ratified-segment-or-complete-preflight-not-established"} ), !.

as_continue_evaluation_admin_checked(Root,Reply) :-
    as_root(Root,_),as_verify_lkg(Root,verified),
    as_evaluation_continuation_bound(Root,Document,Grant,Config,Binding),
    get_time(Now),
    ( Now>Grant.maximum_expires_at_epoch ->
        Reply=_{schema:"miter-assistant-operator-result-v1",
          status:'evaluation-continuation-held',grant_id:Grant.id,
          reason:"ratified-maximum-expired",
          maximum_expires_at_epoch:Grant.maximum_expires_at_epoch}
    ; Now=<Grant.segment_expires_at_epoch ->
        Reply=_{schema:"miter-assistant-operator-result-v1",
          status:'evaluation-segment-already-current',grant_id:Grant.id,
          segment_expires_at_epoch:Grant.segment_expires_at_epoch,
          maximum_expires_at_epoch:Grant.maximum_expires_at_epoch}
    ; as_evaluation_continuation_preflight(Root,Config,Binding),
      as_write_evaluation_continuation(Root,Document,Grant,Config,Now,Reply) ).

as_evaluation_continuation_bound(Root,Document,Grant,Config,Binding) :-
    directory_file_path(Root,'evaluation-grants.json',GrantPath),
    miter_store_read_json(GrantPath,Document),is_dict(Document),
    Document.schema=="miter-evaluation-grants-v1",
    Document.standing=="active-explicit-grants",
    Document.authority=="AMA-1.2-ratified-by-berton",
    Document.authority_separation==
      "grant-bounds-reach-not-meaning-or-movement",
    get_dict(grants,Document,[Grant]),is_dict(Grant),
    Grant.capabilities==["mattermost-new-event","mattermost-create-post",
      "shared-continuity","scoped-semantic-memory",
      "authorized-model-participation"],
    Grant.limits==_{first_segment_hours:72,maximum_hours:168,
      admitted_events:1000,outbound_posts:500,outbound_per_hour:60,
      remote_calls:50},
    Grant.authority_separation==
      "grant-bounds-reach-not-meaning-or-movement",
    as_sha256(Grant.activation_witness_sha256,_),
    as_evaluation_continuation_admin_witness(Grant.disclosure_witness),
    Grant.segment_expires_at_epoch=<Grant.maximum_expires_at_epoch,
    Maximum is Grant.activated_at_epoch+168*3600,
    Grant.maximum_expires_at_epoch=:=Maximum,
    as_mattermost_config(Root,Config),Config.enabled==true,
    as_mattermost_binding_local(Root,Config,Binding),
    as_evaluation_grant_bound(Root,Config,Binding,'ama-1.2',BoundGrant),
    BoundGrant==Grant.

as_evaluation_continuation_admin_witness(Witness) :-
    is_dict(Witness),
    Witness.witness_kind=="administrator-attested-participant-consent",
    Witness.attestor_username=="berton_c",
    Witness.participant_username=="haley",
    Witness.authority=="system-administrator-and-evaluation-owner",
    Witness.scope=="AMA-1.2-only",
    Witness.standing=="ratified-consent-attestation-current",
    number(Witness.attested_at_epoch),
    as_sha256(Witness.content_sha256,_).

as_evaluation_continuation_preflight(Root,Config,Binding) :-
    \+ (as_process_state(Root,State,_),State\==dead),
    as_mattermost_binding_live(Root,Config,Binding),
    as_secure_runtime_tree(Root),
    as_evaluation_private_modes(Root),
    as_evaluation_no_unresolved_effect(Root),
    as_evaluation_memory_health(Root),
    as_evaluation_model_health(Root).

as_write_evaluation_continuation(Root,Document,Grant,Config,Now,Reply) :-
    RequestedExpiry is Now+72*3600,
    SegmentExpiry is min(RequestedExpiry,Grant.maximum_expires_at_epoch),
    SegmentExpiry>Now,
    as_evaluation_model_grants(Root,Config,Grant.activated_at_epoch,
      SegmentExpiry,ModelGrants),
    directory_file_path(Root,'model-grants.json',ModelGrantPath),
    as_write_json_durable(ModelGrantPath,ModelGrants),
    put_dict(segment_expires_at_epoch,Grant,SegmentExpiry,ContinuedGrant),
    as_evaluation_segment_history(Document,Grant,History0),
    append(History0,[_{continued_at_epoch:Now,
      prior_segment_expires_at_epoch:Grant.segment_expires_at_epoch,
      segment_expires_at_epoch:SegmentExpiry,
      maximum_expires_at_epoch:Grant.maximum_expires_at_epoch,
      authority:"explicit-system-administrator-continuation-within-ratified-maximum"}],
      History),
    put_dict(_{grants:[ContinuedGrant],segment_history:History},Document,Continued),
    directory_file_path(Root,'evaluation-grants.json',GrantPath),
    as_write_json_durable(GrantPath,Continued),
    as_write_control(Root,continue,'evaluation-segment-continuation-admin'),
    as_secure_runtime_tree(Root),
    Reply=_{schema:"miter-assistant-operator-result-v1",
      status:'evaluation-segment-continued',grant_id:Grant.id,
      continued_at_epoch:Now,
      prior_segment_expires_at_epoch:Grant.segment_expires_at_epoch,
      segment_expires_at_epoch:SegmentExpiry,
      maximum_expires_at_epoch:Grant.maximum_expires_at_epoch,
      authority_boundary:
        "reach-time-only-no-meaning-movement-memory-or-effect-choice-authority"}.

as_evaluation_segment_history(Document,Grant,History) :-
    ( get_dict(segment_history,Document,Existing) ->
        is_list(Existing),History=Existing
    ; History=[_{activated_at_epoch:Grant.activated_at_epoch,
        segment_expires_at_epoch:Grant.segment_expires_at_epoch,
        maximum_expires_at_epoch:Grant.maximum_expires_at_epoch,
        authority:"original-ratified-activation"}] ).

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

as_activate_evaluation_admin_checked(Root,Reply) :-
    as_root(Root,_),as_verify_lkg(Root,verified),
    ( as_evaluation_already_active_admin(Root,Grant) ->
        Reply=_{schema:"miter-assistant-operator-result-v1",
          status:'evaluation-already-active',grant_id:Grant.id,
          segment_expires_at_epoch:Grant.segment_expires_at_epoch}
    ; as_evaluation_activation_preflight_admin(Root,Inactive,Config,Binding,
        Attestation,BindingHash),
      as_write_evaluation_activation(Root,Inactive,Config,Binding,Attestation,
        BindingHash,Reply) ).

as_evaluation_already_active(Root,PostId,Grant) :-
    directory_file_path(Root,'evaluation-grants.json',Path),
    miter_store_read_json(Path,Document),is_dict(Document),
    Document.schema=="miter-evaluation-grants-v1",
    Document.standing=="active-explicit-grants",
    get_dict(grants,Document,[Grant]),
    as_mattermost_id(Grant.disclosure_witness.post_id,PostId).

as_evaluation_already_active_admin(Root,Grant) :-
    directory_file_path(Root,'evaluation-grants.json',Path),
    miter_store_read_json(Path,Document),is_dict(Document),
    Document.schema=="miter-evaluation-grants-v1",
    Document.standing=="active-explicit-grants",
    get_dict(grants,Document,[Grant]),
    Grant.disclosure_witness.witness_kind==
      "administrator-attested-participant-consent".

as_evaluation_activation_preflight(Root,PostId,Inactive,Config,Binding,
    Affirmation,BindingHash) :-
    \+ (as_process_state(Root,State,_),State\==dead),
    directory_file_path(Root,'evaluation-grants.json',GrantPath),
    miter_store_read_json(GrantPath,Inactive),
    as_evaluation_grants_inactive_valid(Inactive),
    as_mattermost_config(Root,Config),Config.enabled==true,
    as_mattermost_resolve_live(Root,Config,Binding),
    as_mattermost_binding_sha256(Root,BindingHash),
    as_evaluation_affirmation(Root,Config,Binding,Inactive,PostId,Affirmation),
    as_secure_runtime_tree(Root),
    as_evaluation_private_modes(Root),
    as_evaluation_no_unresolved_effect(Root),
    as_evaluation_memory_health(Root),
    as_evaluation_model_health(Root),
    as_write_control(Root,continue,'evaluation-activation-preflight'),
    as_evaluation_control_allows(Root).

as_evaluation_activation_preflight_admin(Root,Inactive,Config,Binding,
    Attestation,BindingHash) :-
    \+ (as_process_state(Root,State,_),State\==dead),
    directory_file_path(Root,'evaluation-grants.json',GrantPath),
    miter_store_read_json(GrantPath,Inactive),
    as_evaluation_grants_inactive_valid(Inactive),
    as_mattermost_config(Root,Config),Config.enabled==true,
    as_mattermost_resolve_live(Root,Config,Binding),
    as_mattermost_binding_sha256(Root,BindingHash),
    as_evaluation_administrator_attestation(Binding,Inactive,Attestation),
    as_secure_runtime_tree(Root),
    as_evaluation_private_modes(Root),
    as_evaluation_no_unresolved_effect(Root),
    as_evaluation_memory_health(Root),
    as_evaluation_model_health(Root),
    as_write_control(Root,continue,'evaluation-activation-admin-preflight'),
    as_evaluation_control_allows(Root).

as_evaluation_administrator_attestation(Binding,Inactive,Attestation) :-
    Admin=Inactive.administrator_attestation,
    Admin.attestor=="berton_c",
    Admin.attested_participant=="haley",
    Admin.standing=="ratified-participant-consent-attestation",
    Admin.activation_authority=="system-administrator-and-evaluation-owner",
    Admin.scope=="AMA-1.2-only",
    member(Berton,Binding.principals),Berton.username=="berton_c",
    member(Haley,Binding.principals),Haley.username=="haley",
    term_string(Admin,AttestationText,[quoted(true),ignore_ops(true)]),
    crypto_data_hash(AttestationText,Hash,[algorithm(sha256),encoding(utf8)]),
    atom_string(HashString,Hash),get_time(Now),
    Attestation=_{witness_kind:"administrator-attested-participant-consent",
      attestor_username:"berton_c",participant_username:"haley",
      authority:"system-administrator-and-evaluation-owner",
      scope:"AMA-1.2-only",attested_at_epoch:Now,
      content_sha256:HashString,
      standing:"ratified-consent-attestation-current"}.

as_evaluation_affirmation(Root,Config,Binding,Inactive,PostId,Affirmation) :-
    as_mattermost_token(Root,Config,Token),
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
    Affirmation=_{witness_kind:"exact-Haley-authored-Mattermost-disclosure",
      post_id:Post.id,event_version:Version,
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
    directory_file_path(Root,'model-direction.json',Path),
    miter_store_read_json(Path,Direction),
    as_dict_atom(Direction,standing,'active-human-direction'),
    as_dict_atom(Direction,resource_id,ResourceId),
    as_model_profile(Root,ResourceId,Profile),
    as_model_resource_health(Root,Profile,_).

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
    as_evaluation_model_grants(Root,Config,Now,SegmentExpiry,ModelGrants),
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
    as_evaluation_active_affirmations(Affirmation,RequiredAffirmations),
    Active=_{schema:"miter-evaluation-grants-v1",
      standing:"active-explicit-grants",authority:Inactive.authority,
      authority_separation:Inactive.authority_separation,
      haley_disclosure:Inactive.haley_disclosure,
      administrator_attestation:Inactive.administrator_attestation,
      required_affirmations:RequiredAffirmations,
      bounds:Inactive.bounds,grants:[Grant]},
    as_write_json_durable(GrantPath,Active),
    Reply0=_{schema:"miter-assistant-operator-result-v1",
      status:'evaluation-activated',grant_id:"ama-1.2",
      activated_at_epoch:Now,segment_expires_at_epoch:SegmentExpiry,
      maximum_expires_at_epoch:MaximumExpiry,
      consent_witness_kind:Affirmation.witness_kind,
      activation_witness_sha256:WitnessHashString},
    as_evaluation_activation_reply(Affirmation,Reply0,Reply).

as_evaluation_active_affirmations(Affirmation,
    _{berton_c:"affirmed-by-ratification-and-current-system-administrator-attestation",
      haley:"consent-attested-by-berton-current-system-administrator"}) :-
    Affirmation.witness_kind=="administrator-attested-participant-consent",!.
as_evaluation_active_affirmations(_,
    _{berton_c:"affirmed-by-ratification",
      haley:"affirmed-by-exact-mattermost-disclosure"}).

as_evaluation_activation_reply(Affirmation,Reply0,Reply) :-
    ( get_dict(post_id,Affirmation,PostId) ->
        put_dict(disclosure_post_id,Reply0,PostId,Reply)
    ; put_dict(administrator_attestor,Reply0,
        Affirmation.attestor_username,Reply) ).

as_evaluation_model_grants(Root,Config,Now,Expiry,Document) :-
    directory_file_path(Root,'model-resources.json',RegistryPath),
    miter_store_read_json(RegistryPath,Registry),
    get_dict(resources,Registry,Resources),is_list(Resources),
    findall(Grant,
      (member(Principal,Config.authorized_humans),
       member(Profile,Resources),is_dict(Profile),get_dict(enabled,Profile,true),
       as_model_profile_exact(Profile),
       get_dict(id,Profile,ResourceString),
       get_dict(limits,Profile,Limits),
       get_dict(deadline_seconds,Limits,Deadline),
       format(string(Id),'ama-1.2-~s-~s',[ResourceString,Principal]),
       ( get_dict(kind,Profile,"remote") ->
           MaxCalls=50,RemoteContext=true,SecurityExcluded=true
       ; MaxCalls=1000,RemoteContext=false,SecurityExcluded=true ),
       Grant=_{id:Id,standing:"active",resource_id:ResourceString,
         purposes:["semantic-reading","language-rendering"],
         scope:_{principal:Principal,audience:Config.scope.audience,
           project:Config.scope.project},max_calls:MaxCalls,
         max_output_tokens:2048,
         deadline_seconds:Deadline,remote_context_authorized:RemoteContext,
         secret_and_security_risk_material_excluded:SecurityExcluded,
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
         process_create(SwiplLd,
          ['-shared','-O2','-o','../libmiter_store_posix.dylib','store_posix.c'],
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

as_supervised_run(Root,Reply) :-
    as_root(Root,_),as_verify_lkg(Root,verified),
    ( as_process_state(Root,State,Pid),State\==dead ->
        Reply=_{schema:"miter-assistant-operator-result-v1",
          status:'supervised-clean-exit',reason:"service-already-running",pid:Pid}
    ; as_mattermost_prepare(Root,_MattermostStanding),
      as_write_control(Root,continue,'cli-supervisor'),
      as_supervised_cycle(Root,Reply) ), !.

as_supervised_cycle(Root,Reply) :-
    as_supervised_cycle(Root,0,Reply).

% A failure window alone cannot contain a child that consumes substantial CPU
% or memory for long enough that the previous failure ages out before the next
% one.  Retain that persisted window as cross-invocation evidence, while also
% bounding consecutive failures owned by this exact supervisor process.  This
% counter observes only process outcomes; it has no contact, Soul, model,
% movement, retry-meaning, or effect authority.
as_supervised_cycle(Root,Consecutive0,Reply) :-
    ( as_supervised_control_finish(Root,0,Reply) -> true
    ; as_crash_admit(Root,CrashStanding),
      ( CrashStanding==blocked ->
        Reply=_{schema:"miter-assistant-operator-result-v1",
          status:'crash-loop-contained'}
      ; miter_workshop_cleanup_orphans(Root,_WorkshopRecovery),
        as_spawn_foreground(Root,ChildPid,ProcessStatus),
        as_supervised_outcome(Root,ChildPid,ProcessStatus,Outcome),
        ( get_dict(control,Outcome,_) -> Reply=Outcome
        ; as_supervised_control_finish(Root,ChildPid,Reply) -> true
        ; as_supervised_crash_decision(Outcome,Consecutive0,Decision),
          ( Decision=restart(Consecutive) ->
              sleep(1),as_supervised_cycle(Root,Consecutive,Reply)
          ; Decision=finish(Reply) ) ) ) ).

as_supervised_shutdown_control(Root,Command) :-
    as_pending_control(Root,Command),memberchk(Command,[stop,panic]).

% An operator stop or panic is authority to end the process family, not a
% semantic diagnosis of the in-flight contact.  The leased carrier remains
% durable.  Checking this boundary before spawn and before restart prevents a
% watchdog replacement from outrunning an already-recorded operator command.
as_supervised_control_finish(Root,Pid,Reply) :-
    as_supervised_shutdown_control(Root,Command),
    as_supervised_control_reply(Root,Pid,Command,Reply).

as_supervised_control_reply(Root,Pid,Command,Reply) :-
    ( Pid>1 ->
        ( Command==panic -> Kind=panic ; Kind='clean-stop' ),
        as_write_exit(Root,Pid,Kind)
    ; true ),
    atom_string(Command,CommandString),
    Reply=_{schema:"miter-assistant-operator-result-v1",
      status:'supervised-clean-exit',pid:Pid,
      reason:"operator-control-no-restart",control:CommandString}.

as_supervised_crash_decision(Outcome,Consecutive0,Decision) :-
    ( Outcome.status=='supervised-crash' ->
        Consecutive is Consecutive0+1,
        ( Consecutive>=3 ->
            put_dict(_{status:'crash-loop-contained',
              crash_count_in_supervisor_run:Consecutive},Outcome,Reply),
            Decision=finish(Reply)
        ; Decision=restart(Consecutive) )
    ; Decision=finish(Outcome) ).

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
         % The child may spend materially longer than the short spawn grace
         % restoring the one native Soul/continuity organization before it can
         % record assistant-started-v3.  Publish only process-bound mechanical
         % liveness here.  Readiness still belongs to the native start record;
         % this lease cannot admit contact, checkpoint state, or certify a
         % release.
         as_heartbeat(Root,'assistant-starting-v3',StartedAt),
         as_supervise_foreground(Root,Pid,StartedAt,ProcessStatus)),
        close(Err)),close(Out)).

% The CLI-started supervisor polls only process and lease state. It cannot
% inspect contact, Soul organization, model output or movement. A stale lease
% causes mechanical termination; the same supervisor may then restore the
% verified LKG within the bounded crash window.
as_supervise_foreground(Root,Pid,StartedAt,ProcessStatus) :-
    as_config(Root,supervision,Supervision),
    as_supervise_foreground_loop(Root,Pid,StartedAt,Supervision,ProcessStatus).

as_supervise_foreground_loop(Root,Pid,StartedAt,Supervision,ProcessStatus) :-
    Poll=Supervision.poll_seconds,
    % SWI-Prolog on Unix supports process_wait/3 polling only at timeout(0).
    % The bounded sleep belongs to this non-cognitive liveness observer.
    ( as_supervised_shutdown_control(Root,Command) ->
        as_control_terminate(Pid,Supervision,TerminationStanding),
        ProcessStatus=operator_control(Command,TerminationStanding)
    ; process_wait(Pid,Observed,[timeout(0)]),
      ( Observed\==timeout -> ProcessStatus=Observed
      ; get_time(Now),
        ( as_supervisor_lease_active(Root,Pid,StartedAt,Now,Supervision) ->
            sleep(Poll),
            as_supervise_foreground_loop(Root,Pid,StartedAt,Supervision,
              ProcessStatus)
        ; as_watchdog_terminate(Root,Pid,StartedAt,Now,Supervision,
            TerminationStanding),
          ProcessStatus=watchdog_stale_heartbeat(TerminationStanding) ) ) ).

as_control_terminate(Pid,Supervision,Standing) :-
    catch(process_kill(Pid,term),_,true),
    Grace=Supervision.termination_grace_seconds,
    get_time(TermStarted),TermDeadline is TermStarted+Grace,
    as_wait_process_exit_until(Pid,TermDeadline,TermStatus),
    ( TermStatus\==timeout -> Standing=terminated(TermStatus)
    ; catch(process_kill(Pid,kill),_,true),
      process_wait(Pid,KillStatus),Standing=killed(KillStatus) ).

as_supervisor_lease_active(_Root,_Pid,StartedAt,Now,Supervision) :-
    Now-StartedAt=<Supervision.startup_grace_seconds,!.
as_supervisor_lease_active(Root,Pid,StartedAt,Now,Supervision) :-
    as_supervisor_heartbeat(Root,Pid,StartedAt,Heartbeat),
    ( Now=<Heartbeat.valid_until_epoch
    ; memberchk(Heartbeat.state,["assistant-stopped","assistant-panicked"]),
      Now-Heartbeat.observed_at_epoch=<Supervision.termination_grace_seconds ).

as_supervisor_heartbeat(Root,Pid,StartedAt,Heartbeat) :-
    directory_file_path(Root,'heartbeat.json',Path),exists_file(Path),
    catch(miter_store_read_json(Path,Heartbeat),_,fail),is_dict(Heartbeat),
    Heartbeat.schema=="miter-assistant-heartbeat-v2",
    get_dict(pid,Heartbeat,Pid),
    get_dict(observed_at_epoch,Heartbeat,Observed),number(Observed),
    Observed>=StartedAt,
    get_dict(valid_until_epoch,Heartbeat,ValidUntil),number(ValidUntil),
    ValidUntil>=Observed,
    as_dict_atom(Heartbeat,state,_),get_dict(run_id,Heartbeat,RunId0),
    as_run_id(RunId0,RunId),
    as_pid_run_id(Root,Pid,RunId).

as_pid_run_id(Root,Pid,RunId) :-
    directory_file_path(Root,'pid.json',Path),
    miter_store_read_json(Path,Dict),get_dict(pid,Dict,Pid),
    get_dict(run_id,Dict,RunId0),as_run_id(RunId0,RunId).

as_watchdog_terminate(Root,Pid,StartedAt,ObservedAt,Supervision,Standing) :-
    as_watchdog_heartbeat_summary(Root,Heartbeat),
    directory_file_path(Root,'service/watchdog-last.json',Path),
    as_write_json_durable(Path,_{schema:"miter-watchdog-event-v1",
      standing:"stale-heartbeat-termination",pid:Pid,
      process_started_at_epoch:StartedAt,observed_at_epoch:ObservedAt,
      heartbeat:Heartbeat,
      boundary:"mechanical-liveness-only-no-semantic-diagnosis"}),
    catch(process_kill(Pid,term),_,true),
    Grace=Supervision.termination_grace_seconds,
    get_time(TermStarted),TermDeadline is TermStarted+Grace,
    as_wait_process_exit_until(Pid,TermDeadline,TermStatus),
    ( TermStatus\==timeout -> Standing=terminated(TermStatus)
    ; catch(process_kill(Pid,kill),_,true),
      process_wait(Pid,KillStatus),Standing=killed(KillStatus) ).

as_wait_process_exit_until(Pid,Deadline,Status) :-
    process_wait(Pid,Observed,[timeout(0)]),
    ( Observed\==timeout -> Status=Observed
    ; get_time(Now),
      ( Now>=Deadline -> Status=timeout
      ; sleep(0.05),as_wait_process_exit_until(Pid,Deadline,Status) ) ).

as_watchdog_heartbeat_summary(Root,Heartbeat) :-
    directory_file_path(Root,'heartbeat.json',Path),
    ( exists_file(Path),catch(miter_store_read_json(Path,Dict),_,fail),
      is_dict(Dict) -> Heartbeat=Dict ; Heartbeat=null ).

as_supervised_outcome(Root,Pid,operator_control(Command,_),Reply) :-
    as_supervised_control_reply(Root,Pid,Command,Reply),!.
as_supervised_outcome(Root,Pid,_ProcessStatus,Reply) :-
    as_supervised_control_finish(Root,Pid,Reply),!.
as_supervised_outcome(Root,Pid,_ProcessStatus,Reply) :-
    as_clean_exit(Root,Pid),!,
    Reply=_{schema:"miter-assistant-operator-result-v1",
      status:'supervised-clean-exit',pid:Pid}.
as_supervised_outcome(Root,Pid,ProcessStatus,Reply) :-
    as_note_crash(Root,Pid,Count),
    ( Count>=3 -> Status='crash-loop-contained'
    ; Status='supervised-crash' ),
    term_string(ProcessStatus,ProcessStanding,[quoted(true),ignore_ops(true)]),
    as_supervised_failure_kind(ProcessStatus,FailureKind),
    Reply=_{schema:"miter-assistant-operator-result-v1",status:Status,pid:Pid,
      crash_count_in_window:Count,process_standing:ProcessStanding,
      failure_kind:FailureKind}.

as_supervised_failure_kind(watchdog_stale_heartbeat(_),
    "stale-heartbeat-watchdog") :- !.
as_supervised_failure_kind(_,"process-exit-without-clean-boundary").

as_start(Root, Reply) :-
    as_root(Root,_), as_verify_lkg(Root,Lkg),
    ( Lkg \== verified ->
        Reply=_{schema:"miter-assistant-operator-result-v1",status:'lkg-mismatch'}
    ; as_process_state(Root,alive,Pid) ->
        Reply=_{schema:"miter-assistant-operator-result-v1",status:running,pid:Pid,
          semantic_health:"not-claimed"}
    ; as_supervisor_state(Root,alive,SupervisorPid) ->
        Reply=_{schema:"miter-assistant-operator-result-v1",status:starting,pid:0,
          supervisor_pid:SupervisorPid,semantic_health:"readiness-pending"}
    ; as_process_state(Root,unconfirmed,Pid) ->
        Reply=_{schema:"miter-assistant-operator-result-v1",
          status:'existing-process-unconfirmed',pid:Pid,
          semantic_health:"not-claimed"}
    ; as_mattermost_prepare(Root,MattermostStanding),
      as_crash_admit(Root,CrashStanding),
      ( CrashStanding == blocked ->
          Reply=_{schema:"miter-assistant-operator-result-v1",
            status:'crash-loop-contained',semantic_health:"not-claimed",
            mattermost_preflight:MattermostStanding}
      ; as_write_control(Root,continue,start),
        as_spawn_supervisor(Root,SupervisorPid,StartedAt),
        ( as_wait_started(Root,SupervisorPid,StartedAt,5),
          as_process_state(Root,alive,ChildPid) ->
            Reply=_{schema:"miter-assistant-operator-result-v1",status:started,
              pid:ChildPid,supervisor_pid:SupervisorPid,
              semantic_health:"not-claimed",mattermost_preflight:MattermostStanding}
        ; as_supervisor_state(Root,alive,SupervisorPid) ->
            Reply=_{schema:"miter-assistant-operator-result-v1",status:starting,pid:0,
              supervisor_pid:SupervisorPid,semantic_health:"readiness-pending",
              mattermost_preflight:MattermostStanding}
        ; Reply=_{schema:"miter-assistant-operator-result-v1",
            status:'start-failed',pid:0,supervisor_pid:SupervisorPid,
            mattermost_preflight:MattermostStanding} ) ) ).

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
    as_heartbeat_schema(Dict),
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

as_spawn_supervisor(Root,Pid,StartedAt) :-
    as_lkg_source_root(Root,SourceRoot),
    directory_file_path(SourceRoot,
      'effect_membranes/assistant_operator.pl',Operator),
    uuid(RunId),
    atomic_list_concat(['logs/supervisor-',RunId,'.stdout'],StdoutRelative),
    atomic_list_concat(['logs/supervisor-',RunId,'.stderr'],StderrRelative),
    directory_file_path(Root,StdoutRelative,Stdout),
    directory_file_path(Root,StderrRelative,Stderr),
    setup_call_cleanup(open(Stdout,write,Out,[encoding(utf8)]),
      setup_call_cleanup(open(Stderr,write,Err,[encoding(utf8)]),
        ( current_prolog_flag(executable,Swipl),
          process_create(Swipl,
            ['-q','-f',none,'-s',Operator,'--','run-supervised',
             '--runtime-root',Root],
            [cwd(SourceRoot),stdin(null),stdout(stream(Out)),stderr(stream(Err)),
             detached(true),process(Pid)]) ),
        close(Err)),close(Out)),
    get_time(StartedAt),
    directory_file_path(Root,'supervisor.json',Path),
    as_write_json_durable(Path,_{schema:"miter-assistant-supervisor-v1",
      pid:Pid,run_id:RunId,started_at_epoch:StartedAt,
      stdout:StdoutRelative,stderr:StderrRelative,
      authority_boundary:"mechanical-liveness-only"}).

as_wait_started(Root, Pid, StartedAt, Seconds) :-
    End is StartedAt+Seconds,as_wait_started_until(Root,Pid,StartedAt,End).
as_wait_started_until(Root,Pid,StartedAt,End) :-
    ( directory_file_path(Root,'heartbeat.json',Heartbeat),exists_file(Heartbeat),
      miter_store_read_json(Heartbeat,Dict),as_heartbeat_schema(Dict),
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

as_supervisor_state(Root,State,Pid) :-
    directory_file_path(Root,'supervisor.json',Path),exists_file(Path),
    miter_store_read_json(Path,Dict),
    as_dict_atom(Dict,schema,'miter-assistant-supervisor-v1'),
    get_dict(pid,Dict,Pid),integer(Pid),Pid>1,
    as_pid_probe(Pid,State).

% Some supervised or sandboxed hosts permit the service to continue while
% denying a later process signal probe. A fresh heartbeat recorded after this
% exact PID's start is a second, run-bound liveness witness. It never drives
% cognition; it only prevents the operator from reporting a live organism as
% stopped when kill(0) is unavailable.
as_heartbeat_active(Root, Pid) :-
    as_pid_started(Root,Pid,Started),
    directory_file_path(Root,'heartbeat.json',Path),exists_file(Path),
    catch(miter_store_read_json(Path,Dict),_,fail),
    as_heartbeat_schema(Dict),
    as_dict_atom(Dict,state,State),
    \+ memberchk(State,['assistant-stopped','assistant-panicked']),
    get_dict(observed_at_epoch,Dict,Observed),number(Observed),Observed>=Started,
    get_time(Now),Now>=Observed,
    as_heartbeat_active_until(Root,Pid,Dict,Observed,Until),
    Now=<Until.

as_heartbeat_schema(Dict) :-
    as_dict_atom(Dict,schema,Schema),
    memberchk(Schema,['miter-assistant-heartbeat-v1',
      'miter-assistant-heartbeat-v2']).

as_heartbeat_active_until(Root,Pid,Dict,_Observed,Until) :-
    as_dict_atom(Dict,schema,'miter-assistant-heartbeat-v2'),!,
    get_dict(pid,Dict,Pid),get_dict(run_id,Dict,RunId0),as_run_id(RunId0,RunId),
    as_pid_run_id(Root,Pid,RunId),
    get_dict(valid_until_epoch,Dict,Until),number(Until).
as_heartbeat_active_until(Root,_Pid,_Dict,Observed,Until) :-
    as_config(Root,idle_cap_seconds,Cap),Freshness is max(5,Cap*4+1),
    Until is Observed+Freshness.

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
        ( catch(as_model_selection(Root,ModelSelection0),_,fail) ->
            ModelSelection=ModelSelection0
        ; ModelSelection=_{standing:"unavailable"} ),
        ( as_supervisor_state(Root,SupervisorState0,SupervisorPid) ->
            Supervisor=_{standing:SupervisorState0,pid:SupervisorPid,
              authority_boundary:"mechanical-liveness-only"}
        ; Supervisor=_{standing:"absent"} ),
        as_operator_source_status(Root,OperatorSource),
        miter_workshop_broker_status(Root,WorkshopBroker),
        as_config(Root,supervision,Supervision),
        Reply=_{schema:"miter-assistant-operator-result-v1",status:State,pid:Pid,
          lkg:Lkg,heartbeat:Heartbeat,evaluation:Evaluation,
          supervisor:Supervisor,model_selection:ModelSelection,
          workshop_broker:WorkshopBroker,
          operator_source:OperatorSource,supervision:Supervision,
          semantic_health:"not-claimed"}
    ; Reply=_{schema:"miter-assistant-operator-result-v1",status:'not-bootstrapped'} ).

as_status_heartbeat(Root, Heartbeat) :-
    directory_file_path(Root,'heartbeat.json',Path),
    (exists_file(Path)->miter_store_read_json(Path,Heartbeat);Heartbeat=null).

as_operator_source_status(Root,Standing) :-
    as_operator_repo_root(OperatorRoot),
    as_lkg_source_root(Root,LkgSourceRoot),
    directory_file_path(OperatorRoot,
      'effect_membranes/assistant_operator.pl',OperatorFile),
    Standing=_{profile:"cleanroom-assistant-operator-v1",
      loaded_from:OperatorFile,runtime_lkg_source_root:LkgSourceRoot}.

as_evaluation_status(Root,Standing) :-
    directory_file_path(Root,'evaluation-grants.json',Path),
    ( catch(miter_store_read_json(Path,Document),_,fail),is_dict(Document),
      Document.schema=="miter-evaluation-grants-v1",
      Document.standing=="active-explicit-grants",
      get_dict(grants,Document,[Grant]),is_dict(Grant) ->
        get_time(Now),
        ( Now>Grant.maximum_expires_at_epoch -> State="maximum-expired"
        ; Now>Grant.segment_expires_at_epoch -> State="paused-segment-expired"
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
    ; Standing=_{standing:"inactive-awaiting-authorized-activation"} ).

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
        (as_wait_runtime_family_stopped(Root,8)->
          Status=stopped,as_write_exit(Root,Pid,'clean-stop')
        ;Status='stop-pending')
    ; as_supervisor_state(Root,SupervisorState,SupervisorPid),
        SupervisorState\==dead ->
        Pid=SupervisorPid,as_write_control(Root,stop,operator),
        (as_wait_runtime_family_stopped(Root,8)->Status=stopped
        ;Status='stop-pending')
    ; Pid=0,Status=stopped ),
    as_verify_lkg(Root,Lkg),
    Reply=_{schema:"miter-assistant-operator-result-v1",status:Status,pid:Pid,
      lkg:Lkg}.

as_runtime_family_stopped(Root) :-
    \+ (as_process_state(Root,ChildState,_),ChildState\==dead),
    \+ (as_supervisor_state(Root,SupervisorState,_),SupervisorState\==dead).

as_wait_runtime_family_stopped(Root,Seconds) :-
    get_time(Start),End is Start+Seconds,
    as_wait_runtime_family_stopped_until(Root,End).
as_wait_runtime_family_stopped_until(Root,_) :-
    as_runtime_family_stopped(Root),!.
as_wait_runtime_family_stopped_until(Root,End) :-
    get_time(Now),Now<End,sleep(0.05),
    as_wait_runtime_family_stopped_until(Root,End).

as_panic(Root, Reply) :-
    as_root(Root,_),
    ( as_process_state(Root,State,Pid),State\==dead ->
        as_panic_active_process(Root,Pid,Standing)
    ; as_supervisor_state(Root,SupervisorState,SupervisorPid),
        SupervisorState\==dead ->
        Pid=SupervisorPid,as_write_control(Root,panic,operator),
        (as_wait_runtime_family_stopped(Root,8)->Standing=panicked
        ;Standing='panic-pending')
    ; Pid=0,Standing=panicked ),
    (Standing==panicked->as_write_exit(Root,Pid,panic);true),
    Reply=_{schema:"miter-assistant-operator-result-v1",status:Standing,pid:Pid,
      history_deleted:false}.

as_panic_active_process(Root, Pid, Standing) :-
    as_write_control(Root,panic,operator),
    ( as_wait_runtime_family_stopped(Root,2) -> Standing=panicked
    ; as_signal(Pid,'-TERM'),
      ( as_wait_runtime_family_stopped(Root,2) -> Standing=panicked
      ; as_signal(Pid,'-KILL'),
        (as_wait_runtime_family_stopped(Root,2)->Standing=panicked
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
