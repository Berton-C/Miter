# G00 Chroma backup and isolation plan

## Verified existing ClarityOmega state

- Client version: ChromaDB 1.5.9.
- Client mode: embedded `PersistentClient(path="./chroma_db")`; it is not an HTTP server.
- Host persistence: `/Users/bcb/Documents/ClarityOmega/clarityomega/volumes/omegaclaw/chroma_db`.
- Container mount: the host persistence is mounted read/write at `/PeTTa/chroma_db` in `clarity_omega`.
- Live writer: `clarity_omega`. It must be stopped before a consistent byte-for-byte backup.
- Inventory before the user restart: collection `memories`, dimension 1024, 44,631 embeddings.
- First read-only snapshot after the user restart: collection `memories`, dimension 1024, 44,640 embeddings.
- Completion snapshot while the writer remained active: collection `memories`, dimension 1024, 44,643 embeddings.
- Source size at inventory: 448,476 KiB. The destination filesystem had 1,024,047,796 KiB available.

The restart changed all six persistence-file hashes and the embedding count continued to advance while the writer remained active. That is evidence of a live writer, not permission to attach Miter to this persistence.

## Proposed backup procedure — not executed in G00

The exact reviewed destination is:

```text
/Users/bcb/Documents/Miter-Backups/clarityomega-chroma-g00-baseline/chroma_db
```

Before copying, obtain explicit approval for the service interruption, stop `clarity_omega`, and verify that no process has the source files open. Then create the destination and copy the directory:

```sh
mkdir -p /Users/bcb/Documents/Miter-Backups/clarityomega-chroma-g00-baseline
ditto /Users/bcb/Documents/ClarityOmega/clarityomega/volumes/omegaclaw/chroma_db /Users/bcb/Documents/Miter-Backups/clarityomega-chroma-g00-baseline/chroma_db
```

Generate relative-path SHA-256 manifests independently from the stopped source and the copy, compare them byte-for-byte, and retain both manifests with the backup record. Do not inspect or migrate from the copy unless the manifests match. Restart ClarityOmega only after the verified copy is complete.

No backup command above was executed during G00.

## Exact isolated Miter deployment proposal

- Image pin: `docker.io/chromadb/chroma:1.5.9@sha256:1e0b73a187a28757c572acba508c46f48c9e8b0acaf5c20e6d95cdedce1acdf6`.
- Apple-silicon manifest: `sha256:bd21353aee6ccdf4a57bd91e6001626826700f3838e1f230d4aae75bfd4889a1` (`linux/arm64`).
- Container name: `miter-chroma`.
- Local endpoint: `http://127.0.0.1:8001` mapped to container port 8000.
- Fresh named volume: `miter-chroma-v1`, mounted only at `/data` in `miter-chroma`.
- Fresh collection: `miter-ltm-v1`.
- Network exposure: loopback only.

This proposal never mounts the ClarityOmega persistence, never shares writable state with ClarityOmega, and leaves Chroma as a replaceable semantic index. G00 did not pull the image, create the container, create the volume, or create the collection.
