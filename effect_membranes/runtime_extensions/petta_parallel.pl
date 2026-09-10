% Narrow PeTTa/SWI scheduling groundings for independent native reductions.
%
% The cognitive constructors invoked here are defined in MeTTa. This layer
% preserves input order and applies each exact constructor once. It does not
% inspect, filter, score, rank, join, or select returned primaries/readings and
% cannot invoke an arbitrary predicate supplied by a model or surface.

:- use_module(library(thread)).

miter_petta_bounded_m25_readings(Primaries, Cut, Developmental, Readings) :-
    is_list(Primaries),
    maplist(miter_petta_m25_reading(Cut, Developmental), Primaries, Readings).

miter_petta_m25_reading(Cut, Developmental, Primary, Reading) :-
    once('M25MovementReading'(Primary, Cut, Developmental, Reading)).

miter_petta_parallel_m25_primaries(Possibilities, Cut, Facts, Flourishing,
      ParticipantRelations, Bridge, FactViews, FlourishingViews,
      ParticipantSource, PayloadRef, Developmental, Primaries) :-
    is_list(Possibilities),
    miter_petta_m25_primaries_in_pairs(Possibilities, Cut, Facts,
      Flourishing, ParticipantRelations, Bridge, FactViews,
      FlourishingViews, ParticipantSource, PayloadRef, Developmental,
      Primaries).

% Each PeTTa worker receives a copy of the complete ground contact surface.
% Dispatching one worker per host core therefore multiplies the largest native
% term without changing any mathematical result.  Two independent primaries
% may still reduce concurrently, but the next ordered pair is not admitted
% until both exact results return.  Every possibility remains present and in
% source order; this membrane has no result-dependent branch.
miter_petta_m25_primaries_in_pairs([], _Cut, _Facts, _Flourishing,
      _ParticipantRelations, _Bridge, _FactViews, _FlourishingViews,
      _ParticipantSource, _PayloadRef, _Developmental, []).
miter_petta_m25_primaries_in_pairs([Possibility], Cut, Facts, Flourishing,
      ParticipantRelations, Bridge, FactViews, FlourishingViews,
      ParticipantSource, PayloadRef, Developmental, [Primary]) :-
    miter_petta_m25_primary(Cut, Facts, Flourishing, ParticipantRelations,
      Bridge, FactViews, FlourishingViews, ParticipantSource, PayloadRef,
      Developmental, Possibility, Primary).
miter_petta_m25_primaries_in_pairs([PossibilityA,PossibilityB|Rest], Cut,
      Facts, Flourishing, ParticipantRelations, Bridge, FactViews,
      FlourishingViews, ParticipantSource, PayloadRef, Developmental,
      [PrimaryA,PrimaryB|Primaries]) :-
    concurrent(2,
      [miter_petta_m25_primary(Cut, Facts, Flourishing,
         ParticipantRelations, Bridge, FactViews, FlourishingViews,
         ParticipantSource, PayloadRef, Developmental, PossibilityA,
         PrimaryA),
       miter_petta_m25_primary(Cut, Facts, Flourishing,
         ParticipantRelations, Bridge, FactViews, FlourishingViews,
         ParticipantSource, PayloadRef, Developmental, PossibilityB,
         PrimaryB)], []),
    miter_petta_m25_primaries_in_pairs(Rest, Cut, Facts, Flourishing,
      ParticipantRelations, Bridge, FactViews, FlourishingViews,
      ParticipantSource, PayloadRef, Developmental, Primaries).

miter_petta_m25_primary(Cut, Facts, Flourishing, ParticipantRelations,
      Bridge, FactViews, FlourishingViews, ParticipantSource, PayloadRef,
      Developmental, Possibility, Primary) :-
    once('M25PrimaryMovement'(Possibility, Cut, Facts, Flourishing,
      ParticipantRelations, Bridge, FactViews, FlourishingViews,
      ParticipantSource, PayloadRef, Developmental, Primary)).

% A complete M25 reading contains eight independent MeTTa-defined bridge
% projections.  They may run concurrently, but readings themselves are mapped
% above in input order so there can be only one such worker family at a time.
% This bounds thread stacks independently of the number of live possibilities;
% the membrane still cannot inspect, filter, rank, select, or change a result.
miter_petta_parallel_m255_bridge_components(Primary, Cut, Developmental, Rap,
      Alignment, Interface, Components) :-
    Tags = [harmonic, interface, obstruction, stuck, reorganization,
      equivalence, recognition, align9],
    miter_petta_m255_bridge_components_in_pairs(Tags, Primary, Cut,
      Developmental, Rap, Alignment, Interface, Components).

% The eight projections are all retained, but only two copies of their shared
% primary/cut carrier inhabit worker stacks at once.  This keeps scheduling
% proportional to the live native surface instead of to the host core count.
miter_petta_m255_bridge_components_in_pairs([], _Primary, _Cut,
      _Developmental, _Rap, _Alignment, _Interface, []).
miter_petta_m255_bridge_components_in_pairs([Tag], Primary, Cut,
      Developmental, Rap, Alignment, Interface, [Result]) :-
    miter_petta_m255_bridge_component(Primary, Cut, Developmental, Rap,
      Alignment, Interface, Tag, Result).
miter_petta_m255_bridge_components_in_pairs([TagA,TagB|Rest], Primary, Cut,
      Developmental, Rap, Alignment, Interface, [ResultA,ResultB|Results]) :-
    concurrent(2,
      [miter_petta_m255_bridge_component(Primary, Cut, Developmental, Rap,
         Alignment, Interface, TagA, ResultA),
       miter_petta_m255_bridge_component(Primary, Cut, Developmental, Rap,
         Alignment, Interface, TagB, ResultB)], []),
    miter_petta_m255_bridge_components_in_pairs(Rest, Primary, Cut,
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
