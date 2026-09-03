% Offline independent content-hash check; no native turn or driver replay loaded.
:- ensure_loaded('../../effect_membranes/miter_store.pl').
:- initialization(main,main).
main(Paths) :- forall(member(P,Paths),
 (miter_store_read_json(P,E),miter_store_canonical_json(E.body,J),crypto_data_hash(J,H,[algorithm(sha256),encoding(utf8)]),atom_string(H,E.hash))),halt(0).
