:- ensure_loaded('../../effect_membranes/miter_modules.pl').
:- initialization(main,main).
main :-
 Root='runtime/g21',directory_file_path(Root,store,S),make_directory_path(S),
 directory_file_path(S,'trajectory.jsonl',L),\+exists_file(L),
 copy_file('runtime/g20/canonical/store/trajectory.jsonl',L),
 directory_file_path(S,objects,O),copy_directory('runtime/g20/canonical/store/objects',O),
 miter_interest_cut('runtime/g20/canonical',Cut),
 miter_interest_id('runtime/g20/canonical','voice-expression-repair',Cut,Id),
 format(atom(OP),'runtime/g20/canonical/interests/~w/opportunity.json',[Id]),
 format(atom(QP),'runtime/g20/canonical/interests/~w/candidate-request.json',[Id]),
 directory_file_path(Root,'source-opportunity.json',DestO),copy_file(OP,DestO),
 directory_file_path(Root,'source-request.json',DestQ),copy_file(QP,DestQ),
 miter_module_source(Root,'module-source-verified'),writeln('g20-generation-source-verified').
