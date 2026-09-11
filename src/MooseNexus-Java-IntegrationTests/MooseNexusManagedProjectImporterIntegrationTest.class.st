"
I exercise Maven and Gradle managed-project import against checked-in, offline build fixtures.

The fixtures are located through the registered Iceberg repository and copied into a disposable working directory before an importer invokes the real build tool.
"
Class {
	#name : 'MooseNexusManagedProjectImporterIntegrationTest',
	#superclass : 'TestCase',
	#instVars : [
		'rootDirectory'
	],
	#category : 'MooseNexus-Java-IntegrationTests-Importer',
	#package : 'MooseNexus-Java-IntegrationTests',
	#tag : 'Importer'
}

{ #category : 'private' }
MooseNexusManagedProjectImporterIntegrationTest >> assertPathlessFixtureDependency: dependency [

	self assert: dependency group equals: 'org.moosenexus.fixture'.
	self assert: dependency name equals: 'materialized-dependency'.
	self assert: dependency version equals: '1.0.0'.
	self assert: dependency type equals: 'jar'.
	self deny: dependency isLocal
]

{ #category : 'private' }
MooseNexusManagedProjectImporterIntegrationTest >> fixtureDirectory [

	^ (IceRepository registry detect: [ :each | each includesPackageNamed: 'MooseNexus' ]) location / 'test-resources'
	  / 'managed-projects'
]

{ #category : 'private' }
MooseNexusManagedProjectImporterIntegrationTest >> fixtureProjectDirectoryNamed: name [

	^ rootDirectory / 'repository' / name
]

{ #category : 'private' }
MooseNexusManagedProjectImporterIntegrationTest >> prepareFixtureScripts [

	OSPlatform current isWindows ifTrue: [ ^ self ].
	LibC resultOfCommand: 'chmod +x "' , ((self fixtureProjectDirectoryNamed: 'maven') / 'mvnw') pathString , '"'
]

{ #category : 'running' }
MooseNexusManagedProjectImporterIntegrationTest >> setUp [

	super setUp.
	self timeLimit: 60 seconds.
	rootDirectory := FileLocator temp / ('MooseNexus-managed-project-import-' , UUID new asString).
	rootDirectory ensureCreateDirectory.
	self fixtureDirectory copyAllTo: rootDirectory / 'repository'.
	self prepareFixtureScripts
]

{ #category : 'running' }
MooseNexusManagedProjectImporterIntegrationTest >> tearDown [

	rootDirectory ifNotNil: [ rootDirectory ifExists: [ rootDirectory deleteAll ] ].
	super tearDown
]

{ #category : 'tests' }
MooseNexusManagedProjectImporterIntegrationTest >> testGradleGroovyImporterRecordsPathlessDependencyAndRestoresBuildFile [

	| directory buildFile originalContents importer project dependency |
	directory := self fixtureProjectDirectoryNamed: 'gradle'.
	buildFile := directory / 'build.gradle'.
	originalContents := buildFile contents.
	importer := MooseNexusGradleProjectImporter new directory: directory.

	project := importer import.

	self assert: project class equals: MooseNexusGradleProject.
	self assert: buildFile contents equals: originalContents.
	self assert: project dependencies size equals: 1.
	dependency := project dependencies first.
	self assertPathlessFixtureDependency: dependency.
	self assert: (dependency scopes includes: 'compileClasspath')
]

{ #category : 'tests' }
MooseNexusManagedProjectImporterIntegrationTest >> testGradleKotlinImporterRecordsPathlessDependencyAndRestoresBuildFile [

	| directory buildFile originalContents importer project dependency |
	directory := self fixtureProjectDirectoryNamed: 'gradle-kotlin'.
	buildFile := directory / 'build.gradle.kts'.
	originalContents := buildFile contents.
	importer := MooseNexusGradleProjectImporter new directory: directory.

	project := importer import.

	self assert: project class equals: MooseNexusGradleProject.
	self assert: buildFile contents equals: originalContents.
	self assert: project dependencies size equals: 1.
	dependency := project dependencies first.
	self assertPathlessFixtureDependency: dependency.
	self assert: (dependency scopes includes: 'compileClasspath')
]

{ #category : 'tests' }
MooseNexusManagedProjectImporterIntegrationTest >> testMavenImporterRecordsPathlessDependency [

	| importer project dependency |
	importer := MooseNexusMavenProjectImporter new directory: (self fixtureProjectDirectoryNamed: 'maven').
	project := importer import.

	self assert: project class equals: MooseNexusMavenProject.
	self assert: project dependencies size equals: 1.
	dependency := project dependencies first.
	self assertPathlessFixtureDependency: dependency.
	self assert: (project projects at: 'org.moosenexus.fixture' at: 'maven-materialization') dependencies equals: { dependency }
]
