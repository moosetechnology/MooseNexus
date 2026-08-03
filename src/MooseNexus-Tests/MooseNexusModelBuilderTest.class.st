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
MooseNexusModelBuilderTest >> testRegisterModelCopiesOutputIntoModelsDirectory [

	| builder source target models |
	source := rootDirectory / 'sources' / 'mooseNexusModel.json'.
	source writeStreamDo: [ :stream | stream nextPutAll: '{ }' ].
	builder := MooseNexusModelBuilder on: project.
	builder modelName: 'demo-model'.

	builder registerModel: 'sources/mooseNexusModel.json'.

	target := rootDirectory / 'models' / 'demo-model.json'.
	self deny: source exists.
	self assert: target exists.
	self assert: target contents equals: '{ }'.
	models := rootDirectory / 'models.json' readStreamDo: [ :stream | STON fromStream: stream ].
	self assert: models size equals: 1.
	self assert: (models first at: 'name') equals: 'demo-model'.
	self assert: (models first at: 'format') equals: 'json'
]
