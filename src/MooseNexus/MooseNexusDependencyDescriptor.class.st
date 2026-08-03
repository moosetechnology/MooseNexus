"
I describe a resolved dependency used by MooseNexus when building models.

I carry the dependency coordinates and artifact metadata that used to be passed around as dictionaries: group, name, version, type, scope, and the local artifact path.

MooseNexus uses me internally as a value-like object. Repository serialization still writes dictionaries at the boundary so existing properties files keep their current shape.
"
Class {
	#name : 'MooseNexusDependencyDescriptor',
	#superclass : 'Object',
	#instVars : [
		'group',
		'name',
		'version',
		'type',
		'scope',
		'path'
	],
	#category : 'MooseNexus-Dependency',
	#package : 'MooseNexus',
	#tag : 'Dependency'
}

{ #category : 'instance creation' }
MooseNexusDependencyDescriptor class >> fromArray: anArray [

	^ self
		  group: (anArray at: 1 ifAbsent: [ nil ])
		  name: (anArray at: 2)
		  version: (anArray at: 3)
		  type: (anArray at: 4 ifAbsent: [ nil ])
		  scope: (anArray at: 5 ifAbsent: [ nil ])
		  path: (anArray at: 6 ifAbsent: [ nil ])
]

{ #category : 'instance creation' }
MooseNexusDependencyDescriptor class >> fromDictionary: aDictionary [

	^ self
		  group: (aDictionary at: #group ifAbsent: [ aDictionary at: 'group' ifAbsent: [ nil ] ])
		  name: (aDictionary at: #name ifAbsent: [ aDictionary at: 'name' ])
		  version: (aDictionary at: #version ifAbsent: [ aDictionary at: 'version' ])
		  type: (aDictionary at: #type ifAbsent: [ aDictionary at: 'type' ifAbsent: [ nil ] ])
		  scope: (aDictionary at: #scope ifAbsent: [ aDictionary at: 'scope' ifAbsent: [ nil ] ])
		  path: (aDictionary at: #path ifAbsent: [ aDictionary at: 'path' ifAbsent: [ nil ] ])
]

{ #category : 'instance creation' }
MooseNexusDependencyDescriptor class >> group: aGroup name: aName version: aVersion type: aType scope: aScope path: aPath [

	^ self new
		  initializeGroup: aGroup
		  name: aName
		  version: aVersion
		  type: aType
		  scope: aScope
		  path: aPath;
		  yourself
]

{ #category : 'comparing' }
MooseNexusDependencyDescriptor >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ anObject group = group and: [
			  anObject name = name and: [
				  anObject version = version and: [ anObject type = type and: [ anObject scope = scope and: [ anObject path = path ] ] ] ] ]
]

{ #category : 'converting' }
MooseNexusDependencyDescriptor >> asDictionary [

	| dictionary |
	dictionary := Dictionary
		              with: #name -> name
		              with: #version -> version
		              with: #type -> type
		              with: #scope -> scope
		              with: #path -> path.
	group ifNotNil: [ dictionary at: #group put: group ].
	^ dictionary
]

{ #category : 'accessing' }
MooseNexusDependencyDescriptor >> group [

	^ group
]

{ #category : 'comparing' }
MooseNexusDependencyDescriptor >> hash [

	^ group hash bitXor: (name hash bitXor: (version hash bitXor: (type hash bitXor: (scope hash bitXor: path hash))))
]

{ #category : 'initialization' }
MooseNexusDependencyDescriptor >> initializeGroup: aGroup name: aName version: aVersion type: aType scope: aScope path: aPath [

	group := aGroup.
	name := aName.
	version := aVersion.
	type := aType.
	scope := aScope.
	path := aPath
]

{ #category : 'accessing' }
MooseNexusDependencyDescriptor >> name [

	^ name
]

{ #category : 'accessing' }
MooseNexusDependencyDescriptor >> path [

	^ path
]

{ #category : 'printing' }
MooseNexusDependencyDescriptor >> printOn: aStream [

	group ifNotNil: [ :theGroup |
			aStream
				nextPutAll: theGroup;
				nextPut: $: ].
	aStream
		nextPutAll: name;
		nextPut: $:;
		nextPutAll: version
]

{ #category : 'accessing' }
MooseNexusDependencyDescriptor >> scope [

	^ scope
]

{ #category : 'accessing' }
MooseNexusDependencyDescriptor >> type [

	^ type
]

{ #category : 'accessing' }
MooseNexusDependencyDescriptor >> version [

	^ version
]

{ #category : 'copying' }
MooseNexusDependencyDescriptor >> withGroup: aGroup [

	^ self class
		  group: aGroup
		  name: name
		  version: version
		  type: type
		  scope: scope
		  path: path
]
