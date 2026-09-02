!(import! &self (library lib_import))
!(import_prolog_functions_from_file "./effect_membranes/miter_reactor.pl"
 (miter_reactor_input miter_reactor_obligation miter_reactor_config miter_reactor_record
  miter_reactor_checkpoint miter_reactor_step miter_reactor_wait))
!(import_prolog_functions_from_file "./effect_membranes/miter_integrity.pl" (miter_integrity_verify))
!(import! &soul "/Users/claritymiter/miter/constitution/soul.metta")
!(import! &self "/Users/claritymiter/miter/src/soul.metta")
!(import! &self "/Users/claritymiter/miter/src/reactor.metta")
