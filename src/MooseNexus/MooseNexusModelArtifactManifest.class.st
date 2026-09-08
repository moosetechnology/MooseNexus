"
I describe one recorded model artifact together with the build context needed to inspect and reproduce it.

I am the object persisted in models.json. The model artifact identifies the produced model. Generated files record repository-relative paths and checksums. The dependency-resolution result records the dependencies, warnings, and conflict decisions used for the build. This schema is intentionally alpha and may evolve without compatibility adapters.
"
Class {
	#name : 'MooseNexusModelArtifactManifest',
	#superclass : 'Object',
	#instVars : [
		'modelArtifact',
		'dependencyResolutionResult',
		'generatedFiles',
		'createdTimestamp',
		'buildProvenance'
	],
	#category : 'MooseNexus-Artifact',
	#package : 'MooseNexus',
	#tag : 'Artifact'
}

{ #category : 'instance creation' }
MooseNexusModelArtifactManifest class >> fromDictionary: aDictionary [

	^ self
		  modelArtifact: (MooseNexusModelArtifact fromDictionary: (aDictionary at: 'modelArtifact'))
		  dependencyResolutionResult: (MooseNexusDependencyResolutionResult fromDictionary: (aDictionary at: 'dependencyResolution'))
		  generatedFiles: (aDictionary at: 'generatedFiles')
		  createdTimestamp: (aDictionary at: 'createdTimestamp')
		  buildProvenance: (MooseNexusBuildProvenance fromDictionary: (aDictionary at: 'buildProvenance'))
]

{ #category : 'instance creation' }
MooseNexusModelArtifactManifest class >> generatedFileFor: fileReference relativeTo: rootDirectory [

	^ Dictionary new
		  add: 'path' -> (fileReference relativeTo: rootDirectory) pathString;
		  add: 'size' -> fileReference size;
		  add: 'checksumAlgorithm' -> 'sha256';
		  add: 'checksum' -> (fileReference binaryReadStreamDo: [ :stream | (SHA256 hashStream: stream) hex ]);
		  yourself
]

{ #category : 'instance creation' }
MooseNexusModelArtifactManifest class >> modelArtifact: aMooseNexusModelArtifact dependencyResolutionResult: aMooseNexusDependencyResolutionResult generatedFiles: generatedFileDescriptors createdTimestamp: aTimestamp buildProvenance: aMooseNexusBuildProvenance [

	^ self new
		  initializeModelArtifact: aMooseNexusModelArtifact
		  dependencyResolutionResult: aMooseNexusDependencyResolutionResult
		  generatedFiles: generatedFileDescriptors
		  createdTimestamp: aTimestamp
		  buildProvenance: aMooseNexusBuildProvenance
]

{ #category : 'comparing' }
MooseNexusModelArtifactManifest >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].

	^ anObject modelArtifact = modelArtifact and: [
			  anObject dependencyResolutionResult = dependencyResolutionResult and: [
					  anObject generatedFiles = generatedFiles and: [
						  anObject createdTimestamp = createdTimestamp and: [ anObject buildProvenance = buildProvenance ] ] ] ]
]

{ #category : 'converting' }
MooseNexusModelArtifactManifest >> asDictionary [

	^ Dictionary new
		  add: 'schemaVersion' -> 'alpha';
		  add: 'modelArtifact' -> modelArtifact asDictionary;
		  add: 'generatedFiles' -> generatedFiles;
		  add: 'dependencyResolution' -> dependencyResolutionResult asDictionary;
		  add: 'createdTimestamp' -> createdTimestamp;
		  add: 'buildProvenance' -> buildProvenance asDictionary;
		  yourself
]

{ #category : 'accessing' }
MooseNexusModelArtifactManifest >> buildProvenance [

	^ buildProvenance
]

{ #category : 'accessing' }
MooseNexusModelArtifactManifest >> createdTimestamp [

	^ createdTimestamp
]

{ #category : 'accessing' }
MooseNexusModelArtifactManifest >> dependencyResolutionResult [

	^ dependencyResolutionResult
]

{ #category : 'accessing' }
MooseNexusModelArtifactManifest >> generatedFiles [

	^ generatedFiles
]

{ #category : 'comparing' }
MooseNexusModelArtifactManifest >> hasSameMetadataAs: anotherManifest [
	"Compare reproducible build metadata without the recording timestamps."

	^ modelArtifact = anotherManifest modelArtifact and: [
			  dependencyResolutionResult = anotherManifest dependencyResolutionResult and: [
				  generatedFiles = anotherManifest generatedFiles and: [ buildProvenance = anotherManifest buildProvenance ] ] ]
]

{ #category : 'comparing' }
MooseNexusModelArtifactManifest >> hash [

	^ modelArtifact hash bitXor:
		  (dependencyResolutionResult hash bitXor: (generatedFiles hash bitXor: (createdTimestamp hash bitXor: buildProvenance hash)))
]

{ #category : 'initialization' }
MooseNexusModelArtifactManifest >> initializeModelArtifact: aMooseNexusModelArtifact dependencyResolutionResult: aMooseNexusDependencyResolutionResult generatedFiles: generatedFileDescriptors createdTimestamp: aTimestamp buildProvenance: aMooseNexusBuildProvenance [

	modelArtifact := aMooseNexusModelArtifact.
	dependencyResolutionResult := aMooseNexusDependencyResolutionResult.
	generatedFiles := generatedFileDescriptors asArray.
	createdTimestamp := aTimestamp.
	buildProvenance := aMooseNexusBuildProvenance
]

{ #category : 'accessing' }
MooseNexusModelArtifactManifest >> modelArtifact [

	^ modelArtifact
]
