% Mechanical observation of the dedicated-user open growth environment.
% This membrane reports configuration, runtime identity and filesystem presence.
% It does not choose a tool, command, site, purpose, credential or movement.

:- ensure_loaded('store.pl').
:- use_module(library(http/json)).
:- use_module(library(pcre)).
:- use_module(library(process)).
:- use_module(library(readutil)).

as_capability_environment(Root0, Observation) :-
    catch(as_capability_environment_checked(Root0, Observation0), _,
      Observation0=['capability-environment-unavailable-v1',
        'mechanical-observation-failed']),
    Observation=Observation0, !.

as_capability_environment_checked(Root0,
    ['capability-environment-observation-v1',
      'miter-open-growth-environment-v1',
      ['runtime-identity',ExpectedUser,ObservedUser,IdentityStanding],
      ['workspace',workspace,WorkspaceStanding],
      ['informational-network',InformationalNetwork,
        'configured-native-request-broker-pending'],
      ['terminal',Terminal,'configured-native-request-broker-pending'],
      ['reversible-writes',ReversibleWrites,
        'configured-native-request-broker-pending'],
      ['credential-access',CredentialAccess,'named-reference-only'],
      ['human-authority-boundaries'|Boundaries],
      OverallStanding]) :-
    ce_root(Root0,Root),
    directory_file_path(Root,'growth-environment.json',ConfigPath),
    miter_store_read_json(ConfigPath,Config),
    ce_config_valid(Config),
    ce_symbol(Config.expected_runtime_user,ExpectedUser),
    ce_observed_user(ObservedUser),
    ( ObservedUser==ExpectedUser -> IdentityStanding='identity-aligned'
    ; IdentityStanding='identity-mismatch' ),
    directory_file_path(Root,Config.workspace_relative,Workspace),
    ( exists_directory(Workspace), \+ read_link(Workspace,_,_) ->
        WorkspaceStanding='private-workspace-present'
    ; WorkspaceStanding='workspace-unavailable' ),
    ce_symbol(Config.informational_network,InformationalNetwork),
    ce_symbol(Config.terminal,Terminal),
    ce_symbol(Config.reversible_writes,ReversibleWrites),
    ce_symbol(Config.credential_access,CredentialAccess),
    maplist(ce_symbol,Config.human_authority_boundaries,Boundaries),
    ce_overall_standing(Config.enabled,IdentityStanding,WorkspaceStanding,
      OverallStanding).

ce_overall_standing(false,_,_,'held-environment-disabled') :- !.
ce_overall_standing(true,'identity-mismatch',_,
    'held-runtime-identity-mismatch') :- !.
ce_overall_standing(true,'identity-aligned','workspace-unavailable',
    'held-workspace-unavailable') :- !.
ce_overall_standing(true,'identity-aligned','private-workspace-present',
    'held-request-broker-unimplemented').

ce_root(Value,Root) :-
    miter_store_nonempty_atom(Value,Root),is_absolute_file_name(Root),
    Root\=='/',exists_directory(Root),
    directory_file_path(Root,'runtime.json',Marker),exists_file(Marker).

ce_observed_user(User) :-
    process_create('/usr/bin/id',['-un'],
      [stdin(null),stdout(pipe(Output)),stderr(null),process(Pid)]),
    setup_call_cleanup(true,read_string(Output,128,Raw),close(Output)),
    process_wait(Pid,exit(0)),normalize_space(string(Name),Raw),ce_symbol(Name,User).

ce_config_valid(Config) :-
    is_dict(Config),
    ce_exact_keys(Config,
      [credential_access,enabled,expected_runtime_user,human_authority_boundaries,
       human_editable,informational_network,operator_notes,reversible_writes,
       schema,terminal,workspace_relative]),
    Config.schema=="miter-open-growth-environment-v1",
    Config.human_editable==true,memberchk(Config.enabled,[true,false]),
    Config.expected_runtime_user=="claritymiter",
    Config.workspace_relative=="workspace",
    Config.informational_network=="open-http-https",
    Config.terminal=="typed-direct-argv-broker",
    Config.credential_access=="named-reference-only",
    Config.reversible_writes=="versioned-owned-workspace",
    Config.human_authority_boundaries==[
      "bind-other-principal","cross-user-private-material",
      "use-named-credential","spend-or-transfer-value",
      "external-publication-or-message",
      "difficult-to-reverse-external-commitment"],
    is_list(Config.operator_notes),maplist(string,Config.operator_notes).

ce_exact_keys(Dict,Expected) :-
    dict_keys(Dict,Keys),sort(Keys,Sorted),sort(Expected,Sorted).

ce_symbol(Value,Atom) :-
    miter_store_nonempty_atom(Value,Atom),
    atom_length(Atom,Length),Length=<128,
    re_match('^[A-Za-z][A-Za-z0-9_.:-]{0,127}$',Atom).
