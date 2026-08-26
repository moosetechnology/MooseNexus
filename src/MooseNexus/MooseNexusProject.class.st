"
I represent a MooseNexus project loaded in memory or recorded in a repository.

My properties follow this mapping:
```text
schemaVersion:         <propertiesSchemaVersion>
language:              <language>
nature:                <subclassOfMooseNexusProject>
group:                 <group>
name:                  <name>
version:               <version>
resolvedDependencies:  <serializedResolvedDependencySet>
```
The schema version identifies the persisted properties format.
The nature corresponds to the concrete subclass of MooseNexusProject that handles the source project.
The group, name, and version are the coordinates that identify the source project as modeled by MooseNexus.
Resolved dependencies are the exact dependency descriptors selected for this project build.

Use MooseNexusBuildSpec to describe build-time intent and MooseNexusProjectSpec for the narrower source-project coordinates and directory. Coordinate inference belongs to importers; this object only carries the coordinates it was initialized with.
"
Class {
	#name : 'MooseNexusProject',
	#superclass : 'Object',
	#instVars : [
		'coordinates',
		'directory',
		'resolvedDependencySet'
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
MooseNexusProject class >> fromNexusDirectory: directory [

	^ (self fromProperties: directory / 'metadata' / 'properties.json') directory: (directory relativeTo: FileLocator home) pathString
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
	"Add a model artifact manifest to this project, overwriting any manifest for the same model name."

	| manifests serializedManifests |
	manifests := self modelManifests reject: [ :manifest |
		             manifest modelArtifact name = aMooseNexusModelArtifactManifest modelArtifact name ].
	manifests := manifests copyWith: aMooseNexusModelArtifactManifest.
	serializedManifests := manifests collect: [ :manifest | manifest asDictionary ].
	self metadataDirectory / 'models.json' writeStreamDo: [ :stream | STON put: serializedManifests asJsonOnStream: stream ]
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
MooseNexusProject >> directory [

	^ directory
]

{ #category : 'accessing' }
MooseNexusProject >> directory: pathString [

	directory := pathString
]

{ #category : 'accessing' }
MooseNexusProject >> group [

	^ self coordinates group
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
		inputFile: FileLocator home / directory / aMooseNexusModelArtifact path;
		runFilteredBy: FamixJavaImportingContext new importMaximum.

	model install. "add to MooseModel root"
	model rootFolder: (FileLocator home / directory / 'sources') absolutePath pathString.
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

	^ directory notNil
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
	"Gather all of the properties of this project in a dictionary."

	^ Dictionary new
		  add: #schemaVersion -> self propertiesSchemaVersion;
		  add: #language -> self language;
		  add: #nature -> self className;
		  add: #group -> self group;
		  add: #name -> self name;
		  add: #version -> self version;
		  add: #resolvedDependencies -> self serializedResolvedDependencies;
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
		(MooseNexusCoordinates group: (properties at: #group) name: (properties at: #name) version: (properties at: #version)).
	properties
		at: #resolvedDependencies
		ifPresent: [ :deps | resolvedDependencySet := self resolvedDependencySetFromProperties: deps ]
]

{ #category : 'enumerating' }
MooseNexusProject >> repositoryDirectory [

	^ FileLocator home / directory
]

{ #category : 'accessing' }
MooseNexusProject >> resolvedDependencySet [

	^ resolvedDependencySet ifNil: [ resolvedDependencySet := MooseNexusResolvedDependencySet empty ]
]

{ #category : 'properties' }
MooseNexusProject >> resolvedDependencySetFromProperties: dependencyDictionaries [

	^ MooseNexusResolvedDependencySet fromDictionaries: dependencyDictionaries
]

{ #category : 'enumerating' }
MooseNexusProject >> serializedResolvedDependencies [

	^ self resolvedDependencySet asDictionaries
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

{ #category : 'properties' }
MooseNexusProject >> writePropertiesOn: stream [

	STON put: self properties asJsonOnStream: stream
]
