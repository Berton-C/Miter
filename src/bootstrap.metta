; Sole supported bootstrap for the continuously cycling Miter runtime.
!(import! &self (library lib_import))
!(import_prolog_functions_from_file "./effect_membranes/integrity.pl"
  (miter_integrity_verify))
!(import_prolog_functions_from_file "./effect_membranes/assistant_service.pl"
  (as_config as_integrity as_control as_input as_checkpoint as_restore as_wait as_record as_effect
    miter_assistant_continuity_restore miter_assistant_semantic_restore))
!(bind! &assistant_state (new-space))
!(bind! &assistant_history (new-space))
!(bind! &assistant_continuity (new-space))
!(bind! &assistant_semantic (new-space))
!(import! &soul "./constitution/soul.metta")
!(import! &fact9 "./constitution/fact9_projection.metta")
!(import! &compass "./constitution/soul_compass.metta")
!(import! &self "./src/soul.metta")
!(import! &self "./src/constitutive_foundation.metta")
!(import! &self "./src/scope_continuity.metta")
!(import! &self "./src/semantic_participation.metta")
!(import! &self "./src/assistant_reactor_foundation.metta")
!(import! &self "./src/authority_inheritance.metta")
!(import! &self "./src/constitutive_authority_joint.metta")
!(import! &self "./src/assistant_reactor_authority.metta")
