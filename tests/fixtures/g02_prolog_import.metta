!(import! &self (library lib_import))
!(import_prolog_functions_from_file "./effect_membranes/miter_probe.pl" (miter_probe_add))

!(miter_probe_add 20 22)
!(miter_probe_add not_an_integer 22)
