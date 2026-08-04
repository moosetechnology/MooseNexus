"
I describe one model artifact recorded for a MooseNexus project.

I carry the project coordinates, model name, repository-relative model path, file format, user comment, creation timestamp, and metamodel version. I own the serialized representation written to models.json so project and build code can work with objects instead of dictionaries.
"
Class {
	#name : 'MooseNexusModelArtifact',
	#superclass : 'Object',
	#instVars : [
		'coordinates',
		'name',
		'path',
		'format',
		'comment',
		'timestamp',
		'famixVersion'
	],
	#category : 'MooseNexus-ModelExtraction',
	#package : 'MooseNexus',
	#tag : 'ModelExtraction'
}

{ #category : 'instance creation' }
MooseNexusModelArtifact class >> coordinates: aMooseNexusCoordinates name: aName path: aPath format: aFormat comment: aComment timestamp: aTimestamp famixVersion: aFamixVersion [

	^ self new
		  initializeCoordinates: aMooseNexusCoordinates
		  name: aName
		  path: aPath
		  format: aFormat
		  comment: aComment
		  timestamp: aTimestamp
		  famixVersion: aFamixVersion;
		  yourself
]

{ #category : 'instance creation' }
MooseNexusModelArtifact class >> fromDictionary: aDictionary [

	| projectCoordinates |
	projectCoordinates := aDictionary at: 'projectCoordinates'.
	^ self
		  coordinates: (MooseNexusCoordinates
				   group: (projectCoordinates at: 'group')
				   name: (projectCoordinates at: 'name')
				   version: (projectCoordinates at: 'version'))
		  name: (aDictionary at: 'name')
		  path: (aDictionary at: 'path')
		  format: (aDictionary at: 'format')
		  comment: (aDictionary at: 'comment')
		  timestamp: (aDictionary at: 'timestamp')
		  famixVersion: (aDictionary at: 'famixVersion')
]

{ #category : 'comparing' }
MooseNexusModelArtifact >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ anObject coordinates = coordinates and: [
			  anObject name = name and: [
					  anObject path = path and: [
							  anObject format = format and: [
								  anObject comment = comment and: [ anObject timestamp = timestamp and: [ anObject famixVersion = famixVersion ] ] ] ] ] ]
]

{ #category : 'converting' }
MooseNexusModelArtifact >> asDictionary [

	^ Dictionary new
		  add: 'projectCoordinates' -> (Dictionary new
					   add: 'group' -> coordinates group;
					   add: 'name' -> coordinates name;
					   add: 'version' -> coordinates version;
					   yourself);
		  add: 'name' -> name;
		  add: 'path' -> path;
		  add: 'format' -> format;
		  add: 'comment' -> comment;
		  add: 'timestamp' -> timestamp;
		  add: 'famixVersion' -> famixVersion;
		  yourself
]

{ #category : 'accessing' }
MooseNexusModelArtifact >> comment [

	^ comment
]

{ #category : 'accessing' }
MooseNexusModelArtifact >> coordinates [

	^ coordinates
]

{ #category : 'accessing' }
MooseNexusModelArtifact >> description [

	^ name
]

{ #category : 'accessing' }
MooseNexusModelArtifact >> famixVersion [

	^ famixVersion
]

{ #category : 'accessing' }
MooseNexusModelArtifact >> format [

	^ format
]

{ #category : 'comparing' }
MooseNexusModelArtifact >> hash [

	^ coordinates hash bitXor:
		  (name hash bitXor: (path hash bitXor: (format hash bitXor: (comment hash bitXor: (timestamp hash bitXor: famixVersion hash)))))
]

{ #category : 'initialization' }
MooseNexusModelArtifact >> initializeCoordinates: aMooseNexusCoordinates name: aName path: aPath format: aFormat comment: aComment timestamp: aTimestamp famixVersion: aFamixVersion [

	coordinates := aMooseNexusCoordinates.
	name := aName.
	path := aPath.
	format := aFormat.
	comment := aComment.
	timestamp := aTimestamp.
	famixVersion := aFamixVersion
]

{ #category : 'accessing' }
MooseNexusModelArtifact >> name [

	^ name
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
		nextPutAll: name;
		nextPut: $)
]

{ #category : 'accessing' }
MooseNexusModelArtifact >> timestamp [

	^ timestamp
]
