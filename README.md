# MooseNexus

Model and dependency manager for Moose.

Currently only works for Maven.
Support for Gradle and unmanaged projects is planned.

## Installation

```st
Metacello new
  githubUser: 'moosetechnology' project: 'MooseNexus' commitish: 'main' path: 'src';
  baseline: 'MooseNexus';
  load
```

## Usage

Record a new project in a Nexus repository.
```st
project := NexusRepository default record: 'artifactId' fromDirectory: 'path/to/sources'.
```

Retrieve an existing model from the Nexus repository.
```st
project := NexusRepository default group: 'groupId' artifact: 'artifactId' version: 'major.minor.patch'.
```

Create a model of the managed project.
```st
project buildModel.
```
