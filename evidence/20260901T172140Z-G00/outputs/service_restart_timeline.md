# Service-state timeline

- At the first inventory snapshot, `clarity_omega` and Mattermost were stopped while Postgres was running.
- The user then stated that ChromaDB was running. A new probe showed all three ClarityOmega Compose services running; Mattermost became healthy, while no Chroma HTTP listener appeared.
- The user then explicitly stated that ChromaDB had been restarted. The repeated probe showed `clarity_omega`, Mattermost, and Postgres running for about one minute; Mattermost returned HTTP 200 and Chroma ports 8000 and 8001 returned connection failure.
- Direct inspection of ClarityOmega's installed Chroma adapter showed `PersistentClient(path="./chroma_db")`. Therefore the observed running mode is embedded in `clarity_omega`, not a standalone Chroma HTTP server.
- The persistence changed during the user-initiated restart interval: the `memories` count rose from 44,631 to 44,640 and all six persistence-file hashes changed. It advanced again to 44,643 by the completion snapshot while the writer remained active. The audit made no Chroma write and did not copy, migrate, or attach Miter state.
