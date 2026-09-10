"
I describe a dependency on another source project managed in the same workspace.

I preserve the target coordinates and declared scopes without claiming that the target is a local repository artifact. Build-tool importers use me for source-module relationships; external artifact dependencies remain MooseNexusDependencyDescriptor instances.
"
Class {
	#name : 'MooseNexusWorkspaceDependencyDescriptor',
	#superclass : 'Object',
	#instVars : [
		'coordinates',
		'scopes'
	],
	#category : 'MooseNexus-Dependency',
	#package : 'MooseNexus',
	#tag : 'Dependency'
}

{ #category : 'instance creation' }
MooseNexusWorkspaceDependencyDescriptor class >> coordinates: aMooseNexusCoordinates scopes: aCollection [

	^ self new initializeCoordinates: aMooseNexusCoordinates scopes: aCollection
]

{ #category : 'instance creation' }
MooseNexusWorkspaceDependencyDescriptor class >> fromDictionary: aDictionary [

	^ self
		  coordinates: (MooseNexusCoordinates
				   group: (aDictionary at: #group ifAbsent: [ nil ])
				   name: (aDictionary at: #name)
				   version: (aDictionary at: #version))
		  scopes: (aDictionary at: #scopes)
]

{ #category : 'comparing' }
MooseNexusWorkspaceDependencyDescriptor >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ anObject coordinates = coordinates and: [ anObject scopes = scopes ]
]

{ #category : 'converting' }
MooseNexusWorkspaceDependencyDescriptor >> asDictionary [

	| dictionary |
	dictionary := Dictionary with: #name -> self name with: #version -> self version with: #scopes -> scopes copy.
	self group ifNotNil: [ :group | dictionary at: #group put: group ].
	^ dictionary
]

{ #category : 'accessing' }
MooseNexusWorkspaceDependencyDescriptor >> coordinates [

	^ coordinates
]

{ #category : 'accessing' }
MooseNexusWorkspaceDependencyDescriptor >> group [

	^ coordinates group
]

{ #category : 'comparing' }
MooseNexusWorkspaceDependencyDescriptor >> hash [

	^ coordinates hash bitXor: scopes hash
]

{ #category : 'initialization' }
MooseNexusWorkspaceDependencyDescriptor >> initializeCoordinates: aMooseNexusCoordinates scopes: aCollection [

	coordinates := aMooseNexusCoordinates.
	scopes := self normalizeScopes: aCollection
]

{ #category : 'accessing' }
MooseNexusWorkspaceDependencyDescriptor >> name [

	^ coordinates name
]

{ #category : 'private' }
MooseNexusWorkspaceDependencyDescriptor >> normalizeScopes: aCollection [

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

{ #category : 'printing' }
MooseNexusWorkspaceDependencyDescriptor >> printOn: aStream [

	coordinates printOn: aStream
]

{ #category : 'accessing' }
MooseNexusWorkspaceDependencyDescriptor >> scopes [

	^ scopes
]

{ #category : 'accessing' }
MooseNexusWorkspaceDependencyDescriptor >> version [

	^ coordinates version
]
