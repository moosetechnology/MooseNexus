"
I exercise recording an explicitly configured unmanaged source project from a checked-in fixture.

I use a disposable MooseNexus repository, so the test covers the build plan, importer, local dependency reference, and recorded source layout together.
"
Class {
	#name : 'MooseNexusUnmanagedProjectIntegrationTest',
	#superclass : 'TestCase',
	#instVars : [
		'rootDirectory',
		'localArtifactDirectory'
	],
	#category : 'MooseNexus-IntegrationTests-Tests',
	#package : 'MooseNexus-IntegrationTests',
	#tag : 'Tests'
}

{ #category : 'private' }
MooseNexusUnmanagedProjectIntegrationTest >> fixtureSourceDirectory [

	^ (IceRepository registry detect: [ :each | each includesPackageNamed: 'MooseNexus' ]) location / 'test-resources' / 'unmanaged'
]

{ #category : 'private' }
MooseNexusUnmanagedProjectIntegrationTest >> localDependency [

	^ MooseNexusLocalDependencyDescriptor
		  coordinates: (MooseNexusCoordinates group: 'org.moosenexus.fixture' name: 'local-dependency' version: '1.0.0')
		  type: 'jar'
		  scopes: #( 'compile' )
		  path: (localArtifactDirectory / 'local-dependency-1.0.0.jar') pathString
]

{ #category : 'private' }
MooseNexusUnmanagedProjectIntegrationTest >> localDependencyDirectory [

	^ MooseNexusLocalDependencyDirectory path: localArtifactDirectory pathString
]

{ #category : 'running' }
MooseNexusUnmanagedProjectIntegrationTest >> setUp [

	super setUp.
	rootDirectory := FileLocator temp / ('MooseNexus-unmanaged-project-import-' , UUID new asString).
	rootDirectory ensureCreateDirectory.
	localArtifactDirectory := FileLocator home / ('moosenexus-integration-local-artifact-' , UUID new asString).
	localArtifactDirectory ensureCreateDirectory.
	localArtifactDirectory / 'local-dependency-1.0.0.jar' writeStreamDo: [ :stream | stream nextPutAll: 'local artifact fixture' ].
	(localArtifactDirectory / 'nested') ensureCreateDirectory.
	localArtifactDirectory / 'nested' / 'local-dependency-1.0.0.jar' writeStreamDo: [ :stream |
		stream nextPutAll: 'local directory fixture' ]
]

{ #category : 'running' }
MooseNexusUnmanagedProjectIntegrationTest >> tearDown [

	rootDirectory ifNotNil: [ rootDirectory ifExists: [ rootDirectory deleteAll ] ].
	localArtifactDirectory ifNotNil: [ localArtifactDirectory ifExists: [ localArtifactDirectory deleteAll ] ].
	super tearDown
]

{ #category : 'tests' }
MooseNexusUnmanagedProjectIntegrationTest >> testBuildPlanMaterializesLocalDependencyByDefault [

	| coordinates importer spec plan result materialization |
	coordinates := MooseNexusCoordinates group: 'org.moosenexus.fixture' name: 'unmanaged-project' version: '1.0.0'.
	importer := MooseNexusUnmanagedProjectImporter new
		            language: 'java';
		            dependencies: { self localDependency }.
	spec := MooseNexusBuildSpec coordinates: coordinates sourceDirectory: self fixtureSourceDirectory.
	spec
		projectImporter: importer;
		modelName: 'unmanaged-fixture';
		extractor: MooseNexusTestModelExtractor new.
	plan := spec planIn: (MooseNexusRepository new directory: rootDirectory / 'nexus').

	result := plan execute.
	self assert: result dependencyResolutionResult materializations size equals: 1.
	materialization := result dependencyResolutionResult materializations first.

	self assert: materialization dependency equals: self localDependency.
	self assert: materialization source equals: 'local'.
	self assert: materialization path equals: 'dependencies/' , self localDependency materializationFileName.
	self assert: result project modelManifests first dependencyResolutionResult equals: result dependencyResolutionResult.
	self deny: (result project repositoryDirectory / 'dependencies') exists
]

{ #category : 'tests' }
MooseNexusUnmanagedProjectIntegrationTest >> testBuildPlanMaterializesLocalDependencyDirectoryByDefault [

	| coordinates importer spec plan result materialization |
	coordinates := MooseNexusCoordinates group: 'org.moosenexus.fixture' name: 'unmanaged-project' version: '1.0.0'.
	importer := MooseNexusUnmanagedProjectImporter new
		            language: 'java';
		            dependencyDirectory: self localDependencyDirectory path.
	spec := MooseNexusBuildSpec coordinates: coordinates sourceDirectory: self fixtureSourceDirectory.
	spec
		projectImporter: importer;
		modelName: 'unmanaged-fixture';
		extractor: MooseNexusTestModelExtractor new.
	plan := spec planIn: (MooseNexusRepository new directory: rootDirectory / 'nexus').

	result := plan execute.
	self assert: result project dependencies equals: { self localDependencyDirectory }.
	self assert: result dependencyResolutionResult materializations size equals: 1.
	materialization := result dependencyResolutionResult materializations first.

	self assert: materialization dependency equals: self localDependencyDirectory.
	self assert: materialization source equals: 'local-directory'.
	self assert: materialization path equals: 'dependencies/' , self localDependencyDirectory materializationDirectoryName.
	self deny: (result project repositoryDirectory / 'dependencies') exists
]

{ #category : 'tests' }
MooseNexusUnmanagedProjectIntegrationTest >> testBuildPlanRecordsConfiguredUnmanagedProjectAndKeepsLocalReference [

	| coordinates importer spec plan result project recordedSource |
	coordinates := MooseNexusCoordinates group: 'org.moosenexus.fixture' name: 'unmanaged-project' version: '1.0.0'.
	importer := MooseNexusUnmanagedProjectImporter new
		            language: 'java';
		            dependencies: { self localDependency }.
	spec := MooseNexusBuildSpec coordinates: coordinates sourceDirectory: self fixtureSourceDirectory.
	spec
		projectImporter: importer;
		withDependencyClasspath: false;
		modelName: 'unmanaged-fixture';
		extractor: MooseNexusTestModelExtractor new.
	plan := spec planIn: (MooseNexusRepository new directory: rootDirectory / 'nexus').

	result := plan execute.
	project := result project.
	recordedSource := project sourceDirectory / 'main' / 'src' / 'main' / 'java' / 'org' / 'moosenexus' / 'fixture' / 'Example.java'.

	self assert: project class equals: MooseNexusUnmanagedProject.
	self assert: project coordinates equals: coordinates.
	self assert: project language equals: 'java'.
	self assert: project dependencies equals: { self localDependency }.
	self assert: project dependencies first isLocal.
	self assert: result dependencyResolutionResult materializations isEmpty.
	self assert: recordedSource exists.
	self assert: result modelArtifact path equals: 'artifacts/models/unmanaged-fixture.json'
]

{ #category : 'tests' }
MooseNexusUnmanagedProjectIntegrationTest >> testLocalDependencyDirectoryMaterializationPreservesItsTree [

	| coordinates importer spec plan result dependencies materialization target |
	coordinates := MooseNexusCoordinates group: 'org.moosenexus.fixture' name: 'unmanaged-project' version: '1.0.0'.
	importer := MooseNexusUnmanagedProjectImporter new
		            language: 'java';
		            dependencyDirectory: self localDependencyDirectory path.
	spec := MooseNexusBuildSpec coordinates: coordinates sourceDirectory: self fixtureSourceDirectory.
	spec
		projectImporter: importer;
		withDependencyClasspath: false;
		modelName: 'unmanaged-fixture';
		extractor: MooseNexusTestModelExtractor new.
	plan := spec planIn: (MooseNexusRepository new directory: rootDirectory / 'nexus').
	result := plan execute.
	dependencies := (result project repositoryDirectory / 'dependencies') ensureCreateDirectory.
	materialization := result project materializeDependency: self localDependencyDirectory into: dependencies.
	target := result project repositoryDirectory / materialization path.

	self assert: (target / 'nested' / 'local-dependency-1.0.0.jar') exists.
	self assert: (target / 'nested' / 'local-dependency-1.0.0.jar') contents equals: 'local directory fixture'
]
