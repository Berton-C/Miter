% G02-only deterministic scalar boundary probe.
% The final argument is the single function-form result imported by PeTTa.

miter_probe_add(X, Y, Result) :-
    (   integer(X),
        integer(Y)
    ->  Sum is X + Y,
        format(atom(Result), 'miter_int_~d', [Sum])
    ;   Result = miter_error_expected_integers
    ),
    !.
