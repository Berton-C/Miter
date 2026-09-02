:- ensure_loaded('../../effect_membranes/miter_interests.pl').
:- initialization(main,main).
main([Report]) :-
 miter_store_read_json('derived/interest-proposals.json',D),D.proposals=[Q],
 forall(member(Kind,[bad_number,duplicate]),
   (format(atom(Root),'runtime/g20-probes/~w',[Kind]),directory_file_path(Root,'interest-proposals.json',P),
    (Kind==bad_number->Bad=Q.put(model_calls,"unbounded"),Proposals=[Bad];Proposals=[Q,Q]),
    miter_store_write_json_atomic(P,D.put(proposals,Proposals)),
    miter_interest_proposals(Root,['invalid-interest-proposals']))),
 miter_interest_proposals('runtime/g20-probes/nonexistent',['invalid-interest-proposals']),
 miter_interest_field('runtime/g20/canonical','voice-expression-repair',nonexistent,'invalid-field'),
 miter_interest_cut('runtime/g20/canonical',Cut),
 miter_interest_id('runtime/g20/canonical','voice-expression-repair',Cut,Before),
 Root='runtime/g20-probes/revised-proposal',directory_file_path(Root,'interest-proposals.json',P),
 Revised=Q.put(living_question,"Which unresolved distinction should the next bounded trial preserve?"),
 miter_store_write_json_atomic(P,D.put(proposals,[Revised])),
 miter_interest_id(Root,'voice-expression-repair',Cut,After),Before\==After,
 miter_store_write_json_atomic(Report,_{status:"PASS",malformed_and_missing_fail_closed:true,
  same_sources_changed_proposal_reconsidered:true,original_context_id:Before,revised_context_id:After}).
