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
	githubUser: 'moosetechnology' project: 'MooseNexus' commitish: 'main' path: 'src';
	baseline: 'MooseNexus';
	load
```

To import Java projects, install the appropriate build tools, [Maven](https://maven.apache.org/install.html) and [Gradle](https://gradle.org/install.html). TypeScript import uses Docker by default; it runs a pinned `ts2famix` image without installing Node or npm packages on the host.

To create new models, you will need to install the appropriate model extractor, such as [VerveineJ](https://github.com/moosetechnology/VerveineJ/) locally or through [VerveineJ-Docker](https://github.com/Evref-BL/VerveineJ-Docker).

TypeScript support is optional. Load it, together with FamixTypeScript, explicitly:

```st
Metacello new
	githubUser: 'moosetechnology' project: 'MooseNexus' commitish: 'main' path: 'src';
	baseline: 'MooseNexus';
	load: 'TypeScript'
```

## Support

Java support lives in the default-loaded `MooseNexus-Java` package and covers Maven, Gradle, and explicitly configured unmanaged projects. The optional `MooseNexus-TypeScript` package supports npm-managed projects with a committed `package-lock.json` in v2 or v3 format; it currently requires Moose 13.

TypeScript extraction defaults to the versioned `ghcr.io/moosetechnology/moosenexus-ts2famix:3.2.0-679f54e` Docker image. A local TypeScript runner is available when a caller explicitly configures a local `ts2famix` command; it never installs npm packages as an import side effect.

Known TypeScript limits: JavaScript is not supported yet; Yarn, pnpm, Bun, and lockfile-free npm projects are not supported; npm packages are recorded as locked remote references but are not downloaded or added to the model.

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
- **Nature**: The kind of source project MooseNexus knows how to inspect, usually derived from the source project's build tool. Maven, Gradle, and locked npm projects are supported natures.
- **Extractor**: A tool that creates a Moose/Famix model from source code. MooseNexus uses VerveineJ for Java and ts2famix for TypeScript.
- **Build**: A MooseNexus operation that resolves source project metadata and dependencies, runs an extractor, and records the resulting model artifact.
- **Managed source project**: A source project whose metadata and dependencies can be read from an existing build tool such as Maven, Gradle, or npm.
- **Unmanaged source project**: A source project whose metadata is supplied explicitly rather than read from a supported build tool descriptor.
