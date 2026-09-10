"
I record a dependency artifact staged temporarily for a model build.

My repository-relative path identifies the staging location used by the extractor. Model-builder cleanup removes that location after extraction, so it is an audit detail rather than a durable dependency reference. The dependency descriptor remains the portable, durable reference.
"
Class {
	#name : 'MooseNexusDependencyMaterializationResult',
	#superclass : 'Object',
	#instVars : [
		'dependency',
		'path',
		'source'
	],
	#category : 'MooseNexus-Dependency',
	#package : 'MooseNexus',
	#tag : 'Dependency'
}

{ #category : 'instance creation' }
MooseNexusDependencyMaterializationResult class >> dependency: aDependency path: aPath source: aSource [

	^ self new initializeDependency: aDependency path: aPath source: aSource
]

{ #category : 'instance creation' }
MooseNexusDependencyMaterializationResult class >> fromDictionary: dictionary [

	^ self
		  dependency: (MooseNexusDependencyDescriptor fromDictionary: (dictionary at: #dependency))
		  path: (dictionary at: #path)
		  source: (dictionary at: #source)
]

{ #category : 'comparing' }
MooseNexusDependencyMaterializationResult >> = anotherResult [

	self == anotherResult ifTrue: [ ^ true ].
	anotherResult class == self class ifFalse: [ ^ false ].
	^ dependency = anotherResult dependency and: [ path = anotherResult path and: [ source = anotherResult source ] ]
]

{ #category : 'converting' }
MooseNexusDependencyMaterializationResult >> asDictionary [

	^ Dictionary with: #dependency -> dependency asDictionary with: #path -> path with: #source -> source
]

{ #category : 'accessing' }
MooseNexusDependencyMaterializationResult >> dependency [

	^ dependency
]

{ #category : 'comparing' }
MooseNexusDependencyMaterializationResult >> hash [

	^ dependency hash bitXor: (path hash bitXor: source hash)
]

{ #category : 'initialization' }
MooseNexusDependencyMaterializationResult >> initializeDependency: aDependency path: aPath source: aSource [

	dependency := aDependency.
	path := aPath.
	source := aSource
]

{ #category : 'accessing' }
MooseNexusDependencyMaterializationResult >> path [

	^ path
]

{ #category : 'accessing' }
MooseNexusDependencyMaterializationResult >> source [

	^ source
]
