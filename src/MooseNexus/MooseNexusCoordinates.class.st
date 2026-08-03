"
I am the stable coordinates of a versioned MooseNexus artifact.

I identify a project or dependency by group, name, and version. These coordinates are used for equality, hashing, printing, and repository path decisions.

I am value-like: create a new instance when an artifact should have different coordinates instead of mutating an existing one.
"
Class {
	#name : 'MooseNexusCoordinates',
	#superclass : 'Object',
	#instVars : [
		'group',
		'name',
		'version'
	],
	#category : 'MooseNexus-Artifact',
	#package : 'MooseNexus',
	#tag : 'Artifact'
}

{ #category : 'instance creation' }
MooseNexusCoordinates class >> group: aGroup name: aName version: aVersion [

	^ self new initializeGroup: aGroup name: aName version: aVersion
]

{ #category : 'comparing' }
MooseNexusCoordinates >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ anObject group = group and: [ anObject name = name and: [ anObject version = version ] ]
]

{ #category : 'accessing' }
MooseNexusCoordinates >> group [

	^ group
]

{ #category : 'comparing' }
MooseNexusCoordinates >> hash [

	^ group hash bitXor: (name hash bitXor: version hash)
]

{ #category : 'initialization' }
MooseNexusCoordinates >> initializeGroup: aGroup name: aName version: aVersion [

	group := aGroup.
	name := aName.
	version := aVersion
]

{ #category : 'accessing' }
MooseNexusCoordinates >> name [

	^ name
]

{ #category : 'printing' }
MooseNexusCoordinates >> printOn: aStream [

	aStream
		nextPutAll: group;
		nextPut: $:;
		nextPutAll: name;
		nextPut: $:;
		nextPutAll: version
]

{ #category : 'accessing' }
MooseNexusCoordinates >> version [

	^ version
]
