# Persisted Metadata

MooseNexus stores a portable project directory. Its metadata is JSON and its payload paths are relative to that project directory, so the directory can be copied, installed into another local repository, or carried in an OCI artifact bundle.

## Contract

The v1 contract covers these files:

| Path | Contents | Schema version |
| --- | --- | --- |
| `metadata/properties.json` | Project identity, project nature, language, and managed-project provenance | `schemaVersion: "1"` |
| `metadata/models.json` | Model-artifact manifests, including dependency resolution, generated-file checksums, and build provenance | `schemaVersion: "1"` per manifest |
| `metadata/images.json` | Optional image-artifact references | No independent schema version yet |
| `artifacts/` | Model and optional image payloads addressed by the metadata | Defined by the corresponding manifest |

Project coordinates in `properties.json` are the canonical identity and determine the repository path. A model manifest records its own artifact coordinates, payload path, generated-file checksums, resolved dependency references, conflict decisions, materialization audit, timestamp, and the MooseNexus, Moose, and Pharo versions that produced it.

Build provenance identifies the runtime that produced a model; it is not a replay environment. Dependency references and generated-file paths are portable metadata, while a materialization entry is only an audit of a particular build.

## Compatibility and Migration

MooseNexus v1 writes version-1 project properties and model manifests, and supports reading version-1 metadata written by earlier MooseNexus releases. Additive fields may be introduced without changing a schema version only when they are optional and older readers can ignore them.

Any incompatible change to a persisted shape must introduce a new schema version. A release that reads the new version must either provide an explicit migration from supported earlier versions or reject the metadata with a clear unsupported-schema error. Migration must create a new portable project directory or explicitly replace a selected copy; MooseNexus must not silently rewrite stored artifacts during ordinary reads.

Payload compatibility is separate from metadata compatibility. Before importing a model, use its recorded build provenance to select a compatible Moose, Pharo, and MooseNexus runtime; verify generated-file checksums when transferring artifacts through an untrusted channel.
