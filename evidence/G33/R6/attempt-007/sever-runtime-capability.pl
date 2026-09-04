% G33 R5 mechanical membrane. It authenticates and projects an already
% accepted expressive capability and joins lexical tokens. It never chooses
% an expression, interprets an alteration, audits meaning, or certifies.
:- ensure_loaded('/Users/claritymiter/miter/effect_membranes/miter_store.pl').

rr_repo('/Users/claritymiter/miter/').
rr_candidate_hash('5c22eaadab79625bf9602e8ed553405a4774e83a1c19a46fe8226d4fa8f58356').
rr_active_hash('8ff2514c5274560cd7e5363376491fb74802ac5691ea3b31f6cf1939c2d02f03').
rr_closure_hash('9884bb7ebbac2e1f97e35073388af09c2f6619dd99ececa94120c900d99ec5f8').
rr_active_path('/Users/claritymiter/miter/evidence/G22/g26-001/accepted/active.json').
rr_closure_path('/Users/claritymiter/miter/docs/gates/G22/closure.json').
rr_runtime_path('/Users/claritymiter/miter/evidence/G33/R6/attempt-007/missing-runtime-reference.json').

rr_native(X, Y) :-
    ( string(X) -> atom_string(Y, X)
    ; is_list(X) -> maplist(rr_native, X, Y)
    ; Y = X
    ).

rr_regular_file(Path0, Path) :-
    miter_store_nonempty_atom(Path0, Path),
    sub_atom(Path, 0, 1, _, '/'),
    \+ sub_atom(Path, _, _, _, '..'),
    exists_file(Path),
    \+ read_link(Path, _, _),
    absolute_file_name(Path, Canonical,
        [file_type(regular), access(read), file_errors(fail)]),
    Canonical == Path.

rr_candidate_scope(Path) :-
    Path == '/Users/claritymiter/miter/evidence/G22/g26-001/accepted/candidate.json', !.
rr_candidate_scope(Path) :-
    sub_atom(Path, 0, _, _, '/Users/claritymiter/miter/evidence/G33/R5/'),
    \+ sub_atom(Path, _, _, _, '/../').

rr_hash(Path, Expected) :-
    crypto_file_hash(Path, Actual, [algorithm(sha256), encoding(octet)]),
    Actual == Expected.

rr_json(Path, Dict) :- catch(miter_store_read_json(Path, Dict), _, fail).

rr_project(D, Native) :-
    is_dict(D),
    dict_pairs(D, _, Pairs),
    pairs_keys(Pairs,
        [allowed_effects,allowed_writes,candidate_id,constructions,purpose,schema]),
    string(D.schema), string(D.candidate_id), string(D.purpose),
    is_list(D.constructions), maplist(rr_construction, D.constructions, Cs),
    D.allowed_writes == ["trial-expression"], D.allowed_effects == [],
    rr_native(['voice-realization',D.schema,D.candidate_id,D.purpose,Cs,
               D.allowed_writes,D.allowed_effects], Native).

rr_construction(D, [construction,D.id,D.meaning,Tokens]) :-
    is_dict(D), dict_pairs(D, _, Pairs), pairs_keys(Pairs, [id,meaning,tokens]),
    string(D.id), string(D.meaning), is_list(D.tokens),
    maplist(rr_token, D.tokens, Tokens).

rr_token(S, [slot,Name]) :-
    string(S), sub_string(S, 0, 1, _, "@"), !,
    sub_string(S, 1, _, 0, Name).
rr_token(S, [literal,S]) :- string(S).

rr_accepted(CandidatePath, Module, TrialHash) :-
    rr_regular_file(CandidatePath, Candidate), rr_candidate_scope(Candidate),
    rr_candidate_hash(CandidateHash), rr_hash(Candidate, CandidateHash),
    rr_active_path(ActivePath), rr_regular_file(ActivePath, Active),
    rr_active_hash(ActiveHash), rr_hash(Active, ActiveHash),
    rr_closure_path(ClosurePath), rr_regular_file(ClosurePath, Closure),
    rr_closure_hash(ClosureHash), rr_hash(Closure, ClosureHash),
    rr_json(Candidate, CandidateJson), rr_project(CandidateJson, Module),
    rr_json(Active, ActiveJson), rr_native(ActiveJson.native, ActiveNative),
    ActiveNative = ['development-intent',_,_,Module,
        ['trial-pins',_,CandidateHash,_,_],
        ['trial-admissible',_,Module,['trial-pins',_,CandidateHash,_,_],_,_],
        ['trial-evidence',TrialHash],['event-kind','accepted-development']].

rr_capability(Path, Result) :-
    ( catch(rr_accepted(Path, Module, TrialHash), _, fail)
    -> rr_candidate_hash(CandidateHash), rr_active_hash(ActiveHash),
       rr_closure_hash(ClosureHash),
       Result = ['accepted-expression-capability',Module,
          ['accepted-lineage',
             ['candidate-sha256',CandidateHash],
             ['active-receipt-sha256',ActiveHash],
             ['g22-closure-sha256',ClosureHash],
             ['trial-evidence-sha256',TrialHash],
             ['event-kind','accepted-development']],
          'no-emission-authority']
    ; Result = ['expression-capability-unaccepted',Path]
    ), !.

rr_runtime_capability(Purpose, Result) :-
    Purpose == 'relational-voice-repair',
    rr_runtime_path(ConfigPath),
    ( catch((rr_regular_file(ConfigPath, Config), rr_json(Config, D),
             is_dict(D), dict_pairs(D, _, Pairs),
             pairs_keys(Pairs, [candidate_path,construction_fuel,
                 external_human_emission,schema,standing]),
             miter_store_nonempty_atom(D.schema,
                 'miter-relational-voice-repair-runtime-v1'),
             miter_store_nonempty_atom(D.standing, 'accepted-development-only'),
             D.external_human_emission == false,
             integer(D.construction_fuel), D.construction_fuel > 0,
             D.construction_fuel =< 512,
             miter_store_nonempty_atom(D.candidate_path, Candidate),
             rr_accepted(Candidate, _, _)), _, fail)
    -> Result = ['repair-runtime-capability','accepted',Candidate,
                 D.construction_fuel,'no-emission-authority']
    ;  Result = ['repair-runtime-capability','unavailable','no-candidate',0,
                 'no-emission-authority']
    ), !.

vc_word(W, true) :-
    atom(W), atom_length(W, N), N > 0, N =< 64,
    atom_codes(W, Codes), maplist(rr_word_char, Codes), !.
vc_word(_, false).
rr_word_char(C) :- code_type(C, alnum); memberchk(C, [0'_,0'-]).

vc_budget(N, true) :- integer(N), N >= 0, N =< 512, !.
vc_budget(_, false).

vc_sentence(Words, Sentence) :-
    is_list(Words), Words \= [], maplist(atom, Words),
    atomic_list_concat(Words, ' ', Text), atom_concat(Text, '.', Atom),
    atom_string(Atom, Sentence).
