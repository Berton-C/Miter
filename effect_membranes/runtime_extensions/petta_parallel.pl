% Narrow PeTTa/SWI scheduling groundings for independent native reductions.
%
% The cognitive constructors invoked here are defined in MeTTa. This layer
% preserves input order and applies each exact constructor once. It does not
% inspect, filter, score, rank, join, or select returned primaries/readings and
% cannot invoke an arbitrary predicate supplied by a model or surface.

:- use_module(library(thread)).

% These predicates are pure MeTTa-defined structural validators over ground,
% immutable carriers. SWI tabling changes only repeated evaluation, never the
% returned truth value or the native definitions. Tables are process-local and
% cleared at every reactor-cycle boundary below so exact carrier growth cannot
% become an unbounded host-memory leak.
:- table 'M255GenSigStructuralValid'/2.
:- table 'M255GenTranslationValid'/2.
:- table 'M255TranslationLawWitnessValid'/3.

miter_petta_clear_exact_validation_tables(
      'exact-native-validation-tables-cleared') :-
    abolish_table_subgoals('M255GenSigStructuralValid'(_,_)),
    abolish_table_subgoals('M255GenTranslationValid'(_,_)),
    abolish_table_subgoals('M255TranslationLawWitnessValid'(_,_,_)).

miter_petta_parallel_m25_readings(Primaries, Cut, Developmental, Readings) :-
    is_list(Primaries),
    concurrent_maplist(miter_petta_m25_reading(Cut, Developmental),
      Primaries, Readings).

miter_petta_m25_reading(Cut, Developmental, Primary, Reading) :-
    once('M25MovementReading'(Primary, Cut, Developmental, Reading)).

miter_petta_parallel_m25_primaries(Possibilities, Cut, Facts, Flourishing,
      ParticipantRelations, Bridge, FactViews, FlourishingViews,
      ParticipantSource, PayloadRef, Developmental, Primaries) :-
    is_list(Possibilities),
    concurrent_maplist(
      miter_petta_m25_primary(Cut, Facts, Flourishing,
        ParticipantRelations, Bridge, FactViews, FlourishingViews,
        ParticipantSource, PayloadRef, Developmental),
      Possibilities, Primaries).

miter_petta_m25_primary(Cut, Facts, Flourishing, ParticipantRelations,
      Bridge, FactViews, FlourishingViews, ParticipantSource, PayloadRef,
      Developmental, Possibility, Primary) :-
    once('M25PrimaryMovement'(Possibility, Cut, Facts, Flourishing,
      ParticipantRelations, Bridge, FactViews, FlourishingViews,
      ParticipantSource, PayloadRef, Developmental, Primary)).

% Each component is an independent MeTTa-defined projection over the same
% already-formed primary/read surface.  This membrane fixes only their
% scheduling order and returns the eight opaque results.  MeTTa retains sole
% ownership of the bridge-family composition and every semantic boundary.
miter_petta_parallel_m255_bridge_components(Primary, Cut, Developmental, Rap,
      Alignment, Interface, Components) :-
    Tags = [harmonic, interface, obstruction, stuck, reorganization,
      equivalence, recognition, align9],
    concurrent_maplist(
      miter_petta_m255_bridge_component(Primary, Cut, Developmental, Rap,
        Alignment, Interface), Tags, Components).

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
