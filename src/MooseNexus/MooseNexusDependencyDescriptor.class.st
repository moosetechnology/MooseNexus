"
I describe a pathless external dependency reference used by MooseNexus when building models.

I carry artifact coordinates, type, and scopes. Managed build-tool importers create me without downloading an artifact; their project materializes me lazily when the extractor classpath requires it. Explicit local artifacts use MooseNexusLocalDependencyDescriptor instead.

Repository serialization writes a portable dictionary without a machine-local path.
"
Class {
	#name : 'MooseNexusDependencyDescriptor',
	#superclass : 'Object',
	#instVars : [
		'coordinates',
		'type',
		'scopes'
	],
	#category : 'MooseNexus-Dependency',
	#package : 'MooseNexus',
	#tag : 'Dependency'
}

{ #category : 'testing' }
MooseNexusDependencyDescriptor class >> canReadDictionary: aDictionary [

	^ false
]

{ #category : 'instance creation' }
MooseNexusDependencyDescriptor class >> coordinates: aMooseNexusCoordinates type: aType scopes: aCollection [

	^ self new initializeCoordinates: aMooseNexusCoordinates type: aType scopes: aCollection
]

{ #category : 'instance creation' }
MooseNexusDependencyDescriptor class >> coordinates: aMooseNexusCoordinates type: aType scopes: aCollection path: aPath [

	aPath ifNil: [ ^ self coordinates: aMooseNexusCoordinates type: aType scopes: aCollection ].
	^ MooseNexusLocalDependencyDescriptor
		  coordinates: aMooseNexusCoordinates
		  type: aType
		  scopes: aCollection
		  path: aPath
]

{ #category : 'instance creation' }
MooseNexusDependencyDescriptor class >> fromDictionary: aDictionary [

	self allSubclassesDo: [ :subclass | (subclass canReadDictionary: aDictionary) ifTrue: [ ^ subclass fromDictionary: aDictionary ] ].
	(aDictionary includesKey: 'ecosystem') ifTrue: [
		Error signal: 'No loaded MooseNexus dependency extension for ecosystem: ' , (aDictionary at: 'ecosystem') ].
	^ self fromGenericDictionary: aDictionary
]

{ #category : 'instance creation' }
MooseNexusDependencyDescriptor class >> fromGenericDictionary: aDictionary [

	| coordinates path |
	coordinates := MooseNexusCoordinates
		               group: (aDictionary at: #group ifAbsent: [ nil ])
		               name: (aDictionary at: #name)
		               version: (aDictionary at: #version).
	path := aDictionary at: #path ifAbsent: [ nil ].
	path ifNotNil: [
			^ MooseNexusLocalDependencyDescriptor
				  coordinates: coordinates
				  type: (aDictionary at: #type ifAbsent: [ nil ])
				  scopes: (aDictionary at: #scopes)
				  path: path ].
	^ self coordinates: coordinates type: (aDictionary at: #type ifAbsent: [ nil ]) scopes: (aDictionary at: #scopes)
]

{ #category : 'comparing' }
MooseNexusDependencyDescriptor >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ anObject coordinates = coordinates and: [ anObject type = type and: [ anObject scopes = scopes ] ]
]

{ #category : 'comparing' }
MooseNexusDependencyDescriptor >> artifactIdentity [

	^ {
		  coordinates.
		  type }
]

{ #category : 'converting' }
MooseNexusDependencyDescriptor >> asDictionary [

	| dictionary |
	dictionary := Dictionary
		              with: #name -> self name
		              with: #version -> self version
		              with: #type -> type
		              with: #scopes -> scopes copy.
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

	^ self artifactIdentity = anotherDescriptor artifactIdentity
]

{ #category : 'comparing' }
MooseNexusDependencyDescriptor >> hash [

	^ coordinates hash bitXor: (type hash bitXor: scopes hash)
]

{ #category : 'initialization' }
MooseNexusDependencyDescriptor >> initializeCoordinates: aMooseNexusCoordinates type: aType scopes: aCollection [

	coordinates := aMooseNexusCoordinates.
	type := aType.
	scopes := self normalizeScopes: aCollection
]

{ #category : 'testing' }
MooseNexusDependencyDescriptor >> isLocal [

	^ false
]

{ #category : 'building' }
MooseNexusDependencyDescriptor >> materializationFileName [
	"Answer an injective, filesystem-safe staging filename for this dependency reference."

	^ String streamContents: [ :stream |
			  {
				  (self group ifNil: [ '' ]).
				  self name.
				  self version } do: [ :component | stream << component size asString << '-' << component ].
			  stream << '.' << self type ]
]

{ #category : 'building' }
MooseNexusDependencyDescriptor >> materializeInto: dependenciesDirectory using: project [

	^ project materializeRemoteDependency: self into: dependenciesDirectory
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

{ #category : 'printing' }
MooseNexusDependencyDescriptor >> printOn: aStream [

	coordinates printOn: aStream
]

{ #category : 'accessing' }
MooseNexusDependencyDescriptor >> scopes [

	^ scopes
]

{ #category : 'capabilities' }
MooseNexusDependencyDescriptor >> supportsClasspathMaterialization [

	^ true
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

	^ self class coordinates: (MooseNexusCoordinates group: aGroup name: self name version: self version) type: type scopes: scopes
]

{ #category : 'copying' }
MooseNexusDependencyDescriptor >> withScopes: aCollection [

	^ self class coordinates: coordinates type: type scopes: aCollection
]
