"
I represent a project managed with Maven.

The `mvn` command is used to get the projects and dependencies declared in a `pom.xml` file.
This means that a `NexusProject` and its Moose model can be recorded in a `NexusRepository` based on a build file alone, without the need to get the sources locally first.

### Specification
Maven descriptors are strings structured as `group:artifact:type:version:scope`.
The type is one of: pom, jar, maven-plugin, ejb, war, ear, rar.
The scope is one of: compile, provided, runtime, test, system, import.
"
Class {
	#name : 'NexusMavenProject',
	#superclass : 'NexusManagedProject',
	#category : 'MooseNexus-Project',
	#package : 'MooseNexus',
	#tag : 'Project'
}

{ #category : 'testing' }
NexusMavenProject >> isMavenProject [

	^ true
]
