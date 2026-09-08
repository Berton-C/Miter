% Non-cognitive persistent-service membrane with stable-scope and bounded
% continuity mechanics.
% Owns strict transport schemas, leases, durable bytes, waits and heartbeat.
% It never interprets contact meaning, classifies a flourishing, constructs a
% movement, calls a model, reads private memory, or grants an external effect.

:- ensure_loaded('store.pl').
:- ensure_loaded('integrity.pl').
:- ensure_loaded('continuity_adapter.pl').
:- ensure_loaded('mattermost.pl').
:- ensure_loaded('runtime_continuity.pl').
:- ensure_loaded('semantic_adapter.pl').
:- ensure_loaded('chroma.pl').
:- use_module(library(crypto)).
:- use_module(library(filesex)).
:- use_module(library(http/json)).
:- use_module(library(lists)).
:- use_module(library(pcre)).
:- use_module(library(readutil)).
:- discontiguous as_mattermost_voice_certificate/5.
:- use_module(library(time)).
:- use_module(library(terms)).
:- use_module(library(uuid)).

% Run a credential lookup as a bounded mechanical read.  A locked Keychain or
% authorization prompt must degrade one surface/model call; it may not freeze
% the single supervisor before the PeTTa reactor can start.  No returned bytes
% are logged or persisted by this helper.
as_bounded_process_line(Executable,Arguments,MaximumBytes,Deadline,Line) :-
    setup_call_cleanup(
      process_create(Executable,Arguments,
        [stdin(null),stdout(pipe(Stream)),stderr(null),process(Pid)]),
      as_bounded_process_line_read(Pid,Stream,MaximumBytes,Deadline,Line),
      as_bounded_process_line_cleanup(Pid,Stream)).

as_bounded_process_line_read(Pid,Stream,MaximumBytes,Deadline,Line) :-
    catch(call_with_time_limit(Deadline,read_line_to_string(Stream,Raw)),_,fail),
    string(Raw),string_length(Raw,Length),Length>0,Length=<MaximumBytes,
    process_wait(Pid,exit(0),[timeout(2)]),Line=Raw.

as_bounded_process_line_cleanup(Pid,Stream) :-
    catch(close(Stream,[force(true)]),_,true),
    ( catch(process_wait(Pid,Status,[timeout(0)]),_,Status=finished),
      Status==timeout ->
        catch(process_kill(Pid,term),_,true),
        catch(process_wait(Pid,_,[timeout(2)]),_,true)
    ; true ).

% Credentials are mechanical capabilities. The public configuration names a
% lookup location; secret bytes remain in either the operator's Keychain or a
% mode-0600 file beneath the private runtime root. Callers receive only bounded
% bytes and never persist them in logs, requests, or observations.
as_credential_reference_valid(
    _Root, _{source:"macos-keychain",account:Account,service:Service}) :-
    as_credential_name(Account),as_credential_name(Service).
as_credential_reference_valid(
    Root, _{source:"private-runtime-file",path:PathString}) :-
    string(PathString),atom_string(Path,PathString),is_absolute_file_name(Path),
    as_path_within(Root,Path),exists_file(Path),\+ read_link(Path,_,_),
    as_private_file_mode(Path).

as_credential_read(Root,Reference,MaximumBytes,Secret) :-
    as_credential_reference_valid(Root,Reference),
    ( Reference.source=="macos-keychain" ->
        atom_string(Account,Reference.account),
        atom_string(Service,Reference.service),
        as_bounded_process_line('/usr/bin/security',
          ['find-generic-password','-w','-a',Account,'-s',Service],
          MaximumBytes,15,Raw)
    ; atom_string(Path,Reference.path),
      size_file(Path,Size),Size>0,Size=<MaximumBytes,
      setup_call_cleanup(open(Path,read,Stream,[encoding(utf8)]),
        read_string(Stream,MaximumBytes,Raw),close(Stream))
    ),
    normalize_space(string(Secret),Raw),string_length(Secret,Length),
    Length>=16,Length=<MaximumBytes.

as_credential_name(Value) :-
    string(Value),string_length(Value,Length),Length>=1,Length=<255,
    re_match("^[A-Za-z0-9_.:@/-]+$",Value).

as_path_within(Root,Path) :-
    atom_concat(Root,'/',Prefix),atom_concat(Prefix,_,Path).

as_private_file_mode(Path) :-
    as_bounded_process_line('/usr/bin/stat',['-f','%Lp',Path],16,5,Raw),
    normalize_space(string(Mode),Raw),Mode=="600".

as_schema('miter-assistant-runtime-v1').
as_input_schema('miter-assistant-input-v1').
as_input_schema('miter-assistant-input-v2').
as_input_schema('miter-assistant-input-v3').
as_config_schema('miter-assistant-config-v1').

as_config_value(idle_base_seconds, Value) :-
    number(Value), Value >= 0.01, Value =< 2.
as_config_value(idle_cap_seconds, Value) :-
    number(Value), Value >= 0.01, Value =< 2.
as_config_value(max_input_batch, Value) :-
    integer(Value), Value >= 1, Value =< 64.
as_config_value(max_input_bytes, Value) :-
    integer(Value), Value >= 1024, Value =< 16777216.
as_config_value(supervision, Value) :-
    is_dict(Value),
    dict_pairs(Value,_,Pairs),pairs_keys(Pairs,Keys),sort(Keys,Sorted),
    Sorted==[model_lease_margin_seconds,poll_seconds,
      processing_lease_seconds,startup_grace_seconds,
      termination_grace_seconds,waiting_lease_seconds],
    as_bounded_integer(Value.startup_grace_seconds,5,120),
    as_bounded_integer(Value.waiting_lease_seconds,5,60),
    as_bounded_integer(Value.processing_lease_seconds,30,600),
    as_bounded_integer(Value.model_lease_margin_seconds,10,120),
    as_bounded_integer(Value.termination_grace_seconds,1,30),
    as_bounded_integer(Value.poll_seconds,1,5).

as_bounded_integer(Value,Minimum,Maximum) :-
    integer(Value),Value>=Minimum,Value=<Maximum.

% Calibrated against the complete C3 Fact9/flourishing/R/A/P proof carrier.
% This remains a finite mechanical envelope, not authority to truncate or
% simplify a native proof that MeTTa has formed.
as_max_native_proof_bytes(33554432).

as_root(Root0, Root) :-
    miter_store_nonempty_atom(Root0, Root),
    is_absolute_file_name(Root),
    exists_directory(Root),
    directory_file_path(Root, 'runtime.json', MarkerPath),
    miter_store_read_json(MarkerPath, Marker),
    get_dict(schema, Marker, Schema0),
    miter_store_nonempty_atom(Schema0, Schema),
    as_schema(Schema),
    directory_file_path(Root, 'lib/libmiter_store_posix.dylib', Extension),
    miter_store_ensure_extension(Extension).

as_path(Root, Relative, Path) :- directory_file_path(Root, Relative, Path).

as_symbol(Value, Atom) :-
    miter_store_nonempty_atom(Value, Atom),
    re_match('^[A-Za-z][A-Za-z0-9_.:-]{0,127}$', Atom).

% Deterministic identifiers are a mechanical hashing service. The caller
% supplies the complete ground provenance-bearing term; this membrane neither
% inspects its meaning nor decides whether an endogenous occurrence exists.
as_native_id(Prefix0, Term, Id) :-
    as_symbol(Prefix0, Prefix), ground(Term), acyclic_term(Term),
    term_string(Term, Text, [quoted(true),ignore_ops(true)]),
    string_length(Text, Length), Length>0, Length=<1048576,
    crypto_data_hash(Text, Hash, [algorithm(sha256),encoding(utf8)]),
    atomic_list_concat([Prefix,Hash], '-', Id), !.

as_sha256(Value, Atom) :-
    miter_store_nonempty_atom(Value, Atom),
    atom_length(Atom, 64),
    atom_codes(Atom, Codes),
    maplist(miter_store_hex_code, Codes).

as_member(Value, Allowed) :- memberchk(Value, Allowed).

as_dict_atom(Dict, Key, Atom) :- get_dict(Key, Dict, Value), as_symbol(Value, Atom).

% Native movement identities may be structured MeTTa data (for example, an
% inquiry keyed to both a development reference and a cut).  The membrane may
% carry that identity but may not parse arbitrary MeTTa source.  This bounded
% JSON tree is therefore the only structured-reference carrier: every node is
% data-only, depth/arity bounded, and composed solely of already-safe symbols.
as_native_reference(Value, Reference) :-
    as_native_reference_at(Value, 0, Reference).

as_native_reference_at(Value, _, Atom) :-
    \+ is_dict(Value),
    as_symbol(Value, Atom).
as_native_reference_at(Dict, Depth, [Constructor|Arguments]) :-
    is_dict(Dict), Depth < 4,
    dict_pairs(Dict, _, Pairs), length(Pairs, 2),
    get_dict(constructor, Dict, ConstructorValue),
    get_dict(arguments, Dict, ArgumentValues),
    as_symbol(ConstructorValue, Constructor),
    is_list(ArgumentValues), ArgumentValues = [_|_],
    length(ArgumentValues, Arity), Arity =< 8,
    NextDepth is Depth + 1,
    maplist(as_native_reference_at_depth(NextDepth), ArgumentValues,
      Arguments).

as_native_reference_at_depth(Depth, Value, Reference) :-
    as_native_reference_at(Value, Depth, Reference).

as_dict_native_reference(Dict, Reference) :-
    ( get_dict(movement_ref, Dict, Value)
    -> as_native_reference(Value, Reference)
    ;  get_dict(movement_id, Dict, Value), as_symbol(Value, Reference)
    ).

as_symbol_list(Values, Atoms) :-
    is_list(Values),
    maplist(as_symbol, Values, Atoms),
    sort(Atoms, Unique),
    same_length(Atoms, Unique).

as_nonempty_symbol_list(Values, Atoms) :-
    as_symbol_list(Values, Atoms), Atoms = [_|_].

as_roles(Values, Roles) :-
    as_nonempty_symbol_list(Values, Atoms),
    sort(Atoms, Roles),
    maplist(as_fact9_role, Roles).

as_fact9_role(Role) :-
    as_member(Role, ['Gravity','Balance','Connection','Precision',
      'Effortlessness','Transformation','Love','Sacred']).

as_flourishing(Value) :-
    as_member(Value, ['AgencyBalance','CognitiveResilience','ConnectionDepth',
      'WonderPreservation','TimeCoherence','PurposeBeyondUtility',
      'SharedUnderstanding','CreativeTranscendence','AttentionStewardship']).

as_relation(Dict, [relation, Id, Kind, Standing, Evidence]) :-
    is_dict(Dict),
    as_dict_atom(Dict, id, Id),
    as_dict_atom(Dict, kind, Kind),
    as_dict_atom(Dict, standing, Standing),
    as_dict_atom(Dict, evidence, Evidence).

as_distinction(Dict, [distinction, Id, Standing, Evidence]) :-
    is_dict(Dict),
    as_dict_atom(Dict, id, Id),
    as_dict_atom(Dict, standing, Standing),
    as_dict_atom(Dict, evidence, Evidence).

as_omega_relation(Dict, ['material-relation', Id, Roles, Standing, Evidence]) :-
    is_dict(Dict),
    as_dict_atom(Dict, id, Id),
    get_dict(roles, Dict, RoleValues), as_roles(RoleValues, Roles),
    as_dict_atom(Dict, standing, Standing),
    as_member(Standing, [support,obstruction,contradiction,unresolved]),
    as_dict_atom(Dict, evidence, Evidence).

as_interface(Dict, [interface, Id, Standing, Evidence]) :-
    is_dict(Dict),
    as_dict_atom(Dict, id, Id),
    as_dict_atom(Dict, standing, Standing),
    as_dict_atom(Dict, evidence, Evidence).

as_thread(Dict, [thread, Id, Standing, Evidence]) :-
    is_dict(Dict),
    as_dict_atom(Dict, id, Id),
    as_dict_atom(Dict, standing, Standing),
    as_dict_atom(Dict, evidence, Evidence).

as_soul_relation(Dict, ['soul-relation', Id, Standing, Evidence]) :-
    is_dict(Dict),
    as_dict_atom(Dict, id, Id),
    as_dict_atom(Dict, standing, Standing),
    as_dict_atom(Dict, evidence, Evidence).

as_fact_view(Dict, ['fact-view', Id, Support, RelationIds, Recognition, Evidence]) :-
    is_dict(Dict),
    as_dict_atom(Dict, id, Id),
    get_dict(support, Dict, SupportValues), as_roles(SupportValues, Support),
    get_dict(relation_ids, Dict, RelationValues),
    as_nonempty_symbol_list(RelationValues, RelationIds),
    as_dict_atom(Dict, recognition, Recognition),
    as_member(Recognition, [recognized,unrecognized]),
    as_dict_atom(Dict, evidence, Evidence).

as_flourishing_view(Dict, ['flourishing-view', Value, RelationId, Standing, Evidence]) :-
    is_dict(Dict),
    as_dict_atom(Dict, value, Value), as_flourishing(Value),
    as_dict_atom(Dict, relation_id, RelationId),
    as_dict_atom(Dict, standing, Standing),
    as_member(Standing, [flourishing,capture,obstruction,disguise,contradiction,
      unresolved,unknown,'beneficial-direction',counterevidence,
      'positive-pole-distortion']),
    as_dict_atom(Dict, evidence, Evidence).

as_possibility(Dict, ['possible-movement', Id, Form, RelationIds, DistinctionIds,
                      InterfaceIds, Flourishings,
                      ['consequence-route', ConsequenceKind, 'non-certifying'],
                      'l2425-supported']) :-
    is_dict(Dict),
    as_dict_atom(Dict, id, Id),
    as_dict_atom(Dict, form, Form),
    as_member(Form, [inquiry,undertaking,join,defer,decline,completion]),
    get_dict(relation_ids, Dict, RelationValues),
    as_nonempty_symbol_list(RelationValues, RelationIds),
    get_dict(distinction_ids, Dict, DistinctionValues),
    as_nonempty_symbol_list(DistinctionValues, DistinctionIds),
    get_dict(interface_ids, Dict, InterfaceValues),
    as_nonempty_symbol_list(InterfaceValues, InterfaceIds),
    get_dict(flourishing_values, Dict, FlourishingValues),
    as_nonempty_symbol_list(FlourishingValues, Flourishings),
    maplist(as_flourishing, Flourishings),
    as_dict_atom(Dict, consequence_kind, ConsequenceKind),
    as_dict_atom(Dict, consequence_standing, 'non-certifying'),
    as_dict_atom(Dict, legality, 'l2425-supported').

as_participant(Scope, Dict,
               ['participant-contribution', Id, Kind, Scope, Lineage,
                [claim, Claim], Standing, 'no-contact-no-movement-authority']) :-
    is_dict(Dict),
    as_dict_atom(Dict, id, Id),
    as_dict_atom(Dict, kind, Kind),
    as_member(Kind, [human,model,memory,pln,nal,tool]),
    get_dict(lineage, Dict, LineageValues),
    as_nonempty_symbol_list(LineageValues, LineageAtoms),
    Lineage = [lineage|LineageAtoms],
    as_dict_atom(Dict, claim, Claim),
    as_dict_atom(Dict, standing, Standing),
    as_member(Standing, [candidate,supported,contradicted,unresolved]),
    as_dict_atom(Dict, authority, 'no-contact-no-movement-authority').

% V2 admits a typed relational claim without interpreting whether it should
% participate. Native MeTTa retains lineage, standing, conflict and authority.
as_participant_claim(Dict,
    ['participant-relation-claim',Target,Proposed,Evidence]) :-
    is_dict(Dict),
    as_dict_atom(Dict, kind, relation),
    as_dict_atom(Dict, target, Target),
    as_dict_atom(Dict, proposed_standing, Proposed),
    as_member(Proposed, [support,contradiction,unresolved]),
    as_dict_atom(Dict, evidence, Evidence).
as_participant_claim(Dict,
    ['participant-text-claim',ContentHash,Text,RawRef,
      'exact-human-utterance-not-movement-authority']) :-
    is_dict(Dict), as_dict_atom(Dict,kind,text),
    get_dict(content_sha256,Dict,Hash0), miter_store_nonempty_atom(Hash0,ContentHash),
    as_sha256(ContentHash,ContentHash),
    get_dict(text,Dict,Text), string(Text), string_length(Text,Length),
    Length>=1, Length=<32768,
    get_dict(raw_ref,Dict,Raw0), miter_store_nonempty_atom(Raw0,RawRef),
    \+ is_absolute_file_name(RawRef), \+ sub_atom(RawRef,_,_,_,'..').

as_participant_v2(Scope, Dict,
                  ['participant-contribution', Id, Kind, Scope, Lineage,
                   Claim, Standing, 'no-contact-no-movement-authority']) :-
    is_dict(Dict),
    as_dict_atom(Dict, id, Id),
    as_dict_atom(Dict, kind, Kind),
    as_member(Kind, [human,model,memory,pln,nal,tool]),
    get_dict(lineage, Dict, LineageValues),
    as_nonempty_symbol_list(LineageValues, LineageAtoms),
    Lineage = [lineage|LineageAtoms],
    get_dict(claim, Dict, ClaimValue), as_participant_claim(ClaimValue, Claim),
    as_dict_atom(Dict, standing, Standing),
    as_member(Standing, [candidate,supported,contradicted,unresolved]),
    as_dict_atom(Dict, authority, 'no-contact-no-movement-authority').

% A structurally invalid participant must not erase an otherwise valid contact.
% The membrane preserves only the local carrier failure and a safe identifier;
% native MeTTa remains responsible for how that unresolved material participates.
as_participant_unresolved_v2(Dict,
                             ['participant-unresolved', Id,
                              'carrier-schema-or-provenance-invalid']) :-
    ( is_dict(Dict), get_dict(id, Dict, Candidate),
      catch(as_symbol(Candidate, Id0), _, fail)
    -> Id = Id0
    ;  Id = unknown
    ).

as_participant_v2_or_unresolved(Scope, Dict, Participant) :-
    ( as_participant_v2(Scope, Dict, Valid)
    -> Participant = Valid
    ;  as_participant_unresolved_v2(Dict, Participant)
    ).

as_present(Dict, ['present-context', Context, Evidence]) :-
    is_dict(Dict),
    as_dict_atom(Dict, context, Context),
    as_dict_atom(Dict, evidence, Evidence).

as_contact(Dict,
           [contact, Id, Source, Principal, Audience, Project, Occurrence, Proto,
            ['encounter-configuration', ['D', Relations, Distinctions],
             ['Omega', Omega], ['I', Interfaces], ['W', Weave], ['C', Soul],
             Present, Facts, Flourishings, Possibilities, Participants], Parents]) :-
    is_dict(Dict),
    as_dict_atom(Dict, id, Id),
    as_dict_atom(Dict, source_kind, Source),
    as_member(Source, ['human-contact','endogenous-contact']),
    as_dict_atom(Dict, principal, Principal),
    as_dict_atom(Dict, audience, Audience),
    as_dict_atom(Dict, project, Project),
    as_dict_atom(Dict, occurrence, Occurrence),
    as_dict_atom(Dict, proto, Proto),
    Scope = [scope,Principal,Audience,Project],
    get_dict(parents, Dict, ParentValues), as_symbol_list(ParentValues, Parents),
    get_dict(configuration, Dict, Configuration), is_dict(Configuration),
    get_dict(d_relations, Configuration, RelationValues),
    is_list(RelationValues), maplist(as_relation, RelationValues, Relations),
    get_dict(d_distinctions, Configuration, DistinctionValues),
    is_list(DistinctionValues), maplist(as_distinction, DistinctionValues, Distinctions),
    get_dict(omega_relations, Configuration, OmegaValues),
    is_list(OmegaValues), maplist(as_omega_relation, OmegaValues, Omega),
    get_dict(interfaces, Configuration, InterfaceValues),
    is_list(InterfaceValues), maplist(as_interface, InterfaceValues, Interfaces),
    get_dict(weave, Configuration, WeaveValues),
    is_list(WeaveValues), maplist(as_thread, WeaveValues, Weave),
    get_dict(soul_relations, Configuration, SoulValues),
    is_list(SoulValues), maplist(as_soul_relation, SoulValues, Soul),
    get_dict(present, Configuration, PresentValue), as_present(PresentValue, Present),
    get_dict(fact_views, Configuration, FactValues),
    is_list(FactValues), maplist(as_fact_view, FactValues, Facts),
    get_dict(flourishing_views, Configuration, FlourishingViewValues),
    is_list(FlourishingViewValues),
    maplist(as_flourishing_view, FlourishingViewValues, Flourishings),
    get_dict(possibilities, Configuration, PossibilityValues),
    is_list(PossibilityValues), maplist(as_possibility, PossibilityValues, Possibilities),
    get_dict(participants, Configuration, ParticipantValues),
    is_list(ParticipantValues),
    maplist(as_participant(Scope), ParticipantValues, Participants).

as_contact_v2(Dict,
              ['contact-v2', Id, Source, Principal, Audience, Project, Occurrence,
               Proto, PayloadRef,
               ['encounter-configuration', ['D', Relations, Distinctions],
                ['Omega', Omega], ['I', Interfaces], ['W', Weave], ['C', Soul],
                Present, Facts, Flourishings, Possibilities, Participants], Parents]) :-
    is_dict(Dict),
    as_dict_atom(Dict, id, Id),
    as_dict_atom(Dict, source_kind, Source),
    as_member(Source, ['human-contact','endogenous-contact']),
    as_dict_atom(Dict, principal, Principal),
    as_dict_atom(Dict, audience, Audience),
    as_dict_atom(Dict, project, Project),
    as_dict_atom(Dict, occurrence, Occurrence),
    as_dict_atom(Dict, proto, Proto),
    as_dict_atom(Dict, payload_ref, PayloadRef),
    Scope = [scope,Principal,Audience,Project],
    get_dict(parents, Dict, ParentValues), as_symbol_list(ParentValues, Parents),
    get_dict(configuration, Dict, Configuration), is_dict(Configuration),
    get_dict(d_relations, Configuration, RelationValues),
    is_list(RelationValues), maplist(as_relation, RelationValues, Relations),
    get_dict(d_distinctions, Configuration, DistinctionValues),
    is_list(DistinctionValues), maplist(as_distinction, DistinctionValues, Distinctions),
    get_dict(omega_relations, Configuration, OmegaValues),
    is_list(OmegaValues), maplist(as_omega_relation, OmegaValues, Omega),
    get_dict(interfaces, Configuration, InterfaceValues),
    is_list(InterfaceValues), maplist(as_interface, InterfaceValues, Interfaces),
    get_dict(weave, Configuration, WeaveValues),
    is_list(WeaveValues), maplist(as_thread, WeaveValues, Weave),
    get_dict(soul_relations, Configuration, SoulValues),
    is_list(SoulValues), maplist(as_soul_relation, SoulValues, Soul),
    get_dict(present, Configuration, PresentValue), as_present(PresentValue, Present),
    get_dict(fact_views, Configuration, FactValues),
    is_list(FactValues), maplist(as_fact_view, FactValues, Facts),
    get_dict(flourishing_views, Configuration, FlourishingViewValues),
    is_list(FlourishingViewValues),
    maplist(as_flourishing_view, FlourishingViewValues, Flourishings),
    get_dict(possibilities, Configuration, PossibilityValues),
    is_list(PossibilityValues), maplist(as_possibility, PossibilityValues, Possibilities),
    get_dict(participants, Configuration, ParticipantValues),
    is_list(ParticipantValues),
    maplist(as_participant_v2_or_unresolved(Scope), ParticipantValues, Participants).

as_scope(Dict, [scope,Principal,Audience,Project]) :-
    is_dict(Dict),
    as_dict_atom(Dict, principal, Principal),
    as_dict_atom(Dict, audience, Audience),
    as_dict_atom(Dict, project, Project).

as_consequence(Dict,
               [consequence, Id, Movement, Effect, Result,
                ['D-delta', Relations, Distinctions], ['I-delta', Interfaces],
                ['W-delta', Weave], Present, Evidence]) :-
    is_dict(Dict),
    as_dict_atom(Dict, id, Id),
    as_dict_native_reference(Dict, Movement),
    as_dict_atom(Dict, effect_key, Effect),
    as_dict_atom(Dict, result, Result),
    get_dict(d_relations, Dict, RelationValues),
    is_list(RelationValues), maplist(as_relation, RelationValues, Relations),
    get_dict(d_distinctions, Dict, DistinctionValues),
    is_list(DistinctionValues), maplist(as_distinction, DistinctionValues, Distinctions),
    get_dict(interfaces, Dict, InterfaceValues),
    is_list(InterfaceValues), maplist(as_interface, InterfaceValues, Interfaces),
    get_dict(weave, Dict, WeaveValues),
    is_list(WeaveValues), maplist(as_thread, WeaveValues, Weave),
    get_dict(present, Dict, PresentValue), as_present(PresentValue, Present),
    as_dict_atom(Dict, evidence, Evidence).

as_consequence_v2(Dict,
                  ['consequence-v2', Id, Movement, Effect, Result,
                   ['D-delta', Relations, Distinctions], ['Omega-delta', Omega],
                   ['I-delta', Interfaces], ['W-delta', Weave], ['C-delta', Soul],
                   ['flourishing-delta', Flourishings], Present, Evidence]) :-
    is_dict(Dict),
    as_dict_atom(Dict, id, Id),
    as_dict_native_reference(Dict, Movement),
    as_dict_atom(Dict, effect_key, Effect),
    as_dict_atom(Dict, result, Result),
    get_dict(d_relations, Dict, RelationValues),
    is_list(RelationValues), maplist(as_relation, RelationValues, Relations),
    get_dict(d_distinctions, Dict, DistinctionValues),
    is_list(DistinctionValues), maplist(as_distinction, DistinctionValues, Distinctions),
    get_dict(omega_relations, Dict, OmegaValues),
    is_list(OmegaValues), maplist(as_omega_relation, OmegaValues, Omega),
    get_dict(interfaces, Dict, InterfaceValues),
    is_list(InterfaceValues), maplist(as_interface, InterfaceValues, Interfaces),
    get_dict(weave, Dict, WeaveValues),
    is_list(WeaveValues), maplist(as_thread, WeaveValues, Weave),
    get_dict(soul_relations, Dict, SoulValues),
    is_list(SoulValues), maplist(as_soul_relation, SoulValues, Soul),
    get_dict(flourishing_views, Dict, FlourishingViewValues),
    is_list(FlourishingViewValues),
    maplist(as_flourishing_view, FlourishingViewValues, Flourishings),
    get_dict(present, Dict, PresentValue), as_present(PresentValue, Present),
    as_dict_atom(Dict, evidence, Evidence).

as_input_dict_v1(Dict, Input, InputId) :-
    is_dict(Dict),
    as_dict_atom(Dict, schema, 'miter-assistant-input-v1'),
    as_dict_atom(Dict, input_id, InputId),
    as_dict_atom(Dict, input_kind, Kind),
    ( Kind == contact -> get_dict(contact, Dict, ContactValue),
      as_contact(ContactValue, Contact), Input = ['assistant-input',contact,Contact]
    ; Kind == consequence -> get_dict(scope, Dict, ScopeValue),
      get_dict(consequence, Dict, ConsequenceValue),
      as_scope(ScopeValue, Scope), as_consequence(ConsequenceValue, Consequence),
      Input = ['assistant-input',consequence,Scope,Consequence]
    ).

as_input_dict_v2(Dict, Input, InputId) :-
    is_dict(Dict),
    as_dict_atom(Dict, schema, 'miter-assistant-input-v2'),
    as_dict_atom(Dict, input_id, InputId),
    as_dict_atom(Dict, input_kind, Kind),
    ( Kind == contact -> get_dict(contact, Dict, ContactValue),
      as_contact_v2(ContactValue, Contact), Input = ['assistant-input',contact,Contact]
    ; Kind == consequence -> get_dict(scope, Dict, ScopeValue),
      get_dict(consequence, Dict, ConsequenceValue),
      as_scope(ScopeValue, Scope), as_consequence_v2(ConsequenceValue, Consequence),
      Input = ['assistant-input',consequence,Scope,Consequence]
    ).

% V3 binds stable carrier identity to configured principal/audience/project
% scope before the contact configuration is converted into a native atom.
as_input_dict_v3(Root, Dict, Input, InputId) :-
    is_dict(Dict),
    as_dict_atom(Dict, schema, 'miter-assistant-input-v3'),
    as_dict_atom(Dict, input_id, InputId),
    as_dict_atom(Dict, input_kind, 'surface-contact'),
    get_dict(surface, Dict, Surface),
    get_dict(contact, Dict, ContactValue), is_dict(ContactValue),
    get_dict(principal, ContactValue, DeclaredPrincipal),
    get_dict(audience, ContactValue, DeclaredAudience),
    get_dict(project, ContactValue, DeclaredProject),
    DeclaredScope=_{principal:DeclaredPrincipal,
      audience:DeclaredAudience,project:DeclaredProject},
    miter_assistant_scope_bind(Root, Surface, DeclaredScope, Binding),
    Binding=['scope-binding-v1',_,_,['surface-event',PostId,_,_],
      'authorized-before-payload-cognition',_],
    as_contact_v2(ContactValue, Contact),
    Contact=['contact-v2',PostId|_],
    Input=['assistant-input',contact,Binding,Contact].

as_input_dict(Dict, Input, InputId) :-
    is_dict(Dict), get_dict(schema, Dict, Schema0), as_symbol(Schema0, Schema),
    as_input_schema(Schema),
    ( Schema == 'miter-assistant-input-v1' -> as_input_dict_v1(Dict, Input, InputId)
    ; Schema == 'miter-assistant-input-v2' -> as_input_dict_v2(Dict, Input, InputId)
    ).

as_input_dict(Root, Dict, Input, InputId) :-
    is_dict(Dict), get_dict(schema, Dict, Schema0), as_symbol(Schema0, Schema),
    as_input_schema(Schema),
    ( Schema == 'miter-assistant-input-v3' ->
        as_input_dict_v3(Root, Dict, Input, InputId)
    ; as_input_dict(Dict, Input, InputId),
      Input=['assistant-input',consequence,_,_]
    ).

as_config(Root0, Key, Value) :-
    catch((as_root(Root0, Root), as_path(Root, 'config.json', Path),
      miter_store_read_json(Path, Config),
      as_dict_atom(Config, schema, Schema), as_config_schema(Schema),
      get_dict(Key, Config, Value), as_config_value(Key, Value)), _, fail), !.

as_integrity(Root0, Result) :-
    ( catch((as_root(Root0, Root),
      as_path(Root, 'integrity-report.json', Report),
      miter_integrity_verify('constitution/authority-manifest.json', Report, Result0),
      Result=Result0), _, fail) -> true ; Result='soul-integrity-error' ), !.

as_control(Root0, Control) :-
    ( catch((as_root(Root0, Root), as_path(Root, 'control.json', Path),
      miter_store_read_json(Path, Dict),
      as_dict_atom(Dict, schema, 'miter-assistant-control-v1'),
      as_dict_atom(Dict, command, Command), as_member(Command, [continue,stop,panic]),
      as_dict_atom(Dict, command_id, Id),
      Control = ['assistant-control',Command,Id]), _, fail) -> true
    ; Control = ['assistant-control',panic,'control-invalid'] ), !.

as_input(Root0, Inputs) :-
    ( catch((as_root(Root0, Root),
      as_mattermost_poll(Root, SurfaceInputs),
      as_json_carriers(Root, leased, Leased),
      as_json_carriers(Root, inbox, Inbox),
      append(Leased, Inbox, Files), as_config(Root, max_input_batch, Max),
      as_take_limit(Files, Max, Selected),
      as_take_inputs(Root, Selected, FileInputs),
      append(SurfaceInputs,FileInputs,Combined),
      as_take_limit(Combined,Max,Inputs),
      (Inputs=[]->true;get_time(Now),as_heartbeat(Root,'assistant-processing',Now))),
      _, fail) -> true ; Inputs=[] ), !.

as_json_carriers(Root, Kind, Carriers) :-
    as_path(Root, Kind, Directory), directory_files(Directory, Files0),
    include(as_json_name, Files0, Files1), sort(Files1, Files),
    maplist(as_carrier(Kind), Files, Carriers).

as_carrier(Kind, Name, carrier(Kind,Name)).

as_json_name(Name) :- file_name_extension(_, json, Name), Name \== '.', Name \== '..'.

as_take_limit(_, Max, []) :- Max =< 0, !.
as_take_limit([], _, []).
as_take_limit([H|T], Max, [H|Rest]) :-
    Next is Max-1, as_take_limit(T, Next, Rest).

as_take_inputs(_, [], []).
as_take_inputs(Root, [Name|Rest], Inputs) :-
    as_take_input(Root, Name, Outcome),
    ( Outcome = accepted(Input) -> Inputs=[Input|Tail] ; Inputs=Tail ),
    as_take_inputs(Root, Rest, Tail).

as_take_input(Root, carrier(leased,Name), Outcome) :-
    as_path(Root, leased, Leased), directory_file_path(Leased, Name, Source),
    ( catch((size_file(Source, Size), as_config(Root, max_input_bytes, Max), Size =< Max,
      miter_store_read_json(Source, Dict), as_input_dict(Root, Dict, Input, InputId),
      Outcome=accepted(Input), as_receipt(Root, InputId, leased, Name)), _,fail)
    -> true ; as_reject_input(Root, Name, Source, Outcome) ), !.
as_take_input(Root, carrier(inbox,Name), Outcome) :-
    as_path(Root, inbox, Inbox), directory_file_path(Inbox, Name, Source),
    ( catch((size_file(Source, Size), as_config(Root, max_input_bytes, Max), Size =< Max,
      miter_store_read_json(Source, Dict), as_input_dict(Root, Dict, Input, InputId),
      as_path(Root, leased, Leased), directory_file_path(Leased, Name, Destination),
      \+ exists_file(Destination), rename_file(Source, Destination),
      Outcome=accepted(Input), as_receipt(Root, InputId, leased, Name)), _,fail)
    -> true ; as_reject_input(Root, Name, Source, Outcome) ), !.

as_reject_input(Root, Name, Source, rejected) :-
    as_path(Root, rejected, Rejected), directory_file_path(Rejected, Name, Destination),
    ( exists_file(Destination) ->
        uuid(Uuid),atomic_list_concat([Name,rejected,Uuid],'.',PreservedName),
        directory_file_path(Rejected,PreservedName,Preserved)
    ; Preserved=Destination ),
    ( exists_file(Source) -> catch(rename_file(Source, Preserved), _, true) ; true ),
    file_name_extension(InputId, _, Name), as_receipt(Root, InputId, rejected, Name).

as_checkpoint(Root0, Snapshot, Result) :-
    ( catch((as_root(Root0, Root), Snapshot=['assistant-snapshot',_,_],
      miter_runtime_continuity_prepare(Root, Snapshot, SnapshotHash,
        ContinuityRelative, ContinuityFileHash),
      as_write_checkpoint_object(Root, Snapshot, SnapshotHash,
        CheckpointRelative, CheckpointFileHash, FactorCount),
      atom_string(SnapshotHash, SnapshotHashString),
      atom_string(CheckpointFileHash, CheckpointFileHashString),
      atom_string(ContinuityFileHash, ContinuityFileHashString), get_time(Now),
      as_path(Root, 'checkpoints/active.json', MetaPath),
      as_write_json_durable(MetaPath, _{
        schema:"miter-assistant-checkpoint-v3",
        encoding:"prolog-factorized-term-v1",
        factor_count:FactorCount,
        snapshot_sha256:SnapshotHashString,
        checkpoint_object:CheckpointRelative,
        checkpoint_object_sha256:CheckpointFileHashString,
        continuity_manifest:ContinuityRelative,
        continuity_manifest_sha256:ContinuityFileHashString,
        retention_standing:"indefinite-no-age-expiry-explicit-authorized-erasure-repair-or-migration-only",
        semantic_index_standing:"rebuildable-projection-never-continuity-authority",
        recorded_at_epoch:Now}),
      as_commit_leases(Root),
      catch(miter_chroma_project_checkpoint(Root, Snapshot, SnapshotHash,
        ContinuityRelative, _), _, true)), _, fail) -> Result=checkpointed
    ; Result='checkpoint-failed' ), !.

as_restore(Root0, Snapshot) :-
    ( catch((as_root(Root0, Root), as_path(Root, 'checkpoints/active.json', MetaPath),
      ( \+ exists_file(MetaPath) -> Snapshot='no-checkpoint'
      ; miter_store_read_json(MetaPath, Meta),
        as_restore_checkpoint(Root, Meta, Term),
        Term=['assistant-snapshot',_,_], ground(Term), acyclic_term(Term),
        Snapshot=Term )), _, fail) -> true
    ; Snapshot='checkpoint-invalid' ), !.

as_restore_checkpoint(Root, Meta, Term) :-
    as_dict_atom(Meta, schema, 'miter-assistant-checkpoint-v3'), !,
    get_dict(snapshot_sha256, Meta, SnapshotHash0),
    as_sha256(SnapshotHash0, SnapshotHash),
    atomic_list_concat(['checkpoints/objects/',SnapshotHash,'.term'], ExpectedRelative),
    get_dict(checkpoint_object, Meta, Relative0),
    miter_store_nonempty_atom(Relative0, Relative), Relative == ExpectedRelative,
    as_path(Root, ExpectedRelative, TermPath), exists_file(TermPath),
    get_dict(checkpoint_object_sha256, Meta, ExpectedFileHash0),
    as_sha256(ExpectedFileHash0, ExpectedFileHash),
    crypto_file_hash(TermPath, ActualFileHash,[algorithm(sha256),encoding(octet)]),
    ActualFileHash == ExpectedFileHash,
    as_read_factorized_checkpoint(TermPath, Meta, Term),
    miter_runtime_continuity_term_hash(Term, SnapshotHash),
    miter_runtime_continuity_verify(Root, Term, Meta).
as_restore_checkpoint(Root, Meta, Term) :-
    as_path(Root, 'checkpoints/active.term', TermPath), exists_file(TermPath),
    get_dict(sha256, Meta, Expected0), as_sha256(Expected0, Expected),
    crypto_file_hash(TermPath, Actual,[algorithm(sha256),encoding(octet)]),
    Actual == Expected,
    as_read_checkpoint(Meta, TermPath, Term).

% V1/V2 remain readable for existing runtime roots. V3 uses an immutable
% content-addressed object plus an exact continuity manifest. The factor list
% is inert data and is unified explicitly; it is never called as Prolog goals.
as_read_checkpoint(Meta, TermPath, Term) :-
    as_dict_atom(Meta, schema, 'miter-assistant-checkpoint-v1'),
    setup_call_cleanup(open(TermPath,read,Stream,[encoding(utf8)]),
      read_term(Stream,Term,[syntax_errors(error)]),close(Stream)), !.
as_read_checkpoint(Meta, TermPath, Term) :-
    as_dict_atom(Meta, schema, 'miter-assistant-checkpoint-v2'),
    as_dict_atom(Meta, encoding, 'prolog-factorized-term-v1'),
    get_dict(factor_count, Meta, ExpectedFactorCount),
    integer(ExpectedFactorCount), ExpectedFactorCount>=0,
    setup_call_cleanup(open(TermPath,read,Stream,[encoding(utf8)]),
      read_term(Stream,Carrier,[syntax_errors(error)]),close(Stream)),
    Carrier=['miter-factorized-checkpoint-v1',Skeleton,Factors],
    is_list(Factors), length(Factors,ExpectedFactorCount),
    as_checkpoint_factors_well_formed(Factors),
    maplist(as_unify_checkpoint_factor, Factors),
    ground(Skeleton), acyclic_term(Skeleton), Term=Skeleton.

as_read_factorized_checkpoint(TermPath, Meta, Term) :-
    as_dict_atom(Meta, encoding, 'prolog-factorized-term-v1'),
    get_dict(factor_count, Meta, ExpectedFactorCount),
    integer(ExpectedFactorCount), ExpectedFactorCount>=0,
    setup_call_cleanup(open(TermPath,read,Stream,[encoding(utf8)]),
      read_term(Stream,Carrier,[syntax_errors(error)]),close(Stream)),
    Carrier=['miter-factorized-checkpoint-v1',Skeleton,Factors],
    is_list(Factors), length(Factors,ExpectedFactorCount),
    as_checkpoint_factors_well_formed(Factors),
    maplist(as_unify_checkpoint_factor, Factors),
    ground(Skeleton), acyclic_term(Skeleton), Term=Skeleton.

as_checkpoint_factors_well_formed([]).
as_checkpoint_factors_well_formed([Left=_|Rest]) :-
    var(Left), as_checkpoint_factors_well_formed(Rest).

as_unify_checkpoint_factor(Left=Right) :- Left=Right.

as_wait(Root0, Seconds, Result) :-
    ( catch((as_root(Root0, Root), number(Seconds), Seconds>0, Seconds=<2,
      get_time(Now), as_heartbeat_if_due(Root,'assistant-waiting',Now),
      End is Now+Seconds, as_wait_until(Root, End, Result)), _,fail)
    -> true ; Result='wait-failed' ), !.

as_heartbeat_if_due(Root, Kind, Now) :-
    as_path(Root,'heartbeat.json',Path),
    ( exists_file(Path), catch(miter_store_read_json(Path,Prior),_,fail),
      get_dict(observed_at_epoch,Prior,Observed), number(Observed), Now-Observed < 1
    -> true ; as_heartbeat(Root,Kind,Now) ).

as_wait_until(Root, End, Result) :-
    as_control(Root, Control),
    ( Control \= ['assistant-control',continue,_] -> Result='control-ready'
    ; as_path(Root, inbox, Inbox), directory_files(Inbox, Files),
      ( member(Name,Files), as_json_name(Name) -> Result='input-ready'
      ; get_time(Now), (Now>=End -> Result='idle-timeout'
        ; sleep(0.01), as_wait_until(Root,End,Result) ) ) ).

as_record(Root0, Kind0, Payload, Result) :-
    ( catch((as_root(Root0, Root), as_symbol(Kind0, Kind),
      term_string(Payload, PayloadText, [quoted(true),ignore_ops(true)]),
      uuid(Uuid), atomic_list_concat([assistant,Kind,Uuid], '-', EventId),
      get_time(Now), stamp_date_time(Now, Date, 'UTC'),
      format_time(string(Time), '%FT%TZ', Date),
      Intent=_{schema:"miter-event-intent-v1",event_id:EventId,event_kind:Kind,
        occurred_at:Time,recorded_at:Time,source_surface:"assistant-service",
        source_principal:"miter:assistant",audience_scope:"scope:assistant-local",
        project_scope:"ama-1.2",provenance_kind:"native-control",
        parent_event_ids:[],correlation_id:"assistant-service",
        payload:_{native_term:PayloadText}},
      atomic_list_concat(['intents/',EventId,'.json'], IntentRelative),
      as_path(Root, IntentRelative, IntentPath), as_write_json_durable(IntentPath, Intent),
      as_path(Root, store, Store), as_path(Root, 'lib/libmiter_store_posix.dylib', Extension),
      miter_store_append_event(Store, Extension, IntentPath, Append),
      Append=='event-appended', as_heartbeat(Root,Kind,Now)), _,fail)
    -> Result=recorded ; Result='record-failed' ), !.

% Commit an already-formed native VoiceRNA certificate either to the isolated
% local outbox or, when the human-editable surface grant is active, to the
% exact resolved Mattermost group.  This membrane validates the carrier and
% durability boundary only.  It does not interpret the movement, compare
% participants, render language, or choose whether an effect should exist.
as_effect(Root0, Descriptor, Result) :-
    ( catch((as_root(Root0, Root),
      as_effect_descriptor(Descriptor, Kind, EffectId, Scope, Certificate,
        CertificateHash, ProofText, ProofHash, EffectMaterial),
      as_commit_native_proof(Root, EffectId, ProofText, ProofHash),
      as_commit_effect_kind(Kind, Root, EffectId, Scope, Certificate,
        CertificateHash, ProofText, ProofHash, EffectMaterial, Result0),
      Result=Result0), _, fail)
    -> true ; as_effect_id_or_unknown(Descriptor, EffectId0),
      as_effect_hold_kind(Descriptor, EffectKind),
      Result=[EffectKind,EffectId0,'mechanical-boundary'] ), !.

as_effect_descriptor(Descriptor, local, EffectId, Scope, Certificate,
    CertificateHash, ProofText, ProofHash, none) :-
    as_local_effect_descriptor(Descriptor, EffectId, Scope, Certificate,
      CertificateHash, ProofText, ProofHash).
as_effect_descriptor(Descriptor, mattermost, EffectId, Scope, Certificate,
    CertificateHash, ProofText, ProofHash,
    ['mattermost-effect-material',ReplyContact,Utterance]) :-
    as_mattermost_effect_descriptor(Descriptor, EffectId, Scope, Certificate,
      ReplyContact, Utterance, CertificateHash, ProofText, ProofHash).

as_commit_effect_kind(local, Root, EffectId, Scope, Certificate,
    CertificateHash, ProofText, ProofHash, none, Result) :-
    as_commit_local_effect(Root, EffectId, Scope, Certificate,
      CertificateHash, ProofText, ProofHash, Result).
as_commit_effect_kind(mattermost, Root, EffectId, Scope, _Certificate,
    CertificateHash, _ProofText, ProofHash,
    ['mattermost-effect-material',ReplyContact,Utterance], Result) :-
    as_mattermost_commit_post(Root, EffectId, Scope, ReplyContact, Utterance,
      CertificateHash, ProofHash, Result).

as_effect_hold_kind(['mattermost-effect-descriptor-v1'|_],
    'mattermost-effect-held') :- !.
as_effect_hold_kind(_, 'local-effect-held').

as_effect_id_or_unknown(Descriptor, EffectId) :-
    ( is_list(Descriptor), Descriptor=[_,Candidate|_], as_symbol(Candidate,EffectId)
    -> true ; EffectId='unknown-effect' ).

as_local_effect_descriptor(
    ['local-effect-descriptor-v2',EffectId0,IdempotencyKey0,Scope,
     [payload,Certificate],
     ['native-proof',Proof],
     [capability,'local-isolated-outbox','no-network','no-external-authority'],
     prepared], EffectId, Scope, Certificate, CertificateHash, ProofText,
     ProofHash) :-
    as_symbol(EffectId0, EffectId), as_symbol(IdempotencyKey0, IdempotencyKey),
    EffectId==IdempotencyKey,
    as_local_scope(Scope),
    as_local_voice_certificate(Certificate, Scope, Proof),
    term_string(Certificate, CertificateText, [quoted(true),ignore_ops(true)]),
    string_length(CertificateText, CertificateLength), CertificateLength=<65536,
    crypto_data_hash(CertificateText, CertificateHash,
      [algorithm(sha256),encoding(utf8)]),
    term_string(Proof, ProofText, [quoted(true),ignore_ops(true)]),
    string_length(ProofText, ProofLength),
    as_max_native_proof_bytes(MaxProofLength), ProofLength=<MaxProofLength,
    crypto_data_hash(ProofText, ProofHash, [algorithm(sha256),encoding(utf8)]).

as_mattermost_effect_descriptor(
    ['mattermost-effect-descriptor-v1',EffectId0,IdempotencyKey0,Scope,
     ['reply-to-contact',ReplyContact0],
     [payload,Certificate],
     ['native-proof',Proof],
     [capability,'mattermost-create-post','exact-resolved-group-only',
       'pending-before-send-reconcile-unknown'],
     prepared], EffectId, Scope, Certificate, ReplyContact, Utterance,
     CertificateHash, ProofText, ProofHash) :-
    as_symbol(EffectId0, EffectId), as_symbol(IdempotencyKey0, IdempotencyKey),
    EffectId==IdempotencyKey,
    as_local_scope(Scope), as_symbol(ReplyContact0, ReplyContact),
    atom_concat(mm_,RawPostId,ReplyContact), as_mattermost_id(RawPostId,_),
    as_mattermost_voice_certificate(Certificate, Scope, Proof, ReplyContact,
      Utterance),
    term_string(Certificate, CertificateText, [quoted(true),ignore_ops(true)]),
    string_length(CertificateText, CertificateLength), CertificateLength=<65536,
    crypto_data_hash(CertificateText, CertificateHash,
      [algorithm(sha256),encoding(utf8)]),
    term_string(Proof, ProofText, [quoted(true),ignore_ops(true)]),
    string_length(ProofText, ProofLength),
    as_max_native_proof_bytes(MaxProofLength), ProofLength=<MaxProofLength,
    crypto_data_hash(ProofText, ProofHash, [algorithm(sha256),encoding(utf8)]).

as_mattermost_voice_certificate(
    ['assistant-voice-certificate-v3',
     ['VoiceRNA','situated-model-rendering'],
     ['source-cut',CutId0],Scope,
     ['movement-source-reference',MovementReference],
     ['intended-expression',
       ['mattermost-response',ReplyContact,Utterance]],
     ParticipantReference,
     ProofReference,
     ['voice-audit-v3',['bindings',Bindings],['uncertainty',Uncertainty],
       AuditReading,RevisionStanding,
       ['native-audit-formation',AuditProofReference,NativeDisposition],
       'source-scope-movement-bound','no-added-effect-authority'],
     ['authorized-disclosure',Disclosure],
     ['emission-authority','mattermost-exact-resolved-group-only']],
    Scope, Proof, ReplyContact, Utterance) :-
    as_local_native_movement_proof(Proof, Scope, CutId, MovementReference,
      _Summary, ParticipantReference, ProofReference),
    CutId0=CutId,
    as_symbol(ReplyContact,_), atom_concat(mm_,RawPostId,ReplyContact),
    as_mattermost_id(RawPostId,_),
    string(Utterance), string_length(Utterance,UtteranceLength),
    UtteranceLength>=1, UtteranceLength=<3000,
    is_list(Bindings), Bindings=[_|_], maplist(as_symbol,Bindings,_),
    sort(Bindings,UniqueBindings), same_length(Bindings,UniqueBindings),
    string(Uncertainty), string_length(Uncertainty,UncertaintyLength),
    UncertaintyLength=<600,
    as_mattermost_voice_audit_reading(AuditReading,[]),
    as_mattermost_voice_revision_standing(RevisionStanding),
    AuditProofReference==ProofReference,
    as_mattermost_native_voice_disposition(NativeDisposition,
      AuditProofReference),
    memberchk(Disclosure,
      ['current-contact-and-derived-readings-only',
       'current-contact-and-scoped-continuity-to-selected-model']).

% This is a closed-shape and cross-reference check only.  MeTTa has already
% formed the disposition from the complete constitutive organization; the
% membrane neither interprets the R/A/P carrier nor chooses the continuation.
as_mattermost_native_voice_disposition(
    ['c4-native-voice-disposition-v1','express-current-candidate',
      ['c4-native-voice-audit-basis-v1',AuditProofReference,
        ['one-simultaneous-rap',Rap],
        ['fact9-participation',Fact9],
        ['interconnected-flourishing-participation',Flourishing],
        ['candidate-source-binding',QuestionReference,Scope,Source,
          RawReference,['bindings',Bindings]]],
      ['provider-audit-participation',ProviderStanding],
      ['retained-voice-continuations','express-current-candidate',
        'revise-candidate-once','hold-expression-and-continue-inquiry'],
      'native-soul-disposition-not-provider-verdict'],AuditProofReference) :-
    ground([Rap,Fact9,Flourishing,QuestionReference,Scope,Source,RawReference,
      Bindings,ProviderStanding]),
    Rap=['rap-read-v2'|_],Fact9=[_|_],
    Flourishing=['flourishing-organization'|_],
    ProviderStanding=['voice-fidelity-standing',_,_,_].

as_mattermost_voice_audit_reading(
    ['voice-audit-reading-v2',['findings',Findings],
      ['uncertainty',Uncertainty],'candidate-fidelity-reading-not-verdict'],
    Findings) :-
    is_list(Findings),length(Findings,Count),Count=<4,
    maplist(as_mattermost_voice_finding,Findings),
    string(Uncertainty),string_length(Uncertainty,UncertaintyLength),
    UncertaintyLength>=1,UncertaintyLength=<600.

as_mattermost_voice_finding(
    ['voice-audit-finding-v2',Kind,['source-basis',SourceBasis],
      ['candidate-span',CandidateSpan],['inferred-alteration',Alteration],
      ['why-material',WhyMaterial],['affected-dependency',Dependency]]) :-
    memberchk(Kind,['semantic-drift','soul-absence','person-not-seen',
      'task-smearing','unsupported-certainty','authority-inflation',
      'coercive-dominance','hidden-scope','tone-mismatch','lost-tension',
      'unsupported-inner-state','unsupported-action','memory-misstatement',
      'source-fidelity','uncertainty-erasure','ungrounded-authority-claim',
      'voice-displacement']),
    maplist(as_mattermost_voice_finding_text,
      [SourceBasis,CandidateSpan,Alteration,WhyMaterial,Dependency]).

as_mattermost_voice_finding_text(Text) :-
    string(Text),string_length(Text,Length),Length>=1,Length=<600.

as_mattermost_voice_revision_standing(
    'initial-candidate-soul-formed-after-audit-participation').
as_mattermost_voice_revision_standing(
    ['revised-once-by-soul-after-audit-participation',InitialAudit,
      ['raw-sha256',Hash],InitialProofReference]) :-
    as_mattermost_voice_audit_reading(InitialAudit,Findings),Findings=[_|_],
    as_sha256(Hash,_),
    as_mattermost_compact_native_proof_reference(InitialProofReference).

as_mattermost_compact_native_proof_reference(
    ['native-proof-reference',CutId,MovementReference,
      'native-proof-store','persisted-before-effect']) :-
    as_local_cut_id(CutId),ground(MovementReference),
    MovementReference=['movement-reference'|_].

as_mattermost_voice_certificate(
    ['assistant-voice-certificate-v3',
     ['VoiceRNA','situated-model-rendering'],
     ['source-cut',CutId0],Scope,
     ['movement-source-reference',MovementReference],
     ['intended-expression',
       ['mattermost-response',ReplyContact,Utterance]],
     ParticipantReference,
     ProofReference,
     ['voice-audit-v1',['bindings',Bindings],['uncertainty',Uncertainty],
       'source-scope-movement-bound','no-added-effect-authority'],
     ['authorized-disclosure','current-contact-and-derived-readings-only'],
     ['emission-authority','mattermost-exact-resolved-group-only']],
    Scope, Proof, ReplyContact, Utterance) :-
    as_local_native_movement_proof(Proof, Scope, CutId, MovementReference,
      _Summary, ParticipantReference, ProofReference),
    CutId0=CutId,
    as_symbol(ReplyContact,_), atom_concat(mm_,RawPostId,ReplyContact),
    as_mattermost_id(RawPostId,_),
    string(Utterance), string_length(Utterance,UtteranceLength),
    UtteranceLength>=1, UtteranceLength=<3000,
    is_list(Bindings), Bindings=[_|_], maplist(as_symbol,Bindings,_),
    sort(Bindings,UniqueBindings), same_length(Bindings,UniqueBindings),
    string(Uncertainty), string_length(Uncertainty,UncertaintyLength),
    UncertaintyLength=<600.

as_local_scope([scope,Principal0,Audience0,Project0]) :-
    as_symbol(Principal0,_), as_symbol(Audience0,_), as_symbol(Project0,_).

as_local_voice_certificate(
    ['assistant-voice-certificate-v2',
     ['VoiceRNA','bounded-native-expression'],
     ['source-cut',CutId0],Scope,
     ['movement-source-reference',MovementReference],
     ['intended-expression',['local-response',Summary]],
     ParticipantReference,
     ProofReference,
     ['voice-audit','source-bound','uncertainty-retained','no-added-authority'],
     'no-emission-authority'], Scope, Proof) :-
    as_local_native_movement_proof(Proof, Scope, CutId, MovementReference,
      Summary, ParticipantReference, ProofReference),
    CutId0=CutId.

as_local_native_movement_proof(
    ['native-movement-proof-v1',Cut,Scope,Movement,Participants], Scope,
    CutId, MovementReference, Summary, ParticipantReference, ProofReference) :-
    is_list(Cut), length(Cut,14),
    Cut=['constitutive-cut',CutId,_,Scope|_], ground(Cut),
    as_local_cut_id(CutId), as_local_movement(Movement),
    as_local_movement_reference(CutId, Movement, MovementReference),
    as_local_movement_summary(Movement, Summary),
    Participants=['participant-reentry-organization',
      'differentiated-by-source-scope-and-lineage',Readings,
      'repeated-same-lineage-is-not-independent-support'],
    is_list(Readings), ground(Readings), length(Readings, ParticipantCount),
    ParticipantReference=['participant-boundary-reference',ParticipantCount,
      'differentiated-by-source-scope-and-lineage',
      'no-contact-no-movement-authority'],
    ProofReference=['native-proof-reference',CutId,MovementReference,
      'native-proof-store','persisted-before-effect'].

as_local_cut_id(['cut-of',Contact0,Proto0]) :-
    as_symbol(Contact0,_), as_symbol(Proto0,_).

as_local_movement([Kind|Rest]) :-
    memberchk(Kind,['movement-formed','movement-plural-live','movement-unresolved']),
    Rest=[_|_], ground(Rest).

as_local_movement_reference(CutId,
    ['movement-formed',MovementId,Form,_,_,_,_],
    ['movement-reference',CutId,formed,MovementId,Form]) :- !.
as_local_movement_reference(CutId,
    ['movement-plural-live',_,Live,Rest],
    ['movement-reference',CutId,'plural-live',Count,unresolved]) :-
    Live=[_,Alternatives|_], is_list(Alternatives), length(Alternatives,Count),
    ground(Rest), !.
as_local_movement_reference(CutId,
    ['movement-unresolved',Reason,Rest],
    ['movement-reference',CutId,unresolved,Reason,unresolved]) :-
    ground(Rest).

as_local_movement_summary(
    ['movement-formed',MovementId,Form,_,_,_,_],
    ['movement-standing',formed,Form,MovementId]) :- !.
as_local_movement_summary(
    ['movement-plural-live',_,Live,Rest],
    ['movement-standing','plural-live',Count]) :-
    Live=[_,Alternatives|_], is_list(Alternatives), length(Alternatives,Count),
    ground(Rest), !.
as_local_movement_summary(
    ['movement-unresolved',Reason,Rest],
    ['movement-standing',unresolved,Reason]) :- ground(Rest).

as_commit_local_effect(Root, EffectId, Scope, Certificate, CertificateHash,
    ProofText, ProofHash, Result) :-
    as_commit_native_proof(Root, EffectId, ProofText, ProofHash),
    atomic_list_concat(['outbox/',EffectId,'.json'], Relative),
    as_path(Root, Relative, Path),
    ( exists_file(Path) ->
        as_verify_local_effect(Path, EffectId, Scope, CertificateHash, ProofHash),
        as_local_effect_receipt(Root, EffectId, CertificateHash, ProofHash,
          'duplicate-observed'),
        Result=['local-effect-duplicate',EffectId,CertificateHash,ProofHash]
    ; as_local_effect_dict(EffectId, Scope, Certificate, CertificateHash,
        ProofHash, Dict),
      as_write_json_durable(Path, Dict),
      as_local_effect_receipt(Root, EffectId, CertificateHash, ProofHash,
        committed),
      Result=['local-effect-committed',EffectId,CertificateHash,ProofHash] ).

% Persist the complete already-certified native proof before making its compact
% effect reference observable. This is byte mechanics only: MeTTa formed the
% proof and its reference; the membrane writes and verifies the exact carrier.
as_commit_native_proof(Root, EffectId, ProofText, ProofHash) :-
    atomic_list_concat(['proofs/',EffectId,'.term'], Relative),
    as_path(Root, Relative, Path),
    ( exists_file(Path) ->
        read_file_to_string(Path, Stored, [encoding(utf8)]),
        crypto_data_hash(Stored, StoredHash,
          [algorithm(sha256),encoding(utf8)]), StoredHash==ProofHash,
        Stored==ProofText
    ; as_write_native_proof_durable(Path, ProofText),
      crypto_file_hash(Path, StoredHash,
        [algorithm(sha256),encoding(octet)]), StoredHash==ProofHash ).

as_write_native_proof_durable(Path, Text) :-
    file_directory_name(Path, Directory), make_directory_path(Directory),
    current_prolog_flag(pid, Pid), format(atom(Suffix), '.tmp.~d', [Pid]),
    atom_concat(Path,Suffix,Temporary),
    setup_call_cleanup(true,
      (setup_call_cleanup(open(Temporary,write,Stream,[encoding(utf8)]),
        (chmod(Temporary,0o600),format(Stream,'~s',[Text]),flush_output(Stream),
         miter_store_fsync_stream(Stream)),close(Stream)),
       rename_file(Temporary,Path)),
      (exists_file(Temporary)->delete_file(Temporary);true)).

as_local_effect_dict(EffectId, [scope,Principal,Audience,Project], Certificate,
    CertificateHash, ProofHash,
    _{schema:"miter-local-effect-v2",effect_id:EffectId,idempotency_key:EffectId,
      principal:Principal,audience:Audience,project:Project,
      certificate_sha256:CertificateHash,native_certificate:CertificateText,
      native_proof_sha256:ProofHash,
      capability:"local-isolated-outbox",network_access:false,
      external_effect:false,standing:"committed-local-only"}) :-
    term_string(Certificate, CertificateText, [quoted(true),ignore_ops(true)]).

as_verify_local_effect(Path, EffectId, [scope,Principal,Audience,Project],
    CertificateHash, ProofHash) :-
    miter_store_read_json(Path, Dict),
    as_dict_atom(Dict,schema,'miter-local-effect-v2'),
    as_dict_atom(Dict,effect_id,EffectId),
    as_dict_atom(Dict,idempotency_key,EffectId),
    as_dict_atom(Dict,principal,Principal), as_dict_atom(Dict,audience,Audience),
    as_dict_atom(Dict,project,Project),
    get_dict(certificate_sha256,Dict,StoredCertificateHash0),
    as_sha256(StoredCertificateHash0,StoredCertificateHash),
    StoredCertificateHash==CertificateHash,
    get_dict(native_proof_sha256,Dict,StoredProofHash0),
    as_sha256(StoredProofHash0,StoredProofHash), StoredProofHash==ProofHash,
    get_dict(native_certificate,Dict,StoredCertificate),
    string(StoredCertificate), string_length(StoredCertificate,StoredLength),
    StoredLength=<65536,
    crypto_data_hash(StoredCertificate,StoredHash,
      [algorithm(sha256),encoding(utf8)]), StoredHash==CertificateHash,
    as_dict_atom(Dict,capability,'local-isolated-outbox'),
    get_dict(network_access,Dict,false), get_dict(external_effect,Dict,false),
    as_dict_atom(Dict,standing,'committed-local-only').

as_local_effect_receipt(Root, EffectId, CertificateHash, ProofHash, Standing) :-
    atomic_list_concat(['receipts/effect-',EffectId,'.json'], Relative),
    as_path(Root,Relative,Path), get_time(Now),
    as_write_json_durable(Path, _{schema:"miter-assistant-effect-receipt-v2",
      effect_id:EffectId,idempotency_key:EffectId,
      certificate_sha256:CertificateHash,native_proof_sha256:ProofHash,
      capability:"local-isolated-outbox",standing:Standing,
      network_access:false,external_effect:false,observed_at_epoch:Now}).

as_heartbeat(Root, Kind, Now) :-
    as_heartbeat_lease_seconds(Root,Kind,Seconds,LeaseKind),
    ValidUntil is Now+Seconds,
    as_heartbeat_write(Root,Kind,Now,ValidUntil,LeaseKind).

% A blocking model transport receives only the exact finite deadline already
% present in the Soul-formed question plus a small mechanical cleanup margin.
% This prevents a valid slow inference from resembling a frozen reactor.  The
% lease grants no model call and contributes no cognitive standing.
as_heartbeat_model_lease(Root, Deadline) :-
    number(Deadline),Deadline>=1,Deadline=<300,
    as_config(Root,supervision,Supervision),
    Seconds is Deadline+Supervision.model_lease_margin_seconds,
    get_time(Now),ValidUntil is Now+Seconds,
    as_heartbeat_write(Root,'assistant-model-transport',Now,ValidUntil,
      'bounded-model-transport').

as_heartbeat_lease_seconds(Root,'assistant-waiting',Seconds,'idle-cycle') :- !,
    as_config(Root,supervision,Supervision),
    Seconds=Supervision.waiting_lease_seconds.
as_heartbeat_lease_seconds(_Root,Kind,0,'terminal') :-
    memberchk(Kind,['assistant-stopped','assistant-panicked']),!.
as_heartbeat_lease_seconds(Root,_Kind,Seconds,'native-processing') :-
    as_config(Root,supervision,Supervision),
    Seconds=Supervision.processing_lease_seconds.

as_heartbeat_write(Root,Kind,Now,ValidUntil,LeaseKind) :-
    as_path(Root,'pid.json',PidPath),miter_store_read_json(PidPath,PidState),
    as_dict_atom(PidState,schema,'miter-assistant-pid-v1'),
    get_dict(pid,PidState,Pid),integer(Pid),Pid>1,
    get_dict(run_id,PidState,RunId0),as_run_id(RunId0,RunId),
    as_path(Root,'heartbeat.json',Path),
    as_write_json_durable(Path,_{schema:"miter-assistant-heartbeat-v2",
      state:Kind,pid:Pid,run_id:RunId,lease_kind:LeaseKind,
      observed_at_epoch:Now,valid_until_epoch:ValidUntil}).

as_run_id(Value,RunId) :-
    miter_store_nonempty_atom(Value,RunId),
    re_match('^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      RunId).

as_receipt(Root, InputId0, Standing, Name) :-
    ( as_symbol(InputId0, InputId) -> true ; InputId='unknown-input' ),
    atomic_list_concat(['receipts/',InputId,'.json'], Relative), as_path(Root,Relative,Path),
    get_time(Now), as_write_json_durable(Path, _{schema:"miter-assistant-input-receipt-v1",
      input_id:InputId,standing:Standing,carrier:Name,observed_at_epoch:Now}).

as_commit_leases(Root) :-
    as_path(Root, leased, Leased), as_path(Root, consumed, Consumed),
    directory_files(Leased, Files), include(as_json_name, Files, JsonFiles),
    maplist(as_commit_lease(Root,Leased,Consumed), JsonFiles).

as_commit_lease(Root, Leased, Consumed, Name) :-
    directory_file_path(Leased,Name,Source), directory_file_path(Consumed,Name,Destination),
    ( exists_file(Destination) ->
        crypto_file_hash(Source,SourceHash,[algorithm(sha256),encoding(octet)]),
        crypto_file_hash(Destination,DestinationHash,[algorithm(sha256),encoding(octet)]),
        SourceHash==DestinationHash,
        as_path(Root,rejected,Rejected),
        uuid(Uuid),atomic_list_concat([Name,'committed-duplicate',Uuid],'.',DuplicateName),
        directory_file_path(Rejected,DuplicateName,Duplicate),rename_file(Source,Duplicate)
    ; rename_file(Source,Destination) ),
    file_name_extension(InputId,_,Name), as_receipt(Root,InputId,'native-checkpointed',Name).

as_write_term_atomic(Path, Term) :-
    file_directory_name(Path, Directory), make_directory_path(Directory),
    current_prolog_flag(pid, Pid), format(atom(Suffix), '.tmp.~d', [Pid]),
    atom_concat(Path,Suffix,Temporary),
    setup_call_cleanup(true,
      (setup_call_cleanup(open(Temporary,write,Stream,[encoding(utf8)]),
        (chmod(Temporary,0o600),write_term(Stream,Term,[quoted(true),ignore_ops(true)]),
         write(Stream,'.'),nl(Stream),flush_output(Stream),miter_store_fsync_stream(Stream)),
        close(Stream)),rename_file(Temporary,Path)),
      (exists_file(Temporary)->delete_file(Temporary);true)).

as_write_factorized_checkpoint_atomic(Path, Snapshot, FactorCount) :-
    term_factorized(Snapshot, Skeleton, Factors),
    length(Factors, FactorCount),
    Carrier=['miter-factorized-checkpoint-v1',Skeleton,Factors],
    as_write_term_atomic(Path, Carrier).

as_write_checkpoint_object(Root, Snapshot, SnapshotHash, Relative, FileHash,
                           FactorCount) :-
    atomic_list_concat(['checkpoints/objects/',SnapshotHash,'.term'], Relative),
    as_path(Root, Relative, Path),
    term_factorized(Snapshot, Skeleton, Factors), length(Factors,FactorCount),
    Carrier=['miter-factorized-checkpoint-v1',Skeleton,Factors],
    ( exists_file(Path) ->
        setup_call_cleanup(open(Path,read,Stream,[encoding(utf8)]),
          read_term(Stream,Existing,[syntax_errors(error)]),close(Stream)),
        Existing =@= Carrier
    ; as_write_term_atomic(Path,Carrier) ),
    crypto_file_hash(Path, FileHash,[algorithm(sha256),encoding(octet)]).

as_write_json_durable(Path, Dict) :-
    file_directory_name(Path, Directory), make_directory_path(Directory),
    current_prolog_flag(pid, Pid), format(atom(Suffix), '.tmp.~d', [Pid]),
    atom_concat(Path,Suffix,Temporary),
    setup_call_cleanup(true,
      (setup_call_cleanup(open(Temporary,write,Stream,[encoding(utf8)]),
        (chmod(Temporary,0o600),json_write_dict(Stream,Dict,[width(0)]),nl(Stream),
         flush_output(Stream),miter_store_fsync_stream(Stream)),close(Stream)),
       rename_file(Temporary,Path)),
      (exists_file(Temporary)->delete_file(Temporary);true)).
