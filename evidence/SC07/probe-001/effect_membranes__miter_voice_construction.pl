% SC07 mechanics only: exact lexical/type transport, not semantic decisions.
:- ensure_loaded('miter_relational_voice.pl').
vc_word(W,true) :- atom(W),atom_length(W,N),N>0,N=<64,atom_codes(W,C),maplist(vc_word_char,C),!.
vc_word(_,false).
vc_budget(N,true) :- integer(N),N>=0,N=<4096,!.
vc_budget(_,false).
vc_word_char(C) :- code_type(C,alnum);memberchk(C,[0'_,0'-]).
vc_sentence(W,S) :- is_list(W),W\=[],maplist(atom,W),atomic_list_concat(W,' ',A),atom_concat(A,'.',B),atom_string(B,S).
vc_module(P,N) :- catch((rv_json(P,D),vc_project(D,N)),_,fail),!.
vc_module(_,['malformed-candidate']).
vc_project(D,N) :- dict_pairs(D,_,Pairs),pairs_keys(Pairs,[allowed_effects,allowed_writes,candidate_id,constructions,purpose,schema]),
 string(D.schema),string(D.candidate_id),string(D.purpose),string_length(D.purpose,L),L>0,L=<500,
 is_list(D.constructions),maplist(vc_construction,D.constructions,Cs),
 is_list(D.allowed_writes),maplist(string,D.allowed_writes),is_list(D.allowed_effects),maplist(string,D.allowed_effects),
 rv_native(['voice-realization',D.schema,D.candidate_id,D.purpose,Cs,D.allowed_writes,D.allowed_effects],N).
vc_construction(D,[construction,D.id,D.meaning,Tokens]) :- dict_pairs(D,_,Pairs),pairs_keys(Pairs,[id,meaning,tokens]),
 string(D.id),string(D.meaning),is_list(D.tokens),maplist(vc_token,D.tokens,Tokens).
vc_token(S,[slot,Name]) :- string(S),sub_string(S,0,1,_,"@"),!,sub_string(S,1,_,0,Name).
vc_token(S,[literal,S]) :- string(S).
