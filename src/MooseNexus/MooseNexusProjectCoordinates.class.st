"
I am the stable identity of a MooseNexus project.

I identify the source project as modeled by MooseNexus, using Maven-like group, name, and version components. These coordinates are used for equality, hashing, printing, and repository path decisions.

I am value-like: create a new instance when a project should have different coordinates instead of mutating an existing one.
"
Class {
	#name : 'MooseNexusProjectCoordinates',
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
MooseNexusProjectCoordinates class >> group: aGroup name: aName version: aVersion [

	^ self new initializeGroup: aGroup name: aName version: aVersion
]

{ #category : 'comparing' }
MooseNexusProjectCoordinates >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ anObject group = group and: [ anObject name = name and: [ anObject version = version ] ]
]

{ #category : 'accessing' }
MooseNexusProjectCoordinates >> group [

	^ group
]

{ #category : 'comparing' }
MooseNexusProjectCoordinates >> hash [

	^ group hash bitXor: (name hash bitXor: version hash)
]

{ #category : 'initialization' }
MooseNexusProjectCoordinates >> initializeGroup: aGroup name: aName version: aVersion [

	group := aGroup.
	name := aName.
	version := aVersion
]

{ #category : 'accessing' }
MooseNexusProjectCoordinates >> name [

	^ name
]

{ #category : 'printing' }
MooseNexusProjectCoordinates >> printOn: aStream [

	aStream
		nextPutAll: group;
		nextPut: $:;
		nextPutAll: name;
		nextPut: $:;
		nextPutAll: version
]

{ #category : 'accessing' }
MooseNexusProjectCoordinates >> version [

	^ version
]
