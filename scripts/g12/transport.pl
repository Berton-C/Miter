:- ensure_loaded('../../effect_membranes/miter_chroma_service.pl').
:- initialization(main,main).
main([Request,Output,Expected]) :-
    miter_chroma_service_request('config/chroma-service.json','config/embedding-profile.json',Request,Output,R),
    writeln(R),(R==Expected->true;halt(1)).
