; Trusted fixed bootstrap for bounded native VoiceRNA. Never evaluate model code.
!(import! &self (library lib_import))
!(import_prolog_functions_from_file "./effect_membranes/miter_voice_transport.pl"
 (miter_voice_input miter_voice_source miter_voice_write_intention miter_voice_render
  miter_voice_schema miter_voice_clause_count miter_voice_clause miter_voice_contains miter_voice_length
  miter_voice_vad_request miter_voice_stage_path miter_voice_cue_id miter_voice_vad_high
  miter_voice_vad_ready miter_voice_audit_write miter_voice_audit_status
  miter_voice_budget miter_voice_withhold))
!(import_prolog_functions_from_file "./effect_membranes/miter_voice_surface.pl"
 (miter_voice_store_root miter_voice_witness_id miter_voice_issue miter_voice_emit))
!(import_prolog_functions_from_file "./effect_membranes/miter_vad.pl"
 (miter_vad_prepare miter_vad_prepare_source miter_vad_metric miter_vad_prior miter_vad_number
  miter_vad_contains miter_vad_clause_contains miter_vad_finish))
!(import_prolog_functions_from_file "./effect_membranes/miter_integrity.pl" (miter_integrity_verify))
!(import_prolog_functions_from_file "./effect_membranes/miter_movement.pl" (miter_movement_source miter_movement_record))
!(import! &soul "/Users/claritymiter/miter/constitution/soul.metta")
!(import! &self "/Users/claritymiter/miter/src/soul.metta")
!(import! &self "/Users/claritymiter/miter/src/movement.metta")
!(import! &self "/Users/claritymiter/miter/src/vad.metta")
!(import! &self "/Users/claritymiter/miter/src/voice_grammar.metta")
!(import! &self "/Users/claritymiter/miter/src/voice.metta")
