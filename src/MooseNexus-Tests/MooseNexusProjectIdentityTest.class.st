Class {
	#name : 'MooseNexusProjectIdentityTest',
	#superclass : 'TestCase',
	#instVars : [
		'repository',
		'sourceDirectory',
		'rootDirectory'
	],
	#category : 'MooseNexus-Tests',
	#package : 'MooseNexus-Tests'
}

{ #category : 'running' }
MooseNexusProjectIdentityTest >> setUp [

	super setUp.
	rootDirectory := FileLocator temp / ('MooseNexus-' , UUID new asString).
	sourceDirectory := rootDirectory / 'source'.
	sourceDirectory ensureCreateDirectory.
	sourceDirectory / 'README.txt' writeStreamDo: [ :stream | stream nextPutAll: 'test source project' ].
	repository := MooseNexusRepository new directory: rootDirectory / 'nexus'
]

{ #category : 'running' }
MooseNexusProjectIdentityTest >> tearDown [

	rootDirectory ifNotNil: [ rootDirectory ifExists: [ rootDirectory deleteAll ] ].
	super tearDown
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testProjectCoordinatesAreInitializedOnce [

	| project coordinates |
	coordinates := MooseNexusProjectCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	project := MooseNexusTestProject coordinates: coordinates.

	self assert: project coordinates equals: coordinates.
	self assert: project group equals: 'com.example'.
	self assert: project name equals: 'demo'.
	self assert: project version equals: '1.0.0'.
	self
		should: [ project initializeCoordinates: (MooseNexusProjectCoordinates group: 'org.example' name: 'demo' version: '1.0.0') ]
		raise: Error
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testProjectCoordinatesAreValueObjects [

	| coordinates sameCoordinates otherCoordinates |
	coordinates := MooseNexusProjectCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	sameCoordinates := MooseNexusProjectCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	otherCoordinates := MooseNexusProjectCoordinates group: 'com.example' name: 'demo' version: '2.0.0'.

	self assert: coordinates equals: sameCoordinates.
	self deny: coordinates equals: otherCoordinates.
	self assert: coordinates printString equals: 'com.example:demo:1.0.0'
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testProjectSpecHoldsRecordingIntent [

	| coordinates spec |
	coordinates := MooseNexusProjectCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	spec := MooseNexusProjectSpec coordinates: coordinates sourceDirectory: sourceDirectory.

	self assert: spec coordinates equals: coordinates.
	self assert: spec group equals: 'com.example'.
	self assert: spec name equals: 'demo'.
	self assert: spec version equals: '1.0.0'.
	self assert: spec sourceDirectory pathString equals: sourceDirectory pathString
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testRecordedProjectRejectsCoordinateChanges [

	| project coordinates |
	coordinates := MooseNexusProjectCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	project := MooseNexusTestProject coordinates: coordinates.
	project directory: 'nexus/repository/com.example/demo/1.0.0'.

	self
		should: [ project initializeCoordinates: (MooseNexusProjectCoordinates group: 'org.example' name: 'demo' version: '1.0.0') ]
		raise: Error
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testRepositoryCreatesLayoutBeforeRecordingProject [

	| project spec projectDirectory |
	project := MooseNexusTestProject new.
	spec := MooseNexusProjectSpec
		        coordinates: (MooseNexusProjectCoordinates group: 'com.example' name: 'demo' version: '1.0.0')
		        sourceDirectory: sourceDirectory.
	projectDirectory := repository directory / 'repository' / 'com.example' / 'demo' / '1.0.0'.

	self deny: repository directory exists.
	repository recordLoadedProject: project describedBy: spec.

	self assert: projectDirectory exists.
	self assert: (projectDirectory / 'sources') exists.
	self assert: (projectDirectory / 'sources' / 'project') exists.
	self assert: (projectDirectory / 'sources' / 'project' / 'README.txt') exists.
	self assert: (projectDirectory / 'properties.json') exists.
	self assert: (projectDirectory / 'models.json') exists
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testRepositoryRecordFromSpecSetsIdentityBeforeRecording [

	| project spec recordedProject coordinates |
	project := MooseNexusTestProject new.
	coordinates := MooseNexusProjectCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	spec := MooseNexusProjectSpec coordinates: coordinates sourceDirectory: sourceDirectory.
	recordedProject := repository recordLoadedProject: project describedBy: spec.

	self assert: recordedProject identicalTo: project.
	self assert: project coordinates equals: coordinates.
	self assert: project isRecorded.
	self assert: (repository directory / 'repository' / 'com.example' / 'demo' / '1.0.0' / 'properties.json') exists
]
