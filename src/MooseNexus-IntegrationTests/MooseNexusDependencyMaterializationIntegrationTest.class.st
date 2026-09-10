"
I exercise Maven and Gradle dependency materialization with checked-in, offline build fixtures.

I locate the fixture through Iceberg because the checkout location backing the running image is not fixed. Each test copies it to a disposable repository directory before invoking the real build tool.
"
Class {
	#name : 'MooseNexusDependencyMaterializationIntegrationTest',
	#superclass : 'TestCase',
	#instVars : [
		'rootDirectory'
	],
	#category : 'MooseNexus-IntegrationTests',
	#package : 'MooseNexus-IntegrationTests'
}

{ #category : 'private' }
MooseNexusDependencyMaterializationIntegrationTest >> assertCollidingMaterializationsIn: project from: source [

	| dependencies firstResult secondResult |
	dependencies := (project repositoryDirectory / 'dependencies') ensureCreateDirectory.
	firstResult := project materializeDependency: self dependency into: dependencies.
	secondResult := project materializeDependency: self collidingDependency into: dependencies.

	self assert: firstResult source equals: source.
	self assert: secondResult source equals: source.
	self deny: firstResult path equals: secondResult path.
	self assert: ((project repositoryDirectory / firstResult path) contents includesSubstring: 'minimal fixture payload').
	self assert: ((project repositoryDirectory / secondResult path) contents includesSubstring: 'second fixture payload')
]

{ #category : 'private' }
MooseNexusDependencyMaterializationIntegrationTest >> assertMaterialization: result from: source in: project [

	| target |
	target := project repositoryDirectory / result path.
	self assert: result dependency equals: self dependency.
	self assert: result source equals: source.
	self assert: result path equals: 'dependencies/' , self dependency materializationFileName.
	self assert: target exists.
	self
		assert: target contents
		equals: 'This is intentionally a minimal fixture payload. The materializers copy it but never inspect its bytecode.' , String lf
]

{ #category : 'private' }
MooseNexusDependencyMaterializationIntegrationTest >> collidingDependency [

	^ MooseNexusDependencyDescriptor
		  coordinates: (MooseNexusCoordinates group: 'org.moosenexus.other' name: 'materialized-dependency' version: '1.0.0')
		  type: 'jar'
		  scopes: #( 'compile' )
]

{ #category : 'private' }
MooseNexusDependencyMaterializationIntegrationTest >> dependency [

	^ MooseNexusDependencyDescriptor
		  coordinates: (MooseNexusCoordinates group: 'org.moosenexus.fixture' name: 'materialized-dependency' version: '1.0.0')
		  type: 'jar'
		  scopes: #( 'compile' )
]

{ #category : 'private' }
MooseNexusDependencyMaterializationIntegrationTest >> fixtureDirectory [

	^ (IceRepository registry detect: [ :each | each includesPackageNamed: 'MooseNexus' ]) location / 'test-resources'
	  / 'managed-projects'
]

{ #category : 'private' }
MooseNexusDependencyMaterializationIntegrationTest >> prepareFixtureScripts [

	OSPlatform current isWindows ifTrue: [ ^ self ].
	LibC resultOfCommand: 'chmod +x "' , (rootDirectory / 'repository' / 'maven' / 'mvnw') pathString , '"'
]

{ #category : 'private' }
MooseNexusDependencyMaterializationIntegrationTest >> project: aProjectClass forFixtureNamed: fixtureName [

	| project backend |
	backend := MooseNexusLocalRepositoryBackend directory: rootDirectory.
	project := aProjectClass new.
	project repositoryBackend: backend path: fixtureName.
	^ project
]

{ #category : 'running' }
MooseNexusDependencyMaterializationIntegrationTest >> setUp [

	super setUp.
	self timeLimit: 60 seconds.
	rootDirectory := FileLocator temp / ('MooseNexus-dependency-materialization-' , UUID new asString).
	rootDirectory ensureCreateDirectory.
	self fixtureDirectory copyAllTo: rootDirectory / 'repository'.
	self prepareFixtureScripts
]

{ #category : 'running' }
MooseNexusDependencyMaterializationIntegrationTest >> tearDown [

	rootDirectory ifNotNil: [ rootDirectory ifExists: [ rootDirectory deleteAll ] ].
	super tearDown
]

{ #category : 'tests' }
MooseNexusDependencyMaterializationIntegrationTest >> testGradleMaterializesCollidingDependenciesWithoutOverwrite [

	| project |
	project := self project: MooseNexusGradleProject forFixtureNamed: 'gradle'.

	self assertCollidingMaterializationsIn: project from: 'gradle'
]

{ #category : 'tests' }
MooseNexusDependencyMaterializationIntegrationTest >> testGradleMaterializesDependencyFromCheckedInRepository [

	| project dependencies result |
	project := self project: MooseNexusGradleProject forFixtureNamed: 'gradle'.
	dependencies := (project repositoryDirectory / 'dependencies') ensureCreateDirectory.

	result := project materializeDependency: self dependency into: dependencies.

	self assertMaterialization: result from: 'gradle' in: project
]

{ #category : 'tests' }
MooseNexusDependencyMaterializationIntegrationTest >> testMavenMaterializesCollidingDependenciesWithoutOverwrite [

	| project |
	project := self project: MooseNexusMavenProject forFixtureNamed: 'maven'.

	self assertCollidingMaterializationsIn: project from: 'maven'
]

{ #category : 'tests' }
MooseNexusDependencyMaterializationIntegrationTest >> testMavenMaterializesDependencyFromCheckedInRepository [

	| project dependencies result |
	project := self project: MooseNexusMavenProject forFixtureNamed: 'maven'.
	dependencies := (project repositoryDirectory / 'dependencies') ensureCreateDirectory.

	result := project materializeDependency: self dependency into: dependencies.

	self assertMaterialization: result from: 'maven' in: project
]
