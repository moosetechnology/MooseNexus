Class {
	#name : 'NexusProjectCoordinates',
	#superclass : 'Object',
	#instVars : [
		'group',
		'name',
		'version'
	],
	#category : 'MooseNexus-Project',
	#package : 'MooseNexus',
	#tag : 'Project'
}

{ #category : 'instance creation' }
NexusProjectCoordinates class >> group: aGroup name: aName version: aVersion [

	^ self new initializeGroup: aGroup name: aName version: aVersion
]

{ #category : 'comparing' }
NexusProjectCoordinates >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class = self class ifFalse: [ ^ false ].
	^ anObject group = group and: [ anObject name = name and: [ anObject version = version ] ]
]

{ #category : 'accessing' }
NexusProjectCoordinates >> group [

	^ group
]

{ #category : 'comparing' }
NexusProjectCoordinates >> hash [

	^ group hash bitXor: (name hash bitXor: version hash)
]

{ #category : 'initialization' }
NexusProjectCoordinates >> initializeGroup: aGroup name: aName version: aVersion [

	group := aGroup.
	name := aName.
	version := aVersion
]

{ #category : 'accessing' }
NexusProjectCoordinates >> name [

	^ name
]

{ #category : 'printing' }
NexusProjectCoordinates >> printOn: aStream [

	aStream
		nextPutAll: group;
		nextPut: $:;
		nextPutAll: name;
		nextPut: $:;
		nextPutAll: version
]

{ #category : 'accessing' }
NexusProjectCoordinates >> version [

	^ version
]
