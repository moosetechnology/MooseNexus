"
I am a repository for `NexusProject`s.
I have a configurable home directory where the projects are stored.
By default, it is the `~/.moose` directory.

My goal is to manage projects to be analyzed with Moose in a reusable, structured, and versioned manner.

### API
To manage a new project, use one of the following methods:

#### `NexusRepository >> #record:fromDirectory:`
The first parameter expects a name that will be given to the project.
The second parameter expects the path string to a local directory containing the sources of the project to analyze.

#### `NexusRepository >> #recordFromDirectory:`
Expects the path string to the sources, and Nexus will attempt to find the project name.
It can only be found if it is a managed project (see `NexusManagedProject`) that declares a single artifact.

#### `NexusRepository >> #recordProject:`
Expects an existing `NexusProject`.
This is generally unnecessary unless you need to have finer control over the project analysis, or if you wish to copy a project from another `NexusRepository`.
"
Class {
	#name : 'NexusRepository',
	#superclass : 'Object',
	#instVars : [
		'directory'
	],
	#classInstVars : [
		'default'
	],
	#category : 'Moose-Nexus-Repository',
	#package : 'Moose-Nexus',
	#tag : 'Repository'
}

{ #category : 'accessing' }
NexusRepository class >> default [

	^ default ifNil: [
		  default := self new directory: FileLocator home / '.moose' ]
]

{ #category : 'accessing' }
NexusRepository >> directory [

	^ directory
]

{ #category : 'accessing' }
NexusRepository >> directory: aFile [

	directory := aFile
]

{ #category : 'enumerating' }
NexusRepository >> group: group project: project version: version [
	"Search the repository for the project with the specified group, project name and version."

	^ NexusProject fromNexusDirectory:
		  directory / 'repository' / (group copyReplaceAll: '.' with: '/')
		  / project / version
]

{ #category : 'printing' }
NexusRepository >> printProjectProperties: propertiesFile on: writeStream [

	propertiesFile readStreamDo: [ :rs |
		| properties |
		properties := STON fromStream: rs.
		writeStream << (properties at: #nature) << '('
		<< (properties at: #group) << ':' << (properties at: #artifact)
		<< ':' << (properties at: #version) << ')' ]
]

{ #category : 'printing' }
NexusRepository >> printProjects [

	directory ifAbsent: [ ^ 'none' ].
	^ String streamContents: [ :s |
		  self projectProperties
			  do: [ :properties | self printProjectProperties: properties on: s ]
			  separatedBy: [ s cr ] ]
]

{ #category : 'enumerating' }
NexusRepository >> projectProperties [
	"Returns the properties files of all managed projects."

	^ SelectVisitor
		  preorder: directory
		  select: [ :child | child basename = 'properties.json' ]
]

{ #category : 'enumerating' }
NexusRepository >> projects [
	"Returns all the projects managed by this repository."

	^ self projectProperties collect: [ :properties |
		  NexusProject fromProperties: properties ]
]

{ #category : 'adding' }
NexusRepository >> record: name fromDirectory: pathString [

	^ self recordProject:
		  ((NexusProject fromDirectory: pathString) analyze name: name)
]

{ #category : 'adding' }
NexusRepository >> recordFromDirectory: pathString [
	"It is recommended that you specify the project name using `record:fromDirectory:`,
	unless you are sure that there is only one managed project in the directory and it can be determined."

	^ self recordProject:
		  (NexusProject fromDirectory: pathString) analyze
]

{ #category : 'adding' }
NexusRepository >> recordProject: project [

	| dir |
	(dir := self resolveDirectoryOf: project) ifExists: [
		Warning signal:
			'This project already exists in the given repository, proceed to overwrite it'.
		dir deleteAll ].

	"write properties file useful for Nexus"
	(dir / 'properties.json') ensureCreateFile writeStreamDo: [ :stream |
		project writePropertiesOn: stream ].

	"copy the project directory to the repository"
	project directory asFileReference copyAllTo:
		(dir / 'sources') createDirectory.

	^ project
]

{ #category : 'enumerating' }
NexusRepository >> resolveDirectoryOf: project [

	^ directory / 'repository'
	  / (project group copyReplaceAll: '.' with: '/') / project name
	  / project version
]
