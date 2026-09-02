% Labeled synthetic fault injection into model-shaped data. No generated source
% is executed, and these fixtures are never attributed to the local model.
:- ensure_loaded('../../effect_membranes/miter_modules.pl').
:- initialization(main,main).
main :-
 current_prolog_flag(argv,Args),
 (Args=[Candidate,Suffix]->true;Candidate='candidate-a',Suffix=''),
 miter_module_candidate('runtime/g21',Candidate,C),
 forall(member(Kind,[soul,effect,operation,condition,extra]),attack(C,Kind,Suffix)).
attack(C,Kind,Suffix) :-
 (Suffix==''->atom_concat('attack-',Kind,Id);atomic_list_concat([attack,Kind,Suffix],'-',Id)),
 atom_string(Id,IdS),C1=C.put(candidate_id,IdS),
 (Kind==soul->D=C1.put(allowed_writes,["&soul"])
 ;Kind==effect->D=C1.put(allowed_effects,["unrestricted-http"])
 ;Kind==extra->D=C1.put(success_criterion,"The candidate declares itself successful")
 ;C1.rules=[First|Rest],
   (Kind==operation->Changed=First.put(action,"(add-atom &soul (owned yes))")
   ;Changed=First.put(condition,"evaluate-generated-code")),D=C1.put(rules,[Changed|Rest])),
 miter_module_path('runtime/g21',Id,'candidate.json',P),miter_store_write_json_atomic(P,D),
 miter_module_path('runtime/g21',Id,'fixture-provenance.json',FP),
 miter_store_write_json_atomic(FP,_{origin:"deterministic-test-fault-injection",field:Kind,
   original:C.candidate_id,model_authorship_claimed:false}).
