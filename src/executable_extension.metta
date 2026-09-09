; Native schema for executable tentacles acquired through open growth.
; These functions validate exact carriers and returned mechanical contact.
; They do not select an extension, infer purpose, certify a candidate or decide
; that activation is warranted.  Those remain properties of the complete
; Soul-formed movement and its one simultaneous R/A/P read.

(= (C4ExecutableExtensionFileValid $file)
   (if (CPShape $file extension-file 4)
     (==
       ((== (is-expr (index-atom $file 1)) false)
        (== (is-expr (index-atom $file 2)) false)
        (== (is-expr (index-atom $file 3)) false))
       (true true true))
     false))

(= (C4ExecutableExtensionFilesValidAt $files $i)
   (if (< $i (size-atom $files))
     (and (C4ExecutableExtensionFileValid (index-atom $files $i))
          (C4ExecutableExtensionFilesValidAt $files (+ $i 1)))
     true))

(= (C4ExecutableExtensionTrialValid $trial)
   (if (CPShape $trial extension-trial-v1 5)
     (==
       ((== (is-expr (index-atom $trial 1)) false)
        (is-expr (index-atom $trial 2))
        (== (is-expr (index-atom $trial 3)) false)
        (== (is-expr (index-atom $trial 4)) false))
       (true true true true))
     false))

(= (C4ExecutableExtensionTrialsValidAt $trials $i)
   (if (< $i (size-atom $trials))
     (and (C4ExecutableExtensionTrialValid (index-atom $trials $i))
          (C4ExecutableExtensionTrialsValidAt $trials (+ $i 1)))
     true))

(= (C4ExecutableExtensionFlatValuesAt $values $i)
   (if (< $i (size-atom $values))
     (and (== (is-expr (index-atom $values $i)) false)
          (C4ExecutableExtensionFlatValuesAt $values (+ $i 1)))
     true))

(= (C4ExecutableExtensionManifestValid $manifest)
   (if (CPShape $manifest executable-extension-manifest-v1 18)
     (let* (($files-wrapper (index-atom $manifest 5))
            ($files (if (CPShape $files-wrapper source-files 2)
              (index-atom $files-wrapper 1) ()))
            ($authority (index-atom $manifest 9))
            ($permissions (if (CPShape $authority authority-contract 5)
              (index-atom (index-atom $authority 1) 1) ()))
            ($network (if (CPShape $authority authority-contract 5)
              (index-atom (index-atom $authority 2) 1) ()))
            ($credentials (if (CPShape $authority authority-contract 5)
              (index-atom (index-atom $authority 3) 1) ()))
            ($effects (if (CPShape $authority authority-contract 5)
              (index-atom (index-atom $authority 4) 1) ()))
            ($trials-wrapper (index-atom $manifest 11))
            ($trials (if (CPShape $trials-wrapper independent-trials 2)
              (index-atom $trials-wrapper 1) ()))
            ($memory-wrapper (index-atom $manifest 13))
            ($memory (if (CPShape $memory-wrapper memory-scopes 2)
              (index-atom $memory-wrapper 1) ())))
       (==
         ((CPShape (index-atom $manifest 1) extension-id 2)
          (CPShape (index-atom $manifest 2) extension-version 2)
          (CPShape (index-atom $manifest 3) purpose 2)
          (CPShape (index-atom $manifest 4) source-pressure 2)
          (CPShape $files-wrapper source-files 2)
          (> (size-atom $files) 0)
          (C4ExecutableExtensionFilesValidAt $files 0)
          (CPShape (index-atom $manifest 6) entrypoint 2)
          (CPShape (index-atom $manifest 7) interface-contract 4)
          (CPShape (index-atom $manifest 8) state-contract 3)
          (CPShape $authority authority-contract 5)
          (CPShape (index-atom $authority 1) permissions 2)
          (CPShape (index-atom $authority 2) network-surfaces 2)
          (CPShape (index-atom $authority 3) credential-capabilities 2)
          (CPShape (index-atom $authority 4) effect-classes 2)
          (C4ExecutableExtensionFlatValuesAt $permissions 0)
          (C4ExecutableExtensionFlatValuesAt $network 0)
          (C4ExecutableExtensionFlatValuesAt $credentials 0)
          (C4ExecutableExtensionFlatValuesAt $effects 0)
          (CPShape (index-atom $manifest 10) resource-envelope 3)
          (CPShape (index-atom (index-atom $manifest 10) 1)
            deadline-seconds 2)
          (CPShape (index-atom (index-atom $manifest 10) 2)
            maximum-output-bytes 2)
          (CPShape $trials-wrapper independent-trials 2)
          (> (size-atom $trials) 1)
          (C4ExecutableExtensionTrialsValidAt $trials 0)
          (CPShape (index-atom $manifest 12) runtime-contract 5)
          (CPShape $memory-wrapper memory-scopes 2)
          (C4ExecutableExtensionFlatValuesAt $memory 0)
          (== (index-atom $manifest 14)
            (rollback previous-active-version))
          (CPShape (index-atom $manifest 15) module-provenance 3)
          (CPShape (index-atom $manifest 16) human-approval 2)
          (== (index-atom $manifest 17) candidate-not-self-certifying))
         (true true true true true true true true true true true true true true
          true true true true true true true true true true true true true true
          true true true true)))
     false))

(= (C4ExecutableExtensionExpectedActiveValid $expected)
   (or (== $expected no-active-version)
       (CPShape $expected active-version 3)))

(= (C4ExecutableExtensionOperationValid $operation)
   (if (CPShape $operation extension-stage-v1 2)
     (C4ExecutableExtensionManifestValid (index-atom $operation 1))
     (if (CPShape $operation extension-trial-v1 4)
       (==
         ((== (is-expr (index-atom $operation 1)) false)
          (== (is-expr (index-atom $operation 2)) false)
          (== (is-expr (index-atom $operation 3)) false))
         (true true true))
       (if (CPShape $operation extension-activate-v1 6)
         (and
           (==
             ((== (is-expr (index-atom $operation 1)) false)
              (== (is-expr (index-atom $operation 2)) false)
              (== (is-expr (index-atom $operation 3)) false)
              (== (is-expr (index-atom $operation 4)) false))
             (true true true true))
           (C4ExecutableExtensionExpectedActiveValid
             (index-atom $operation 5)))
         (if (CPShape $operation extension-invoke-v1 4)
           (==
             ((== (is-expr (index-atom $operation 1)) false)
              (== (is-expr (index-atom $operation 2)) false)
              (is-expr (index-atom $operation 3)))
             (true true true))
           (if (CPShape $operation extension-rollback-v1 3)
             (==
               ((== (is-expr (index-atom $operation 1)) false)
                (== (is-expr (index-atom $operation 2)) false))
               (true true))
             false))))))

(= (C4ExecutableExtensionOperationKind $operation)
   (if (CPShape $operation extension-stage-v1 2) stage
     (if (CPShape $operation extension-trial-v1 4) trial
       (if (CPShape $operation extension-activate-v1 6) activate
         (if (CPShape $operation extension-invoke-v1 4) invoke
           (if (CPShape $operation extension-rollback-v1 3) rollback
             malformed-extension-operation))))))

(= (C4ExecutableExtensionOutcomeValid $outcome $operation)
   (if (and (C4ExecutableExtensionOperationValid $operation)
            (CPShape $outcome extension-workshop-result-v1 6))
     (==
       ((CPHas (index-atom $outcome 1)
          (staged trial-passed trial-failed activated invoked rolled-back
            held failed) 0)
        (== (index-atom $outcome 2)
          (operation (C4ExecutableExtensionOperationKind $operation)))
        (CPShape (index-atom $outcome 3) extension 3)
        (== (index-atom $outcome 5)
          mechanical-observation-no-meaning-no-movement-authority))
       (true true true true))
     false))

(= (C4ExecutableExtensionCapability $operation)
   (if (C4ExecutableExtensionOperationValid $operation)
     (capability executable-extension-workshop no-credential
       reversible-local-tentacle)
     no-executable-extension-capability))

(= (C4ExecutableExtensionResource $operation)
   (if (C4ExecutableExtensionOperationValid $operation)
     (resource executable-extension-workshop)
     (resource unavailable-executable-extension-workshop)))
