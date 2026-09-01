; nace_beliefs.metta -- DYNAMIC belief store.
; Definitions live in nace_substrate.metta (static, never written here).
; One atom per capability: (cap-efficacy <name> (stv <freq> <conf>)).
; New capability starts agnostic (stv 0.5 0.0).
(cap-efficacy web-search (stv 0.5 0.0))
(cap-efficacy file-write (stv 0.5 0.0))
(cap-efficacy metta-query (stv 0.5 0.0))