"
I describe a resolved dependency used by MooseNexus when building models.

I carry the dependency coordinates and artifact metadata that used to be passed around as dictionaries: group, name, version, type, scopes, and the local artifact path.

MooseNexus uses me internally as a value-like object. Repository serialization writes dictionaries at the boundary with a #scopes collection so the same dependency can belong to multiple scopes without becoming multiple dependencies.
"
Class {
	#name : 'MooseNexusDependencyDescriptor',
	#superclass : 'Object',
	#instVars : [
		'group',
		'name',
		'version',
		'type',
		'path',
		'scopes'
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
		  scopes: (anArray at: 5 ifAbsent: [ #(  ) ])
		  path: (anArray at: 6 ifAbsent: [ nil ])
]

{ #category : 'instance creation' }
MooseNexusDependencyDescriptor class >> fromDictionary: aDictionary [

	^ self
		  group: (aDictionary at: #group ifAbsent: [ aDictionary at: 'group' ifAbsent: [ nil ] ])
		  name: (aDictionary at: #name ifAbsent: [ aDictionary at: 'name' ])
		  version: (aDictionary at: #version ifAbsent: [ aDictionary at: 'version' ])
		  type: (aDictionary at: #type ifAbsent: [ aDictionary at: 'type' ifAbsent: [ nil ] ])
		  scopes: (aDictionary at: #scopes ifAbsent: [ aDictionary at: 'scopes' ])
		  path: (aDictionary at: #path ifAbsent: [ aDictionary at: 'path' ifAbsent: [ nil ] ])
]

{ #category : 'instance creation' }
MooseNexusDependencyDescriptor class >> group: aGroup name: aName version: aVersion type: aType scopes: aCollection path: aPath [

	^ self new
		  initializeGroup: aGroup
		  name: aName
		  version: aVersion
		  type: aType
		  scopes: aCollection
		  path: aPath;
		  yourself
]

{ #category : 'comparing' }
MooseNexusDependencyDescriptor >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ anObject group = group and: [
			  anObject name = name and: [
				  anObject version = version and: [ anObject type = type and: [ anObject scopes = scopes and: [ anObject path = path ] ] ] ] ]
]

{ #category : 'converting' }
MooseNexusDependencyDescriptor >> asDictionary [

	| dictionary |
	dictionary := Dictionary
		              with: #name -> name
		              with: #version -> version
		              with: #type -> type
		              with: #scopes -> scopes
		              with: #path -> path.
	group ifNotNil: [ dictionary at: #group put: group ].
	^ dictionary
]

{ #category : 'accessing' }
MooseNexusDependencyDescriptor >> group [

	^ group
]

{ #category : 'comparing' }
MooseNexusDependencyDescriptor >> hasSameArtifactAs: anotherDescriptor [

	^ anotherDescriptor group = group and: [
			  anotherDescriptor name = name and: [
				  anotherDescriptor version = version and: [ anotherDescriptor type = type and: [ anotherDescriptor path = path ] ] ] ]
]

{ #category : 'comparing' }
MooseNexusDependencyDescriptor >> hash [

	^ group hash bitXor: (name hash bitXor: (version hash bitXor: (type hash bitXor: (scopes hash bitXor: path hash))))
]

{ #category : 'initialization' }
MooseNexusDependencyDescriptor >> initializeGroup: aGroup name: aName version: aVersion type: aType scopes: aCollection path: aPath [

	group := aGroup.
	name := aName.
	version := aVersion.
	type := aType.
	scopes := self normalizeScopes: aCollection.
	path := aPath
]

{ #category : 'copying' }
MooseNexusDependencyDescriptor >> mergedWith: anotherDescriptor [

	(self hasSameArtifactAs: anotherDescriptor) ifFalse: [ Error signal: 'Cannot merge different dependency artifacts' ].
	^ self withScopes: scopes , anotherDescriptor scopes
]

{ #category : 'accessing' }
MooseNexusDependencyDescriptor >> name [

	^ name
]

{ #category : 'private' }
MooseNexusDependencyDescriptor >> normalizeScopes: aCollection [

	| normalizedScopes |
	aCollection ifNil: [ ^ #(  ) ].
	normalizedScopes := OrderedCollection new.
	(aCollection isString
		 ifTrue: [ { aCollection } ]
		 ifFalse: [ aCollection ]) do: [ :scope |
		(scope notNil and: [ (normalizedScopes includes: scope) not ]) ifTrue: [ normalizedScopes add: scope ] ].
	^ normalizedScopes asArray
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
MooseNexusDependencyDescriptor >> scopes [

	^ scopes
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
		  scopes: scopes
		  path: path
]

{ #category : 'copying' }
MooseNexusDependencyDescriptor >> withScopes: aCollection [

	^ self class
		  group: group
		  name: name
		  version: version
		  type: type
		  scopes: aCollection
		  path: path
]
