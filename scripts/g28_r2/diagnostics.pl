% Offline observation-reader test instrument, not a cognitive consumer.
:- ensure_loaded('../../effect_membranes/miter_executable_development_v3.pl').
zd_read(Path,Transport,O) :- size_file(Path,N),
 T=_{transport:Transport,http_status:200,elapsed_ms:1,bytes:N},wz_observation(fixture,Path,T,O).
