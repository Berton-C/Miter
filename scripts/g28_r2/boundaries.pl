% Offline read instrument. Never loaded by the organism's bootstrap.
:- ensure_loaded('../../effect_membranes/miter_executable_development_v3.pl').
xb_saved(R,Name,N) :- wz_path(R,Name,P),rv_json(P,D),tv_document_native(D,N).
xb_candidate(R,C) :- xb_saved(R,'final.json',['executable-awaiting-approval',['executable-promotion-proposal',_,C|_]|_]).
xb_generation(R,Q) :- xb_candidate(R,['executable-candidate',Id|_]),wz_named(R,Id,generation,P),rv_json(P,D),tv_document_native(D,Q).
xb_exhausted_question(R,['executable-generation','budget-probe',O,2,Model,Prompt,Feedback]) :-
 xb_generation(R,['executable-generation',_,O,_,Model,Prompt,Feedback]).
xb_opportunity(R,O) :- xb_saved(R,'opportunity.json',O).
xb_forged_manifest(R,C) :- xb_candidate(R,['executable-candidate',Id,F,M]),
 nth0(13,M,_,Rest),nth0(13,Changed,'self-approved',Rest),C=['executable-candidate',Id,F,Changed].
xb_forged_candidate(R,C) :- xb_candidate(R,['executable-candidate',Id,[['candidate-file',Path,Text,Hash]|Rest],M]),
 string_concat(Text,"\n# synthetic in-memory lineage tamper, never written\n",Changed),
 C=['executable-candidate',Id,[['candidate-file',Path,Changed,Hash]|Rest],M].
xb_neutral_candidate(R,C) :- xb_candidate(R,['executable-candidate',_,F,M]),
 append(Prefix,[['candidate-lineage',_,Pressure,Hashes]],M),append(Prefix,[['candidate-lineage','neutral-executable-id',Pressure,Hashes]],New),
 C=['executable-candidate','neutral-executable-id',F,New].
xb_receipt(R,Name,Receipt) :- wz_verify(R,D),format(atom(File),'receipts/~w.json',[Name]),ww_path(D.workshop_root,File,P),rv_json(P,J),ww_result(D.workshop_root,Name,J,Receipt).
