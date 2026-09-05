; AMA-1.2 R3 bootstrap. The promoted v1 modules remain the substrate;
; AssistantServiceStartV2 is the sole supported cognitive entry for this version.
!(import! &self (library lib_import))
!(import_prolog_functions_from_file "./effect_membranes/miter_integrity.pl"
  (miter_integrity_verify))
!(import_prolog_functions_from_file "./effect_membranes/miter_assistant_service_v1.pl"
  (as_config as_integrity as_control as_input as_checkpoint as_restore as_wait as_record as_effect
    miter_assistant_continuity_restore miter_assistant_semantic_restore))
!(bind! &assistant_state (new-space))
!(bind! &assistant_history (new-space))
!(bind! &assistant_continuity (new-space))
!(bind! &assistant_semantic (new-space))
!(import! &soul "./constitution/soul.metta")
!(import! &fact9 "./constitution/fact9_projection_v1.metta")
!(import! &compass "./constitution/soul_compass_v02.metta")
!(import! &self "./src/soul.metta")
!(import! &self "./src/constitutive_participation_v1.metta")
!(import! &self "./src/assistant_scope_continuity_v1.metta")
!(import! &self "./src/assistant_semantic_participation_v1.metta")
!(import! &self "./src/assistant_reactor_v1.metta")
!(import! &self "./src/authority_inheritance_v1.metta")
!(import! &self "./src/constitutive_participation_v2.metta")
!(import! &self "./src/assistant_reactor_v2.metta")
