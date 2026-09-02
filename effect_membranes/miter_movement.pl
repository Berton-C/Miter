% Mechanical verified event lookup and certificate serialization.
% No eligibility, floor, scoring or promotion decision lives here.
% Trusted native caller supplies source context; output files are new diagnostic
% records, never Soul or a live effect. Failure is a typed error.
:- ensure_loaded('miter_store.pl').
miter_movement_source(Root,Id,Principal,Audience,Project,Kind,Result) :-
 catch((miter_store_load_ledger(Root,Lines),
        miter_store_analyze(Root,Lines,A,Events), A.status==valid,
        maplist(miter_store_nonempty_atom,[Id,Principal,Audience,Project,Kind],
                [I,P,U,J,K]),
        member(E,Events),
        maplist(miter_store_nonempty_atom,
          [E.event_id,E.source_principal,E.audience_scope,E.project_scope,E.provenance_kind],
          [I,P,U,J,K])
        -> Result='movement-source-verified'; Result='movement-source-invalid'),
       _,Result='movement-source-invalid'), !.
miter_movement_record(Path,Product,Result) :-
 catch((miter_movement_product(Product,D),
        \+ exists_file(Path), miter_store_write_json_atomic(Path,D)
        -> Result='movement-result-stored'; Result='movement-result-error'),
       _,Result='movement-result-error'), !.
miter_movement_product('movement-blocked',_{status:"blocked",certificate: null}).
miter_movement_product(['movement-certificate'|Fields],
                       _{status:"certified",certificate:D}) :-
 is_list(Fields), maplist(miter_movement_pair,Fields,Pairs),
 pairs_keys(Pairs,Keys), sort(Keys,Unique), length(Keys,N),length(Unique,N),
 dict_create(D,certificate,Pairs).
miter_movement_pair([Name,Value],Name-Value) :-
 atom(Name), ground(Value), (atomic(Value);is_list(Value)).
