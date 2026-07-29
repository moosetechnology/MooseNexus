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
MooseNexusProjectIdentityTest >> testCoordinatesCanChangeBeforeRecording [

	| project coordinates |
	project := MooseNexusTestProject new.
	coordinates := MooseNexusProjectCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	project coordinates: coordinates.

	self assert: project coordinates equals: coordinates.
	self assert: project group equals: 'com.example'.
	self assert: project name equals: 'demo'.
	self assert: project version equals: '1.0.0'
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
MooseNexusProjectIdentityTest >> testRecordedProjectRejectsCoordinateChanges [

	| project coordinates |
	coordinates := MooseNexusProjectCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	project := MooseNexusTestProject new.
	project
		coordinates: coordinates;
		directory: 'nexus/repository/com.example/demo/1.0.0'.

	self should: [ project coordinates: (MooseNexusProjectCoordinates group: 'org.example' name: 'demo' version: '1.0.0') ] raise: Error.
	self should: [ project group: 'org.example' ] raise: Error.
	self should: [ project name: 'renamed' ] raise: Error.
	self should: [ project version: '2.0.0' ] raise: Error
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testRepositoryCreatesLayoutBeforeRecordingProject [

	| project coordinates projectDirectory |
	project := MooseNexusTestProject new.
	coordinates := MooseNexusProjectCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	projectDirectory := repository directory / 'repository' / 'com.example' / 'demo' / '1.0.0'.

	self deny: repository directory exists.
	repository recordProject: project coordinates: coordinates fromDirectory: sourceDirectory pathString.

	self assert: projectDirectory exists.
	self assert: (projectDirectory / 'sources') exists.
	self assert: (projectDirectory / 'sources' / 'project') exists.
	self assert: (projectDirectory / 'sources' / 'project' / 'README.txt') exists.
	self assert: (projectDirectory / 'properties.json') exists.
	self assert: (projectDirectory / 'models.json') exists
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testRepositoryRecordWithCoordinatesSetsIdentityBeforeRecording [

	| project coordinates recordedProject |
	project := MooseNexusTestProject new.
	coordinates := MooseNexusProjectCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	recordedProject := repository recordProject: project coordinates: coordinates fromDirectory: sourceDirectory pathString.

	self assert: recordedProject identicalTo: project.
	self assert: project coordinates equals: coordinates.
	self assert: project isRecorded.
	self assert: (repository directory / 'repository' / 'com.example' / 'demo' / '1.0.0' / 'properties.json') exists
]
