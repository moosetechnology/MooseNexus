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
MooseNexusOciArtifactPublishingTest >> copyBundle: bundleDirectory intoPullDirectoryFromArguments: arguments [

	| outputDirectory configFile |
	outputDirectory := (arguments at: (arguments indexOf: '--output') + 1) asFileReference.
	configFile := (arguments at: (arguments indexOf: '--config') + 1) asFileReference.
	outputDirectory ensureCreateDirectory.
	bundleDirectory / MooseNexusOciArtifactBundleBuilder manifestFileName copyTo: configFile.
	bundleDirectory / MooseNexusOciArtifactBundleBuilder projectPropertiesFileName copyTo:
		outputDirectory / MooseNexusOciArtifactBundleBuilder projectPropertiesFileName.
	bundleDirectory / 'model.json' copyTo: outputDirectory / 'model.json'.
	bundleDirectory / MooseNexusOciArtifactBundleBuilder sourceArchiveFileName copyTo:
		outputDirectory / MooseNexusOciArtifactBundleBuilder sourceArchiveFileName
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

{ #category : 'private' }
MooseNexusOciArtifactPublishingTest >> repositoryDirectoryForTestRepository: aMooseNexusRepository [

	^ aMooseNexusRepository directory / 'repository' / 'com.example' / 'demo' / '1.0.0'
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
MooseNexusOciArtifactPublishingTest >> testBundleBuilderCopiesModelPropertiesAndArchivesSources [

	| bundle bundleDirectory propertiesLayer modelLayer sourceLayer manifestDictionary propertiesDictionary |
	bundleDirectory := rootDirectory / 'bundle'.

	bundle := (MooseNexusOciArtifactBundleBuilder project: project manifest: manifest directory: bundleDirectory) build.

	propertiesLayer := bundle layers first.
	modelLayer := bundle layers second.
	sourceLayer := bundle layers third.
	self assert: bundle artifactType equals: MooseNexusOciArtifactBundleBuilder artifactType.
	self assert: bundle configMediaType equals: MooseNexusOciArtifactBundleBuilder configMediaType.
	self
		assert: bundle configArgument
		equals: MooseNexusOciArtifactBundleBuilder manifestFileName , ':' , MooseNexusOciArtifactBundleBuilder configMediaType.
	self assert: propertiesLayer mediaType equals: MooseNexusOciArtifactBundleBuilder projectPropertiesMediaType.
	self
		assert: propertiesLayer asOrasArgument
		equals:
		MooseNexusOciArtifactBundleBuilder projectPropertiesFileName , ':'
		, MooseNexusOciArtifactBundleBuilder projectPropertiesMediaType.
	propertiesDictionary := propertiesLayer file readStreamDo: [ :stream | STON fromStream: stream ].
	self assert: (propertiesDictionary at: #nature) equals: 'MooseNexusTestProject'.
	self assert: modelLayer mediaType equals: 'application/vnd.moose.famix+json'.
	self assert: modelLayer asOrasArgument equals: 'model.json:application/vnd.moose.famix+json'.
	self assert: modelLayer file contents equals: '{ }'.
	self assert: sourceLayer mediaType equals: MooseNexusOciArtifactBundleBuilder sourceArchiveMediaType.
	self
		assert: sourceLayer asOrasArgument
		equals:
		MooseNexusOciArtifactBundleBuilder sourceArchiveFileName , ':' , MooseNexusOciArtifactBundleBuilder sourceArchiveMediaType.
	self assert: (ZipArchive isZipArchive: sourceLayer file).
	manifestDictionary := bundle configFile readStreamDo: [ :stream | STON fromStream: stream ].
	self assert: ((manifestDictionary at: 'modelArtifact') at: 'path') equals: 'artifacts/models/demo-model.json'
]

{ #category : 'tests' }
MooseNexusOciArtifactPublishingTest >> testInstallerRestoresPulledBundleIntoLocalRepository [

	| bundleDirectory repository installedProject projectDirectory |
	bundleDirectory := rootDirectory / 'bundle'.
	(MooseNexusOciArtifactBundleBuilder project: project manifest: manifest directory: bundleDirectory) build.
	repository := MooseNexusRepository new directory: rootDirectory / 'installed'.

	installedProject := MooseNexusOciArtifactInstaller new installBundleFrom: bundleDirectory in: repository.

	projectDirectory := self repositoryDirectoryForTestRepository: repository.
	self assert: installedProject class equals: MooseNexusTestProject.
	self assert: installedProject coordinates equals: project coordinates.
	self assert: installedProject dependencies equals: project dependencies.
	self assert: (projectDirectory / 'sources' / 'project' / 'src' / 'Demo.java') contents equals: 'class Demo { }'.
	self assert: (projectDirectory / 'artifacts' / 'models' / 'demo-model.json') contents equals: '{ }'.
	self assert: installedProject modelManifests first equals: manifest
]

{ #category : 'tests' }
MooseNexusOciArtifactPublishingTest >> testOrasTransportAcceptsPullReferenceWithDigest [

	| transport outputDirectory pulledDirectory |
	transport := MooseNexusOrasTransport new.
	transport commandRunner: [ :arguments | 0 ].
	outputDirectory := rootDirectory / 'pulled'.

	pulledDirectory := transport pull: 'harbor.example.com/team/moosenexus/com.example/demo@sha256:abcdef' into: outputDirectory.

	self assert: pulledDirectory pathString equals: outputDirectory pathString
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
				'--config'.
				(outputDirectory / MooseNexusOciArtifactBundleBuilder manifestFileName) pathString.
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
	self assert: (arguments copyFrom: 2 to: 6) equals: {
			'push'.
			'--artifact-type'.
			MooseNexusOciArtifactBundleBuilder artifactType.
			'--config'.
			bundle configArgument }.
	self deny: (arguments includes: '--disable-path-validation').
	self assert: (arguments includes: 'harbor.example.com/team/moosenexus/com.example/demo:1.0.0').
	self assert: (arguments includes: bundle layers first asOrasArgument).
	self assert: (arguments includes: bundle layers second asOrasArgument)
]

{ #category : 'tests' }
MooseNexusOciArtifactPublishingTest >> testOrasTransportPullReturnsExplicitOutputDirectory [

	| transport outputDirectory pulledDirectory |
	transport := MooseNexusOrasTransport new.
	transport commandRunner: [ :arguments | 0 ].
	outputDirectory := rootDirectory / 'pulled'.

	pulledDirectory := transport pull: 'harbor.example.com/team/moosenexus/com.example/demo:1.0.0' into: outputDirectory.

	self assert: pulledDirectory pathString equals: outputDirectory pathString
]

{ #category : 'tests' }
MooseNexusOciArtifactPublishingTest >> testOrasTransportPullUsesUniqueTemporaryDirectory [

	| transport pulledDirectory pushedArguments |
	pushedArguments := #(  ).
	transport := MooseNexusOrasTransport new.
	transport commandRunner: [ :arguments |
			pushedArguments := arguments.
			0 ].

	pulledDirectory := transport pull: 'harbor.example.com/team/moosenexus/com.example/demo:1.0.0'.

	self assert: (pulledDirectory basename beginsWith: 'moosenexus-oci-pull-').
	self assert: (pushedArguments includes: pulledDirectory pathString)
]

{ #category : 'tests' }
MooseNexusOciArtifactPublishingTest >> testOrasTransportPushRunsFromBundleDirectory [

	| bundle transport workingDirectory |
	bundle := (MooseNexusOciArtifactBundleBuilder project: project manifest: manifest directory: rootDirectory / 'bundle') build.
	bundle reference: 'harbor.example.com/team/moosenexus/com.example/demo:1.0.0'.
	transport := MooseNexusOrasTransport new.
	transport commandRunner: [ :arguments :directory |
			workingDirectory := directory.
			0 ].

	transport pushBundle: bundle.

	self assert: workingDirectory pathString equals: bundle configFile parent pathString
]

{ #category : 'tests' }
MooseNexusOciArtifactPublishingTest >> testOrasTransportRejectsPullReferenceWithoutTagOrDigest [

	| transport |
	transport := MooseNexusOrasTransport new.
	transport commandRunner: [ :arguments | self fail: 'Invalid references should fail before running ORAS' ].

	self
		should: [ transport pull: 'harbor.example.com/team/moosenexus/com.example/demo' ]
		raise: Error
		whoseDescriptionIncludes: 'OCI reference must include a tag or digest'
		description: 'Pull references must include the version tag or a digest'
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
MooseNexusOciArtifactPublishingTest >> testPullerForceInstallsPulledBundle [

	| bundleDirectory repository mapper transport puller pulledProject projectDirectory |
	bundleDirectory := rootDirectory / 'bundle'.
	(MooseNexusOciArtifactBundleBuilder project: project manifest: manifest directory: bundleDirectory) build.
	repository := MooseNexusRepository new directory: rootDirectory / 'installed'.
	mapper := MooseNexusOciReferenceMapper registry: 'harbor.example.com' harborProject: 'team'.
	transport := MooseNexusOrasTransport new.
	transport commandRunner: [ :arguments |
			self copyBundle: bundleDirectory intoPullDirectoryFromArguments: arguments.
			0 ].
	puller := MooseNexusOciArtifactPuller referenceMapper: mapper transport: transport repository: repository.

	pulledProject := puller pull: 'harbor.example.com/team/moosenexus/com.example/demo:1.0.0' force: true.

	projectDirectory := self repositoryDirectoryForTestRepository: repository.
	self assert: pulledProject coordinates equals: project coordinates.
	self assert: (projectDirectory / 'sources' / 'project' / 'src' / 'Demo.java') contents equals: 'class Demo { }'.
	self assert: (projectDirectory / 'artifacts' / 'models' / 'demo-model.json') contents equals: '{ }'
]

{ #category : 'tests' }
MooseNexusOciArtifactPublishingTest >> testPullerReturnsLocalProjectWhenAlreadyInstalled [

	| bundleDirectory repository mapper transport puller installedProject pulledProject |
	bundleDirectory := rootDirectory / 'bundle'.
	(MooseNexusOciArtifactBundleBuilder project: project manifest: manifest directory: bundleDirectory) build.
	repository := MooseNexusRepository new directory: rootDirectory / 'installed'.
	installedProject := MooseNexusOciArtifactInstaller new installBundleFrom: bundleDirectory in: repository.
	mapper := MooseNexusOciReferenceMapper registry: 'harbor.example.com' harborProject: 'team'.
	transport := MooseNexusOrasTransport new.
	transport commandRunner: [ :arguments | self fail: 'Pull should not contact ORAS when the project already exists locally' ].
	puller := MooseNexusOciArtifactPuller referenceMapper: mapper transport: transport repository: repository.

	pulledProject := puller pull: 'harbor.example.com/team/moosenexus/com.example/demo:1.0.0'.

	self assert: pulledProject coordinates equals: installedProject coordinates.
	self assert: pulledProject modelManifests first equals: manifest
]

{ #category : 'tests' }
MooseNexusOciArtifactPublishingTest >> testReferenceMapperNormalizesHarborReference [

	| mapper |
	mapper := MooseNexusOciReferenceMapper registry: 'harbor.example.com' harborProject: 'Moose Team'.

	self
		assert: (mapper referenceFor: self artifactCoordinates)
		equals: 'harbor.example.com/moose-team/moosenexus/com.example/demo:1.0.0'
]
