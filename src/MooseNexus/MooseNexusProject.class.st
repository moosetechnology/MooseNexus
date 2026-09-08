"
I represent a MooseNexus project after its identity has been determined.

My properties follow this mapping:
```text
schemaVersion: <propertiesSchemaVersion>
language:      <language>
nature:        <subclassOfMooseNexusProject>
group:         <group>
name:          <name>
version:       <version>
```
The schema version identifies the persisted project-properties format. The nature corresponds to the concrete subclass of MooseNexusProject that handles managed or unmanaged project behavior. The group, name, and version are the coordinates that identify the source project as modeled by MooseNexus. Each model manifest records its own resolved dependency set.

A recorded project keeps its repositoryPath relative to the backend storage layout that hosts it, for example `<group>/<name>/<version>`. The repository backend owns the repository root, the storage layout segment such as `repository`, and the resolution to concrete filesystem locations.

Use MooseNexusBuildSpec to describe build-time intent and MooseNexusProjectSpec for the narrower source-project coordinates and directory. Coordinate inference belongs to importers; this object only carries the coordinates it was initialized with.
"
Class {
	#name : 'MooseNexusProject',
	#superclass : 'Object',
	#instVars : [
		'coordinates',
		'resolvedDependencySet',
		'repositoryBackend',
		'repositoryPath'
	],
	#category : 'MooseNexus-Project',
	#package : 'MooseNexus',
	#tag : 'Project'
}

{ #category : 'instance creation' }
MooseNexusProject class >> coordinates: aMooseNexusCoordinates [

	^ self new initializeCoordinates: aMooseNexusCoordinates
]

{ #category : 'instance creation' }
MooseNexusProject class >> fromNexusDirectory: projectDirectory inBackend: aMooseNexusRepositoryBackend [

	^ (self fromProperties: projectDirectory / 'metadata' / 'properties.json')
		  repositoryBackend: aMooseNexusRepositoryBackend
		  path: (aMooseNexusRepositoryBackend projectPathForDirectory: projectDirectory)
]

{ #category : 'instance creation' }
MooseNexusProject class >> fromProperties: file [
	"Read the project data from the properties file recorded in the repository."

	| properties |
	properties := file readStreamDo: [ :s | STON fromStream: s ].
	^ ((properties at: #nature) asClassInEnvironment: self environment) new readProperties: properties
]

{ #category : 'testing' }
MooseNexusProject class >> isAbstract [

	^ self == MooseNexusProject
]

{ #category : 'properties' }
MooseNexusProject class >> propertiesSchemaVersion [

	^ 'alpha'
]

{ #category : 'properties' }
MooseNexusProject class >> supportsPropertiesSchemaVersion: schemaVersion [

	^ schemaVersion = self propertiesSchemaVersion
]

{ #category : 'adding' }
MooseNexusProject >> addImageArtifact: anImageArtifact [
	"Record an image directory for a model artifact already recorded by this project."

	| existingArtifact |
	(self modelManifestNamed: anImageArtifact modelArtifactName) ifNil: [
		Error signal: 'Cannot record MooseNexus image artifact for missing model artifact: ' , anImageArtifact modelArtifactName ].
	existingArtifact := self imageArtifacts detect: [ :artifact | artifact name = anImageArtifact name ] ifNone: [ nil ].
	existingArtifact ifNotNil: [
			existingArtifact = anImageArtifact ifTrue: [ ^ existingArtifact ].
			Error signal: 'Cannot replace existing MooseNexus image artifact: ' , anImageArtifact name ].
	(self imageArtifactsDirectory / anImageArtifact name) ensureCreateDirectory.
	self writeImageArtifacts: (self imageArtifacts copyWith: anImageArtifact).
	^ anImageArtifact
]

{ #category : 'adding' }
MooseNexusProject >> addModel: aMooseNexusModelArtifact [
	"Add a model artifact to this project with an empty build context. Prefer addModelManifest: when build context is available."

	self addModelManifest: (MooseNexusModelArtifactManifest
			 modelArtifact: aMooseNexusModelArtifact
			 dependencyResolutionResult: (MooseNexusDependencyResolutionResult forProject: self)
			 generatedFiles: #(  )
			 createdTimestamp: aMooseNexusModelArtifact timestamp)
]

{ #category : 'adding' }
MooseNexusProject >> addModelManifest: aMooseNexusModelArtifactManifest [
	"Record a uniquely named model artifact. A different manifest cannot replace an existing model name."

	| existingManifest |
	existingManifest := self modelManifestNamed: aMooseNexusModelArtifactManifest modelArtifact name.
	existingManifest ifNotNil: [
			(existingManifest hasSameMetadataAs: aMooseNexusModelArtifactManifest) ifTrue: [ ^ existingManifest ].
			Error signal: 'Cannot replace existing MooseNexus model artifact with a different manifest: '
				, aMooseNexusModelArtifactManifest modelArtifact name ].
	self writeModelManifests: (self modelManifests copyWith: aMooseNexusModelArtifactManifest).
	^ aMooseNexusModelArtifactManifest
]

{ #category : 'enumerating' }
MooseNexusProject >> artifactPayloadDirectory [

	^ self repositoryDirectory / 'artifacts'
]

{ #category : 'accessing' }
MooseNexusProject >> coordinates [

	^ coordinates
]

{ #category : 'accessing' }
MooseNexusProject >> dependencies [

	^ self resolvedDependencySet dependencies
]

{ #category : 'accessing' }
MooseNexusProject >> dependencies: aCollection [

	resolvedDependencySet := MooseNexusResolvedDependencySet dependencies: aCollection
]

{ #category : 'accessing' }
MooseNexusProject >> group [

	^ self coordinates group
]

{ #category : 'enumerating' }
MooseNexusProject >> imageArtifacts [

	^ self metadataDirectory / 'images.json' readStreamDo: [ :stream |
		  (STON fromStream: stream) collect: [ :dictionary | MooseNexusImageArtifact fromDictionary: dictionary ] ]
]

{ #category : 'enumerating' }
MooseNexusProject >> imageArtifactsDirectory [

	^ self artifactPayloadDirectory / 'images'
]

{ #category : 'setup' }
MooseNexusProject >> importModel [
	"There can be multiple models with different settings for the same project."

	self models ifEmpty: [ self inform: 'No models to import' ] ifNotEmpty: [ :models |
			models size = 1 ifTrue: [ ^ self importModel: models first ].

			"Open a presenter to choose a model to import."
			(MooseNexusModelSelectionPresenter on: self) open ]
]

{ #category : 'setup' }
MooseNexusProject >> importModel: aMooseNexusModelArtifact [

	| model |
	self validateModelImportRequirements.
	model := FamixJavaModel new.

	FamixJSONFileImporter new
		model: model;
		inputFile: self repositoryDirectory / aMooseNexusModelArtifact path;
		runFilteredBy: FamixJavaImportingContext new importMaximum.

	model install. "add to MooseModel root"
	model rootFolder: self sourceDirectory.
	^ model
]

{ #category : 'initialization' }
MooseNexusProject >> initializeCoordinates: aMooseNexusCoordinates [

	self isRecorded ifTrue: [ Error signal: 'Cannot change project coordinates after recording the project in a repository' ].
	coordinates ifNotNil: [ Error signal: 'Cannot change project coordinates after initialization' ].
	coordinates := aMooseNexusCoordinates
]

{ #category : 'testing' }
MooseNexusProject >> isManagedProject [

	^ false
]

{ #category : 'testing' }
MooseNexusProject >> isRecorded [

	^ repositoryBackend notNil and: [ repositoryPath notNil ]
]

{ #category : 'accessing' }
MooseNexusProject >> language [
	"Subclasses must return a lowercase string of the project's language name."

	self subclassResponsibility
]

{ #category : 'enumerating' }
MooseNexusProject >> metadataDirectory [

	^ self repositoryDirectory / 'metadata'
]

{ #category : 'enumerating' }
MooseNexusProject >> modelArtifactsDirectory [

	^ self artifactPayloadDirectory / 'models'
]

{ #category : 'setup' }
MooseNexusProject >> modelImportRequirements [

	^ { MooseNexusImageRequirement
		    name: 'Famix Java JSON import'
		    availabilityValidation: [
			    (Smalltalk includesKey: #FamixJavaModel) and: [
				    (Smalltalk includesKey: #FamixJSONFileImporter) and: [ Smalltalk includesKey: #FamixJavaImportingContext ] ] ]
		    versionValidation: [ '' ]
		    expectedVersionDescription: 'loaded Famix Java JSON import support' }
]

{ #category : 'enumerating' }
MooseNexusProject >> modelManifestNamed: modelName [

	^ self modelManifests detect: [ :manifest | manifest modelArtifact name = modelName ] ifNone: [ nil ]
]

{ #category : 'enumerating' }
MooseNexusProject >> modelManifests [

	^ self metadataDirectory / 'models.json' readStreamDo: [ :stream |
		  (STON fromStream: stream) collect: [ :manifest | MooseNexusModelArtifactManifest fromDictionary: manifest ] ]
]

{ #category : 'enumerating' }
MooseNexusProject >> models [

	^ self modelManifests collect: [ :manifest | manifest modelArtifact ]
]

{ #category : 'accessing' }
MooseNexusProject >> name [

	^ self coordinates name
]

{ #category : 'printing' }
MooseNexusProject >> printOn: stream [

	super printOn: stream.
	stream nextPut: $(.
	coordinates ifNil: [ stream nextPutAll: '<coordinates>' ] ifNotNil: [ coordinates printOn: stream ].
	stream nextPut: $)
]

{ #category : 'enumerating' }
MooseNexusProject >> projectSourceDirectory [
	"The directory containing all of the original project sources."

	^ self sourceDirectory / 'project'
]

{ #category : 'enumerating' }
MooseNexusProject >> properties [
	"Gather the project identity shared by all model artifacts."

	^ Dictionary new
		  add: #schemaVersion -> self propertiesSchemaVersion;
		  add: #language -> self language;
		  add: #nature -> self className;
		  add: #group -> self group;
		  add: #name -> self name;
		  add: #version -> self version;
		  yourself
]

{ #category : 'properties' }
MooseNexusProject >> propertiesSchemaVersion [

	^ self class propertiesSchemaVersion
]

{ #category : 'properties' }
MooseNexusProject >> readProperties: properties [

	self validatePropertiesSchemaVersion: properties.
	self initializeCoordinates:
		(MooseNexusCoordinates group: (properties at: #group) name: (properties at: #name) version: (properties at: #version))
]

{ #category : 'adding' }
MooseNexusProject >> replaceModelManifest: aMooseNexusModelArtifactManifest [
	"Replace the manifest recorded for an existing model name."

	(self modelManifestNamed: aMooseNexusModelArtifactManifest modelArtifact name) ifNil: [
		Error signal: 'Cannot replace missing MooseNexus model artifact: ' , aMooseNexusModelArtifactManifest modelArtifact name ].
	self writeModelManifests: (self modelManifests collect: [ :manifest |
				 manifest modelArtifact name = aMooseNexusModelArtifactManifest modelArtifact name
					 ifTrue: [ aMooseNexusModelArtifactManifest ]
					 ifFalse: [ manifest ] ])
]

{ #category : 'accessing' }
MooseNexusProject >> repositoryBackend [

	^ repositoryBackend ifNil: [ Error signal: 'MooseNexus project is not attached to a repository backend' ]
]

{ #category : 'accessing' }
MooseNexusProject >> repositoryBackend: aMooseNexusRepositoryBackend [

	repositoryBackend := aMooseNexusRepositoryBackend
]

{ #category : 'accessing' }
MooseNexusProject >> repositoryBackend: aMooseNexusRepositoryBackend path: repositoryPathString [

	repositoryBackend := aMooseNexusRepositoryBackend.
	repositoryPath := repositoryPathString
]

{ #category : 'enumerating' }
MooseNexusProject >> repositoryDirectory [

	^ self repositoryBackend projectDirectoryFor: self
]

{ #category : 'accessing' }
MooseNexusProject >> repositoryPath [

	^ repositoryPath
]

{ #category : 'accessing' }
MooseNexusProject >> repositoryPath: repositoryPathString [

	repositoryPath := repositoryPathString
]

{ #category : 'accessing' }
MooseNexusProject >> resolvedDependencySet [

	^ resolvedDependencySet ifNil: [ resolvedDependencySet := MooseNexusResolvedDependencySet empty ]
]

{ #category : 'enumerating' }
MooseNexusProject >> sourceDirectory [
	"The directory containing all of the sources for this project.
	This includes the original project sources, and additional sources from dependencies."

	^ self repositoryDirectory / 'sources'
]

{ #category : 'properties' }
MooseNexusProject >> supportsPropertiesSchemaVersion: schemaVersion [

	^ self class supportsPropertiesSchemaVersion: schemaVersion
]

{ #category : 'setup' }
MooseNexusProject >> validateModelImportRequirements [

	| validationResults |
	validationResults := self modelImportRequirements collect: [ :requirement | requirement validate ].
	validationResults detect: [ :result | result isAvailable not ] ifFound: [ :result | Error signal: result errorMessage ].
	^ validationResults
]

{ #category : 'properties' }
MooseNexusProject >> validatePropertiesSchemaVersion: properties [

	| schemaVersion |
	schemaVersion := properties at: #schemaVersion ifAbsent: [ self propertiesSchemaVersion ].
	(self supportsPropertiesSchemaVersion: schemaVersion) ifFalse: [
		Error signal: 'Unsupported MooseNexus project properties schema version: ' , schemaVersion asString ]
]

{ #category : 'accessing' }
MooseNexusProject >> version [

	^ self coordinates version
]

{ #category : 'private' }
MooseNexusProject >> writeImageArtifacts: imageArtifacts [

	self metadataDirectory / 'images.json' writeStreamDo: [ :stream |
		STON put: (imageArtifacts collect: [ :artifact | artifact asDictionary ]) asJsonOnStream: stream ]
]

{ #category : 'private' }
MooseNexusProject >> writeModelManifests: manifests [

	self metadataDirectory / 'models.json' writeStreamDo: [ :stream |
		STON put: (manifests collect: [ :manifest | manifest asDictionary ]) asJsonOnStream: stream ]
]

{ #category : 'properties' }
MooseNexusProject >> writePropertiesOn: stream [

	STON put: self properties asJsonOnStream: stream
]
