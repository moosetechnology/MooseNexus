"
I am a repository for `NexusProject`s.
I have a configurable home directory where the projects are stored.
The default instance uses the `~/.moose` directory.

My goal is to manage projects to be analyzed with Moose in a reusable, structured, and versioned manner.

### API
To manage a new project, use one of the following methods:

#### `NexusRepository >> #import:fromDirectory:`
The first parameter expects a name that will be given to the project.
The second parameter expects the path string to a local directory containing the sources of the project to analyze.

#### `NexusRepository >> #importFromDirectory:`
Expects the path string to the sources, and Nexus will try to figure out the project name.
It can only be found if it is a managed project (see `NexusManagedProject`) that declares a single artifact.

#### `NexusRepository >> #recordProject:fromDirectory:`
Expects an existing `NexusProject` and a path string to a local directory containing the project sources.
This is useful if you want to have finer control over the project analysis, such as specifying the group or version, or if you want to copy a project from another `NexusRepository`.
The name, group and version must be specified before the project is added to the repository:
```
project := NexusProjectImporter importFromDirectory: pathString.
project name: name.
project group: group.
project version: version.
NexusRepository default recordProject: project fromDirectory: pathString.
```
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

	| dir |
	dir := directory / 'repository' / group ifAbsent: [
		       NotFound signal:
			       'Group `' , group , '`, not found in repository' ].
	dir := dir / project ifAbsent: [
		       NotFound signal:
			       'Project `' , project , '` not found in group `' , group
			       , '`' ].
	dir := dir / version ifAbsent: [
		       NotFound signal:
			       'Version `' , version , '` not found for project `'
			       , project , '` in group `' , group , '`' ].
	^ NexusProject fromNexusDirectory: dir
]

{ #category : 'importing' }
NexusRepository >> import: name fromDirectory: pathString [
	"Import the project within the given directory and name it."

	| project |
	project := NexusProjectImporter importFromDirectory: pathString.
	project name: name.
	self recordProject: project fromDirectory: pathString.
	^ project
]

{ #category : 'importing' }
NexusRepository >> importFromDirectory: pathString [
	"Import the project within the given directory and try to determine its name.
	It is recommended that you specify the project name using `import:fromDirectory:`,
	unless you are sure that there is only one managed project in the directory."

	| project |
	project := NexusProjectImporter importFromDirectory: pathString.
	self recordProject: project fromDirectory: pathString.
	^ project
]

{ #category : 'printing' }
NexusRepository >> printOn: stream [

	super printOn: stream.
	stream nextPut: $(.
	stream nextPutAll: directory pathString.
	stream nextPut: $)
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

	| properties |
	properties := OrderedCollection new.
	(directory / 'repository') directories do: [ :groupDirectory |
		groupDirectory directories do: [ :nameDirectory |
			nameDirectory directories do: [ :versionDirectory |
				properties add: versionDirectory / 'properties.json' ] ] ].
	^ properties
]

{ #category : 'enumerating' }
NexusRepository >> projects [
	"Returns all the projects managed by this repository."

	^ self projectProperties collect: [ :properties |
		  NexusProject fromProperties: properties ]
]

{ #category : 'adding' }
NexusRepository >> recordProject: project fromDirectory: pathString [
	"Add the project to this repository, copying the sources from the given directory."

	| projectDirectory |
	(projectDirectory := self resolveDirectoryOf: project) ifExists: [
		Warning signal:
			'This project already exists in the given repository, proceed to overwrite it'.
		projectDirectory deleteAll ].
	project directory:
		(projectDirectory relativeTo: FileLocator home) pathString.

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

	^ directory / 'repository' / project group / project name
	  / project version
]
