"
I describe one produced model artifact for a MooseNexus project.

I carry model artifact coordinates, repository-relative model path, user comment, and creation timestamp. The coordinates keep the source project coordinates plus model-specific dimensions such as format, metamodel, and classifier. MooseNexusModelArtifactManifest embeds me in models.json together with build context, generated-file checksums, and dependency-resolution data.
"
Class {
	#name : 'MooseNexusModelArtifact',
	#superclass : 'Object',
	#instVars : [
		'artifactCoordinates',
		'path',
		'comment',
		'timestamp'
	],
	#category : 'MooseNexus-Artifact',
	#package : 'MooseNexus',
	#tag : 'Artifact'
}

{ #category : 'instance creation' }
MooseNexusModelArtifact class >> artifactCoordinates: aMooseNexusModelArtifactCoordinates path: aPath comment: aComment timestamp: aTimestamp [

	^ self new
		  initializeArtifactCoordinates: aMooseNexusModelArtifactCoordinates
		  path: aPath
		  comment: aComment
		  timestamp: aTimestamp
]

{ #category : 'instance creation' }
MooseNexusModelArtifact class >> fromDictionary: aDictionary [

	^ self
		  artifactCoordinates: (MooseNexusModelArtifactCoordinates fromDictionary: (aDictionary at: 'artifactCoordinates'))
		  path: (aDictionary at: 'path')
		  comment: (aDictionary at: 'comment')
		  timestamp: (aDictionary at: 'timestamp')
]

{ #category : 'comparing' }
MooseNexusModelArtifact >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ anObject artifactCoordinates = artifactCoordinates and: [
		  anObject path = path and: [ anObject comment = comment and: [ anObject timestamp = timestamp ] ] ]
]

{ #category : 'accessing' }
MooseNexusModelArtifact >> artifactCoordinates [

	^ artifactCoordinates
]

{ #category : 'converting' }
MooseNexusModelArtifact >> asDictionary [

	^ Dictionary new
		  add: 'artifactCoordinates' -> artifactCoordinates asDictionary;
		  add: 'path' -> path;
		  add: 'comment' -> comment;
		  add: 'timestamp' -> timestamp;
		  yourself
]

{ #category : 'accessing' }
MooseNexusModelArtifact >> comment [

	^ comment
]

{ #category : 'accessing' }
MooseNexusModelArtifact >> coordinates [

	^ artifactCoordinates projectCoordinates
]

{ #category : 'accessing' }
MooseNexusModelArtifact >> description [

	^ self name
]

{ #category : 'accessing' }
MooseNexusModelArtifact >> format [

	^ artifactCoordinates format
]

{ #category : 'comparing' }
MooseNexusModelArtifact >> hash [

	^ artifactCoordinates hash bitXor: (path hash bitXor: (comment hash bitXor: timestamp hash))
]

{ #category : 'initialization' }
MooseNexusModelArtifact >> initializeArtifactCoordinates: aMooseNexusModelArtifactCoordinates path: aPath comment: aComment timestamp: aTimestamp [

	artifactCoordinates := aMooseNexusModelArtifactCoordinates.
	path := aPath.
	comment := aComment.
	timestamp := aTimestamp
]

{ #category : 'accessing' }
MooseNexusModelArtifact >> name [

	^ artifactCoordinates name
]

{ #category : 'accessing' }
MooseNexusModelArtifact >> path [

	^ path
]

{ #category : 'printing' }
MooseNexusModelArtifact >> printOn: aStream [

	aStream
		nextPutAll: self className;
		nextPut: $(;
		nextPutAll: self name;
		nextPut: $)
]

{ #category : 'accessing' }
MooseNexusModelArtifact >> timestamp [

	^ timestamp
]
