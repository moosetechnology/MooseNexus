"
I persist MooseNexus repository data in the local filesystem.

I own the current directory layout under <repository>/repository/<group>/<name>/<version>. MooseNexusRepository delegates storage operations to me so another backend can provide the same client-side repository protocol later.
"
Class {
	#name : 'MooseNexusLocalRepositoryBackend',
	#superclass : 'MooseNexusRepositoryBackend',
	#instVars : [
		'directory'
	],
	#category : 'MooseNexus-Repository',
	#package : 'MooseNexus',
	#tag : 'Repository'
}

{ #category : 'instance creation' }
MooseNexusLocalRepositoryBackend class >> directory: aFileReference [

	^ self new directory: aFileReference
]

{ #category : 'artifacts' }
MooseNexusLocalRepositoryBackend >> artifactAt: repositoryRelativePath [

	| artifactFile |
	artifactFile := self artifactFileAt: repositoryRelativePath.
	artifactFile ifAbsent: [ NotFound signal: 'Artifact `' , repositoryRelativePath , '` not found in local repository' ].
	^ artifactFile
]

{ #category : 'artifacts' }
MooseNexusLocalRepositoryBackend >> artifactExistsAt: repositoryRelativePath [

	^ (self artifactFileAt: repositoryRelativePath) exists
]

{ #category : 'artifacts' }
MooseNexusLocalRepositoryBackend >> artifactFileAt: repositoryRelativePath [

	^ directory / repositoryRelativePath
]

{ #category : 'accessing' }
MooseNexusLocalRepositoryBackend >> directory [

	^ directory
]

{ #category : 'accessing' }
MooseNexusLocalRepositoryBackend >> directory: aFileReference [

	directory := aFileReference
]

{ #category : 'artifacts' }
MooseNexusLocalRepositoryBackend >> fetchArtifactAt: repositoryRelativePath into: aMooseNexusLocalRepositoryBackend ifAbsent: absentBlock [

	(self artifactExistsAt: repositoryRelativePath) ifFalse: [ ^ absentBlock value ].
	^ aMooseNexusLocalRepositoryBackend storeArtifactAt: repositoryRelativePath from: (self artifactAt: repositoryRelativePath)
]

{ #category : 'enumerating' }
MooseNexusLocalRepositoryBackend >> group: group project: project version: version [
	"Search the repository for the project with the specified group, project name and version."

	| dir |
	dir := self storageDirectory / group ifAbsent: [ NotFound signal: 'Group `' , group , '`, not found in repository' ].
	dir := dir / project ifAbsent: [ NotFound signal: 'Project `' , project , '` not found in group `' , group , '`' ].
	dir := dir / version ifAbsent: [
		       NotFound signal: 'Version `' , version , '` not found for project `' , project , '` in group `' , group , '`' ].
	^ MooseNexusProject fromNexusDirectory: dir inBackend: self
]

{ #category : 'accessing' }
MooseNexusLocalRepositoryBackend >> localProjectBackend [

	^ self
]

{ #category : 'adding' }
MooseNexusLocalRepositoryBackend >> prepareDirectoryFor: aMooseNexusProjectSpec [
	"Create the repository layout needed before copying sources or writing metadata."

	| projectDirectory |
	projectDirectory := self resolveDirectoryFor: aMooseNexusProjectSpec.
	projectDirectory ifExists: [
			Warning signal: 'This project already exists in given repository, proceed to overwrite it'.
			projectDirectory deleteAll ].
	(projectDirectory / 'metadata') ensureCreateDirectory.
	(projectDirectory / 'sources' / 'project') ensureCreateDirectory.
	(projectDirectory / 'artifacts' / 'models') ensureCreateDirectory.
	(projectDirectory / 'artifacts' / 'images') ensureCreateDirectory.
	projectDirectory / 'metadata' / 'images.json' writeStreamDo: [ :stream | stream nextPutAll: '[]' ].
	^ projectDirectory
]

{ #category : 'printing' }
MooseNexusLocalRepositoryBackend >> printOn: stream [

	super printOn: stream.
	stream nextPut: $(.
	stream nextPutAll: directory pathString.
	stream nextPut: $)
]

{ #category : 'printing' }
MooseNexusLocalRepositoryBackend >> printProjectProperties: propertiesFile on: writeStream [

	propertiesFile readStreamDo: [ :rs |
			| properties |
			properties := STON fromStream: rs.
			writeStream << (properties at: #nature) << '(' << (properties at: #group) << ':' << (properties at: #name) << ':'
			<< (properties at: #version) << ')' ]
]

{ #category : 'printing' }
MooseNexusLocalRepositoryBackend >> printProjects [

	directory ifAbsent: [ ^ 'none' ].
	^ self projectProperties ifEmpty: [ ^ 'none' ] ifNotEmpty: [ :projectProperties |
			  String streamContents: [ :s |
				  projectProperties do: [ :properties | self printProjectProperties: properties on: s ] separatedBy: [ s cr ] ] ]
]

{ #category : 'enumerating' }
MooseNexusLocalRepositoryBackend >> projectDirectories [
	"Returns the directories of all projects recorded by this repository."

	| directories |
	directories := OrderedCollection new.
	self storageDirectory directories do: [ :groupDirectory |
			groupDirectory directories do: [ :nameDirectory |
				nameDirectory directories do: [ :versionDirectory | directories add: versionDirectory ] ] ].
	^ directories
]

{ #category : 'enumerating' }
MooseNexusLocalRepositoryBackend >> projectDirectoryFor: aMooseNexusProject [

	^ self storageDirectory / aMooseNexusProject repositoryPath
]

{ #category : 'enumerating' }
MooseNexusLocalRepositoryBackend >> projectPathFor: aMooseNexusProjectSpec [

	^ String streamContents: [ :stream |
			  stream
				  nextPutAll: aMooseNexusProjectSpec group;
				  nextPut: $/;
				  nextPutAll: aMooseNexusProjectSpec name;
				  nextPut: $/;
				  nextPutAll: aMooseNexusProjectSpec version ]
]

{ #category : 'enumerating' }
MooseNexusLocalRepositoryBackend >> projectPathForDirectory: projectDirectory [

	^ (projectDirectory relativeTo: self storageDirectory) pathString
]

{ #category : 'enumerating' }
MooseNexusLocalRepositoryBackend >> projectProperties [
	"Returns the properties files of all projects recorded by this repository."

	^ self projectDirectories collect: [ :projectDirectory | projectDirectory / 'metadata' / 'properties.json' ]
]

{ #category : 'enumerating' }
MooseNexusLocalRepositoryBackend >> projects [
	"Returns all the projects recorded by this repository."

	^ self projectDirectories collect: [ :projectDirectory | MooseNexusProject fromNexusDirectory: projectDirectory inBackend: self ]
]

{ #category : 'adding' }
MooseNexusLocalRepositoryBackend >> recordLoadedProject: project describedBy: aMooseNexusProjectSpec [
	"Add an already loaded project to the repository using the spec that describes recording intent."

	| projectDirectory metadataDirectory |
	aMooseNexusProjectSpec validateForRecording.
	project coordinates ifNil: [ project initializeCoordinates: aMooseNexusProjectSpec coordinates ] ifNotNil: [ :coordinates |
			coordinates = aMooseNexusProjectSpec coordinates ifFalse: [
				Error signal: 'Cannot record a MooseNexus project with coordinates different from its spec' ] ].
	projectDirectory := self prepareDirectoryFor: aMooseNexusProjectSpec.
	metadataDirectory := projectDirectory / 'metadata'.
	project repositoryBackend: self path: (self projectPathFor: aMooseNexusProjectSpec).

	aMooseNexusProjectSpec sourceDirectory copyAllTo: projectDirectory / 'sources' / 'project'.
	(metadataDirectory / 'properties.json') ensureCreateFile writeStreamDo: [ :stream | project writePropertiesOn: stream ].
	(metadataDirectory / 'models.json') ensureCreateFile writeStreamDo: [ :stream | stream nextPutAll: '[]' ].
	^ project
]

{ #category : 'enumerating' }
MooseNexusLocalRepositoryBackend >> resolveDirectoryFor: aMooseNexusProjectSpec [

	^ self storageDirectory / (self projectPathFor: aMooseNexusProjectSpec)
]

{ #category : 'enumerating' }
MooseNexusLocalRepositoryBackend >> storageDirectory [

	^ directory / 'repository'
]

{ #category : 'artifacts' }
MooseNexusLocalRepositoryBackend >> storeArtifactAt: repositoryRelativePath from: sourceFileReference [

	| targetFile |
	targetFile := self artifactFileAt: repositoryRelativePath.
	targetFile parent ensureCreateDirectory.
	targetFile ifExists: [ targetFile delete ].
	sourceFileReference asFileReference copyTo: targetFile.
	^ targetFile
]
