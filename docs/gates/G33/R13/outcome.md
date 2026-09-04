# G33 R13 outcome — runtime passed; closure needs version-aware correction

Status: **PASS-RUNTIME / CLOSURE INCOMPLETE**

Plan commit: `706e2d4c6b2957f67df90c420ae18476daed7f79`

Attempt 005 passed the four runtime claims through the promoted default v2
bootstrap. The exact R12 candidate was recomputed under the pinned v2 trial and
NAL/NACE consumers. The consequence-bearing arm produced one later maximum;
the consequence-severed arm retained two. Reverse manifest ordering preserved
candidate, trial and later maxima. A fresh process rehydrated the one maximum
without generation replay.

The original recurring process wrote a 6,914-byte final proof, received an
explicit stop, appended `reactor-stopped`, and exited status 0 without a signal
or harness timeout. Trial was 1,496 bytes, before/after ranking projections were
1,776/1,514 bytes, restart was 1,818 bytes, stdout was 22 bytes, and the entire
canonical runtime was 1,178,109 bytes. Model, credential, Mattermost, Chroma,
private-memory, human-emission and external-effect counts were all zero.

The independent R13 verifier passed. The historical R12 verifier failed only
because its freeze compares the old default-bootstrap hash to the deliberately
promoted current v2 file. R12 evidence itself was not altered. Because the R13
plan simultaneously permitted that default switch and treated any old-verifier
failure as a falsifier, R13 cannot honestly close under the original package.
A version-aware no-runtime correction must be frozen and executed next.
