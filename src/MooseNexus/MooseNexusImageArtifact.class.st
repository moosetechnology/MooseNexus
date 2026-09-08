"
I describe one Pharo image artifact recorded for a MooseNexus project.

My name identifies a self-contained directory under artifacts/images. I refer to one recorded model artifact by name; the corresponding model manifest remains the single source of model metadata.
"
Class {
	#name : 'MooseNexusImageArtifact',
	#superclass : 'Object',
	#instVars : [
		'name',
		'modelArtifactName'
	],
	#category : 'MooseNexus-Artifact',
	#package : 'MooseNexus',
	#tag : 'Artifact'
}

{ #category : 'instance creation' }
MooseNexusImageArtifact class >> fromDictionary: aDictionary [

	^ self named: (aDictionary at: 'name') forModelArtifactNamed: (aDictionary at: 'modelArtifact')
]

{ #category : 'instance creation' }
MooseNexusImageArtifact class >> named: imageName forModelArtifactNamed: aModelArtifactName [

	^ self new initializeName: imageName modelArtifactName: aModelArtifactName
]

{ #category : 'comparing' }
MooseNexusImageArtifact >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ name = anObject name and: [ modelArtifactName = anObject modelArtifactName ]
]

{ #category : 'converting' }
MooseNexusImageArtifact >> asDictionary [

	^ Dictionary new
		  add: 'name' -> name;
		  add: 'modelArtifact' -> modelArtifactName;
		  yourself
]

{ #category : 'comparing' }
MooseNexusImageArtifact >> hash [

	^ name hash bitXor: modelArtifactName hash
]

{ #category : 'initialization' }
MooseNexusImageArtifact >> initializeName: imageName modelArtifactName: aModelArtifactName [

	name := imageName.
	modelArtifactName := aModelArtifactName
]

{ #category : 'accessing' }
MooseNexusImageArtifact >> modelArtifactName [

	^ modelArtifactName
]

{ #category : 'accessing' }
MooseNexusImageArtifact >> name [

	^ name
]
