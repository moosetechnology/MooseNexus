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

	result := importer requirements first validateAvailabilityUsing: [ :command |
		          self assert: (command includesSubstring: '--version').
		          0 ] versionUsing: [ :command |
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
	result := MooseNexusRequirementValidationResult
		          requirement: importer requirements first
		          available: false
		          details: '127'.

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
	self assert: (requirement expectedVersionDescription includesSubstring: 'dependency:resolve')
]

{ #category : 'tests' }
MooseNexusImporterExtractorProtocolTest >> testModelBuilderValidatesExtractorBeforeRunningIt [

	| project extractor builder |
	(rootDirectory / 'metadata') ensureCreateDirectory.
	rootDirectory / 'metadata' / 'models.json' writeStreamDo: [ :stream | stream nextPutAll: '[]' ].
	(rootDirectory / 'sources') ensureCreateDirectory.
	project := MooseNexusTestProject coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0').
	project directory: (rootDirectory relativeTo: FileLocator home) pathString.
	extractor := MooseNexusUnavailableToolModelExtractor new.
	builder := MooseNexusModelBuilder on: project.
	builder extractor: extractor.

	self should: [ builder build ] raise: Error.
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
