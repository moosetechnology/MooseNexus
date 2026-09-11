"
I test TypeScript runner configuration and TypeScript-aware importer selection without invoking Docker or npm.
"
Class {
	#name : 'MooseNexusTypeScriptRunnerTest',
	#superclass : 'TestCase',
	#instVars : [
		'rootDirectory'
	],
	#category : 'MooseNexus-TypeScript-Tests-ModelExtraction',
	#package : 'MooseNexus-TypeScript-Tests',
	#tag : 'ModelExtraction'
}

{ #category : 'running' }
MooseNexusTypeScriptRunnerTest >> setUp [

	super setUp.
	rootDirectory := FileLocator temp / ('MooseNexus-typescript-runner-' , UUID new asString).
	rootDirectory ensureCreateDirectory
]

{ #category : 'running' }
MooseNexusTypeScriptRunnerTest >> tearDown [

	rootDirectory ifNotNil: [ rootDirectory ifExists: [ rootDirectory deleteAll ] ].
	super tearDown
]

{ #category : 'tests' }
MooseNexusTypeScriptRunnerTest >> testDockerTypeScriptRunnerDeclaresCapabilitiesAndReadOnlySourceCommand [

	| extractor requirements dockerRequirement command |
	(rootDirectory / 'sources' / 'main') ensureCreateDirectory.
	rootDirectory / 'sources' / 'main' / 'tsconfig.json' writeStreamDo: [ :stream | stream nextPutAll: '{}' ].
	extractor := MooseNexusDockerTypeScriptRunner new target: rootDirectory pathString.
	requirements := extractor requirements.
	dockerRequirement := requirements detect: [ :requirement | requirement name = 'Docker' ].
	command := extractor writeCommand.

	self assert: extractor language equals: 'typescript'.
	self assert: extractor metamodel equals: 'Famix-TypeScript'.
	self assertCollection: extractor modelFormats hasSameElements: #( json ).
	self assert: requirements size equals: 1.
	self assert: dockerRequirement availabilityValidation equals: 'docker --version'.
	self assert: (dockerRequirement expectedVersionDescription includesSubstring: 'moosenexus-ts2famix:3.2.0-679f54e').
	self assert: (command includesSubstring: ':/source:ro').
	self assert: (command includesSubstring: ':/output').
	self assert: (command includesSubstring: '-i /source/tsconfig.json').
	self assert: (command includesSubstring: '-o /output/mooseNexusTypeScriptModel.json')
]

{ #category : 'tests' }
MooseNexusTypeScriptRunnerTest >> testLocalTypeScriptRunnerUsesConfiguredCommandWithoutInstallation [

	| extractor requirements nodeRequirement importerRequirement command |
	(rootDirectory / 'sources' / 'main') ensureCreateDirectory.
	rootDirectory / 'sources' / 'main' / 'tsconfig.json' writeStreamDo: [ :stream | stream nextPutAll: '{}' ].
	extractor := MooseNexusLocalTypeScriptRunner new
		             target: rootDirectory pathString;
		             command: 'npx --no-install ts2famix';
		             yourself.
	requirements := extractor requirements.
	nodeRequirement := requirements detect: [ :requirement | requirement name = 'Node.js' ].
	importerRequirement := requirements detect: [ :requirement | requirement name = 'ts2famix' ].
	command := extractor writeCommand.

	self assert: requirements size equals: 2.
	self assert: nodeRequirement availabilityValidation equals: 'node --version'.
	self assert: importerRequirement availabilityValidation equals: 'npx --no-install ts2famix --version'.
	self assert: (command beginsWith: 'npx --no-install ts2famix').
	self deny: (command includesSubstring: 'npm install').
	self assert: (command includesSubstring: 'tsconfig.json')
]

{ #category : 'tests' }
MooseNexusTypeScriptRunnerTest >> testProjectImporterAutodetectionReportsAmbiguousNatures [

	rootDirectory / 'package.json' writeStreamDo: [ :stream | stream nextPutAll: '{}' ].
	rootDirectory / 'package-lock.json' writeStreamDo: [ :stream | stream nextPutAll: '{"lockfileVersion": 3, "packages": {}}' ].
	rootDirectory / 'pom.xml' writeStreamDo: [ :stream | stream nextPutAll: '<project />' ].

	self should: [ MooseNexusProjectImporter fromDirectory: rootDirectory ] raise: Error
]

{ #category : 'tests' }
MooseNexusTypeScriptRunnerTest >> testProjectImporterAutodetectionUsesExplicitLanguageToResolveAmbiguity [

	rootDirectory / 'package.json' writeStreamDo: [ :stream | stream nextPutAll: '{}' ].
	rootDirectory / 'package-lock.json' writeStreamDo: [ :stream | stream nextPutAll: '{"lockfileVersion": 3, "packages": {}}' ].
	rootDirectory / 'pom.xml' writeStreamDo: [ :stream | stream nextPutAll: '<project />' ].

	self
		assert: (MooseNexusProjectImporter fromDirectory: rootDirectory language: 'typescript') class
		equals: MooseNexusNpmProjectImporter
]

{ #category : 'tests' }
MooseNexusTypeScriptRunnerTest >> testTypeScriptModelImporterDeclaresRequirements [

	| importer requirement |
	importer := MooseNexusModelImporter forMetamodel: 'Famix-TypeScript'.
	requirement := importer modelImportRequirements first.

	self assert: importer class equals: MooseNexusTypeScriptModelImporter.
	self assert: requirement name equals: 'Famix TypeScript JSON import'.
	self assert: requirement versionValidation value equals: ''.
	self assert: requirement validate isAvailable
]

{ #category : 'tests' }
MooseNexusTypeScriptRunnerTest >> testTypeScriptRunnerCleansItsTemporaryOutputDirectory [

	| extractor outputFile |
	extractor := MooseNexusDockerTypeScriptRunner new target: rootDirectory pathString.
	extractor prepareOutput.
	outputFile := extractor outputFile.
	outputFile writeStreamDo: [ :stream | stream nextPutAll: '{}' ].

	extractor cleanUp.

	self deny: extractor outputDirectory exists
]

{ #category : 'tests' }
MooseNexusTypeScriptRunnerTest >> testTypeScriptRunnerDefaultsToDocker [

	self assert: (MooseNexusModelExtractor forLanguage: 'typescript') class equals: MooseNexusDockerTypeScriptRunner
]

{ #category : 'tests' }
MooseNexusTypeScriptRunnerTest >> testTypeScriptRunnerRequiresTsconfig [

	| extractor |
	extractor := MooseNexusDockerTypeScriptRunner new target: rootDirectory pathString.

	self should: [ extractor tsConfigFile ] raise: Error
]
