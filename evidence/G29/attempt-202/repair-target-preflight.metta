!(import! &self "/Users/claritymiter/miter/src/bootstrap_surface_extension_v1.metta")
!(let $input (sd_input "/Users/claritymiter/miter/evidence/G29/attempt-202") (result targets (SXRepairTargets (index-atom $input 4) (index-atom $input 5))))
!(let $input (sd_input "/Users/claritymiter/miter/evidence/G29/attempt-202") (let $targets (SXRepairTargets (index-atom $input 4) (index-atom $input 5)) (result ready (SXRepairReady $targets))))
