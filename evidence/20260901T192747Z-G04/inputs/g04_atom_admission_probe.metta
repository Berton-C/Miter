!(bind! &g04-results (new-space))

(= (admit-if-valid $status $alias $path)
   (if (== $status semantic-result-valid)
       (let $ignored (add-atom &g04-results (semantic-result g04-fixed-request-001 $alias $path))
            semantic-result-admitted)
       $status))

!(admit-if-valid semantic-result-valid qwen-local qwen-result.json)
!(admit-if-valid malformed-model-response malformed-local malformed-result.json)
!(collapse (match &g04-results (semantic-result $request $alias $path)
                               (semantic-result $request $alias $path)))
