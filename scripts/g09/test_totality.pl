:- ensure_loaded('../../effect_membranes/miter_chroma_service.pl').
:- initialization(main, main).
main :-
    forall(member(Input-Expected,
        ['runtime/g09/wrong-profile.json'-'chroma-profile-mismatch',
         'runtime/g09/legacy-target.json'-'chroma-target-blocked',
         'runtime/g09/legacy-http.json'-'chroma-target-blocked',
         '/nonexistent/miter-request.json'-'chroma-membrane-error']),
        ( findall(R, miter_chroma_service_request('config/chroma-service.json',
                   'config/embedding-profile.json', Input,
                   'runtime/g09/totality.json', R), Results),
          (Results == [Expected] -> format('PASS ~w ~w~n', [Input, Results]); halt(1)) )),
    findall(R, miter_chroma_service_request([], [], [], [], R), Invalid),
    (Invalid == ['chroma-invalid-request'] -> writeln('PASS invalid-scalar total'); halt(1)).
