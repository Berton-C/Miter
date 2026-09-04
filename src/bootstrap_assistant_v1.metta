; AMA-1.1 bootstrap. Relative imports are resolved from the repository working
; directory by the supported launcher. Prolog imports below expose mechanics
; only; AssistantServiceStart remains the sole cognitive service controller.
!(import! &self (library lib_import))
!(import_prolog_functions_from_file "./effect_membranes/miter_integrity.pl"
  (miter_integrity_verify))
!(import_prolog_functions_from_file "./effect_membranes/miter_assistant_service_v1.pl"
  (as_config as_integrity as_control as_input as_checkpoint as_restore as_wait as_record))
!(bind! &assistant_state (new-space))
!(bind! &assistant_history (new-space))
!(import! &soul "./constitution/soul.metta")
!(import! &fact9 "./constitution/fact9_projection_v1.metta")
!(import! &compass "./constitution/soul_compass_v02.metta")
!(import! &self "./src/soul.metta")
!(import! &self "./src/constitutive_participation_v1.metta")
!(import! &self "./src/assistant_reactor_v1.metta")
