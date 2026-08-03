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
MooseNexusProjectIdentityTest >> testCoordinatesAreInitializedOnce [

	| project coordinates |
	coordinates := MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	project := MooseNexusTestProject coordinates: coordinates.

	self assert: project coordinates equals: coordinates.
	self assert: project group equals: 'com.example'.
	self assert: project name equals: 'demo'.
	self assert: project version equals: '1.0.0'.
	self
		should: [ project initializeCoordinates: (MooseNexusCoordinates group: 'org.example' name: 'demo' version: '1.0.0') ]
		raise: Error
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testCoordinatesAreValueObjects [

	| coordinates sameCoordinates otherCoordinates |
	coordinates := MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	sameCoordinates := MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	otherCoordinates := MooseNexusCoordinates group: 'com.example' name: 'demo' version: '2.0.0'.

	self assert: coordinates equals: sameCoordinates.
	self deny: coordinates equals: otherCoordinates.
	self assert: coordinates printString equals: 'com.example:demo:1.0.0'
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testManagedProjectDescriptorDictionaryRoundTrip [

	| dictionary descriptor |
	dictionary := Dictionary
		              with: #path -> '.'
		              with: #version -> '1.0.0'
		              with: #dependencies -> (Dictionary with: 'org.example' -> { (Dictionary
					                with: #name -> 'dep'
					                with: #version -> '2.0.0'
					                with: #type -> 'jar'
					                with: #scopes -> #( 'compile' )
					                with: #path -> 'repository/dep-2.0.0.jar') }).
	descriptor := MooseNexusManagedProjectDescriptor fromDictionary: dictionary.

	self assert: descriptor version equals: '1.0.0'.
	self assert: descriptor path equals: '.'.
	self assert: descriptor asDictionary equals: dictionary
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testManagedProjectDescriptorIsValueObject [

	| dependency descriptor sameDescriptor otherDescriptor |
	dependency := MooseNexusDependencyDescriptor
		              coordinates: (MooseNexusCoordinates group: nil name: 'dep' version: '2.0.0')
		              type: 'jar'
		              scopes: #( 'compile' )
		              path: 'repository/dep-2.0.0.jar'.
	descriptor := MooseNexusManagedProjectDescriptor
		              version: '1.0.0'
		              path: '.'
		              dependencies: (Dictionary with: 'org.example' -> { dependency }).
	sameDescriptor := MooseNexusManagedProjectDescriptor
		                  version: '1.0.0'
		                  path: '.'
		                  dependencies: (Dictionary with: 'org.example' -> { dependency }).
	otherDescriptor := MooseNexusManagedProjectDescriptor
		                   version: '2.0.0'
		                   path: '.'
		                   dependencies: (Dictionary with: 'org.example' -> { dependency }).

	self assert: descriptor equals: sameDescriptor.
	self deny: descriptor equals: otherDescriptor.
	self assert: descriptor hash equals: sameDescriptor hash
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testManagedProjectPropertiesRoundTripFromFile [

	| project loadedProject propertiesFile projects projectDependencies dependency |
	dependency := MooseNexusDependencyDescriptor
		              coordinates: (MooseNexusCoordinates group: nil name: 'dep' version: '2.0.0')
		              type: 'jar'
		              scopes: #( 'compile' )
		              path: 'repository/dep-2.0.0.jar'.
	projectDependencies := Dictionary with: 'org.example' -> { dependency }.
	projects := Dictionary with: 'com.example'
		            ->
		            (Dictionary with:
			             'demo' -> (MooseNexusManagedProjectDescriptor version: '1.0.0' path: nil dependencies: projectDependencies)).
	project := MooseNexusMavenProject coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0').
	project
		language: 'java';
		projects: projects;
		dependencies: #(  ).
	propertiesFile := rootDirectory / 'managed-properties.json'.
	propertiesFile writeStreamDo: [ :stream | project writePropertiesOn: stream ].

	loadedProject := MooseNexusProject fromProperties: propertiesFile.

	self assert: loadedProject class equals: MooseNexusMavenProject.
	self assert: loadedProject coordinates equals: project coordinates.
	self assert: loadedProject language equals: 'java'.
	self assert: loadedProject projects equals: project projects.
	self assert: loadedProject serializedProjects equals: project serializedProjects
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testProjectPropertiesFlattenCoordinates [

	| project properties |
	project := MooseNexusTestProject coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0').
	project dependencies: #(  ).
	properties := project properties.

	self assert: (properties at: #group) equals: 'com.example'.
	self assert: (properties at: #name) equals: 'demo'.
	self assert: (properties at: #version) equals: '1.0.0'.
	self deny: (properties includesKey: #coordinates)
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testProjectPropertiesIncludeSchemaVersion [

	| project properties |
	project := MooseNexusTestProject coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0').
	project dependencies: #(  ).
	properties := project properties.

	self assert: (properties at: #schemaVersion) equals: MooseNexusProject propertiesSchemaVersion
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testProjectPropertiesReadUnversionedDataAsCurrentSchema [

	| project properties |
	properties := Dictionary new
		              add: #group -> 'com.example';
		              add: #name -> 'demo';
		              add: #version -> '1.0.0';
		              yourself.

	project := MooseNexusTestProject new readProperties: properties.

	self assert: project coordinates equals: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0')
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testProjectPropertiesRejectUnsupportedSchemaVersion [

	| properties |
	properties := Dictionary new
		              add: #schemaVersion -> 'unsupported';
		              add: #group -> 'com.example';
		              add: #name -> 'demo';
		              add: #version -> '1.0.0';
		              yourself.

	self should: [ MooseNexusTestProject new readProperties: properties ] raise: Error
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testProjectPropertiesRoundTripFromFile [

	| project loadedProject propertiesFile dependency |
	project := MooseNexusTestProject coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0').
	dependency := MooseNexusDependencyDescriptor
		              coordinates: (MooseNexusCoordinates group: 'org.example' name: 'dep' version: '2.0.0')
		              type: 'jar'
		              scopes: #( 'compile' )
		              path: 'repository/dep-2.0.0.jar'.
	project dependencies: { dependency }.
	propertiesFile := rootDirectory / 'properties.json'.
	propertiesFile writeStreamDo: [ :stream | project writePropertiesOn: stream ].

	loadedProject := MooseNexusProject fromProperties: propertiesFile.

	self assert: loadedProject class equals: MooseNexusTestProject.
	self assert: loadedProject coordinates equals: project coordinates.
	self assert: loadedProject dependencies equals: project dependencies
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testProjectSpecHoldsRecordingIntent [

	| coordinates spec |
	coordinates := MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
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
	coordinates := MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	project := MooseNexusTestProject coordinates: coordinates.
	project directory: 'nexus/repository/com.example/demo/1.0.0'.

	self
		should: [ project initializeCoordinates: (MooseNexusCoordinates group: 'org.example' name: 'demo' version: '1.0.0') ]
		raise: Error
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testRepositoryCreatesLayoutBeforeRecordingProject [

	| project spec projectDirectory |
	project := MooseNexusTestProject new.
	spec := MooseNexusProjectSpec
		        coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0')
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
	coordinates := MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	spec := MooseNexusProjectSpec coordinates: coordinates sourceDirectory: sourceDirectory.
	recordedProject := repository recordLoadedProject: project describedBy: spec.

	self assert: recordedProject identicalTo: project.
	self assert: project coordinates equals: coordinates.
	self assert: project isRecorded.
	self assert: (repository directory / 'repository' / 'com.example' / 'demo' / '1.0.0' / 'properties.json') exists
]
