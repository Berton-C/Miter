% Offline read instrument. Never loaded by the organism's bootstrap.
:- ensure_loaded('../../effect_membranes/miter_executable_development_v2.pl').
xb_saved(R,Name,N) :- wy_path(R,Name,P),rv_json(P,D),tv_document_native(D,N).
xb_candidate(R,C) :- xb_saved(R,'trial-1.json',['executable-trial',C|_]).
xb_generation(R,Q) :- xb_candidate(R,['executable-candidate',Id|_]),wy_named(R,Id,generation,P),rv_json(P,D),tv_document_native(D,Q).
xb_opportunity(R,O) :- xb_saved(R,'opportunity.json',O).
xb_forged_candidate(R,C) :- xb_candidate(R,['executable-candidate',Id,[['candidate-file',Path,Text,Hash]|Rest],M]),
 string_concat(Text,"\n# synthetic in-memory lineage tamper, never written\n",Changed),
 C=['executable-candidate',Id,[['candidate-file',Path,Changed,Hash]|Rest],M].
xb_neutral_candidate(R,C) :- xb_candidate(R,['executable-candidate',_,F,M]),
 append(Prefix,[['candidate-lineage',_,Pressure,Hashes]],M),append(Prefix,[['candidate-lineage','neutral-executable-id',Pressure,Hashes]],New),
 C=['executable-candidate','neutral-executable-id',F,New].
xb_receipt(R,Name,Receipt) :- wy_verify(R,D),format(atom(File),'receipts/~w.json',[Name]),ww_path(D.workshop_root,File,P),rv_json(P,J),ww_result(D.workshop_root,Name,J,Receipt).
