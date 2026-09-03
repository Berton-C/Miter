% Test-owner mutation of the isolated laboratory only; not a runtime capability.
:- ensure_loaded('../../effect_membranes/miter_undertaking.pl').
:- initialization(main,main).
main([Root,Kind]) :-
 miter_store_ensure_extension('/Users/claritymiter/miter/runtime/g07/libmiter_store_posix.dylib'),u_load(Root,W),
 (Kind==continuity_severed->u_path(Root,'seed.json',P),u_read_json(P,S),put_dict(state,W,S.state,N)
 ;Kind==relevant_contact->subtract(W.edges,[[edge,artifact,original]],E),V is W.revision+1,put_dict(_{edges:E,revision:V},W,N)
 ;Kind==unrelated_contact->V is W.revision+1,append(W.edges,[[edge,other,observation]],E),put_dict(_{edges:E,revision:V},W,N)
 ;Kind==revoke->W.grant=[G,P,J,_],put_dict(grant,W,[G,P,J,revoked],N)
 ;Kind==purpose_missing->exclude(purpose_record,W.records,Records),put_dict(records,W,Records,N)
 ;Kind==stale_semantics->W.state=[A,B,C,D,E,F,G,H,_|Rest],put_dict(state,W,[A,B,C,D,E,F,G,H,'old-semantic-version'|Rest],N)),
 u_save(Root,N).
purpose_record([node,'purpose-source'|_]).
