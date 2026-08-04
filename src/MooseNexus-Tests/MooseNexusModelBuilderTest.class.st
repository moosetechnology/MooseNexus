"
I test model artifact registration behavior without running an external extractor.
"
Class {
	#name : 'MooseNexusModelBuilderTest',
	#superclass : 'TestCase',
	#instVars : [
		'rootDirectory',
		'project'
	],
	#category : 'MooseNexus-Tests',
	#package : 'MooseNexus-Tests'
}

{ #category : 'running' }
MooseNexusModelBuilderTest >> setUp [

	super setUp.
	rootDirectory := FileLocator temp / ('MooseNexus-' , UUID new asString).
	(rootDirectory / 'sources') ensureCreateDirectory.
	(rootDirectory / 'models') ensureCreateDirectory.
	rootDirectory / 'models.json' writeStreamDo: [ :stream | stream nextPutAll: '[]' ].
	project := MooseNexusTestProject coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0').
	project directory: (rootDirectory relativeTo: FileLocator home) pathString
]

{ #category : 'running' }
MooseNexusModelBuilderTest >> tearDown [

	rootDirectory ifNotNil: [ rootDirectory ifExists: [ rootDirectory deleteAll ] ].
	super tearDown
]

{ #category : 'tests' }
MooseNexusModelBuilderTest >> testBuildSpecConfiguresModelBuilder [

	| spec builder extractor |
	extractor := Object new.
	spec := MooseNexusBuildSpec projectSpec: (MooseNexusProjectSpec coordinates: project coordinates sourceDirectory: rootDirectory).
	spec
		withDependencies: false;
		modelName: 'configured-model';
		modelComment: 'configured comment';
		extractor: extractor.
	builder := MooseNexusModelBuilder on: project.

	spec configureModelBuilder: builder.

	self assert: builder project equals: project.
	self deny: builder withDependencies.
	self assert: builder modelName equals: 'configured-model'.
	self assert: builder modelComment equals: 'configured comment'.
	self assert: builder extractor identicalTo: extractor
]

{ #category : 'tests' }
MooseNexusModelBuilderTest >> testBuildSpecExecutesPlanAndAnswersModelBuildResult [

	| sourceProjectDirectory spec plan result modelFile |
	sourceProjectDirectory := (rootDirectory / 'source-project') ensureCreateDirectory.
	(sourceProjectDirectory / '.moosenexus-test') ensureCreateFile.
	spec := MooseNexusBuildSpec coordinates: project coordinates sourceDirectory: sourceProjectDirectory.
	spec
		withDependencies: false;
		modelName: 'planned-model';
		extractor: MooseNexusTestModelExtractor new.

	plan := spec planIn: (MooseNexusRepository new directory: rootDirectory / 'nexus').
	result := plan execute.

	modelFile := rootDirectory / 'nexus' / 'repository' / 'com.example' / 'demo' / '1.0.0' / 'models' / 'planned-model.json'.
	self assert: plan projectImporter class equals: MooseNexusTestProjectImporter.
	self assert: result project isRecorded.
	self assert: result dependencyResolutionResult project identicalTo: result project.
	self assert: result dependencyResolutionResult warnings isEmpty.
	self assert: result dependencyResolutionResult decisions isEmpty.
	self assert: result modelArtifact coordinates equals: result project coordinates.
	self assert: result modelArtifact path equals: 'models/planned-model.json'.
	self assert: result modelName equals: 'planned-model'.
	self assert: result modelFormat equals: 'json'.
	self assert: modelFile exists.
	self assert: modelFile contents equals: '{ }'
]

{ #category : 'tests' }
MooseNexusModelBuilderTest >> testBuildSpecKeepsModelBuilderDefaultsWhenOptionsAreAbsent [

	| spec builder |
	spec := MooseNexusBuildSpec projectSpec: (MooseNexusProjectSpec coordinates: project coordinates sourceDirectory: rootDirectory).
	builder := MooseNexusModelBuilder on: project.

	spec configureModelBuilder: builder.

	self assert: builder project equals: project.
	self deny: builder withDependencies.
	self assert: builder modelName equals: project name.
	self assert: builder modelComment equals: ''
]

{ #category : 'tests' }
MooseNexusModelBuilderTest >> testModelArtifactDictionaryRoundTrip [

	| artifact sameArtifact |
	artifact := MooseNexusModelArtifact
		            coordinates: project coordinates
		            name: 'demo-model'
		            path: 'models/demo-model.json'
		            format: 'json'
		            comment: 'generated for tests'
		            timestamp: '2026-08-04T10:00:00+02:00'
		            famixVersion: 'unknown'.

	sameArtifact := MooseNexusModelArtifact fromDictionary: artifact asDictionary.

	self assert: sameArtifact equals: artifact.
	self assert: sameArtifact hash equals: artifact hash
]

{ #category : 'tests' }
MooseNexusModelBuilderTest >> testRegisterModelCopiesOutputIntoModelsDirectory [

	| builder source target models modelArtifact serializedModels serializedArtifact |
	source := rootDirectory / 'sources' / 'mooseNexusModel.json'.
	source writeStreamDo: [ :stream | stream nextPutAll: '{ }' ].
	builder := MooseNexusModelBuilder on: project.
	builder modelName: 'demo-model'.

	modelArtifact := builder registerModel: 'sources/mooseNexusModel.json'.

	target := rootDirectory / 'models' / 'demo-model.json'.
	self deny: source exists.
	self assert: target exists.
	self assert: target contents equals: '{ }'.
	self assert: modelArtifact coordinates equals: project coordinates.
	self assert: modelArtifact name equals: 'demo-model'.
	self assert: modelArtifact path equals: 'models/demo-model.json'.
	self assert: modelArtifact format equals: 'json'.
	self assert: modelArtifact famixVersion equals: 'unknown'.
	models := project models.
	self assert: models size equals: 1.
	self assert: models first equals: modelArtifact.
	serializedModels := rootDirectory / 'models.json' readStreamDo: [ :stream | STON fromStream: stream ].
	self assert: serializedModels size equals: 1.
	serializedArtifact := serializedModels first.
	self assert: (serializedArtifact at: 'name') equals: 'demo-model'.
	self assert: (serializedArtifact at: 'path') equals: 'models/demo-model.json'.
	self assert: ((serializedArtifact at: 'projectCoordinates') at: 'group') equals: 'com.example'
]
