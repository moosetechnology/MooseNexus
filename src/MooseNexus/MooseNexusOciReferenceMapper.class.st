"
I map MooseNexus artifact coordinates to Harbor OCI references.
"
Class {
	#name : 'MooseNexusOciReferenceMapper',
	#superclass : 'Object',
	#instVars : [
		'registry',
		'harborProject'
	],
	#category : 'MooseNexus-Artifact',
	#package : 'MooseNexus',
	#tag : 'Artifact'
}

{ #category : 'instance creation' }
MooseNexusOciReferenceMapper class >> registry: registryName harborProject: projectName [

	^ self new initializeRegistry: registryName harborProject: projectName
]

{ #category : 'accessing' }
MooseNexusOciReferenceMapper >> harborProject [

	^ harborProject
]

{ #category : 'initialization' }
MooseNexusOciReferenceMapper >> initializeRegistry: registryName harborProject: projectName [

	registry := registryName.
	harborProject := projectName
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
				  nextPutAll: (self normalized: harborProject);
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
