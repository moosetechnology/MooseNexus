"
I describe dependencies declared by one managed project descriptor.

I preserve the dependency descriptors as declared by an external build tool, including their scopes or configurations. The owning managed project descriptor provides the provenance for this graph. I own the serialized representation used inside managed project properties.
"
Class {
	#name : 'MooseNexusDependencyGraph',
	#superclass : 'Object',
	#instVars : [
		'dependencies'
	],
	#category : 'MooseNexus-Dependency',
	#package : 'MooseNexus',
	#tag : 'Dependency'
}

{ #category : 'instance creation' }
MooseNexusDependencyGraph class >> dependencies: dependencyDescriptors [

	^ self new initializeDependencies: dependencyDescriptors
]

{ #category : 'instance creation' }
MooseNexusDependencyGraph class >> empty [

	^ self dependencies: #(  )
]

{ #category : 'instance creation' }
MooseNexusDependencyGraph class >> fromDictionaries: dependencyDictionaries [

	^ self dependencies:
		  (dependencyDictionaries collect: [ :dependency | MooseNexusDependencyDescriptor fromDictionary: dependency ])
]

{ #category : 'instance creation' }
MooseNexusDependencyGraph class >> fromDictionary: aDictionary [

	^ self fromDictionaries: (aDictionary at: #dependencies ifAbsent: [ #(  ) ])
]

{ #category : 'comparing' }
MooseNexusDependencyGraph >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ anObject dependencies = dependencies
]

{ #category : 'converting' }
MooseNexusDependencyGraph >> asDictionaries [

	^ dependencies collect: [ :dependency | dependency asDictionary ] as: Array
]

{ #category : 'converting' }
MooseNexusDependencyGraph >> asDictionary [

	^ Dictionary with: #dependencies -> self asDictionaries
]

{ #category : 'accessing' }
MooseNexusDependencyGraph >> dependencies [

	^ dependencies
]

{ #category : 'enumerating' }
MooseNexusDependencyGraph >> do: aBlock [

	^ dependencies do: aBlock
]

{ #category : 'comparing' }
MooseNexusDependencyGraph >> hash [

	^ dependencies hash
]

{ #category : 'initialization' }
MooseNexusDependencyGraph >> initializeDependencies: dependencyDescriptors [

	dependencies := dependencyDescriptors ifNil: [ #(  ) ] ifNotNil: [ dependencyDescriptors asArray ]
]

{ #category : 'testing' }
MooseNexusDependencyGraph >> isEmpty [

	^ dependencies isEmpty
]

{ #category : 'accessing' }
MooseNexusDependencyGraph >> size [

	^ dependencies size
]
