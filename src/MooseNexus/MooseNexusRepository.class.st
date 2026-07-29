"
I am a repository for `MooseNexusProject`s.
I have a configurable home directory where the projects are stored.
The default instance uses the `~/.moose` directory.

My goal is to manage projects to be analyzed with Moose in a reusable, structured, and versioned manner.

### API
To manage a new project, use one of the following methods:

#### `MooseNexusRepository >> #import:fromDirectory:`
The first parameter expects a name that will be given to the project.
The second parameter expects the path string to a local directory containing the sources of the project to analyze.

#### `MooseNexusRepository >> #importFromDirectory:`
Expects the path string to the sources, and Nexus will try to figure out the project name.
It can only be found if it is a managed project (see `MooseNexusManagedProject`) that declares a single artifact.

#### `MooseNexusRepository >> #recordProject:fromDirectory:`
Expects an existing `MooseNexusProject` and a path string to a local directory containing the project sources.
This is useful if you want to have finer control over the project analysis, such as specifying the group or version, or if you want to copy a project from another `MooseNexusRepository`.
The name, group and version must be specified before the project is added to the repository:
```
project := MooseNexusProjectImporter importFromDirectory: pathString.
project name: name.
project group: group.
project version: version.
MooseNexusRepository default recordProject: project fromDirectory: pathString.
```
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

{ #category : 'importing' }
MooseNexusRepository >> import: name fromDirectory: pathString [
	"Import the project within the given directory and name it."

	| project |
	project := MooseNexusProjectImporter importFromDirectory: pathString.
	project name: name.
	self recordProject: project fromDirectory: pathString.
	^ project
]

{ #category : 'importing' }
MooseNexusRepository >> importCoordinates: coordinates fromDirectory: pathString [
	"Import the project within the given directory and record it with explicit coordinates."

	| project |
	project := MooseNexusProjectImporter importFromDirectory: pathString.
	^ self recordProject: project coordinates: coordinates fromDirectory: pathString
]

{ #category : 'importing' }
MooseNexusRepository >> importFromDirectory: pathString [
	"Import the project within the given directory and try to determine its name.
	It is recommended that you specify the project name using `import:fromDirectory:`,
	unless you are sure that there is only one managed project in the directory."

	| project |
	project := MooseNexusProjectImporter importFromDirectory: pathString.
	self recordProject: project fromDirectory: pathString.
	^ project
]

{ #category : 'importing' }
MooseNexusRepository >> importGroup: group name: name version: version fromDirectory: pathString [
	"Import the project within the given directory and record it with explicit coordinates."

	^ self importCoordinates: (MooseNexusProjectCoordinates group: group name: name version: version) fromDirectory: pathString
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
MooseNexusRepository >> recordProject: project coordinates: coordinates fromDirectory: pathString [
	"Set project coordinates before recording it in the repository."

	project coordinates: coordinates.
	^ self recordProject: project fromDirectory: pathString
]

{ #category : 'adding' }
MooseNexusRepository >> recordProject: project fromDirectory: pathString [
	"Add project to the repository, copying sources from the given directory."

	| projectDirectory |
	(projectDirectory := self resolveDirectoryOf: project) ifExists: [
			Warning signal: 'This project already exists in given repository, proceed to overwrite it'.
			projectDirectory deleteAll ].
	project directory: (projectDirectory relativeTo: FileLocator home) pathString.

	"copy project directory to repository"
	pathString asFileReference copyAllTo: (projectDirectory / 'sources/project') ensureCreateDirectory.

	"write properties file useful for Nexus"
	(projectDirectory / 'properties.json') ensureCreateFile writeStreamDo: [ :stream | project writePropertiesOn: stream ].

	"JSON list of models created, empty by default"
	(projectDirectory / 'models.json') ensureCreateFile writeStreamDo: [ :stream | stream nextPutAll: '[]' ].

	^ project
]

{ #category : 'adding' }
MooseNexusRepository >> recordProject: project group: group name: name version: version fromDirectory: pathString [
	"Set project coordinates before recording it in the repository."

	^ self
		  recordProject: project
		  coordinates: (MooseNexusProjectCoordinates group: group name: name version: version)
		  fromDirectory: pathString
]

{ #category : 'enumerating' }
MooseNexusRepository >> resolveDirectoryOf: project [

	^ directory / 'repository' / project group / project name / project version
]
