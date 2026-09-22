"
I map MooseNexus artifact coordinates to backend-agnostic OCI references.

The namespace and repository prefix form the configurable repository path below an OCI registry. Depending on the registry product, the namespace may correspond to a Harbor project, a Nexus repository path, an Artifactory repository, or another registry namespace. The default repository prefix is `moosenexus`; callers can choose another path or an empty prefix when their registry layout does not need that segment.
"
Class {
	#name : 'MooseNexusOciReferenceMapper',
	#superclass : 'Object',
	#instVars : [
		'registry',
		'namespace',
		'repositoryPrefix'
	],
	#category : 'MooseNexus-Artifact',
	#package : 'MooseNexus',
	#tag : 'Artifact'
}

{ #category : 'constants' }
MooseNexusOciReferenceMapper class >> defaultRepositoryPrefix [

	^ 'moosenexus'
]

{ #category : 'instance creation' }
MooseNexusOciReferenceMapper class >> registry: registryName namespace: namespaceName [

	^ self registry: registryName namespace: namespaceName repositoryPrefix: self defaultRepositoryPrefix
]

{ #category : 'instance creation' }
MooseNexusOciReferenceMapper class >> registry: registryName namespace: namespaceName repositoryPrefix: prefix [

	^ self new initializeRegistry: registryName namespace: namespaceName repositoryPrefix: prefix
]

{ #category : 'mapping' }
MooseNexusOciReferenceMapper >> coordinatesFromReference: reference [

	| referenceString referenceSegments coordinateSegments group nameAndVersion |
	referenceString := reference asString.
	(referenceString includes: $@) ifTrue: [ Error signal: 'Cannot infer MooseNexus coordinates from digest reference' ].

	referenceSegments := referenceString substrings: '/'.
	(self matchesRepositoryPathSegments: referenceSegments) ifFalse: [
		Error signal: 'OCI reference does not use this mapper''s configured repository layout' ].

	coordinateSegments := referenceSegments allButFirst: self repositoryPathSegments size.
	coordinateSegments size = 2 ifFalse: [ Error signal: 'OCI reference does not use this mapper''s configured repository layout' ].

	group := coordinateSegments first.
	nameAndVersion := coordinateSegments second.
	(nameAndVersion includes: $:) ifFalse: [ Error signal: 'OCI reference must include a version tag' ].

	^ MooseNexusCoordinates group: group name: (nameAndVersion copyUpTo: $:) version: (nameAndVersion copyAfterLast: $:)
]

{ #category : 'initialization' }
MooseNexusOciReferenceMapper >> initializeRegistry: registryName namespace: namespaceName [

	^ self initializeRegistry: registryName namespace: namespaceName repositoryPrefix: self class defaultRepositoryPrefix
]

{ #category : 'initialization' }
MooseNexusOciReferenceMapper >> initializeRegistry: registryName namespace: namespaceName repositoryPrefix: prefix [

	registry := registryName.
	namespace := namespaceName.
	repositoryPrefix := prefix
]

{ #category : 'private' }
MooseNexusOciReferenceMapper >> matchesRepositoryPathSegments: referenceSegments [

	| expectedSegments |
	expectedSegments := self repositoryPathSegments.
	^ referenceSegments size >= expectedSegments size and: [
		  (1 to: expectedSegments size) allSatisfy: [ :index | (referenceSegments at: index) = (expectedSegments at: index) ] ]
]

{ #category : 'accessing' }
MooseNexusOciReferenceMapper >> namespace [

	^ namespace
]

{ #category : 'private' }
MooseNexusOciReferenceMapper >> normalized: aString [

	^ String streamContents: [ :stream | self writeNormalized: aString on: stream ]
]

{ #category : 'private' }
MooseNexusOciReferenceMapper >> normalizedCharacter: aCharacter [

	^ (aCharacter isAlphaNumeric or: [ #( $- $_ $. ) includes: aCharacter ])
		  ifTrue: [ aCharacter asLowercase ]
		  ifFalse: [ $- ]
]

{ #category : 'private' }
MooseNexusOciReferenceMapper >> normalizedPathSegments: pathString [

	^ (pathString substrings: '/') collect: [ :segment | self normalized: segment ] as: Array
]

{ #category : 'mapping' }
MooseNexusOciReferenceMapper >> referenceFor: artifactCoordinates [

	^ String streamContents: [ :stream |
			  stream nextPutAll: registry.
			  self writeNormalizedPath: namespace on: stream.
			  self writeNormalizedPath: repositoryPrefix on: stream.
			  stream nextPut: $/.
			  self writeNormalized: artifactCoordinates group on: stream.
			  stream nextPut: $/.
			  self writeNormalized: artifactCoordinates projectCoordinates name on: stream.
			  stream nextPut: $:.
			  self writeNormalized: artifactCoordinates version on: stream ]
]

{ #category : 'accessing' }
MooseNexusOciReferenceMapper >> registry [

	^ registry
]

{ #category : 'private' }
MooseNexusOciReferenceMapper >> repositoryPathSegments [

	^ Array streamContents: [ :stream |
			  stream
				  nextPut: registry;
				  nextPutAll: (self normalizedPathSegments: namespace);
				  nextPutAll: (self normalizedPathSegments: repositoryPrefix) ]
]

{ #category : 'accessing' }
MooseNexusOciReferenceMapper >> repositoryPrefix [

	^ repositoryPrefix
]

{ #category : 'private' }
MooseNexusOciReferenceMapper >> writeNormalized: aString on: stream [

	aString asString do: [ :character | stream nextPut: (self normalizedCharacter: character) ]
]

{ #category : 'private' }
MooseNexusOciReferenceMapper >> writeNormalizedPath: pathString on: stream [

	| hasWrittenCharacter pendingSeparator |
	hasWrittenCharacter := false.
	pendingSeparator := true.

	pathString do: [ :character |
			character = $/
				ifTrue: [ hasWrittenCharacter ifTrue: [ pendingSeparator := true ] ]
				ifFalse: [
						pendingSeparator ifTrue: [
								stream nextPut: $/.
								pendingSeparator := false ].
						stream nextPut: (self normalizedCharacter: character).
						hasWrittenCharacter := true ] ]
]
