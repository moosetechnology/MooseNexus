# MooseNexus

Build automation and dependency management for Moose models.  
Nexus provides structured and versioned tracking of models of software systems under analysis.
It handles the analysis and management of dependencies, similar to systems such as Maven and Gradle.

Currently only works for Maven.
Support for Gradle and unmanaged ("vanilla") projects is planned.

## Installation

```st
Metacello new
  githubUser: 'moosetechnology' project: 'MooseNexus' commitish: 'main' path: 'src';
  baseline: 'MooseNexus';
  load
```

To import and analyse new managed projects, you will need to install the appropriate build tool, such as [Maven](https://maven.apache.org/install.html).

To create new models, you will need to install the appropriate model extractor, such as [VerveineJ](https://github.com/moosetechnology/VerveineJ/) (in this case, either locally or using [VerveineJ-Docker](https://github.com/Evref-BL/VerveineJ-Docker)).

## Usage

Record a new project in a Nexus repository.
```st
project := NexusRepository default record: 'artifactId' fromDirectory: 'path/to/sources'.
```

Retrieve an existing project from a Nexus repository.
```st
project := NexusRepository default group: 'groupId' artifact: 'artifactId' version: 'major.minor.patch'.
```

Create a model of the managed project.
```st
project buildModel.
```

## Terminology

- **Repository**: A central directory where Moose models are stored and managed by Nexus.
- **Project**: One or more software systems that are part of the same model, managed as a unit by Nexus.
- **Managed**: Refers to a software system or project that is controlled using a build automation and dependency management tool. This term applies both to systems under analysis managed by Maven or other tools, and to internal projects managed by Nexus.
- **Artifact**: A file or output produced as part of a build process. In the context of Nexus, an artifact is a model. In the context of systems under analysis, they are dependencies, such as jar files in Java.
