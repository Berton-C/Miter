; Sole supported bootstrap for the continuously cycling Miter runtime.
!(import! &self (library lib_import))
!(import_prolog_functions_from_file "./effect_membranes/integrity.pl"
  (miter_integrity_verify))
!(import_prolog_functions_from_file "./effect_membranes/assistant_service.pl"
  (as_config as_integrity as_control as_input as_checkpoint as_restore as_wait as_record as_effect
    as_native_id
    miter_assistant_continuity_restore miter_assistant_semantic_restore
    as_chroma))
!(import_prolog_functions_from_file "./effect_membranes/model.pl"
  (as_model as_model_direction))
!(import_prolog_functions_from_file "./effect_membranes/capability_environment.pl"
  (as_capability_environment as_capability_request))
!(import_prolog_functions_from_file "./effect_membranes/vad.pl"
  (as_vad))
; The functions remain MeTTa-owned cognitive reductions. This pinned runtime
; extension only schedules independent alternatives concurrently and returns
; them in their original order; it has no selection or semantic authority.
!(import_prolog_functions_from_file
  "./effect_membranes/runtime_extensions/petta_parallel.pl"
  (miter_petta_parallel_m25_primaries
    miter_petta_parallel_m25_readings
    miter_petta_parallel_m255_bridge_components
    miter_petta_clear_exact_validation_tables))
!(bind! &assistant_state (new-space))
!(bind! &assistant_history (new-space))
!(bind! &assistant_continuity (new-space))
!(bind! &assistant_semantic (new-space))
!(bind! &assistant_repair (new-space))
!(import! &soul "./constitution/soul.metta")
!(import! &fact9 "./constitution/fact9_projection.metta")
!(import! &compass "./constitution/soul_compass.metta")
!(import! &self "./src/soul.metta")
!(import! &self "./src/constitutive_foundation.metta")
!(import! &self "./src/scope_continuity.metta")
!(import! &self "./src/semantic_participation.metta")
!(import! &self "./src/assistant_reactor_foundation.metta")
; Capability possibility constructors must be known before the provisional
; dynamics compile inside authority_inheritance.  Otherwise PeTTa correctly
; preserves their names as inert atoms rather than silently treating them as
; executable cognition.
!(import! &self "./src/capability_environment.metta")
!(import! &self "./src/vad.metta")
!(import! &self "./src/authority_inheritance.metta")
!(import! &self "./src/constitutive_authority_joint.metta")
!(import! &self "./src/assistant_reactor_authority.metta")
; These modules depend on the completed AR4 preparation/incorporation seam.
; They must be imported here, not through nested import expressions, so their
; definitions causally inhabit the one runtime AtomSpace under pinned PeTTa.
!(import! &self "./src/dialogue_participation.metta")
!(import! &self "./src/soul_regeneration.metta")
!(import! &self "./src/assistant_service_runtime.metta")
