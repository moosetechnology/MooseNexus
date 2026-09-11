# General

## Concepts

MooseNexus sits one meta layer above source code: it builds Moose models of software projects rather than building the software itself. A project can be managed by a build tool such as Maven or Gradle, or described explicitly as unmanaged.

## Key Features

MooseNexus imports project metadata and dependencies, runs a model extractor, and records a portable model artifact. The artifact records its source-project identity, dependency-resolution result, generated payloads, and build provenance.

## Architecture

```text
Source project → Build spec → Importer → MooseNexus project → Extractor → Model artifact
```

The build spec provides the intended identity and source directory. An importer reads build-tool metadata when applicable. MooseNexus records the resulting project and model artifact in a repository, while extractors produce the model payload. Repository metadata uses paths relative to the project directory so it can be transferred between repositories or OCI bundles.

## Glossary

- **Source project**: The software project being analyzed.
- **MooseNexus project**: The MooseNexus representation of a source project as a model-building unit.
- **Project spec**: Build-time intent for recording a source project, including its coordinates and source directory.
- **Project coordinates**: The group, name, and version that identify a source project as modeled by MooseNexus.
- **Repository**: A storage location for MooseNexus projects and model artifacts.
- **Model**: A Moose/Famix representation of a source project.
- **Model artifact**: A stored model output and its metadata.
- **Dependency**: A source project or software artifact needed to analyze or model a source project.
- **Nature**: The kind of source project MooseNexus can inspect, often derived from its build tool.
- **Extractor**: A tool that creates a Moose/Famix model from source code.
- **Managed source project**: A project whose metadata is read from a build-tool descriptor.
- **Unmanaged source project**: A project whose metadata is supplied explicitly.
