"
I exercise complete Maven and Gradle build plans against checked-in, offline fixtures.

Each scenario uses the real managed-project importer, records the source project in a disposable MooseNexus repository, creates a model artifact through the test extractor, and reads the persisted manifest back from metadata. This joins the build-tool integration coverage to the artifact-manifest contract without depending on an external model extractor.
"
Class {
	#name : 'MooseNexusManagedProjectBuildIntegrationTest',
	#superclass : 'TestCase',
	#instVars : [
		'rootDirectory'
	],
	#category : 'MooseNexus-Java-IntegrationTests-Build',
	#package : 'MooseNexus-Java-IntegrationTests',
	#tag : 'Build'
}

{ #category : 'private' }
MooseNexusManagedProjectBuildIntegrationTest >> assertManagedBuildForFixtureNamed: fixtureName projectClass: projectClass importerClass: importerClass sourceBuildFile: sourceBuildFileName [

	| plan result project |
	plan := self buildPlanForFixtureNamed: fixtureName.
	result := plan execute.
	project := result project.

	self assert: plan projectImporter class equals: importerClass.
	self assertRecordedProject: project hasCoordinates: (self fixtureCoordinatesForProjectNamed: fixtureName) class: projectClass.
	self assert: result dependencyResolutionResult dependencies equals: project dependencies.
	self assert: result dependencyResolutionResult materializations isEmpty.
	self assertManifestFor: result project: project sourceBuildFile: sourceBuildFileName
]

{ #category : 'private' }
MooseNexusManagedProjectBuildIntegrationTest >> assertManifestFor: result project: project sourceBuildFile: sourceBuildFileName [

	| manifest persistedManifest modelFile sourceBuildFile |
	manifest := project modelManifestNamed: result modelArtifact name.
	persistedManifest := project modelManifests detect: [ :each | each modelArtifact = result modelArtifact ].
	modelFile := project repositoryDirectory / result modelArtifact path.
	sourceBuildFile := project mainSourceDirectory / sourceBuildFileName.

	self assert: manifest modelArtifact equals: result modelArtifact.
	self assert: persistedManifest equals: manifest.
	self assert: manifest dependencyResolutionResult equals: result dependencyResolutionResult.
	self assert: manifest buildProvenance extractorProvenance runnerName equals: MooseNexusTestModelExtractor name.
	self assert: manifest generatedFiles size equals: 1.
	manifest validateGeneratedFilesIn: project repositoryDirectory.
	self assert: modelFile exists.
	self assert: modelFile contents equals: '{ }'.
	self assert: sourceBuildFile exists
]

{ #category : 'private' }
MooseNexusManagedProjectBuildIntegrationTest >> assertRecordedProject: project hasCoordinates: coordinates class: projectClass [

	self assert: project class equals: projectClass.
	self assert: project coordinates equals: coordinates.
	self assert: project dependencies size equals: 1
]

{ #category : 'private' }
MooseNexusManagedProjectBuildIntegrationTest >> buildPlanForFixtureNamed: fixtureName [

	| coordinates spec |
	coordinates := self fixtureCoordinatesForProjectNamed: fixtureName.
	spec := MooseNexusBuildSpec coordinates: coordinates sourceDirectory: (self fixtureProjectDirectoryNamed: fixtureName).
	spec
		language: 'java';
		withDependencyClasspath: false;
		modelName: fixtureName , '-model';
		extractor: MooseNexusTestModelExtractor new.
	^ spec planIn: (MooseNexusRepository new directory: rootDirectory / 'nexus')
]

{ #category : 'private' }
MooseNexusManagedProjectBuildIntegrationTest >> fixtureCoordinatesForProjectNamed: name [

	^ MooseNexusCoordinates group: 'org.moosenexus.fixture' name: name version: '1.0.0'
]

{ #category : 'private' }
MooseNexusManagedProjectBuildIntegrationTest >> fixtureDirectory [

	^ (IceRepository registry detect: [ :each | each includesPackageNamed: 'MooseNexus' ]) location / 'test-resources'
	  / 'managed-projects'
]

{ #category : 'private' }
MooseNexusManagedProjectBuildIntegrationTest >> fixtureProjectDirectoryNamed: name [

	^ rootDirectory / 'repository' / name
]

{ #category : 'private' }
MooseNexusManagedProjectBuildIntegrationTest >> prepareFixtureScripts [

	OSPlatform current isWindows ifTrue: [ ^ self ].
	LibC resultOfCommand: (String streamContents: [ :stream |
				 stream
					 nextPutAll: 'chmod +x "';
					 nextPutAll: ((self fixtureProjectDirectoryNamed: 'maven') / 'mvnw') pathString;
					 nextPut: $" ])
]

{ #category : 'running' }
MooseNexusManagedProjectBuildIntegrationTest >> setUp [

	super setUp.
	self timeLimit: 60 seconds.
	rootDirectory := FileLocator temp / ('MooseNexus-managed-project-build-' , UUID new asString).
	rootDirectory ensureCreateDirectory.
	self fixtureDirectory copyAllTo: rootDirectory / 'repository'.
	self prepareFixtureScripts
]

{ #category : 'running' }
MooseNexusManagedProjectBuildIntegrationTest >> tearDown [

	rootDirectory ifNotNil: [ rootDirectory ifExists: [ rootDirectory deleteAll ] ].
	super tearDown
]

{ #category : 'tests' }
MooseNexusManagedProjectBuildIntegrationTest >> testGradleBuildRecordsModelArtifactManifest [

	self
		assertManagedBuildForFixtureNamed: 'gradle'
		projectClass: MooseNexusGradleProject
		importerClass: MooseNexusGradleProjectImporter
		sourceBuildFile: 'build.gradle'
]

{ #category : 'tests' }
MooseNexusManagedProjectBuildIntegrationTest >> testMavenBuildRecordsModelArtifactManifest [

	self
		assertManagedBuildForFixtureNamed: 'maven'
		projectClass: MooseNexusMavenProject
		importerClass: MooseNexusMavenProjectImporter
		sourceBuildFile: 'pom.xml'
]
