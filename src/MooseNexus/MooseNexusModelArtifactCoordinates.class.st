"
I identify a model artifact produced for a MooseNexus project.

I keep the source project coordinates and add model-specific dimensions: model name, model format, metamodel, and classifier. This keeps source-project identity separate from artifact identity while preserving Maven-like group/name/version context for repository paths and manifests.
"
Class {
	#name : 'MooseNexusModelArtifactCoordinates',
	#superclass : 'Object',
	#instVars : [
		'projectCoordinates',
		'name',
		'format',
		'metamodel',
		'classifier'
	],
	#category : 'MooseNexus-Artifact',
	#package : 'MooseNexus',
	#tag : 'Artifact'
}

{ #category : 'instance creation' }
MooseNexusModelArtifactCoordinates class >> fromDictionary: aDictionary [

	| projectCoordinates |
	projectCoordinates := aDictionary at: 'projectCoordinates'.
	^ self
		  projectCoordinates: (MooseNexusCoordinates
				   group: (projectCoordinates at: 'group')
				   name: (projectCoordinates at: 'name')
				   version: (projectCoordinates at: 'version'))
		  name: (aDictionary at: 'name')
		  format: (aDictionary at: 'format')
		  metamodel: (aDictionary at: 'metamodel')
		  classifier: (aDictionary at: 'classifier')
]

{ #category : 'instance creation' }
MooseNexusModelArtifactCoordinates class >> projectCoordinates: aMooseNexusCoordinates name: aName format: aFormat metamodel: aMetamodel classifier: aClassifier [

	^ self new
		  initializeProjectCoordinates: aMooseNexusCoordinates
		  name: aName
		  format: aFormat
		  metamodel: aMetamodel
		  classifier: aClassifier;
		  yourself
]

{ #category : 'comparing' }
MooseNexusModelArtifactCoordinates >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ anObject projectCoordinates = projectCoordinates and: [
			  anObject name = name and: [
				  anObject format = format and: [ anObject metamodel = metamodel and: [ anObject classifier = classifier ] ] ] ]
]

{ #category : 'converting' }
MooseNexusModelArtifactCoordinates >> asDictionary [

	^ Dictionary new
		  add: 'projectCoordinates' -> (Dictionary new
					   add: 'group' -> projectCoordinates group;
					   add: 'name' -> projectCoordinates name;
					   add: 'version' -> projectCoordinates version;
					   yourself);
		  add: 'name' -> name;
		  add: 'format' -> format;
		  add: 'metamodel' -> metamodel;
		  add: 'classifier' -> classifier;
		  yourself
]

{ #category : 'accessing' }
MooseNexusModelArtifactCoordinates >> classifier [

	^ classifier
]

{ #category : 'accessing' }
MooseNexusModelArtifactCoordinates >> format [

	^ format
]

{ #category : 'accessing' }
MooseNexusModelArtifactCoordinates >> group [

	^ projectCoordinates group
]

{ #category : 'comparing' }
MooseNexusModelArtifactCoordinates >> hash [

	^ projectCoordinates hash bitXor: (name hash bitXor: (format hash bitXor: (metamodel hash bitXor: classifier hash)))
]

{ #category : 'initialization' }
MooseNexusModelArtifactCoordinates >> initializeProjectCoordinates: aMooseNexusCoordinates name: aName format: aFormat metamodel: aMetamodel classifier: aClassifier [

	projectCoordinates := aMooseNexusCoordinates.
	name := aName.
	format := aFormat.
	metamodel := aMetamodel.
	classifier := aClassifier
]

{ #category : 'accessing' }
MooseNexusModelArtifactCoordinates >> metamodel [

	^ metamodel
]

{ #category : 'accessing' }
MooseNexusModelArtifactCoordinates >> name [

	^ name
]

{ #category : 'printing' }
MooseNexusModelArtifactCoordinates >> printOn: aStream [

	aStream
		nextPutAll: projectCoordinates printString;
		nextPut: $:;
		nextPutAll: name;
		nextPut: $:;
		nextPutAll: format;
		nextPut: $:;
		nextPutAll: metamodel;
		nextPut: $:;
		nextPutAll: classifier
]

{ #category : 'accessing' }
MooseNexusModelArtifactCoordinates >> projectCoordinates [

	^ projectCoordinates
]

{ #category : 'accessing' }
MooseNexusModelArtifactCoordinates >> version [

	^ projectCoordinates version
]
