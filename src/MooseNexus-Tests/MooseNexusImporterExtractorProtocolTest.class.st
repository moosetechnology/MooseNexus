"
I test the explicit importer and extractor protocol used for source-project and model-extraction preflight checks.
"
Class {
	#name : 'MooseNexusImporterExtractorProtocolTest',
	#superclass : 'TestCase',
	#instVars : [
		'rootDirectory'
	],
	#category : 'MooseNexus-Tests',
	#package : 'MooseNexus-Tests'
}

{ #category : 'running' }
MooseNexusImporterExtractorProtocolTest >> setUp [

	super setUp.
	rootDirectory := FileLocator temp / ('MooseNexus-' , UUID new asString).
	rootDirectory ensureCreateDirectory
]

{ #category : 'running' }
MooseNexusImporterExtractorProtocolTest >> tearDown [

	rootDirectory ifNotNil: [ rootDirectory ifExists: [ rootDirectory deleteAll ] ].
	super tearDown
]

{ #category : 'tests' }
MooseNexusImporterExtractorProtocolTest >> testDockerVerveineJDeclaresJavaModelExtractionCapabilities [

	| extractor requirements dockerRequirement result |
	extractor := MooseNexusDockerVerveineJRunner new.
	requirements := extractor requirements.
	dockerRequirement := requirements detect: [ :requirement | requirement name = 'Docker' ].

	self assert: extractor language equals: 'java'.
	self assert: extractor metamodel equals: 'Famix-Java'.
	self assertCollection: extractor modelFormats hasSameElements: #( json mse ).
	self assert: requirements size equals: 1.
	self assert: dockerRequirement availabilityValidation equals: 'docker --version'.
	self assert: dockerRequirement versionValidation equals: 'docker --version'.
	self assert: (dockerRequirement expectedVersionDescription includesSubstring: 'verveinej:latest').
	result := dockerRequirement validateAvailabilityUsing: [ :command | 0 ] versionUsing: [ :command | 'Docker version 1.2.3' ].
	self assert: result isAvailable.
	self assert: (result versionDetails includesSubstring: '1.2.3')
]

{ #category : 'tests' }
MooseNexusImporterExtractorProtocolTest >> testGradleImporterDeclaresCapabilitiesAndRequirements [

	| importer requirement |
	(rootDirectory / 'build.gradle') ensureCreateFile.
	importer := MooseNexusGradleProjectImporter new directory: rootDirectory.
	requirement := importer requirements first.

	self assert: importer buildToolName equals: 'gradle'.
	self assertCollection: importer supportedLanguages hasSameElements: #( java ).
	self assert: importer requirements size equals: 1.
	self assert: requirement name equals: 'Gradle'.
	self assert: (requirement availabilityValidation includesSubstring: '--version').
	self assert: (requirement versionValidation includesSubstring: '--version').
	self assert: (requirement expectedVersionDescription includesSubstring: 'dependency task')
]

{ #category : 'tests' }
MooseNexusImporterExtractorProtocolTest >> testGradleImporterSignalsCommandFailure [

	| importer commandResult |
	importer := MooseNexusGradleProjectImporter new.
	commandResult := 'FAILURE: Could not resolve dependency' , importer commandExitStatusMarker , '1'.

	self
		should: [ importer commandOutputFrom: commandResult forToolNamed: 'Gradle' ]
		raise: Error
		whoseDescriptionIncludes: 'Could not resolve dependency'
		description: 'Gradle command failures must preserve the Gradle diagnostic'
]

{ #category : 'tests' }
MooseNexusImporterExtractorProtocolTest >> testImageRequirementValidatesMooseFamixCompatibilityInImage [

	| requirement result |
	requirement := MooseNexusImageRequirement
		               name: 'Image capability'
		               availabilityValidation: [ true ]
		               versionValidation: [ 'Loaded image capability' ]
		               expectedVersionDescription: 'loaded capability'.

	result := requirement validate.

	self assert: result isAvailable.
	self assert: result requirementName equals: 'Image capability'.
	self assert: result versionDetails equals: 'Loaded image capability'
]

{ #category : 'tests' }
MooseNexusImporterExtractorProtocolTest >> testImporterValidatesAllRequirements [

	| importer result |
	(rootDirectory / 'pom.xml') ensureCreateFile.
	importer := MooseNexusMavenProjectImporter new directory: rootDirectory.

	result := importer requirements first
		          validateAvailabilityUsing: [ :command |
				          self assert: (command includesSubstring: '--version').
				          0 ]
		          versionUsing: [ :command |
				          self assert: (command includesSubstring: '--version').
				          'Apache Maven 3.9.9' ].

	self assert: result isAvailable.
	self assert: (result versionDetails includesSubstring: '3.9.9')
]

{ #category : 'tests' }
MooseNexusImporterExtractorProtocolTest >> testImporterValidationRaisesWhenARequiredToolIsUnavailable [

	| importer result |
	(rootDirectory / 'pom.xml') ensureCreateFile.
	importer := MooseNexusMavenProjectImporter new directory: rootDirectory.
	result := MooseNexusRequirementValidationResult requirement: importer requirements first available: false details: '127'.

	self should: [ importer validateRequirements: { result } ] raise: Error
]

{ #category : 'tests' }
MooseNexusImporterExtractorProtocolTest >> testLocalVerveineJDeclaresJavaAndWrapperRequirements [

	| extractor requirements javaRequirement wrapperRequirement |
	(rootDirectory / 'gradlew') ensureCreateFile.
	extractor := MooseNexusLocalVerveineJRunner new directory: rootDirectory.
	requirements := extractor requirements.
	javaRequirement := requirements detect: [ :requirement | requirement name = 'Java' ].
	wrapperRequirement := requirements detect: [ :requirement | requirement name = 'VerveineJ Gradle wrapper' ].

	self assert: extractor language equals: 'java'.
	self assert: extractor metamodel equals: 'Famix-Java'.
	self assertCollection: extractor modelFormats hasSameElements: #( json mse ).
	self assert: requirements size equals: 2.
	self assert: javaRequirement availabilityValidation equals: 'java -version'.
	self assert: javaRequirement versionValidation equals: 'java -version'.
	self assert: (wrapperRequirement availabilityValidation includesSubstring: 'gradlew').
	self assert: (wrapperRequirement versionValidation includesSubstring: 'gradlew')
]

{ #category : 'tests' }
MooseNexusImporterExtractorProtocolTest >> testMavenImporterAnswersOutputWhenMavenSucceeds [

	| importer commandResult |
	importer := MooseNexusMavenProjectImporter new.
	commandResult := 'Maven output' , importer commandExitStatusMarker , '0'.

	self assert: (importer commandOutputFrom: commandResult forToolNamed: 'Maven') equals: 'Maven output'
]

{ #category : 'tests' }
MooseNexusImporterExtractorProtocolTest >> testMavenImporterCreatesPathlessDependencyReferencesFromTreeNodes [

	| importer descriptor |
	importer := MooseNexusMavenProjectImporter new.

	descriptor := importer dependencyReferenceForTreeNode: (Dictionary
			               with: 'groupId' -> 'org.example'
			               with: 'artifactId' -> 'lib'
			               with: 'version' -> '1.0.0'
			               with: 'type' -> 'jar'
			               with: 'scope' -> 'runtime').

	self assert: descriptor class equals: MooseNexusDependencyDescriptor.
	self deny: descriptor isLocal.
	self assert: descriptor scopes equals: #( 'runtime' ).
	self deny: (descriptor asDictionary includesKey: #path)
]

{ #category : 'tests' }
MooseNexusImporterExtractorProtocolTest >> testMavenImporterDeclaresCapabilitiesAndRequirements [

	| importer requirement |
	(rootDirectory / 'pom.xml') ensureCreateFile.
	importer := MooseNexusMavenProjectImporter new directory: rootDirectory.
	requirement := importer requirements first.

	self assert: importer buildToolName equals: 'maven'.
	self assertCollection: importer supportedLanguages hasSameElements: #( java ).
	self assert: importer requirements size equals: 1.
	self assert: requirement name equals: 'Maven'.
	self assert: (requirement availabilityValidation includesSubstring: '--version').
	self assert: (requirement versionValidation includesSubstring: '--version').
	self assert: (requirement expectedVersionDescription includesSubstring: '3.6.3')
]

{ #category : 'tests' }
MooseNexusImporterExtractorProtocolTest >> testMavenImporterParsesMavenVersionBanners [

	| importer |
	importer := MooseNexusMavenProjectImporter new.

	self assert: (importer mavenVersionFrom: 'Apache Maven 3.9.11') equals: '3.9.11'.
	self assert: (importer mavenVersionFrom: 'Apache Maven 3.9.11 (deadbeef)') equals: '3.9.11'.
	self should: [ importer mavenVersionFrom: 'Maven 3.9.11' ] raise: Error.
	self should: [ importer mavenVersionFrom: 'Apache Maven ' ] raise: Error
]

{ #category : 'tests' }
MooseNexusImporterExtractorProtocolTest >> testMavenImporterParsesSingleAndReactorEffectiveProjects [

	| importer singleProject reactorProjects |
	importer := MooseNexusMavenProjectImporter new.

	singleProject := importer effectiveProjectElementsFrom: '<project><groupId>org.example</groupId></project>'.
	reactorProjects := importer effectiveProjectElementsFrom:
		                   '<projects><project><groupId>org.first</groupId></project><project><groupId>org.second</groupId></project></projects>'.

	self assert: singleProject size equals: 1.
	self assert: singleProject first name equals: 'project'.
	self assert: reactorProjects size equals: 2.
	self assertCollection: (reactorProjects collect: #name) hasSameElements: #( project project )
]

{ #category : 'tests' }
MooseNexusImporterExtractorProtocolTest >> testMavenImporterRecognizesSupportedMaven3Versions [

	| importer |
	importer := MooseNexusMavenProjectImporter new.

	#( '3.6.3' '3.8.8' '3.9.11' ) do: [ :version | self assert: (importer isSupportedMavenVersion: version) ].
	self deny: (importer isSupportedMavenVersion: '3.6.2').
	self deny: (importer isSupportedMavenVersion: '4.0.0')
]

{ #category : 'tests' }
MooseNexusImporterExtractorProtocolTest >> testMavenImporterRejectsUnsupportedVersionsDuringPreflight [

	| importer |
	importer := MooseNexusMavenProjectImporter new.

	self
		should: [ importer validateMavenVersion: 'Apache Maven 3.6.2' ]
		raise: Error
		whoseDescriptionIncludes: 'Maven 3.6.3 through 3.x'
		description: 'Maven below the plugin floor must not proceed'.
	self
		should: [ importer validateMavenVersion: 'Apache Maven 4.0.0' ]
		raise: Error
		whoseDescriptionIncludes: 'Maven 4 is not yet supported'
		description: 'Untested Maven 4 must not proceed'
]

{ #category : 'tests' }
MooseNexusImporterExtractorProtocolTest >> testMavenImporterSignalsCommandFailure [

	| importer commandResult |
	importer := MooseNexusMavenProjectImporter new.
	commandResult := '[ERROR] Could not resolve POM' , importer commandExitStatusMarker , '1'.

	self
		should: [ importer commandOutputFrom: commandResult forToolNamed: 'Maven' ]
		raise: Error
		whoseDescriptionIncludes: 'Could not resolve POM'
		description: 'Maven command failures must preserve the Maven diagnostic'
]

{ #category : 'tests' }
MooseNexusImporterExtractorProtocolTest >> testModelBuilderValidatesExtractorBeforeRunningIt [

	| project extractor builder repositoryBackend |
	(rootDirectory / 'metadata') ensureCreateDirectory.
	rootDirectory / 'metadata' / 'models.json' writeStreamDo: [ :stream | stream nextPutAll: '[]' ].
	(rootDirectory / 'sources') ensureCreateDirectory.
	repositoryBackend := MooseNexusLocalRepositoryBackend directory: rootDirectory parent.
	project := MooseNexusTestProject coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0').
	project repositoryBackend: repositoryBackend path: rootDirectory basename.
	extractor := MooseNexusUnavailableToolModelExtractor new.
	builder := MooseNexusModelBuilder on: project.
	builder extractor: extractor.

	self
		should: [ builder build ]
		raise: Error
		whoseDescriptionIncludes: 'Unavailable test extractor tool is not available'
		description: 'The model builder must surface an unavailable extractor before it runs'.
	self deny: extractor didRun
]

{ #category : 'tests' }
MooseNexusImporterExtractorProtocolTest >> testProjectDeclaresFamixModelImportRequirement [

	| project requirement result |
	project := MooseNexusTestProject coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0').
	requirement := project modelImportRequirements first.

	self assert: requirement name equals: 'Famix Java JSON import'.
	self assert: requirement versionValidation value equals: ''.
	result := requirement validate.
	self assert: result isAvailable
]

{ #category : 'tests' }
MooseNexusImporterExtractorProtocolTest >> testToolRequirementCanValidateAvailabilityAndVersionWithInjectedRunners [

	| requirement result |
	requirement := MooseNexusToolRequirement
		               name: 'Example Tool'
		               availabilityValidation: 'example --help'
		               versionValidation: 'example --version'
		               expectedVersionDescription: 'Example Tool 1.x'.

	result := requirement
		          validateAvailabilityUsing: [ :command |
				          self assert: command equals: 'example --help'.
				          0 ]
		          versionUsing: [ :command |
				          self assert: command equals: 'example --version'.
				          'Example Tool 1.2.3' ].

	self assert: result isAvailable.
	self assert: result requirementName equals: 'Example Tool'.
	self assert: result details equals: '0'.
	self assert: result versionDetails equals: 'Example Tool 1.2.3'
]

{ #category : 'tests' }
MooseNexusImporterExtractorProtocolTest >> testToolRequirementReportsUnavailableRunnerResult [

	| requirement result |
	requirement := MooseNexusToolRequirement
		               name: 'Missing Tool'
		               availabilityValidation: 'missing --help'
		               versionValidation: 'missing --version'
		               expectedVersionDescription: 'Missing Tool 1.x'.

	result := requirement validateAvailabilityUsing: [ :command | 127 ] versionUsing: [ :command | self fail ].

	self deny: result isAvailable.
	self assert: result requirementName equals: 'Missing Tool'.
	self assert: result details equals: '127'.
	self assert: result versionDetails equals: ''
]
