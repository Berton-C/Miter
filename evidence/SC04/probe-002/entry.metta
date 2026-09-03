!(import! &self "/Users/claritymiter/miter/src/bootstrap_grounded_language.metta")
!(let $r (let* (($t (miter_language_tokens "Please revise ledger.")) ($w (LUnpunctuate (LWords $t 0)))) (scanned $t $w (LParse $w))) (case-result probe $r))
