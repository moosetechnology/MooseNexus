"
I exercise TypeScript import through the npm lockfile importer, Docker ts2famix runner, artifact recording, and FamixTypeScript model import.

I require Docker and the pinned MooseNexus ts2famix image; CI builds that image locally before this test runs.
"
Class {
	#name : 'MooseNexusTypeScriptIntegrationTest',
	#superclass : 'TestCase',
	#instVars : [
		'rootDirectory',
		'repository'
	],
	#category : 'MooseNexus-TypeScript-IntegrationTests-ModelExtraction',
	#package : 'MooseNexus-TypeScript-IntegrationTests',
	#tag : 'ModelExtraction'
}

{ #category : 'accessing' }
MooseNexusTypeScriptIntegrationTest >> fixtureDirectory [

	^ (IceRepository registry detect: [ :each | each includesPackageNamed: 'MooseNexus' ]) location / 'test-resources' / 'typescript'
]

{ #category : 'running' }
MooseNexusTypeScriptIntegrationTest >> setUp [

	super setUp.
	rootDirectory := FileLocator temp / ('MooseNexus-typescript-import-' , UUID new asString).
	repository := MooseNexusRepository new directory: rootDirectory
]

{ #category : 'running' }
MooseNexusTypeScriptIntegrationTest >> tearDown [

	rootDirectory ifNotNil: [ rootDirectory ifExists: [ rootDirectory deleteAll ] ].
	super tearDown
]

{ #category : 'tests' }
MooseNexusTypeScriptIntegrationTest >> testImportsTypeScriptProjectWithLockedNpmReferences [

	| spec plan result project artifact model dependency |
	spec := MooseNexusBuildSpec
		        coordinates: (MooseNexusCoordinates group: 'com.example' name: 'typescript-fixture' version: '1.0.0')
		        sourceDirectory: self fixtureDirectory.
	plan := spec planIn: repository.
	result := plan execute.
	project := result project.
	artifact := result modelArtifact.
	dependency := project dependencies first.

	self assert: plan projectImporter class equals: MooseNexusNpmProjectImporter.
	self assert: project class equals: MooseNexusNpmProject.
	self assert: project language equals: 'typescript'.
	self assert: project packageLockVersion equals: 3.
	self assert: project dependencies size equals: 1.
	self assert: dependency class equals: MooseNexusNpmDependencyDescriptor.
	self assert: dependency name equals: 'is-number'.
	self deny: dependency supportsClasspathMaterialization.
	self assert: artifact metamodel equals: 'Famix-TypeScript'.
	self assert: (project repositoryDirectory / artifact path) exists.
	self deny: (project repositoryDirectory / 'temporary' / 'typescript-extraction') exists.

	model := project importModel: artifact.
	[
		self assert: model class equals: FamixTypeScriptModel.
		self assert: model name equals: artifact name.
		self assert: model rootFolder pathString equals: project mainSourceDirectory pathString ] ensure: [ model remove ]
]
