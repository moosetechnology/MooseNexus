"
I am a repository for MooseNexusProject instances.
I have a configurable home directory where recorded projects are stored. The default instance uses the ~/.moose directory.

My goal is to manage projects to be analyzed with Moose in a reusable, structured, and versioned manner.

A MooseNexusBuildSpec describes the client-side intent to import, build, and record. A MooseNexusBuildPlan executes that intent against me. A MooseNexusProjectSpec is the narrower source-project recording intent used inside a build spec. A MooseNexusProject represents a project loaded from a source project or from this repository.

Use MooseNexusBuildSpec for full client builds. Use recordLoadedProject:describedBy: only at the boundary where a project has already been loaded in memory and must be recorded with the coordinates and source directory from a spec.
"
Class {
	#name : 'MooseNexusRepository',
	#superclass : 'Object',
	#instVars : [
		'directory'
	],
	#classInstVars : [
		'default'
	],
	#category : 'MooseNexus-Repository',
	#package : 'MooseNexus',
	#tag : 'Repository'
}

{ #category : 'accessing' }
MooseNexusRepository class >> default [

	^ default ifNil: [ default := self new directory: FileLocator home / '.moose' ]
]

{ #category : 'accessing' }
MooseNexusRepository >> directory [

	^ directory
]

{ #category : 'accessing' }
MooseNexusRepository >> directory: aFile [

	directory := aFile
]

{ #category : 'enumerating' }
MooseNexusRepository >> group: group project: project version: version [
	"Search the repository for the project with the specified group, project name and version."

	| dir |
	dir := directory / 'repository' / group ifAbsent: [ NotFound signal: 'Group `' , group , '`, not found in repository' ].
	dir := dir / project ifAbsent: [ NotFound signal: 'Project `' , project , '` not found in group `' , group , '`' ].
	dir := dir / version ifAbsent: [
		       NotFound signal: 'Version `' , version , '` not found for project `' , project , '` in group `' , group , '`' ].
	^ MooseNexusProject fromNexusDirectory: dir
]

{ #category : 'adding' }
MooseNexusRepository >> prepareDirectoryFor: aMooseNexusProjectSpec [
	"Create the repository layout needed before copying sources or writing metadata."

	| projectDirectory |
	projectDirectory := self resolveDirectoryFor: aMooseNexusProjectSpec.
	projectDirectory ifExists: [
			Warning signal: 'This project already exists in given repository, proceed to overwrite it'.
			projectDirectory deleteAll ].
	(projectDirectory / 'sources' / 'project') ensureCreateDirectory.
	^ projectDirectory
]

{ #category : 'printing' }
MooseNexusRepository >> printOn: stream [

	super printOn: stream.
	stream nextPut: $(.
	stream nextPutAll: directory pathString.
	stream nextPut: $)
]

{ #category : 'printing' }
MooseNexusRepository >> printProjectProperties: propertiesFile on: writeStream [

	propertiesFile readStreamDo: [ :rs |
			| properties |
			properties := STON fromStream: rs.
			writeStream << (properties at: #nature) << '(' << (properties at: #group) << ':' << (properties at: #name) << ':'
			<< (properties at: #version) << ')' ]
]

{ #category : 'printing' }
MooseNexusRepository >> printProjects [

	directory ifAbsent: [ ^ 'none' ].
	^ self projectProperties ifEmpty: [ ^ 'none' ] ifNotEmpty: [ :projectProperties |
			  String streamContents: [ :s |
				  projectProperties do: [ :properties | self printProjectProperties: properties on: s ] separatedBy: [ s cr ] ] ]
]

{ #category : 'enumerating' }
MooseNexusRepository >> projectProperties [
	"Returns the properties files of all managed projects."

	| properties |
	properties := OrderedCollection new.
	(directory / 'repository') directories do: [ :groupDirectory |
			groupDirectory directories do: [ :nameDirectory |
				nameDirectory directories do: [ :versionDirectory | properties add: versionDirectory / 'properties.json' ] ] ].
	^ properties
]

{ #category : 'enumerating' }
MooseNexusRepository >> projects [
	"Returns all the projects managed by this repository."

	^ self projectProperties collect: [ :properties | MooseNexusProject fromProperties: properties ]
]

{ #category : 'adding' }
MooseNexusRepository >> recordLoadedProject: project describedBy: aMooseNexusProjectSpec [
	"Add an already loaded project to the repository using the spec that describes recording intent."

	| projectDirectory |
	aMooseNexusProjectSpec validateForRecording.
	project coordinates ifNil: [ project initializeCoordinates: aMooseNexusProjectSpec coordinates ] ifNotNil: [ :coordinates |
			coordinates = aMooseNexusProjectSpec coordinates ifFalse: [
				Error signal: 'Cannot record a MooseNexus project with coordinates different from its spec' ] ].
	projectDirectory := self prepareDirectoryFor: aMooseNexusProjectSpec.
	project directory: (projectDirectory relativeTo: FileLocator home) pathString.

	"copy project directory to repository"
	aMooseNexusProjectSpec sourceDirectory copyAllTo: projectDirectory / 'sources' / 'project'.

	"write properties file useful for Nexus"
	(projectDirectory / 'properties.json') ensureCreateFile writeStreamDo: [ :stream | project writePropertiesOn: stream ].

	"JSON list of models created, empty by default"
	(projectDirectory / 'models.json') ensureCreateFile writeStreamDo: [ :stream | stream nextPutAll: '[]' ].

	^ project
]

{ #category : 'enumerating' }
MooseNexusRepository >> resolveDirectoryFor: aMooseNexusProjectSpec [

	^ directory / 'repository' / aMooseNexusProjectSpec group / aMooseNexusProjectSpec name / aMooseNexusProjectSpec version
]
