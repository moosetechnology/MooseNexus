"
I test importing and rebasing a recorded Famix TypeScript model.
"
Class {
	#name : 'MooseNexusTypeScriptModelImporterTest',
	#superclass : 'TestCase',
	#instVars : [
		'rootDirectory',
		'project'
	],
	#category : 'MooseNexus-TypeScript-Tests-ModelExtraction',
	#package : 'MooseNexus-TypeScript-Tests',
	#tag : 'ModelExtraction'
}

{ #category : 'private' }
MooseNexusTypeScriptModelImporterTest >> buildProvenance [

	^ MooseNexusBuildProvenance mooseNexusVersion: '0.5.0' mooseVersion: '12.0.0' pharoVersion: '12'
]

{ #category : 'running' }
MooseNexusTypeScriptModelImporterTest >> setUp [

	| repositoryBackend projectDirectory |
	super setUp.
	rootDirectory := FileLocator temp / ('MooseNexus-typescript-model-' , UUID new asString).
	projectDirectory := rootDirectory / 'repository' / 'com.example' / 'demo' / '1.0.0'.
	(projectDirectory / 'sources') ensureCreateDirectory.
	(projectDirectory / 'artifacts' / 'models') ensureCreateDirectory.
	(projectDirectory / 'artifacts' / 'images') ensureCreateDirectory.
	(projectDirectory / 'metadata') ensureCreateDirectory.
	projectDirectory / 'metadata' / 'models.json' writeStreamDo: [ :stream | stream nextPutAll: '[]' ].
	projectDirectory / 'metadata' / 'images.json' writeStreamDo: [ :stream | stream nextPutAll: '[]' ].
	repositoryBackend := MooseNexusLocalRepositoryBackend directory: rootDirectory.
	project := MooseNexusTestProject coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0').
	project repositoryBackend: repositoryBackend path: 'com.example/demo/1.0.0'
]

{ #category : 'running' }
MooseNexusTypeScriptModelImporterTest >> tearDown [

	rootDirectory ifNotNil: [ rootDirectory ifExists: [ rootDirectory deleteAll ] ].
	super tearDown
]

{ #category : 'tests' }
MooseNexusTypeScriptModelImporterTest >> testImportTypeScriptModelStoresMainSourceDirectoryAsRootFolder [

	| modelFile artifact artifactCoordinates importedModel manifest |
	project mainSourceDirectory ensureCreateDirectory.
	modelFile := project repositoryDirectory / 'artifacts' / 'models' / 'typescript-model.json'.
	modelFile writeStreamDo: [ :stream | FamixTypeScriptModel new exportToJSONStream: stream ].
	artifactCoordinates := MooseNexusModelArtifactCoordinates
		                       projectCoordinates: project coordinates
		                       name: 'typescript-model'
		                       format: 'json'
		                       metamodel: 'Famix-TypeScript'
		                       classifier: 'main'.
	artifact := MooseNexusModelArtifact
		            artifactCoordinates: artifactCoordinates
		            path: 'artifacts/models/typescript-model.json'
		            comment: ''
		            timestamp: '2026-09-10T00:00:00+02:00'.
	manifest := MooseNexusModelArtifactManifest
		            modelArtifact: artifact
		            dependencyResolutionResult: (MooseNexusDependencyResolutionResult forProject: project)
		            generatedFiles: #(  )
		            createdTimestamp: artifact timestamp
		            buildProvenance: self buildProvenance.
	project addModelManifest: manifest.
	importedModel := project importModel: artifact.

	[
		self assert: importedModel class equals: FamixTypeScriptModel.
		self assert: importedModel name equals: artifact name.
		self assert: importedModel rootFolder pathString equals: project mainSourceDirectory pathString.
		importedModel rootFolder: rootDirectory.
		project rebaseLoadedModelNamed: importedModel name.
		self assert: importedModel rootFolder pathString equals: project mainSourceDirectory pathString ] ensure: [
		importedModel remove ]
]
