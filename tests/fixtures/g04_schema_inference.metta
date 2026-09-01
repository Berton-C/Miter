!(bind! &g04-results (new-space))

(= (admit-if-valid $status $alias)
   (if (== $status semantic-result-valid)
       (let $ignored (add-atom &g04-results (semantic-result g04-fixed-request-001 $alias validated))
            semantic-result-admitted)
       $status))

!(import! &self (library lib_import))
!(import_prolog_functions_from_file "./effect_membranes/miter_llm.pl" (miter_lm_prepare_request miter_lm_execute_request miter_lm_parse_result))

!(miter_lm_prepare_request "./config/local/g03-model-profiles.json" "qwen-local" "./tests/fixtures/g04_structured_request.json" "./runtime/g04/qwen.request.json")
!(miter_lm_execute_request "./runtime/g04/qwen.request.json" "./runtime/g04/qwen.raw.json" "./runtime/g04/qwen.timing.json")
!(let $qwen-status (miter_lm_parse_result "./tests/fixtures/g04_structured_request.json" "./runtime/g04/qwen.raw.json" "./runtime/g04/qwen.typed.json")
      (admit-if-valid $qwen-status qwen-local))

!(miter_lm_prepare_request "./config/local/g03-model-profiles.json" "nemotron-local" "./tests/fixtures/g04_nemotron_structured_request.json" "./runtime/g04/nemotron.request.json")
!(miter_lm_execute_request "./runtime/g04/nemotron.request.json" "./runtime/g04/nemotron.raw.json" "./runtime/g04/nemotron.timing.json")
!(let $nemotron-status (miter_lm_parse_result "./tests/fixtures/g04_nemotron_structured_request.json" "./runtime/g04/nemotron.raw.json" "./runtime/g04/nemotron.typed.json")
      (admit-if-valid $nemotron-status nemotron-local))

!(let $malformed-status (miter_lm_parse_result "./tests/fixtures/g04_structured_request.json" "./tests/fixtures/g04_malformed_response.json" "./runtime/g04/malformed.typed.json")
      (admit-if-valid $malformed-status malformed-mock))

!(collapse (match &g04-results (semantic-result $request $alias $standing)
                               (semantic-result $request $alias $standing)))
