% Offline probe; never in Miter's loaded runtime manifest.
:- ensure_loaded('../../effect_membranes/miter_executable_development_v2.pl').
:- initialization(main,main).
main([Request,Root,SecondsText]) :-
 atom_number(SecondsText,Seconds),
 directory_file_path(Root,'wire.bin',Wire),directory_file_path(Root,'header.json',Header),
 directory_file_path(Root,'timing.json',Timing),directory_file_path(Root,'observation.json',Obs),
 ms_capture(Request,Wire,Header,Seconds,2097152,T),tv_durable_json(Timing,T),
 wy_observation(diagnostic,Wire,T,O),tv_encode(O,Enc),tv_durable_json(Obs,_{native:O,term:Enc}).
