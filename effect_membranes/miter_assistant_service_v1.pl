% AMA-1.1 non-cognitive persistent-service membrane.
% Owns strict transport schemas, leases, durable bytes, waits and heartbeat.
% It never interprets contact meaning, classifies a flourishing, constructs a
% movement, calls a model, reads private memory, or grants an external effect.

:- ensure_loaded('miter_store.pl').
:- ensure_loaded('miter_integrity.pl').
:- use_module(library(crypto)).
:- use_module(library(filesex)).
:- use_module(library(http/json)).
:- use_module(library(lists)).
:- use_module(library(pcre)).
:- use_module(library(readutil)).
:- use_module(library(uuid)).

as_schema('miter-assistant-runtime-v1').
as_input_schema('miter-assistant-input-v1').
as_input_schema('miter-assistant-input-v2').
as_config_schema('miter-assistant-config-v1').

as_config_value(idle_base_seconds, Value) :-
    number(Value), Value >= 0.01, Value =< 2.
as_config_value(idle_cap_seconds, Value) :-
    number(Value), Value >= 0.01, Value =< 2.
as_config_value(max_input_batch, Value) :-
    integer(Value), Value >= 1, Value =< 64.
as_config_value(max_input_bytes, Value) :-
    integer(Value), Value >= 1024, Value =< 16777216.

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

as_sha256(Value, Atom) :-
    miter_store_nonempty_atom(Value, Atom),
    atom_length(Atom, 64),
    atom_codes(Atom, Codes),
    maplist(miter_store_hex_code, Codes).

as_member(Value, Allowed) :- memberchk(Value, Allowed).

as_dict_atom(Dict, Key, Atom) :- get_dict(Key, Dict, Value), as_symbol(Value, Atom).

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
    as_dict_atom(Dict, movement_id, Movement),
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
    as_dict_atom(Dict, movement_id, Movement),
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

as_input_dict(Dict, Input, InputId) :-
    is_dict(Dict), get_dict(schema, Dict, Schema0), as_symbol(Schema0, Schema),
    as_input_schema(Schema),
    ( Schema == 'miter-assistant-input-v1' -> as_input_dict_v1(Dict, Input, InputId)
    ; Schema == 'miter-assistant-input-v2' -> as_input_dict_v2(Dict, Input, InputId)
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
      as_json_carriers(Root, leased, Leased),
      as_json_carriers(Root, inbox, Inbox),
      append(Leased, Inbox, Files), as_config(Root, max_input_batch, Max),
      as_take_limit(Files, Max, Selected),
      as_take_inputs(Root, Selected, Inputs)), _, fail) -> true ; Inputs=[] ), !.

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
      miter_store_read_json(Source, Dict), as_input_dict(Dict, Input, InputId),
      Outcome=accepted(Input), as_receipt(Root, InputId, leased, Name)), _,fail)
    -> true ; as_reject_input(Root, Name, Source, Outcome) ), !.
as_take_input(Root, carrier(inbox,Name), Outcome) :-
    as_path(Root, inbox, Inbox), directory_file_path(Inbox, Name, Source),
    ( catch((size_file(Source, Size), as_config(Root, max_input_bytes, Max), Size =< Max,
      miter_store_read_json(Source, Dict), as_input_dict(Dict, Input, InputId),
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
      as_path(Root, 'checkpoints/active.term', TermPath),
      as_write_term_atomic(TermPath, Snapshot),
      crypto_file_hash(TermPath, Hash, [algorithm(sha256),encoding(octet)]),
      atom_string(Hash, HashString), get_time(Now),
      as_path(Root, 'checkpoints/active.json', MetaPath),
      as_write_json_durable(MetaPath, _{schema:"miter-assistant-checkpoint-v1",
        sha256:HashString,recorded_at_epoch:Now}),
      as_commit_leases(Root)), _, fail) -> Result=checkpointed
    ; Result='checkpoint-failed' ), !.

as_restore(Root0, Snapshot) :-
    ( catch((as_root(Root0, Root), as_path(Root, 'checkpoints/active.term', TermPath),
      as_path(Root, 'checkpoints/active.json', MetaPath),
      ( \+ exists_file(TermPath), \+ exists_file(MetaPath) -> Snapshot='no-checkpoint'
      ; exists_file(TermPath), exists_file(MetaPath),
        miter_store_read_json(MetaPath, Meta), as_dict_atom(Meta, schema, 'miter-assistant-checkpoint-v1'),
        get_dict(sha256, Meta, Expected0), as_sha256(Expected0, Expected),
        crypto_file_hash(TermPath, Actual, [algorithm(sha256),encoding(octet)]),
        Actual==Expected,
        setup_call_cleanup(open(TermPath,read,Stream,[encoding(utf8)]),
          read_term(Stream,Term,[syntax_errors(error)]),close(Stream)),
        Term=['assistant-snapshot',_,_], Snapshot=Term )), _, fail) -> true
    ; Snapshot='checkpoint-invalid' ), !.

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
        project_scope:"ama-1.1",provenance_kind:"native-control",
        parent_event_ids:[],correlation_id:"assistant-service",
        payload:_{native_term:PayloadText}},
      atomic_list_concat(['intents/',EventId,'.json'], IntentRelative),
      as_path(Root, IntentRelative, IntentPath), as_write_json_durable(IntentPath, Intent),
      as_path(Root, store, Store), as_path(Root, 'lib/libmiter_store_posix.dylib', Extension),
      miter_store_append_event(Store, Extension, IntentPath, Append),
      Append=='event-appended', as_heartbeat(Root,Kind,Now)), _,fail)
    -> Result=recorded ; Result='record-failed' ), !.

% Commit an already-formed native VoiceRNA certificate to the isolated local
% outbox. This membrane validates the carrier and durability boundary only. It
% does not interpret the movement, compare participants, render language, or
% gain network/external-effect authority.
as_effect(Root0, Descriptor, Result) :-
    ( catch((as_root(Root0, Root),
      as_local_effect_descriptor(Descriptor, EffectId, Scope, Certificate, Hash),
      as_commit_local_effect(Root, EffectId, Scope, Certificate, Hash, Result0),
      Result=Result0), _, fail)
    -> true ; as_effect_id_or_unknown(Descriptor, EffectId0),
      Result=['local-effect-held',EffectId0,'mechanical-boundary'] ), !.

as_effect_id_or_unknown(Descriptor, EffectId) :-
    ( is_list(Descriptor), Descriptor=[_,Candidate|_], as_symbol(Candidate,EffectId)
    -> true ; EffectId='unknown-effect' ).

as_local_effect_descriptor(
    ['local-effect-descriptor-v1',EffectId0,IdempotencyKey0,Scope,
     [payload,Certificate],
     [capability,'local-isolated-outbox','no-network','no-external-authority'],
     prepared], EffectId, Scope, Certificate, Hash) :-
    as_symbol(EffectId0, EffectId), as_symbol(IdempotencyKey0, IdempotencyKey),
    EffectId==IdempotencyKey,
    as_local_scope(Scope), as_local_voice_certificate(Certificate, Scope),
    term_string(Certificate, CertificateText, [quoted(true),ignore_ops(true)]),
    string_length(CertificateText, Length), Length=<1048576,
    crypto_data_hash(CertificateText, Hash, [algorithm(sha256),encoding(utf8)]).

as_local_scope([scope,Principal0,Audience0,Project0]) :-
    as_symbol(Principal0,_), as_symbol(Audience0,_), as_symbol(Project0,_).

as_local_voice_certificate(
    ['assistant-voice-certificate-v1',
     ['VoiceRNA','bounded-native-expression'],
     ['source-cut',CutId0],Scope,
     ['movement-source',Movement],
     ['intended-expression',['local-response',Summary]],
     ['participant-boundaries',Participants],
     ['voice-audit','source-bound','uncertainty-retained','no-added-authority'],
     'no-emission-authority'], Scope) :-
    as_local_cut_id(CutId0),
    as_local_movement(Movement), as_local_summary(Summary),
    Participants=['participant-reentry-organization',
      'differentiated-by-source-scope-and-lineage',Readings,
      'repeated-same-lineage-is-not-independent-support'],
    is_list(Readings), ground(Readings).

as_local_cut_id(['cut-of',Contact0,Proto0]) :-
    as_symbol(Contact0,_), as_symbol(Proto0,_).

as_local_movement([Kind|Rest]) :-
    memberchk(Kind,['movement-formed','movement-plural-live','movement-unresolved']),
    Rest=[_|_], ground(Rest).

as_local_summary(['movement-standing'|Rest]) :- Rest=[_|_], ground(Rest).

as_commit_local_effect(Root, EffectId, Scope, Certificate, Hash, Result) :-
    atomic_list_concat(['outbox/',EffectId,'.json'], Relative),
    as_path(Root, Relative, Path),
    ( exists_file(Path) ->
        as_verify_local_effect(Path, EffectId, Scope, Hash),
        as_local_effect_receipt(Root, EffectId, Hash, 'duplicate-observed'),
        Result=['local-effect-duplicate',EffectId,Hash]
    ; as_local_effect_dict(EffectId, Scope, Certificate, Hash, Dict),
      as_write_json_durable(Path, Dict),
      as_local_effect_receipt(Root, EffectId, Hash, committed),
      Result=['local-effect-committed',EffectId,Hash] ).

as_local_effect_dict(EffectId, [scope,Principal,Audience,Project], Certificate, Hash,
    _{schema:"miter-local-effect-v1",effect_id:EffectId,idempotency_key:EffectId,
      principal:Principal,audience:Audience,project:Project,
      certificate_sha256:Hash,native_certificate:CertificateText,
      capability:"local-isolated-outbox",network_access:false,
      external_effect:false,standing:"committed-local-only"}) :-
    term_string(Certificate, CertificateText, [quoted(true),ignore_ops(true)]).

as_verify_local_effect(Path, EffectId, [scope,Principal,Audience,Project], Hash) :-
    miter_store_read_json(Path, Dict),
    as_dict_atom(Dict,schema,'miter-local-effect-v1'),
    as_dict_atom(Dict,effect_id,EffectId),
    as_dict_atom(Dict,idempotency_key,EffectId),
    as_dict_atom(Dict,principal,Principal), as_dict_atom(Dict,audience,Audience),
    as_dict_atom(Dict,project,Project),
    as_dict_atom(Dict,certificate_sha256,Hash),
    as_dict_atom(Dict,capability,'local-isolated-outbox'),
    get_dict(network_access,Dict,false), get_dict(external_effect,Dict,false),
    as_dict_atom(Dict,standing,'committed-local-only').

as_local_effect_receipt(Root, EffectId, Hash, Standing) :-
    atomic_list_concat(['receipts/effect-',EffectId,'.json'], Relative),
    as_path(Root,Relative,Path), get_time(Now),
    as_write_json_durable(Path, _{schema:"miter-assistant-effect-receipt-v1",
      effect_id:EffectId,idempotency_key:EffectId,certificate_sha256:Hash,
      capability:"local-isolated-outbox",standing:Standing,
      network_access:false,external_effect:false,observed_at_epoch:Now}).

as_heartbeat(Root, Kind, Now) :-
    as_path(Root, 'heartbeat.json', Path),
    as_write_json_durable(Path, _{schema:"miter-assistant-heartbeat-v1",
      state:Kind,observed_at_epoch:Now}).

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
