% Narrow PeTTa/SWI scheduling groundings for independent native reductions.
%
% The cognitive constructors invoked here are defined in MeTTa. This layer
% preserves input order and invokes each exact constructor for one complete
% result family.  Exact cardinality is part of the mechanical grounding
% contract: one result is carried unchanged; zero or plural results are carried
% as unresolved native evidence with their exact source.  This prevents a
% failed once/1 from erasing the whole service query and prevents once/1 from
% silently selecting one result.  MeTTa remains responsible for interpreting
% the unresolved carrier.  This layer does not inspect, filter, score, rank,
% join, or select returned primaries/readings and cannot invoke an arbitrary
% predicate supplied by a model or surface.

% These three predicates are pure MeTTa structural validators over exact
% ground carriers. They are tabled only so repeated validation inside one
% material contact can share the identical result. The complete cycle wrapper
% below opens and destroys that scope with setup_call_cleanup/3; unlike the
% former process-lifetime cache, no developmental carrier can accumulate
% across contacts, held returns, or idle cycles.
:- table 'M255GenSigStructuralValid'/2.
:- table 'M255GenTranslationValid'/2.
:- table 'M255TranslationLawWitnessValid'/3.

miter_petta_clear_cycle_validation_tables :-
    abolish_table_subgoals('M255GenSigStructuralValid'(_,_)),
    abolish_table_subgoals('M255GenTranslationValid'(_,_)),
    abolish_table_subgoals('M255TranslationLawWitnessValid'(_,_,_)).

% Execute exactly the one named native cycle constructor inside a bounded
% structural-validation scope. This membrane neither inspects its rows nor
% interprets a standing: it carries the sole result unchanged and makes zero
% or plural native results explicit. Soul, R/A/P, movement, and effect
% formation remain wholly inside AS4CycleStep in MeTTa.
miter_petta_c4_cycle_step(Root, Inputs, Step) :-
    setup_call_cleanup(
      miter_petta_clear_cycle_validation_tables,
      findall(Candidate, 'AS4CycleStep'(Root, Inputs, Candidate), Candidates),
      miter_petta_clear_cycle_validation_tables),
    ( Candidates = [Only] ->
        Step = Only
    ; length(Candidates, Count),
      Step = ['c4-native-cycle-reduction-unresolved-v1',
        ['result-count', Count],
        'native-cardinality-observation-no-movement-authority']
    ).

miter_petta_bounded_m25_readings(Primaries, Cut, Developmental, Readings) :-
    is_list(Primaries),
    maplist(miter_petta_m25_reading(Cut, Developmental), Primaries, Readings).

miter_petta_m25_reading(Cut, Developmental, Primary, Reading) :-
    findall(Candidate,
      'M25MovementReading'(Primary, Cut, Developmental, Candidate),
      Candidates),
    ( Candidates = [Only] ->
        Reading = Only
    ; length(Candidates, Count),
      Reading = ['m25-native-reading-reduction-unresolved-v1',
        ['source-primary', Primary], ['result-count', Count],
        'native-cardinality-observation-no-movement-authority']
    ).

miter_petta_parallel_m25_primaries(Possibilities, Cut, Facts, Flourishing,
      ParticipantRelations, Bridge, FactViews, FlourishingViews,
      ParticipantSource, PayloadRef, Developmental, Primaries) :-
    is_list(Possibilities),
    miter_petta_m25_primaries_in_order(Possibilities, Cut, Facts,
      Flourishing, ParticipantRelations, Bridge, FactViews,
      FlourishingViews, ParticipantSource, PayloadRef, Developmental,
      Primaries).

% Each PeTTa worker receives a copy of the complete ground contact surface.
% Dispatching workers therefore multiplies the largest native term without
% changing any mathematical result.  Form the independent primaries one at a
% time in source order so the live organism retains only one working copy of
% that surface.  Every possibility remains present; this membrane has no
% result-dependent branch.
miter_petta_m25_primaries_in_order([], _Cut, _Facts, _Flourishing,
      _ParticipantRelations, _Bridge, _FactViews, _FlourishingViews,
      _ParticipantSource, _PayloadRef, _Developmental, []).
miter_petta_m25_primaries_in_order([Possibility|Rest], Cut, Facts, Flourishing,
      ParticipantRelations, Bridge, FactViews, FlourishingViews,
      ParticipantSource, PayloadRef, Developmental, [Primary|Primaries]) :-
    miter_petta_m25_primary(Cut, Facts, Flourishing, ParticipantRelations,
      Bridge, FactViews, FlourishingViews, ParticipantSource, PayloadRef,
      Developmental, Possibility, Primary),
    miter_petta_m25_primaries_in_order(Rest, Cut, Facts, Flourishing,
      ParticipantRelations, Bridge, FactViews, FlourishingViews,
      ParticipantSource, PayloadRef, Developmental, Primaries).

miter_petta_m25_primary(Cut, Facts, Flourishing, ParticipantRelations,
      Bridge, FactViews, FlourishingViews, ParticipantSource, PayloadRef,
      Developmental, Possibility, Primary) :-
    findall(Candidate,
      'M25PrimaryMovement'(Possibility, Cut, Facts, Flourishing,
        ParticipantRelations, Bridge, FactViews, FlourishingViews,
        ParticipantSource, PayloadRef, Developmental, Candidate),
      Candidates),
    ( Candidates = [Only] ->
        Primary = Only
    ; length(Candidates, Count),
      Primary = ['m25-native-primary-reduction-unresolved-v1',
        ['source-possibility', Possibility], ['result-count', Count],
        'native-cardinality-observation-no-movement-authority']
    ).

% Semantic evidence re-enters one complete, named constitutive constructor.
% Treat its result cardinality exactly like the lower M25 reductions above so
% an empty native family cannot erase the enclosing always-on service query and
% a plural family cannot be silently narrowed by the host.  The complete input
% organization remains present in the unresolved carrier for native MeTTa.
miter_petta_c4_reformed_encounter(Contact, Additional, Grounded, Reformed) :-
    findall(Candidate,
      'CP2ReformFreshGroundedWithParticipants'(Contact, Additional, Grounded,
        Candidate),
      Candidates),
    ( Candidates = [Only] ->
        Reformed = Only
    ; length(Candidates, Count),
      Reformed = ['c4-native-reformation-reduction-unresolved-v1',
        ['source-contact', Contact], ['additional-participants', Additional],
        ['source-grounded-encounter', Grounded],
        ['result-count', Count],
        'native-cardinality-observation-no-movement-authority']
    ).

% A complete M25 reading contains eight independent MeTTa-defined bridge
% projections.  They are carried one at a time in input order so the living
% AtomSpace is never multiplied across worker stacks.  The membrane still
% cannot inspect, filter, rank, select, or change a result.
miter_petta_parallel_m255_bridge_components(Primary, Cut, Developmental, Rap,
      Alignment, Interface, Components) :-
    Tags = [harmonic, interface, obstruction, stuck, reorganization,
      equivalence, recognition, align9],
    miter_petta_m255_bridge_components_in_order(Tags, Primary, Cut,
      Developmental, Rap, Alignment, Interface, Components).

% The eight projections are all retained, but only two copies of their shared
% primary/cut carrier must not inhabit concurrent worker stacks.  Serial native
% formation keeps scheduling proportional to one live surface.
miter_petta_m255_bridge_components_in_order([], _Primary, _Cut,
      _Developmental, _Rap, _Alignment, _Interface, []).
miter_petta_m255_bridge_components_in_order([Tag|Rest], Primary, Cut,
      Developmental, Rap, Alignment, Interface, [Result|Results]) :-
    miter_petta_m255_bridge_component(Primary, Cut, Developmental, Rap,
      Alignment, Interface, Tag, Result),
    miter_petta_m255_bridge_components_in_order(Rest, Primary, Cut,
      Developmental, Rap, Alignment, Interface, Results).

miter_petta_m255_bridge_component(Primary, Cut, Developmental, Rap,
      Alignment, Interface, Tag, Result) :-
    findall(Candidate,
      miter_petta_m255_bridge_candidate(Primary, Cut, Developmental, Rap,
        Alignment, Interface, Tag, Candidate), Candidates),
    ( Candidates = [Only] ->
        Result = Only
    ; length(Candidates, Count),
      Result = ['m255-native-bridge-component-unresolved', Tag,
        ['result-count', Count]]
    ).

miter_petta_m255_bridge_candidate(Primary, Cut, _Developmental, Rap,
      Alignment, _Interface, harmonic, Result) :-
    'M255HarmonicAlignmentBridge'(Primary, Cut, Rap, Alignment, Result).
miter_petta_m255_bridge_candidate(Primary, Cut, _Developmental, _Rap,
      _Alignment, Interface, interface, Result) :-
    'M255InterfaceEvolutionBridge'(Primary, Cut, Interface, Result).
miter_petta_m255_bridge_candidate(Primary, Cut, Developmental, _Rap,
      _Alignment, _Interface, obstruction, Result) :-
    'M255ObstructionSNSBridge'(Primary, Cut, Developmental, Result).
miter_petta_m255_bridge_candidate(Primary, Cut, Developmental, _Rap,
      _Alignment, _Interface, stuck, Result) :-
    'M255ThresholdedStuckBridge'(Primary, Cut, Developmental, Result).
miter_petta_m255_bridge_candidate(Primary, Cut, Developmental, _Rap,
      _Alignment, _Interface, reorganization, Result) :-
    'M255M24ReorganizationEvidenceBridge'(Primary, Cut, Developmental,
      Result).
miter_petta_m255_bridge_candidate(Primary, Cut, _Developmental, _Rap,
      _Alignment, _Interface, equivalence, Result) :-
    'M255EquivalenceNonAmalgamationBridge'(Primary, Cut, Result).
miter_petta_m255_bridge_candidate(Primary, Cut, _Developmental, _Rap,
      _Alignment, _Interface, recognition, Result) :-
    'M255RecognitionNonReconstructionBridge'(Primary, Cut, Result).
miter_petta_m255_bridge_candidate(Primary, Cut, Developmental, Rap,
      Alignment, _Interface, align9, Result) :-
    'M263Align9HarmonicBridge'(Primary, Cut, Developmental, Rap,
      Alignment, Result).
