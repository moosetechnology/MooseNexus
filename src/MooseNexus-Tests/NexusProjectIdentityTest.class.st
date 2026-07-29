Class {
	#name : 'NexusProjectIdentityTest',
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
NexusProjectIdentityTest >> setUp [

	super setUp.
	rootDirectory := FileLocator temp / ('MooseNexus-' , UUID new asString).
	sourceDirectory := rootDirectory / 'source'.
	sourceDirectory ensureCreateDirectory.
	sourceDirectory / 'README.txt' writeStreamDo: [ :stream | stream nextPutAll: 'test source project' ].
	repository := NexusRepository new directory: rootDirectory / 'nexus'
]

{ #category : 'running' }
NexusProjectIdentityTest >> tearDown [

	rootDirectory ifNotNil: [ rootDirectory ifExists: [ rootDirectory deleteAll ] ].
	super tearDown
]

{ #category : 'tests' }
NexusProjectIdentityTest >> testCoordinatesCanChangeBeforeRecording [

	| project coordinates |
	project := NexusTestProject new.
	coordinates := NexusProjectCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	project coordinates: coordinates.

	self assert: project coordinates equals: coordinates.
	self assert: project group equals: 'com.example'.
	self assert: project name equals: 'demo'.
	self assert: project version equals: '1.0.0'
]

{ #category : 'tests' }
NexusProjectIdentityTest >> testProjectCoordinatesAreValueObjects [

	| coordinates sameCoordinates otherCoordinates |
	coordinates := NexusProjectCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	sameCoordinates := NexusProjectCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	otherCoordinates := NexusProjectCoordinates group: 'com.example' name: 'demo' version: '2.0.0'.

	self assert: coordinates equals: sameCoordinates.
	self deny: coordinates equals: otherCoordinates.
	self assert: coordinates printString equals: 'com.example:demo:1.0.0'
]

{ #category : 'tests' }
NexusProjectIdentityTest >> testRecordedProjectRejectsCoordinateChanges [

	| project coordinates |
	coordinates := NexusProjectCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	project := NexusTestProject new.
	project
		coordinates: coordinates;
		directory: 'nexus/repository/com.example/demo/1.0.0'.

	self should: [ project coordinates: (NexusProjectCoordinates group: 'org.example' name: 'demo' version: '1.0.0') ] raise: Error.
	self should: [ project group: 'org.example' ] raise: Error.
	self should: [ project name: 'renamed' ] raise: Error.
	self should: [ project version: '2.0.0' ] raise: Error
]

{ #category : 'tests' }
NexusProjectIdentityTest >> testRepositoryRecordWithCoordinatesSetsIdentityBeforeRecording [

	| project coordinates recordedProject |
	project := NexusTestProject new.
	coordinates := NexusProjectCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	recordedProject := repository recordProject: project coordinates: coordinates fromDirectory: sourceDirectory pathString.

	self assert: recordedProject identicalTo: project.
	self assert: project coordinates equals: coordinates.
	self assert: project isRecorded.
	self assert: (repository directory / 'repository' / 'com.example' / 'demo' / '1.0.0' / 'properties.json') exists
]
