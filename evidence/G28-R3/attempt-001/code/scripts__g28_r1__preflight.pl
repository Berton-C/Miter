% Offline replay fixture readback. Never used to generate or admit code.
:- ensure_loaded('../../effect_membranes/miter_executable_development_v2.pl').
pf_question(R,Q) :- wy_path(R,'opportunity.json',P),rv_json(P,D),tv_document_native(D,O),
 Q=['executable-generation','replay-probe',O,1,'qwen-local',"Synthetic replay fixture: do not send",'no-prior-trial'].
