:- ensure_loaded('../../effect_membranes/miter_vad.pl').
:- initialization(main,main).
main :-
 % Entirely synthetic values; do not load or print the NRC lexicon.
 assertz(miter_vad_lex(zorb,0.1,0.2,0.3)),
 assertz(miter_vad_lex('zorb glim',0.7,0.8,0.9)),
 assertz(miter_vad_lex(glim,0.4,0.5,0.6)),
 miter_vad_scan([zorb,glim],[],exact_only,Ms,Unknown),
 writeln(Ms),writeln(Unknown),
 Ms=[m('zorb glim',0.7,0.8,0.9,2,exact)],Unknown=[],
 miter_vad_scan([zorb,glim],[glim],exact_only,Filtered,_),
 writeln(Filtered),Filtered=[m(zorb,0.1,0.2,0.3,1,exact)],
 writeln('synthetic-mwe-longest-pass').
