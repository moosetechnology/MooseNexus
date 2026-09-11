[![Moose version](https://img.shields.io/badge/Moose-11-%23aac9ff.svg)](https://github.com/moosetechnology/Moose)
[![Moose version](https://img.shields.io/badge/Moose-12-%23aac9ff.svg)](https://github.com/moosetechnology/Moose)
![Build Info](https://github.com/moosetechnology/MooseNexus/workflows/Tests/badge.svg)
[![Coverage Status](https://coveralls.io/repos/github/moosetechnology/MooseNexus/badge.svg?branch=main)](https://coveralls.io/github/moosetechnology/MooseNexus?branch=main)

# MooseNexus

Build automation and dependency management for Moose models.
Nexus provides dependency analysis and management similar to Maven and Gradle when building models.
It also provides structured and versioned tracking of models.

## Installation

```st
Metacello new
	githubUser: 'moosetechnology' project: 'MooseNexus' commitish: 'v1.x.x' path: 'src';
	baseline: 'MooseNexus';
	load
```

`v1.x.x` is the floating tag for the newest compatible v1 release. Use an exact version tag when reproducibility matters.

To depend on MooseNexus from another baseline:

```st
spec
	baseline: 'MooseNexus'
	with: [ spec repository: 'github://moosetechnology/MooseNexus:v1.x.x/src' ].
```

To import Java projects, install [Maven](https://maven.apache.org/install.html) and [Gradle](https://gradle.org/install.html).

To create new models, you will need to install the appropriate model extractor, such as [VerveineJ](https://github.com/moosetechnology/VerveineJ/) locally or through [VerveineJ-Docker](https://github.com/Evref-BL/VerveineJ-Docker).

TypeScript support is experimental and deferred from the v1 support commitment. It can be loaded, together with FamixTypeScript, explicitly for evaluation:

```st
Metacello new
	githubUser: 'moosetechnology' project: 'MooseNexus' commitish: 'v1.x.x' path: 'src';
	baseline: 'MooseNexus';
	load: 'TypeScript'
```

## Support

Java support lives in the default-loaded `MooseNexus-Java` package and covers Maven, Gradle, and explicitly configured unmanaged projects.

The core package is tested on Moose 11, 12, and 13. Java managed-import integration tests run on every pull request with these build-tool boundaries:

| Toolchain | Java | Maven | Gradle |
| --- | --- | --- | --- |
| Oldest supported | 8 | 3.6.3 | 6.9.4 |
| Current stable | 17 | 3.9.16 | 9.7.1 |

The Maven importer accepts Maven 3.6.3 and later Maven 3 releases; it rejects Maven 4. Gradle has no importer-side version guard yet, so its support is defined by the continuously checked boundary configurations above.

`MooseNexus-TypeScript` is an optional experimental package for npm-managed projects with a committed v2 or v3 `package-lock.json`; it currently requires Moose 13. Its v1 delivery is deferred until ts2famix has a stable upstream release. MooseNexus will then pin that upstream release, document the supported runtime, and add extraction integration coverage. It does not publish or support a MooseNexus-owned ts2famix image.

Known experimental TypeScript limits: JavaScript is not supported; Yarn, pnpm, Bun, and lockfile-free npm projects are not supported; npm packages are recorded as locked remote references but are not downloaded or added to the model.

## Usage

Use `MooseNexusBuildSpec` to record a source project, run a model extractor, and store the resulting model artifact.

```st
sourceDirectory := '/path/to/sources' asFileReference.
coordinates := MooseNexusCoordinates
	group: 'group'
	name: 'name'
	version: 'version'.
spec := MooseNexusBuildSpec
	coordinates: coordinates
	sourceDirectory: sourceDirectory.
result := spec executeIn: MooseNexusRepository default.
```

See [Build Spec](docs/build-spec.md) for managed and unmanaged project build examples.

See [Persisted Metadata](docs/persisted-metadata.md) for the project and model-artifact portability contract.

See [OCI Artifacts](docs/oci-artifacts.md) for publishing model artifacts and source archives to an OCI registry such as Harbor through ORAS.

Retrieve an existing project from a Nexus repository:

```st
project := MooseNexusRepository default group: 'group' project: 'name' version: 'version'.
```

Create a model of the managed project:

```st
project buildModel.
```

Import a model into the image:

```st
project importModel.
```

## Glossary

MooseNexus sits one meta layer above source code: it does not build the software itself, it builds Moose models of that software. To avoid ambiguity, these terms are used consistently in code and documentation:
- **Source project**: The software project being analyzed. This is the codebase that may already be managed by Maven, Gradle, npm, or another build tool.
- **MooseNexus project**: The MooseNexus representation of a source project as a model-building unit. It records the source project identity, nature, dependencies, and produced models.
- **Project spec**: The recording intent for a MooseNexus project before it exists in a repository. It contains the selected project coordinates and source directory.
- **Project coordinates**: The stable identity of a MooseNexus project, composed of group, name, and version. These coordinates identify the source project as modeled by MooseNexus, not necessarily a published software package.
- **Repository**: A MooseNexus storage location for MooseNexus projects and produced model artifacts. The current implementation is a local filesystem repository.
- **Model**: A Moose/Famix representation of a source project, or of a selected set of source projects and dependencies.
- **Model artifact**: A stored output of a MooseNexus build. It contains, or points to, a generated model and should carry enough metadata to identify how it was produced.
- **Dependency**: Another source project or software artifact required to analyze or model a source project. Dependencies may be pathless Maven, Gradle, or npm references, or explicit local paths for unmanaged projects.
- **Dependency scope**: The context in which a dependency is used by the source project, such as compile, runtime, or test. MooseNexus may use scopes to decide which dependencies are included in a model.
- **Nature**: The kind of source project MooseNexus knows how to inspect, usually derived from the source project's build tool. Maven and Gradle are supported natures; locked npm projects are experimental.
- **Extractor**: A tool that creates a Moose/Famix model from source code. MooseNexus uses VerveineJ for Java and has experimental ts2famix support for TypeScript.
- **Build**: A MooseNexus operation that resolves source project metadata and dependencies, runs an extractor, and records the resulting model artifact.
- **Managed source project**: A source project whose metadata and dependencies can be read from an existing build tool such as Maven, Gradle, or npm.
- **Unmanaged source project**: A source project whose metadata is supplied explicitly rather than read from a supported build tool descriptor.
