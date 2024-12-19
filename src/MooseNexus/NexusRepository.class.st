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
	#category : 'MooseNexus-Repository',
	#package : 'MooseNexus',
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

{ #category : 'importing' }
NexusRepository >> import: name fromDirectory: pathString [
	"Import the project within the given directory and name it."

	| importer project |
	importer := NexusProjectImporter fromDirectory: pathString.
	project := importer import.
	project name: name.
	self recordProject: project fromDirectory: pathString.
	^ project
]

{ #category : 'importing' }
NexusRepository >> importFromDirectory: pathString [
	"Import the project within the given directory and try to determine its name.
	It is recommended that you specify the project name using `import:fromDirectory:`,
	unless you are sure that there is only one managed project in the directory."

	| importer project |
	importer := NexusProjectImporter fromDirectory: pathString.
	project := importer import.
	self recordProject: project fromDirectory: pathString.
	^ project
]

{ #category : 'printing' }
NexusRepository >> printProjectProperties: propertiesFile on: writeStream [

	propertiesFile readStreamDo: [ :rs |
		| properties |
		properties := STON fromStream: rs.
		writeStream << (properties at: #nature) << '('
		<< (properties at: #group) << ':' << (properties at: #name) << ':'
		<< (properties at: #version) << ')' ]
]

{ #category : 'printing' }
NexusRepository >> printProjects [

	directory ifAbsent: [ ^ 'none' ].
	^ self projectProperties
		  ifEmpty: [ ^ 'none' ]
		  ifNotEmpty: [ :projectProperties |
			  String streamContents: [ :s |
				  projectProperties
					  do: [ :properties |
					  self printProjectProperties: properties on: s ]
					  separatedBy: [ s cr ] ] ]
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
NexusRepository >> recordProject: project [
	"Add the project to this repository, without including sources."

	| projectDirectory |
	(projectDirectory := self resolveDirectoryOf: project) ifExists: [
		Warning signal:
			'This project already exists in the given repository, proceed to overwrite it'.
		projectDirectory deleteAll ].
	project directory: projectDirectory.

	"write properties file useful for Nexus"
	(projectDirectory / 'properties.json') ensureCreateFile
		writeStreamDo: [ :stream | project writePropertiesOn: stream ].

	"JSON list of models that were created, empty by default"
	(projectDirectory / 'models.json') ensureCreateFile writeStreamDo: [
		:stream | stream nextPutAll: '[]' ]
]

{ #category : 'adding' }
NexusRepository >> recordProject: project fromDirectory: pathString [
	"Add the project to this repository, copying the sources from the given directory."

	| projectDirectory |
	(projectDirectory := self resolveDirectoryOf: project) ifExists: [
		Warning signal:
			'This project already exists in the given repository, proceed to overwrite it'.
		projectDirectory deleteAll ].
	project directory: projectDirectory.

	"copy the project directory to the repository"
	pathString asFileReference copyAllTo:
		(projectDirectory / 'sources/project') ensureCreateDirectory.

	"write properties file useful for Nexus"
	(projectDirectory / 'properties.json') ensureCreateFile
		writeStreamDo: [ :stream | project writePropertiesOn: stream ].

	"JSON list of models that were created, empty by default"
	(projectDirectory / 'models.json') ensureCreateFile writeStreamDo: [
		:stream | stream nextPutAll: '[]' ]
]

{ #category : 'enumerating' }
NexusRepository >> resolveDirectoryOf: project [

	^ directory / 'repository'
	  / (project group copyReplaceAll: '.' with: '/') / project name
	  / project version
]
