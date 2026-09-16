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

## Location Ownership

MooseNexus distinguishes a location by its owner rather than treating every path as a generic string:

- external local inputs, such as a source directory or an unmanaged local dependency, are filesystem locations. APIs accept `FileReference` values and persist their normalized absolute paths when they need to be recorded;
- project payload paths, such as model artifacts and generated files, are relative to their owning MooseNexus project directory and are resolved through that project's repository backend;
- remote repository and OCI paths are identifiers within their respective remote backends, not local filesystem paths.

Consequently, a repository-relative payload path cannot be absolute or escape its project backend. A local input may live on any mounted filesystem; it is intentionally environment-specific.

## Installation Integrity

Every generated file recorded by a model manifest carries its size and SHA-256 checksum. Before MooseNexus installs a portable project directory or OCI bundle, it verifies every recorded generated file. A missing, truncated, or altered payload is rejected before the destination repository is changed.

Installation stages the complete incoming project in a sibling temporary directory. For an existing project, metadata merging and payload copies occur only in that staging directory. MooseNexus then promotes the staged directory and restores the prior directory if promotion fails, so an invalid or failed installation does not leave a partially updated project in the repository.

## Compatibility and Migration

MooseNexus v1 writes version-1 project properties and model manifests, and supports reading version-1 metadata written by earlier MooseNexus releases. Additive fields may be introduced without changing a schema version only when they are optional and older readers can ignore them.

Any incompatible change to a persisted shape must introduce a new schema version. A release that reads the new version must either provide an explicit migration from supported earlier versions or reject the metadata with a clear unsupported-schema error. Migration must create a new portable project directory or explicitly replace a selected copy; MooseNexus must not silently rewrite stored artifacts during ordinary reads.

Payload compatibility is separate from metadata compatibility. Before importing a model, use its recorded build provenance to select a compatible Moose, Pharo, and MooseNexus runtime.
