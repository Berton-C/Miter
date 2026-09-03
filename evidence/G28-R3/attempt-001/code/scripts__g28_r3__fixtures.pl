% Offline fixture reader only; not imported by the organism bootstrap.
:- ensure_loaded('../../effect_membranes/miter_workshop_promotion_v1.pl').
ef_case(R,Name,I,S) :- wp_root(R,A),directory_file_path(A,'fixtures.json',P),rv_json(P,D),
 atom_string(Name,N),member(Row,D.cases),Row.name==N,rv_native(Row.input,I),tv_document_native(Row.snapshot,S).
ef_pair(R,'broken-trial',[I,S]) :- ef_case(R,canonical,I,Old),nth0(3,Old,T,Rest),
 nth0(4,T,Smoke,TRest),nth0(2,Smoke,_,SRest),nth0(2,ChangedSmoke,1,SRest),nth0(4,ChangedTrial,ChangedSmoke,TRest),nth0(3,S,ChangedTrial,Rest),!.
ef_pair(R,'changed-cut',[I,S]) :- ef_case(R,canonical,I,Old),nth0(7,Old,_,Rest),nth0(7,S,stale,Rest),!.
ef_pair(R,'changed-bytes',[I,S]) :- ef_case(R,canonical,I,Old),nth0(11,Old,_,Rest),nth0(11,S,false,Rest),!.
ef_pair(R,N,[I,S]) :- ef_case(R,N,I,S).
