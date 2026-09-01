; nace_pending.metta -- pending revision queue. The loop processes these each
; cycle via do-process-pending-revisions!, then removes each processed entry.
; Empty (no pending-revision atoms) means nothing to do this cycle.
;
; Shape: (pending-revision <cap> <outcome>)
; Valid outcomes: confirmed, disconfirmed. See nace_substrate.metta evidence-stv.
; The <cap> must be a capability with a line in nace_beliefs.metta (v1).
