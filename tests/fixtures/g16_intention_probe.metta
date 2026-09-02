!(import! &self (library lib_import))
!(import_prolog_functions_from_file "./effect_membranes/miter_voice_transport.pl"
 (miter_voice_input miter_voice_source miter_voice_write_intention miter_voice_render
  miter_voice_schema miter_voice_clause_count miter_voice_clause miter_voice_contains miter_voice_length
  miter_voice_vad_request miter_voice_stage_path miter_voice_cue_id miter_voice_vad_high
  miter_voice_vad_ready miter_voice_audit_write miter_voice_audit_status))
!(import_prolog_functions_from_file "./effect_membranes/miter_vad.pl"
 (miter_vad_prepare miter_vad_prepare_source miter_vad_metric miter_vad_prior miter_vad_number
  miter_vad_contains miter_vad_clause_contains miter_vad_finish))
!(import! &self "/Users/claritymiter/miter/src/vad.metta")
!(import! &self "/Users/claritymiter/miter/src/voice_grammar.metta")
!(import! &self "/Users/claritymiter/miter/src/voice.metta")
!(VoiceKind "runtime/g16" boundary)
!(match &self (voice-kind $k) $k)
!(VoiceRequiredGroups boundary)
!(miter_voice_source "runtime/g16" boundary)
!(VoiceIntention "runtime/g16" boundary)
