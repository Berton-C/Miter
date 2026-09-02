# Exact version identities — unchanged image pin

The pulled image and running container match the G00 release digest exactly.
The collection guard initially rejected its `/api/v2/version` response `1.0.0`
because it expected the distribution label `1.5.9`. No collection was created.
The maintenance trap restarted clarity_omega after 25 seconds. The six-file
backup had already been independently byte-verified.

Official release source at
https://github.com/chroma-core/chroma/blob/1.5.9/rust/frontend/src/server.rs
lines 649–654 hardcodes the API response to `1.0.0`. The same release's
`rust/cli/Cargo.toml` declares CLI version `1.4.4`, matching `chroma --version`
inside the pinned image. Short source excerpts are retained in raw/.

The config now records distribution, API, and CLI identities separately.
The image pin is unchanged. No alternate release was silently selected.
The HTTP version string is a protocol observation, not an image attestation;
Docker digest/mount/port evidence provides deployment identity.

ClarityOmega is back online. The remaining brief create/negative/readback test
will take fresh live before/after hashes and counts. It passes only if those
match, without another service interruption. The stopped-writer backup has its
own preserved source manifest, separate from this live isolation comparison.
