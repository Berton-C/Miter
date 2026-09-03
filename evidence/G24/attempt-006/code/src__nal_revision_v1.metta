; Qualified transitive operator closure from PeTTa lib/lib_nars.metta,
; pin ae66fa8e41dcd5539d614706bd4e5cfb34f9608d,
; SHA256 f2a1ab3be59c59128894367a2f52a12c0fafdf1fb26b4affedd48270b47d4b43.
; Only names are qualified. The upstream confidence clamp is library semantics,
; not a constitutional threshold. Production never calls the ambiguous originals.
;
; MIT License
; Copyright (c) 2025 Patrick Hammer
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

(= (MiterNAL_Truth_c2w $c)
   (/ $c (- 1 $c)))
(= (MiterNAL_Truth_w2c $w)
   (/ $w (+ $w 1)))
(= (MiterNAL_Truth_Revision (stv $f1 $c1)
                          (stv $f2 $c2))
   (let* (($w1 (MiterNAL_Truth_c2w $c1))
          ($w2 (MiterNAL_Truth_c2w $c2))
          ($w  (+ $w1 $w2))
          ($f (/ (+ (* $w1 $f1) (* $w2 $f2)) $w))
          ($c (MiterNAL_Truth_w2c $w)))
          (stv (min 1.00 $f) (min 0.99 (max (max $c $c1) $c2)))))
(= (MiterNAL_Truth_Expectation (stv $f $c))
   (+ (* $c (- $f 0.5)) 0.5))
