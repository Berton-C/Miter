% AMA-1.2 non-cognitive scope and continuity membrane.
% This first increment resolves stable controlled-fixture identities to an
% explicit principal/audience/project scope before a payload becomes native
% contact. It does not inspect contact meaning or select a movement.

:- ensure_loaded('miter_store.pl').
:- use_module(library(http/json)).
:- use_module(library(lists)).
:- use_module(library(pcre)).

miter_assistant_scope_bind(Root0, Surface, DeclaredScope, Result) :-
    ( catch(miter_assistant_scope_bind_checked(
              Root0, Surface, DeclaredScope, Result0), _, fail)
    -> Result=Result0
    ;  Result=['scope-binding-rejected','malformed-or-unavailable-binding']
    ), !.

miter_assistant_scope_bind_checked(Root0, Surface, DeclaredScope, Result) :-
    miter_store_nonempty_atom(Root0, Root),
    is_absolute_file_name(Root), exists_directory(Root),
    miter_assistant_surface(Surface, Route, EventIdentity),
    miter_assistant_declared_scope(DeclaredScope, Scope),
    directory_file_path(Root, 'scope-bindings.json', BindingsPath),
    miter_store_read_json(BindingsPath, Document),
    miter_assistant_bindings_document(Document, Bindings),
    findall(Binding,
      (member(Candidate, Bindings),
       miter_assistant_binding(Candidate, Route, Scope, Binding)),
      Matches),
    ( Matches=[Only] ->
        Result=['scope-binding-v1',Route,Scope,EventIdentity,
                'authorized-before-payload-cognition',Only]
    ; Matches=[] ->
        Result=['scope-binding-rejected','stable-identity-or-scope-not-authorized']
    ; Result=['scope-binding-rejected','ambiguous-stable-identity-binding']
    ).

miter_assistant_bindings_document(Document, Bindings) :-
    is_dict(Document),
    miter_assistant_expect_symbol(Document, schema,
      'miter-assistant-scope-bindings-v1'),
    miter_assistant_expect_symbol(Document, authority_mode,
      'controlled-fixture-only'),
    get_dict(bindings, Document, Bindings), is_list(Bindings).

miter_assistant_surface(Surface,
    ['surface-route','controlled-fixture',Server,Team,Channel,Principal],
    ['surface-event',Post,Thread,Version]) :-
    is_dict(Surface),
    miter_assistant_expect_symbol(Surface, carrier_kind, 'controlled-fixture'),
    miter_assistant_dict_symbol(Surface, server_id, Server),
    miter_assistant_dict_symbol(Surface, team_id, Team),
    miter_assistant_dict_symbol(Surface, channel_id, Channel),
    miter_assistant_dict_symbol(Surface, principal_id, Principal),
    miter_assistant_dict_symbol(Surface, post_id, Post),
    miter_assistant_dict_symbol(Surface, thread_id, Thread),
    miter_assistant_dict_symbol(Surface, event_version, Version).

miter_assistant_declared_scope(Declared,
    [scope,Principal,Audience,Project]) :-
    is_dict(Declared),
    miter_assistant_dict_symbol(Declared, principal, Principal),
    miter_assistant_dict_symbol(Declared, audience, Audience),
    miter_assistant_dict_symbol(Declared, project, Project).

miter_assistant_binding(Binding,
    ['surface-route','controlled-fixture',Server,Team,Channel,StablePrincipal],
    [scope,Principal,Audience,Project],
    ['binding-record',BindingId,'controlled-fixture']) :-
    is_dict(Binding),
    miter_assistant_dict_symbol(Binding, binding_id, BindingId),
    miter_assistant_expect_symbol(Binding, carrier_kind, 'controlled-fixture'),
    miter_assistant_dict_symbol(Binding, server_id, Server),
    miter_assistant_dict_symbol(Binding, team_id, Team),
    miter_assistant_dict_symbol(Binding, channel_id, Channel),
    miter_assistant_dict_symbol(Binding, principal_id, StablePrincipal),
    miter_assistant_dict_symbol(Binding, principal, Principal),
    miter_assistant_dict_symbol(Binding, audience, Audience),
    miter_assistant_dict_symbol(Binding, project, Project),
    miter_assistant_expect_symbol(Binding, standing, authorized).

miter_assistant_expect_symbol(Dict, Key, Expected) :-
    get_dict(Key, Dict, Value), miter_assistant_symbol(Value, Atom), Atom==Expected.
miter_assistant_dict_symbol(Dict, Key, Atom) :-
    get_dict(Key, Dict, Value), miter_assistant_symbol(Value, Atom).

miter_assistant_symbol(Value, Atom) :-
    miter_store_nonempty_atom(Value, Atom),
    re_match('^[A-Za-z][A-Za-z0-9_.:-]{0,127}$', Atom).
