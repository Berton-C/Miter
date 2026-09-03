# G31 P4 pre-implementation fidelity assessment

The initial P4 plan correctly requires a capability-limited Prolog mechanical layer, but its proposed `miter_mattermost_transport_v1.pl` name and “build one offline loopback transport” wording leave room for Work to author Mattermost-specific adapter behavior. That would conflict with D-024, C-099, S-1005, and the POC specification: Work may provide generic surface transport mechanics and fixed mocks, while the omitted Mattermost adapter must remain attributable to Miter.

P3's candidate already owns the Mattermost-specific mappings: authorized frame interpretation, stable event identities, create-post path/body, `pending_post_id`, reconnect, duplicate suppression, and panic. P4 therefore needs a generic laboratory transport that consumes a capability-limited typed descriptor and returns mechanical observations. The loopback fixture may emulate the exact destination contract, but it is test infrastructure and cannot become the adapter or decide live standing.

No P4 implementation or effect occurred under the ambiguous plan. P4 R1 narrows the filenames, representation, authorship boundary, and falsifiers before coding.
