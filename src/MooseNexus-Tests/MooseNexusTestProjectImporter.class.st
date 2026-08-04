"
I am a test importer used to exercise build-spec planning without invoking Maven or Gradle.
"
Class {
	#name : 'MooseNexusTestProjectImporter',
	#superclass : 'MooseNexusProjectImporter',
	#category : 'MooseNexus-Tests',
	#package : 'MooseNexus-Tests'
}

{ #category : 'testing' }
MooseNexusTestProjectImporter class >> canHandle: directory [

	^ (directory asFileReference / '.moosenexus-test') exists
]

{ #category : 'importing' }
MooseNexusTestProjectImporter >> import [

	^ self importWithCoordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0')
]

{ #category : 'importing' }
MooseNexusTestProjectImporter >> importWithCoordinates: aMooseNexusCoordinates [

	project ifNil: [ project := self newProject ].
	project initializeCoordinates: aMooseNexusCoordinates.
	project dependencies: #(  ).
	^ project
]

{ #category : 'instance creation' }
MooseNexusTestProjectImporter >> newProject [

	^ MooseNexusTestProject new
]
