"
I am the client-facing repository facade for MooseNexusProject instances.

I delegate storage to a repository backend. The default backend stores data in the local filesystem under ~/.moose. This keeps build plans and client code independent from whether projects and model artifacts are stored locally or, later, in a remote artifact repository.

Use MooseNexusBuildSpec for full client builds. Use recordLoadedProject:describedBy: only at the boundary where a project has already been loaded in memory and must be recorded with the coordinates and source directory from a spec.
"
Class {
	#name : 'MooseNexusRepository',
	#superclass : 'Object',
	#instVars : [
		'backend'
	],
	#classInstVars : [
		'default'
	],
	#category : 'MooseNexus-Repository',
	#package : 'MooseNexus',
	#tag : 'Repository'
}

{ #category : 'instance creation' }
MooseNexusRepository class >> backend: aMooseNexusRepositoryBackend [

	^ self new
		  backend: aMooseNexusRepositoryBackend;
		  yourself
]

{ #category : 'accessing' }
MooseNexusRepository class >> default [

	^ default ifNil: [ default := self localDirectory: FileLocator home / '.moose' ]
]

{ #category : 'instance creation' }
MooseNexusRepository class >> localDirectory: aFileReference [

	^ self new directory: aFileReference
]

{ #category : 'accessing' }
MooseNexusRepository >> backend [

	^ backend ifNil: [ self directory: FileLocator home / '.moose'. backend ]
]

{ #category : 'accessing' }
MooseNexusRepository >> backend: aMooseNexusRepositoryBackend [

	backend := aMooseNexusRepositoryBackend
]

{ #category : 'accessing' }
MooseNexusRepository >> directory [

	^ self backend directory
]

{ #category : 'accessing' }
MooseNexusRepository >> directory: aFileReference [

	backend := MooseNexusLocalRepositoryBackend directory: aFileReference
]

{ #category : 'enumerating' }
MooseNexusRepository >> group: group project: project version: version [
	"Search the repository for the project with the specified group, project name and version."

	^ self backend group: group project: project version: version
]

{ #category : 'adding' }
MooseNexusRepository >> prepareDirectoryFor: aMooseNexusProjectSpec [
	"Create the repository layout needed before copying sources or writing metadata."

	^ self backend prepareDirectoryFor: aMooseNexusProjectSpec
]

{ #category : 'printing' }
MooseNexusRepository >> printOn: stream [

	super printOn: stream.
	stream nextPut: $(.
	self backend printOn: stream.
	stream nextPut: $)
]

{ #category : 'printing' }
MooseNexusRepository >> printProjectProperties: propertiesFile on: writeStream [

	^ self backend printProjectProperties: propertiesFile on: writeStream
]

{ #category : 'printing' }
MooseNexusRepository >> printProjects [

	^ self backend printProjects
]

{ #category : 'enumerating' }
MooseNexusRepository >> projectProperties [
	"Returns the properties files of all managed projects."

	^ self backend projectProperties
]

{ #category : 'enumerating' }
MooseNexusRepository >> projects [
	"Returns all the projects managed by this repository."

	^ self backend projects
]

{ #category : 'adding' }
MooseNexusRepository >> recordLoadedProject: project describedBy: aMooseNexusProjectSpec [
	"Add an already loaded project to the repository using the spec that describes recording intent."

	^ self backend recordLoadedProject: project describedBy: aMooseNexusProjectSpec
]

{ #category : 'enumerating' }
MooseNexusRepository >> resolveDirectoryFor: aMooseNexusProjectSpec [

	^ self backend resolveDirectoryFor: aMooseNexusProjectSpec
]
