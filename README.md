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

To import and analyze managed projects, you will need to install the appropriate build tools, such as [Maven](https://maven.apache.org/install.html) and [Gradle](https://gradle.org/install/).

To create new models, you will need to install the appropriate model extractor, such as [VerveineJ](https://github.com/moosetechnology/VerveineJ/) (in this case, either locally or using [VerveineJ-Docker](https://github.com/Evref-BL/VerveineJ-Docker)).


## Support

Currently only works for Java projects.
Supported project natures, based on their build automation tool, are Maven and Gradle.
Dependency management support for unmanaged ("vanilla") projects is planned.


## Usage

Import a new project into a Nexus repository:
```st
project := NexusRepository default import: 'projectName' fromDirectory: 'path/to/sources'.
```
This will attempt to find the project properties automatically: group, version and language.
If more control over these properties is required, they must be set before the project is added to the repository:
```st
sourcePath := 'path/to/sources'.
project := NexusProjectImporter importFromDirectory: sourcePath.
project name: 'name'.
project group: 'group'.
project version: 'version'.
project language: 'language'. "in lower case"
NexusRepository default recordProject: project fromDirectory: sourcePath.
```

Retrieve an existing project from a Nexus repository:
```st
project := NexusRepository default group: 'group' project: 'name' version: 'version'.
```

Create a model of the managed project:
```st
project buildModel.
```

Import a model into the image:
```st
project importModel.
```

## Terminology

- **Repository**: A central directory where Moose models are stored and managed by Nexus.
- **Project**: One or more software systems that are part of the same model, managed as a unit by Nexus.
- **Managed**: Refers to a software system or project that is managed by a build automation tool. This term applies to systems under analysis that are managed by Maven or other tools, as well as projects that are managed by Nexus.
- **Artifact**: A file or output produced as part of a build process. In the context of Nexus, an artifact is a model. In the context of systems under analysis, they are dependencies, such as jar files in Java.
- **Nature**: Specifies the build automation tool, such as Maven or Gradle, used to manage the configuration and lifecycle of the project under analysis.
