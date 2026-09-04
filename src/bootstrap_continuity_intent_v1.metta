; G33 R2 fixed bootstrap. Generated JSON is read only as inert data and is
; never imported into an AtomSpace or evaluated as MeTTa.
!(import! &self (library lib_import))
!(import_prolog_functions_from_file "/Users/claritymiter/miter/effect_membranes/miter_resume.pl"
  (miter_resume_field miter_resume_registry_count miter_resume_registry_project
   miter_resume_begin miter_resume_witness miter_resume_answer miter_memory_query
   miter_continuity_reconstruct))
!(import_prolog_functions_from_file "/Users/claritymiter/miter/effect_membranes/miter_continuity_intent_v1.pl"
  (miter_continuity_reading_prepare miter_continuity_reading_execute
   miter_continuity_reading_parse miter_continuity_reading_field
   miter_continuity_reading_source_status miter_continuity_reading_claim_total
   miter_continuity_reading_relation_count miter_continuity_reading_claim_count
   miter_continuity_reading_project_kind))
!(import! &self "/Users/claritymiter/miter/src/memory.metta")
!(import! &self "/Users/claritymiter/miter/src/continuity_intent_v1.metta")
!(import! &self "/Users/claritymiter/miter/src/continuity.metta")
