"
I map MooseNexus artifact coordinates to backend-agnostic OCI references.

The namespace is the repository path prefix inside an OCI registry. Depending on the registry product this may correspond to a Harbor project, a Nexus repository path, an Artifactory repository, or another registry namespace.
"
Class {
	#name : 'MooseNexusOciReferenceMapper',
	#superclass : 'Object',
	#instVars : [
		'registry',
		'namespace'
	],
	#category : 'MooseNexus-Artifact',
	#package : 'MooseNexus',
	#tag : 'Artifact'
}

{ #category : 'instance creation' }
MooseNexusOciReferenceMapper class >> registry: registryName namespace: namespaceName [

	^ self new initializeRegistry: registryName namespace: namespaceName
]

{ #category : 'mapping' }
MooseNexusOciReferenceMapper >> coordinatesFromReference: reference [

	| referenceString segments markerIndex group nameAndVersion |
	referenceString := reference asString.
	(referenceString includes: $@) ifTrue: [ Error signal: 'Cannot infer MooseNexus coordinates from digest reference' ].
	segments := referenceString substrings: '/'.
	markerIndex := segments indexOf: 'moosenexus'.
	(markerIndex = 0 or: [ markerIndex + 2 > segments size ]) ifTrue: [
		Error signal: 'OCI reference does not use the MooseNexus path layout' ].
	group := segments at: markerIndex + 1.
	nameAndVersion := segments at: markerIndex + 2.
	(nameAndVersion includes: $:) ifFalse: [ Error signal: 'OCI reference must include a version tag' ].
	^ MooseNexusCoordinates group: group name: (nameAndVersion copyUpTo: $:) version: (nameAndVersion copyAfterLast: $:)
]

{ #category : 'initialization' }
MooseNexusOciReferenceMapper >> initializeRegistry: registryName namespace: namespaceName [

	registry := registryName.
	namespace := namespaceName
]

{ #category : 'accessing' }
MooseNexusOciReferenceMapper >> namespace [

	^ namespace
]

{ #category : 'private' }
MooseNexusOciReferenceMapper >> normalized: aString [

	^ String streamContents: [ :stream |
			  aString asString do: [ :character |
					  (character isAlphaNumeric or: [ '.-_' includes: character ])
						  ifTrue: [ stream nextPut: character asLowercase ]
						  ifFalse: [ stream nextPut: $- ] ] ]
]

{ #category : 'mapping' }
MooseNexusOciReferenceMapper >> referenceFor: artifactCoordinates [

	^ String streamContents: [ :stream |
			  stream
				  nextPutAll: registry;
				  nextPut: $/;
				  nextPutAll: (self normalized: namespace);
				  nextPutAll: '/moosenexus/';
				  nextPutAll: (self normalized: artifactCoordinates group);
				  nextPut: $/;
				  nextPutAll: (self normalized: artifactCoordinates projectCoordinates name);
				  nextPut: $:;
				  nextPutAll: (self normalized: artifactCoordinates version) ]
]

{ #category : 'accessing' }
MooseNexusOciReferenceMapper >> registry [

	^ registry
]
