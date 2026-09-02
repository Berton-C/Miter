# Bounded VAD cue

Miter uses the NRC VAD Lexicon, created by Saif M. Mohammad at the National
Research Council Canada, as a private, read-only research asset.
Obtain it from the [lexicon homepage](https://saifmohammad.com/WebPages/nrc-vad.html).
References: Mohammad, *NRC VAD Lexicon v2: Norms for Valence, Arousal, and
Dominance for over 55k English Terms* (2025); Mohammad, *Obtaining Reliable
Human Ratings of Valence, Arousal, and Dominance for 20,000 English Words*
(ACL 2018). See the downloaded README for terms; commercial use requires
separate licensing. This repository does not distribute the lexicon.

Point ignored config/local/vad-asset.json at the locally acquired asset. The
public profile pins the v2.1 checksum and the -1..1 coordinate range. Prolog
checks source contact and asset bytes, tokenizes, searches longest exact
multi-word matches before unigrams, and only then optionally tries bounded
English suffix normalization. Raw lexical values stay in local process memory.
Neither a public API nor an extension may expose that lookup table.

PeTTa/MeTTa computes clause averages, coverage, bands, trajectory and presence
requirements. Thresholds in vad-profile.json are uncalibrated priors, not earned
confidence or Soul authority. Profiles published as evidence contain only
coarse aggregate bands, coverage, hashed term IDs and explicit limitations;
they do not reproduce per-term numeric ratings.

The required pivot sentence has an improving lexical trajectory. The required
minimization sentence does not: its lexical trajectory is ambiguous. A separate
bounded English discourse rule detects a final-clause minimizer plus unease
language. The output retains both findings instead of changing the lexical
measurement. Positive-ending, missing-minimizer, reversed-clause and alternate
sentence controls bound this rule. It is not a general sentiment model.

All outputs are affective-language-cue, never person-inner-state-fact. A small
conservative identity-term exclusion list supplements the asset's own filtering
but is not comprehensive. Irony, ambiguity and negation remain unresolved.
Sparse and absent matches withhold affective inference. No human-state memory
is admitted and no diagnosis is made.

Presence requirements can change; task permission cannot. TaskPermission has
only scope and task-fact inputs. The native permission dependency gate rejects
an affective-language-cue dependency, including the deliberately bad test policy.
VoiceRNA may use these cues only through its separately audited expression path.
