% Offline typed readback, not loaded by the organism.
:- ensure_loaded('../../effect_membranes/miter_executable_development_v2.pl').
dg_observation(Path,N) :- atom_string(P,Path),re_match('^/Users/claritymiter/miter/evidence/G28-R1/diagnostic-[0-9]+/(good|timeout|length|malformed|error)/observation[.]json$',P),
 rv_json(P,D),tv_document_native(D,N).
dg_incomplete(Path,[H,I,T,S,E,false,F,P,B,C,A]) :- dg_observation(Path,[H,I,T,S,E,_,F,P,B,C,A]).
