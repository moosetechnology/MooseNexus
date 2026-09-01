"
I test the client-side OCI artifact publication workflow without contacting an OCI registry.
"
Class {
	#name : 'MooseNexusOciArtifactPublishingTest',
	#superclass : 'TestCase',
	#instVars : [
		'rootDirectory',
		'project',
		'manifest'
	],
	#category : 'MooseNexus-Tests-Artifact',
	#package : 'MooseNexus-Tests',
	#tag : 'Artifact'
}

{ #category : 'private' }
MooseNexusOciArtifactPublishingTest >> artifactCoordinates [

	^ MooseNexusModelArtifactCoordinates
		  projectCoordinates: project coordinates
		  name: 'demo-model'
		  format: 'json'
		  metamodel: 'Famix-Java'
		  classifier: 'main'
]

{ #category : 'private' }
MooseNexusOciArtifactPublishingTest >> manifestForModelPath: modelPath [

	| artifact |
	artifact := MooseNexusModelArtifact
		            artifactCoordinates: self artifactCoordinates
		            path: modelPath
		            comment: 'generated for publishing tests'
		            timestamp: '2026-09-01T10:00:00+02:00'.
	^ MooseNexusModelArtifactManifest
		  modelArtifact: artifact
		  dependencyResolutionResult: (MooseNexusDependencyResolutionResult forProject: project)
		  generatedFiles: #(  )
		  createdTimestamp: artifact timestamp
]

{ #category : 'running' }
MooseNexusOciArtifactPublishingTest >> setUp [

	| repositoryDirectory modelFile |
	super setUp.
	rootDirectory := FileLocator temp / ('MooseNexus-' , UUID new asString).
	repositoryDirectory := rootDirectory / 'repository' / 'com.example' / 'demo' / '1.0.0'.
	(repositoryDirectory / 'sources' / 'project' / 'src') ensureCreateDirectory.
	(repositoryDirectory / 'artifacts' / 'models') ensureCreateDirectory.
	(repositoryDirectory / 'metadata') ensureCreateDirectory.
	repositoryDirectory / 'sources' / 'project' / 'src' / 'Demo.java' writeStreamDo: [ :stream | stream nextPutAll: 'class Demo { }' ].
	modelFile := repositoryDirectory / 'artifacts' / 'models' / 'demo-model.json'.
	modelFile writeStreamDo: [ :stream | stream nextPutAll: '{ }' ].
	project := MooseNexusTestProject coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0').
	project
		directory: (repositoryDirectory relativeTo: FileLocator home) pathString;
		dependencies: #(  ).
	manifest := self manifestForModelPath: 'artifacts/models/demo-model.json'
]

{ #category : 'running' }
MooseNexusOciArtifactPublishingTest >> tearDown [

	rootDirectory ifNotNil: [ rootDirectory ifExists: [ rootDirectory deleteAll ] ].
	super tearDown
]

{ #category : 'tests' }
MooseNexusOciArtifactPublishingTest >> testBundleBuilderCopiesModelAndArchivesSources [

	| bundle bundleDirectory modelLayer sourceLayer manifestDictionary |
	bundleDirectory := rootDirectory / 'bundle'.

	bundle := (MooseNexusOciArtifactBundleBuilder project: project manifest: manifest directory: bundleDirectory) build.

	modelLayer := bundle layers first.
	sourceLayer := bundle layers second.
	self assert: bundle artifactType equals: MooseNexusOciArtifactBundleBuilder artifactType.
	self assert: bundle configMediaType equals: MooseNexusOciArtifactBundleBuilder configMediaType.
	self assert: modelLayer mediaType equals: 'application/vnd.moose.famix+json'.
	self assert: modelLayer file contents equals: '{ }'.
	self assert: sourceLayer mediaType equals: MooseNexusOciArtifactBundleBuilder sourceArchiveMediaType.
	self assert: (ZipArchive isZipArchive: sourceLayer file).
	manifestDictionary := bundle configFile readStreamDo: [ :stream | STON fromStream: stream ].
	self assert: ((manifestDictionary at: 'modelArtifact') at: 'path') equals: 'artifacts/models/demo-model.json'
]

{ #category : 'tests' }
MooseNexusOciArtifactPublishingTest >> testOrasTransportBuildsPullArguments [

	| transport outputDirectory |
	transport := MooseNexusOrasTransport new.
	outputDirectory := rootDirectory / 'pulled'.

	self
		assert: (transport pullArgumentsFor: 'harbor.example.com/team/moosenexus/com.example/demo:1.0.0' into: outputDirectory)
		equals: {
				'oras'.
				'pull'.
				'--output'.
				outputDirectory pathString.
				'harbor.example.com/team/moosenexus/com.example/demo:1.0.0' }
]

{ #category : 'tests' }
MooseNexusOciArtifactPublishingTest >> testOrasTransportBuildsPushArguments [

	| bundle transport arguments |
	bundle := (MooseNexusOciArtifactBundleBuilder project: project manifest: manifest directory: rootDirectory / 'bundle') build.
	bundle reference: 'harbor.example.com/team/moosenexus/com.example/demo:1.0.0'.
	transport := MooseNexusOrasTransport new.

	arguments := transport pushArgumentsFor: bundle.

	self assert: arguments first equals: 'oras'.
	self assert: (arguments copyFrom: 2 to: 7) equals: {
			'push'.
			'--disable-path-validation'.
			'--artifact-type'.
			MooseNexusOciArtifactBundleBuilder artifactType.
			'--config'.
			bundle configArgument }.
	self assert: (arguments includes: 'harbor.example.com/team/moosenexus/com.example/demo:1.0.0').
	self assert: (arguments includes: bundle layers first asOrasArgument).
	self assert: (arguments includes: bundle layers second asOrasArgument)
]

{ #category : 'tests' }
MooseNexusOciArtifactPublishingTest >> testOrasTransportSignalsPullFailure [

	| transport |
	transport := MooseNexusOrasTransport new.
	transport commandRunner: [ :arguments | 256 ].

	self
		should: [ transport pull: 'harbor.example.com/team/moosenexus/com.example/demo:1.0.0' into: rootDirectory / 'pulled' ]
		raise: Error
		whoseDescriptionIncludes: 'Failed to pull OCI artifact bundle, error code: 256'
		description: 'ORAS failures should be reported to the caller'
]

{ #category : 'tests' }
MooseNexusOciArtifactPublishingTest >> testOrasTransportSignalsPushFailure [

	| bundle transport |
	bundle := (MooseNexusOciArtifactBundleBuilder project: project manifest: manifest directory: rootDirectory / 'bundle') build.
	bundle reference: 'harbor.example.com/team/moosenexus/com.example/demo:1.0.0'.
	transport := MooseNexusOrasTransport new.
	transport commandRunner: [ :arguments | 256 ].

	self
		should: [ transport pushBundle: bundle ]
		raise: Error
		whoseDescriptionIncludes: 'Failed to push OCI artifact bundle, error code: 256'
		description: 'ORAS failures should be reported to the caller'
]

{ #category : 'tests' }
MooseNexusOciArtifactPublishingTest >> testPublisherBuildsBundleAssignsReferenceAndDelegatesPush [

	| mapper transport publisher pushedArguments bundle |
	pushedArguments := #(  ).
	mapper := MooseNexusOciReferenceMapper registry: 'harbor.example.com' harborProject: 'Moose Team'.
	transport := MooseNexusOrasTransport new.
	transport commandRunner: [ :arguments |
			pushedArguments := arguments.
			0 ].
	publisher := MooseNexusOciArtifactPublisher referenceMapper: mapper transport: transport.

	bundle := publisher publishManifest: manifest of: project in: rootDirectory / 'bundle'.

	self assert: bundle reference equals: 'harbor.example.com/moose-team/moosenexus/com.example/demo:1.0.0'.
	self assert: pushedArguments equals: (transport pushArgumentsFor: bundle)
]

{ #category : 'tests' }
MooseNexusOciArtifactPublishingTest >> testPublisherUsesUniqueTemporaryBundleDirectory [

	| mapper transport publisher pushedArguments bundle |
	pushedArguments := #(  ).
	mapper := MooseNexusOciReferenceMapper registry: 'harbor.example.com' harborProject: 'Moose Team'.
	transport := MooseNexusOrasTransport new.
	transport commandRunner: [ :arguments |
			pushedArguments := arguments.
			0 ].
	publisher := MooseNexusOciArtifactPublisher referenceMapper: mapper transport: transport.

	bundle := publisher publishManifest: manifest of: project.

	self assert: (bundle configFile parent basename beginsWith: 'moosenexus-oci-bundle-').
	self assert: bundle configFile exists.
	self assert: pushedArguments equals: (transport pushArgumentsFor: bundle)
]

{ #category : 'tests' }
MooseNexusOciArtifactPublishingTest >> testReferenceMapperNormalizesHarborReference [

	| mapper |
	mapper := MooseNexusOciReferenceMapper registry: 'harbor.example.com' harborProject: 'Moose Team'.

	self
		assert: (mapper referenceFor: self artifactCoordinates)
		equals: 'harbor.example.com/moose-team/moosenexus/com.example/demo:1.0.0'
]
