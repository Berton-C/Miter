; Native admission and standing policy. Prolog only reads/verifies bytes and
; carries out the exact durable-write/index/query request selected here.
(= (MemoryTypeAllowed $kind)
   (or (or (== $kind project-checkpoint) (== $kind relationship-preference))
       (or (or (== $kind fact) (== $kind decision))
           (or (or (== $kind commitment) (== $kind episode))
               (or (or (== $kind relationship) (== $kind open-question))
                   (or (== $kind learned-procedure) (== $kind developmental-trace)))))))

(= (MemoryAdmission $kind $durability $provenance $source)
   (if (== $durability transient) rejected-transient
     (if (== $source sources-verified)
       (if (== $durability durable)
         (if (MemoryTypeAllowed $kind)
           (if (or (== $provenance direct-contact) (== $provenance capsule-derived))
             admitted rejected-provenance)
           rejected-type)
         rejected-durability)
       rejected-source)))

(= (MemoryCandidateRNA $root $extension $candidate)
   (let* (($kind (miter_memory_field $candidate "memory_type"))
          ($durability (miter_memory_field $candidate "durability"))
          ($provenance (miter_memory_field $candidate "provenance_kind"))
          ($source (miter_memory_check_sources $root $candidate))
          ($decision (MemoryAdmission $kind $durability $provenance $source)))
     (if (== $decision admitted)
       (miter_memory_persist $root $extension $candidate)
       (miter_memory_reject $root $extension $candidate $decision))))

(= (MemoryStanding $root $id)
   (let $count (miter_memory_supersession_count $root $id)
     (if (< $count 0) malformed
       (if (> $count 0) superseded active))))

(= (IndexAdmittedMemoryRNA $root $id)
   (let $standing (MemoryStanding $root $id)
     (if (== $standing malformed) memory-integrity-failed
       (miter_memory_index $root $id $standing))))

; The caller supplies a trusted identity/scope, not a model-authored grant.
; Filter equality is fixed before nearest-neighbor ranking, never afterward.
(= (RecallRNA $root $principal $audience $project $standing $text $tag)
   (if (or (== $standing active) (== $standing superseded))
     (miter_memory_query $root $principal $audience $project $standing $text $tag)
     invalid-recall-standing))
