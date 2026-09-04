; The NACE consumer import is intentionally absent. This total test adapter
; reports only whether an actual STV product was returned; it cannot create one.
!(import! &self (library lib_import))
!(import! &self "/Users/claritymiter/miter/src/participation.metta")
(= (G32R2NaceImportStanding)
 (let $product (NRevision (stv 0.5 0.5) (stv 1 0.5))
  (if (PShape $product stv 3)
   (nace-consumer-product $product)
   (nace-consumer-unavailable (raw $product)))))
