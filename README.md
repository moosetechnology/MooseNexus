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

To import and analyze managed projects, you will need to install the appropriate build tools, [Maven](https://maven.apache.org/install.html) and [Gradle](https://gradle.org/install/).

To create new models, you will need to install the appropriate model extractor, such as [VerveineJ](https://github.com/moosetechnology/VerveineJ/) locally or through [VerveineJ-Docker](https://github.com/Evref-BL/VerveineJ-Docker).

## Support

Currently, MooseNexus only works with Java source projects.
The supported source project natures, based on build automation tool, are Maven and Gradle.
Dependency management support for unmanaged source projects is planned.

## Usage

Import a new project into the Nexus repository:

```st
project := MooseNexusRepository default
	import: 'projectName'
	fromDirectory: 'path/to/sources'.
```

This will attempt to find project properties automatically: group, version, and language.
If more control over coordinates is required, provide them before the project is added to the repository:

```st
sourcePath := 'path/to/sources'.
coordinates := MooseNexusProjectCoordinates
	group: 'group'
	name: 'name'
	version: 'version'.
project := MooseNexusRepository default
	importCoordinates: coordinates
	fromDirectory: sourcePath.
```

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
- **Source project**: The software project being analyzed. This is the codebase that may already be built by Maven, Gradle, or another build tool.
- **MooseNexus project**: The MooseNexus representation of a source project as a model-building unit. It records the source project identity, nature, dependencies, and produced models.
- **Project coordinates**: The stable identity of a MooseNexus project, composed of group, name, and version. These coordinates identify the source project as modeled by MooseNexus, not necessarily a published software package.
- **Repository**: A MooseNexus storage location for MooseNexus projects and produced model artifacts. The current implementation is a local filesystem repository.
- **Model**: A Moose/Famix representation of a source project, or of a selected set of source projects and dependencies.
- **Model artifact**: A stored output of a MooseNexus build. It contains, or points to, a generated model and should carry enough metadata to identify how it was produced.
- **Dependency**: Another source project or software artifact required to analyze or model a source project. Dependencies may come from Maven, Gradle, local repositories, or future MooseNexus repositories.
- **Dependency scope**: The context in which a dependency is used by the source project, such as compile, runtime, or test. MooseNexus may use scopes to decide which dependencies are included in a model.
- **Nature**: The kind of source project MooseNexus knows how to inspect, usually derived from the source project's build tool. Maven and Gradle are the currently supported natures.
- **Extractor**: A tool that creates a Moose/Famix model from source code. For Java, MooseNexus currently uses VerveineJ.
- **Build**: A MooseNexus operation that resolves source project metadata and dependencies, runs an extractor, and records the resulting model artifact.
- **Managed source project**: A source project whose metadata and dependencies can be read from an existing build tool such as Maven or Gradle.
- **Unmanaged source project**: A source project without a supported build tool descriptor. Support for unmanaged source projects is planned.
