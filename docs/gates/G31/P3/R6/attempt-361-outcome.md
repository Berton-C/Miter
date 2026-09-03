# G31 P3 R6 attempt 361 — canonical standing passed; severed failure was not observable

R6 resumed entirely from attempt 351's committed provider observation, call owner, and candidate bytes. It performed no OpenRouter call or credential lookup. The candidate identity and exact one-line transform were verified, compilation passed, the corrected exact-repeat assertion passed as `stale_cursor`, the full canonical mock observation was returned, and native MeTTa constructed `g31-p3-candidate-qualified`.

The severed mapping control then failed at the observation boundary. Removing `pending_post_id` made the checked Prolog relation fail normally, as intended, but `g31_p3_mock_trial/3` converted only exceptions into a typed failure. Normal failure therefore produced no result for MeTTa to interpret, and the builder stopped.

This is an offline membrane-totality defect, not candidate success on the negative control. No model, network, credential, Mattermost, message, activation, or promotion effect occurred.

R7 will totalize the mock membrane so normal contract failure and exceptions both become explicit `g31-p3-mock-failure` observations, then rerun the captured-byte continuation and all remaining causal tests.
