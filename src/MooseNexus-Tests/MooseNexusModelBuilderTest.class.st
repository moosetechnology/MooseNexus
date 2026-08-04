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
MooseNexusModelBuilderTest >> testModelArtifactCoordinatesAreValueObjects [

	| coordinates sameCoordinates otherCoordinates |
	coordinates := MooseNexusModelArtifactCoordinates
		               projectCoordinates: project coordinates
		               name: 'demo-model'
		               format: 'json'
		               metamodel: 'Famix-Java'
		               classifier: 'main'.
	sameCoordinates := MooseNexusModelArtifactCoordinates fromDictionary: coordinates asDictionary.
	otherCoordinates := MooseNexusModelArtifactCoordinates
		                    projectCoordinates: project coordinates
		                    name: 'demo-model'
		                    format: 'json'
		                    metamodel: 'Famix-Java'
		                    classifier: 'summary'.

	self assert: sameCoordinates equals: coordinates.
	self assert: sameCoordinates hash equals: coordinates hash.
	self deny: otherCoordinates equals: coordinates.
	self assert: coordinates group equals: 'com.example'.
	self assert: coordinates version equals: '1.0.0'
]

{ #category : 'tests' }
MooseNexusModelBuilderTest >> testModelArtifactDictionaryRoundTrip [

	| artifact sameArtifact artifactCoordinates |
	artifactCoordinates := MooseNexusModelArtifactCoordinates
		                       projectCoordinates: project coordinates
		                       name: 'demo-model'
		                       format: 'json'
		                       metamodel: 'unknown'
		                       classifier: 'main'.
	artifact := MooseNexusModelArtifact
		            artifactCoordinates: artifactCoordinates
		            path: 'models/demo-model.json'
		            comment: 'generated for tests'
		            timestamp: '2026-08-04T10:00:00+02:00'.

	sameArtifact := MooseNexusModelArtifact fromDictionary: artifact asDictionary.

	self assert: sameArtifact equals: artifact.
	self assert: sameArtifact hash equals: artifact hash.
	self assert: sameArtifact coordinates equals: project coordinates.
	self assert: sameArtifact name equals: 'demo-model'.
	self assert: sameArtifact format equals: 'json'.
	self assert: sameArtifact artifactCoordinates metamodel equals: 'unknown'
]

{ #category : 'tests' }
MooseNexusModelBuilderTest >> testModelArtifactManifestDictionaryRoundTrip [

	| dependency conflict decision resolutionResult artifact manifest sameManifest generatedFile artifactCoordinates |
	dependency := MooseNexusDependencyDescriptor
		              coordinates: (MooseNexusCoordinates group: 'org.example' name: 'dep' version: '1.0.0')
		              type: 'jar'
		              scopes: #( 'compile' )
		              path: 'repository/dep-1.0.0.jar'.
	conflict := MooseNexusDependencyConflict conflictId: 'org.example:dep' candidates: { dependency }.
	decision := MooseNexusDependencyConflictDecision conflict: conflict selectedDependency: dependency.
	resolutionResult := MooseNexusDependencyResolutionResult
		                    project: project
		                    dependencies: { dependency }
		                    warnings: #( 'warning' )
		                    decisions: { decision }.
	artifactCoordinates := MooseNexusModelArtifactCoordinates
		                       projectCoordinates: project coordinates
		                       name: 'demo-model'
		                       format: 'json'
		                       metamodel: 'unknown'
		                       classifier: 'main'.
	artifact := MooseNexusModelArtifact
		            artifactCoordinates: artifactCoordinates
		            path: 'models/demo-model.json'
		            comment: 'generated for tests'
		            timestamp: '2026-08-04T10:00:00+02:00'.
	generatedFile := Dictionary new
		                 add: 'path' -> 'models/demo-model.json';
		                 add: 'size' -> 3;
		                 add: 'checksumAlgorithm' -> 'sha256';
		                 add: 'checksum' -> '257c1be96ae69f4b01c2c69bdb6d78605f59175819fb007d0bf245bf48444c4a';
		                 yourself.
	manifest := MooseNexusModelArtifactManifest
		            modelArtifact: artifact
		            dependencyResolutionResult: resolutionResult
		            generatedFiles: { generatedFile }
		            createdTimestamp: artifact timestamp.

	sameManifest := MooseNexusModelArtifactManifest fromDictionary: manifest asDictionary.

	self assert: sameManifest equals: manifest.
	self assert: sameManifest hash equals: manifest hash
]

{ #category : 'tests' }
MooseNexusModelBuilderTest >> testRegisterModelCopiesOutputIntoModelsDirectory [

	| builder source target models modelArtifact serializedModels serializedManifest serializedArtifact artifactCoordinates generatedFile |
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
	self assert: modelArtifact artifactCoordinates metamodel equals: 'unknown'.
	self assert: modelArtifact artifactCoordinates classifier equals: 'main'.
	models := project models.
	self assert: models size equals: 1.
	self assert: models first equals: modelArtifact.
	serializedModels := rootDirectory / 'models.json' readStreamDo: [ :stream | STON fromStream: stream ].
	self assert: serializedModels size equals: 1.
	serializedManifest := serializedModels first.
	serializedArtifact := serializedManifest at: 'modelArtifact'.
	artifactCoordinates := serializedArtifact at: 'artifactCoordinates'.
	self assert: (artifactCoordinates at: 'name') equals: 'demo-model'.
	self assert: (artifactCoordinates at: 'format') equals: 'json'.
	self assert: (artifactCoordinates at: 'metamodel') equals: 'unknown'.
	self assert: (artifactCoordinates at: 'classifier') equals: 'main'.
	self assert: ((artifactCoordinates at: 'projectCoordinates') at: 'group') equals: 'com.example'.
	self assert: (serializedArtifact at: 'path') equals: 'models/demo-model.json'.
	self assert: (serializedManifest includesKey: 'dependencyResolution').
	generatedFile := (serializedManifest at: 'generatedFiles') first.
	self assert: (generatedFile at: 'path') equals: 'models/demo-model.json'.
	self assert: (generatedFile at: 'size') equals: 3.
	self assert: (generatedFile at: 'checksumAlgorithm') equals: 'sha256'.
	self assert: (generatedFile at: 'checksum') equals: '257c1be96ae69f4b01c2c69bdb6d78605f59175819fb007d0bf245bf48444c4a'
]
