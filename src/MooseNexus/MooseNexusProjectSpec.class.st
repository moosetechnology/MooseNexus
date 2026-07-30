"
I describe the intent to import and record a source project in MooseNexus.

I am configuration, not a recorded project. A MooseNexusProjectSpec carries the source directory and coordinates chosen before repository recording starts. The repository uses me to create a MooseNexusProject and then records that project.
"
Class {
	#name : 'MooseNexusProjectSpec',
	#superclass : 'Object',
	#instVars : [
		'coordinates',
		'sourceDirectory'
	],
	#category : 'MooseNexus-Project',
	#package : 'MooseNexus',
	#tag : 'Project'
}

{ #category : 'instance creation' }
MooseNexusProjectSpec class >> coordinates: coordinates sourceDirectory: sourceDirectory [

	^ self new
		  coordinates: coordinates;
		  sourceDirectory: sourceDirectory;
		  yourself
]

{ #category : 'instance creation' }
MooseNexusProjectSpec class >> group: group projectName: projectName version: version sourceDirectory: sourceDirectory [

	^ self
		  coordinates: (MooseNexusProjectCoordinates group: group name: projectName version: version)
		  sourceDirectory: sourceDirectory
]

{ #category : 'accessing' }
MooseNexusProjectSpec >> coordinates [

	^ coordinates
]

{ #category : 'accessing' }
MooseNexusProjectSpec >> coordinates: aMooseNexusProjectCoordinates [

	coordinates := aMooseNexusProjectCoordinates
]

{ #category : 'accessing' }
MooseNexusProjectSpec >> group [

	^ self coordinates group
]

{ #category : 'importing' }
MooseNexusProjectSpec >> importProject [

	self validateForRecording.
	^ (MooseNexusProjectImporter fromDirectory: sourceDirectory pathString) importWithCoordinates: coordinates
]

{ #category : 'accessing' }
MooseNexusProjectSpec >> name [

	^ self coordinates name
]

{ #category : 'accessing' }
MooseNexusProjectSpec >> sourceDirectory [

	^ sourceDirectory
]

{ #category : 'accessing' }
MooseNexusProjectSpec >> sourceDirectory: aFileReference [

	sourceDirectory := aFileReference asFileReference
]

{ #category : 'validating' }
MooseNexusProjectSpec >> validateForRecording [

	coordinates ifNil: [ Error signal: 'Cannot record a MooseNexus project without project coordinates' ].
	sourceDirectory ifNil: [ Error signal: 'Cannot record a MooseNexus project without a source directory' ].
	sourceDirectory exists ifFalse: [
		Error signal: 'Cannot record a MooseNexus project from missing source directory: ' , sourceDirectory pathString ].
	sourceDirectory isDirectory ifFalse: [
		Error signal: 'Cannot record a MooseNexus project from a file: ' , sourceDirectory pathString ]
]

{ #category : 'accessing' }
MooseNexusProjectSpec >> version [

	^ self coordinates version
]
