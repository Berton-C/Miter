% Narrow PeTTa/SWI scheduling groundings for independent native reductions.
%
% The cognitive constructors invoked here are defined in MeTTa. This layer
% preserves input order and applies each exact constructor once. It does not
% inspect, filter, score, rank, join, or select returned primaries/readings and
% cannot invoke an arbitrary predicate supplied by a model or surface.

:- use_module(library(thread)).

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
