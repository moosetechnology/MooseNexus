"
I describe a resolved dependency used by MooseNexus when building models.

I carry the dependency coordinates, artifact metadata, scopes, and local artifact path. The coordinates identify the dependency module; type identifies the selected artifact shape; scopes describe where the dependency is used; path records the resolved local artifact.

MooseNexus uses me internally as a value-like object. Repository serialization writes flat dictionaries at the boundary so properties files remain easy to inspect.
"
Class {
	#name : 'MooseNexusDependencyDescriptor',
	#superclass : 'Object',
	#instVars : [
		'coordinates',
		'type',
		'path',
		'scopes'
	],
	#category : 'MooseNexus-Dependency',
	#package : 'MooseNexus',
	#tag : 'Dependency'
}

{ #category : 'instance creation' }
MooseNexusDependencyDescriptor class >> coordinates: aMooseNexusCoordinates type: aType scopes: aCollection path: aPath [

	^ self new
		  initializeCoordinates: aMooseNexusCoordinates
		  type: aType
		  scopes: aCollection
		  path: aPath;
		  yourself
]

{ #category : 'instance creation' }
MooseNexusDependencyDescriptor class >> fromDictionary: aDictionary [

	^ self
		  coordinates: (MooseNexusCoordinates
				   group: (aDictionary at: #group ifAbsent: [ aDictionary at: 'group' ifAbsent: [ nil ] ])
				   name: (aDictionary at: #name ifAbsent: [ aDictionary at: 'name' ])
				   version: (aDictionary at: #version ifAbsent: [ aDictionary at: 'version' ]))
		  type: (aDictionary at: #type ifAbsent: [ aDictionary at: 'type' ifAbsent: [ nil ] ])
		  scopes: (aDictionary at: #scopes ifAbsent: [ aDictionary at: 'scopes' ])
		  path: (aDictionary at: #path ifAbsent: [ aDictionary at: 'path' ifAbsent: [ nil ] ])
]

{ #category : 'comparing' }
MooseNexusDependencyDescriptor >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ anObject coordinates = coordinates and: [ anObject type = type and: [ anObject scopes = scopes and: [ anObject path = path ] ] ]
]

{ #category : 'converting' }
MooseNexusDependencyDescriptor >> asDictionary [

	| dictionary |
	dictionary := Dictionary
		              with: #name -> self name
		              with: #version -> self version
		              with: #type -> type
		              with: #scopes -> scopes
		              with: #path -> path.
	self group ifNotNil: [ :group | dictionary at: #group put: group ].
	^ dictionary
]

{ #category : 'accessing' }
MooseNexusDependencyDescriptor >> coordinates [

	^ coordinates
]

{ #category : 'accessing' }
MooseNexusDependencyDescriptor >> group [

	^ coordinates group
]

{ #category : 'comparing' }
MooseNexusDependencyDescriptor >> hasSameArtifactAs: anotherDescriptor [

	^ anotherDescriptor coordinates = coordinates and: [ anotherDescriptor type = type and: [ anotherDescriptor path = path ] ]
]

{ #category : 'comparing' }
MooseNexusDependencyDescriptor >> hash [

	^ coordinates hash bitXor: (type hash bitXor: (scopes hash bitXor: path hash))
]

{ #category : 'initialization' }
MooseNexusDependencyDescriptor >> initializeCoordinates: aMooseNexusCoordinates type: aType scopes: aCollection path: aPath [

	coordinates := aMooseNexusCoordinates.
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

	^ coordinates name
]

{ #category : 'private' }
MooseNexusDependencyDescriptor >> normalizeScopes: aCollection [

	| normalizedScopes seenScopes |
	aCollection ifNil: [ ^ #(  ) ].
	normalizedScopes := OrderedCollection new.
	seenScopes := Set new.
	(aCollection isString
		 ifTrue: [ { aCollection } ]
		 ifFalse: [ aCollection ]) do: [ :scope |
			(scope notNil and: [ (seenScopes includes: scope) not ]) ifTrue: [
					seenScopes add: scope.
					normalizedScopes add: scope ] ].
	^ normalizedScopes asArray
]

{ #category : 'accessing' }
MooseNexusDependencyDescriptor >> path [

	^ path
]

{ #category : 'printing' }
MooseNexusDependencyDescriptor >> printOn: aStream [

	coordinates printOn: aStream
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

	^ coordinates version
]

{ #category : 'copying' }
MooseNexusDependencyDescriptor >> withGroup: aGroup [

	^ self class
		  coordinates: (MooseNexusCoordinates group: aGroup name: self name version: self version)
		  type: type
		  scopes: scopes
		  path: path
]

{ #category : 'copying' }
MooseNexusDependencyDescriptor >> withScopes: aCollection [

	^ self class
		  coordinates: coordinates
		  type: type
		  scopes: aCollection
		  path: path
]
