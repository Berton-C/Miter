% Exact lexical transport only. No grammar, meaning, or constitutional judgment.
% Character offsets are zero-based Unicode codepoint offsets, end-exclusive.
miter_language_tokens(Text,Tokens) :-
 (string(Text)->string_codes(Text,Codes);atom(Text)->atom_codes(Text,Codes)),
 length(Codes,N),N=<8192,miter_language_scan(Codes,0,Tokens).
miter_language_scan([],_,[]).
miter_language_scan([C|Cs],I,Ts) :- code_type(C,space),!,J is I+1,miter_language_scan(Cs,J,Ts).
miter_language_scan([C|Cs],I,[[token,Word,I,J]|Ts]) :-
 (miter_language_word(C)->miter_language_take(Cs,Rest,[C],Rev),reverse(Rev,WordCodes)
 ;Rest=Cs,WordCodes=[C]),
 length(WordCodes,N),J is I+N,string_codes(S,WordCodes),string_lower(S,Lower),atom_string(Word,Lower),
 miter_language_scan(Rest,J,Ts).
miter_language_word(C) :- code_type(C,alnum);memberchk(C,[95,45]).
miter_language_take([C|Cs],Rest,Acc,Out) :- miter_language_word(C),!,miter_language_take(Cs,Rest,[C|Acc],Out).
miter_language_take(Rest,Rest,Acc,Acc).
