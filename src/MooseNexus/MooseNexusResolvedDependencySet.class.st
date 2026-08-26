"
I describe the exact dependency descriptors resolved for a MooseNexus project build.

I am distinct from a declared dependency graph: I contain the dependency artifacts selected for a build after scope aggregation and conflict resolution. I own the serialized representation used by project properties.
"
Class {
	#name : 'MooseNexusResolvedDependencySet',
	#superclass : 'Object',
	#instVars : [
		'dependencies'
	],
	#category : 'MooseNexus-Dependency',
	#package : 'MooseNexus',
	#tag : 'Dependency'
}

{ #category : 'instance creation' }
MooseNexusResolvedDependencySet class >> dependencies: dependencyDescriptors [

	^ self new initializeDependencies: dependencyDescriptors
]

{ #category : 'instance creation' }
MooseNexusResolvedDependencySet class >> empty [

	^ self dependencies: #(  )
]

{ #category : 'instance creation' }
MooseNexusResolvedDependencySet class >> fromDictionaries: dependencyDictionaries [

	^ self dependencies:
		  (dependencyDictionaries collect: [ :dependency | MooseNexusDependencyDescriptor fromDictionary: dependency ])
]

{ #category : 'comparing' }
MooseNexusResolvedDependencySet >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ anObject dependencies = dependencies
]

{ #category : 'converting' }
MooseNexusResolvedDependencySet >> asDictionaries [

	^ dependencies collect: [ :dependency | dependency asDictionary ] as: Array
]

{ #category : 'accessing' }
MooseNexusResolvedDependencySet >> dependencies [

	^ dependencies
]

{ #category : 'enumerating' }
MooseNexusResolvedDependencySet >> do: aBlock [

	^ dependencies do: aBlock
]

{ #category : 'comparing' }
MooseNexusResolvedDependencySet >> hash [

	^ dependencies hash
]

{ #category : 'initialization' }
MooseNexusResolvedDependencySet >> initializeDependencies: dependencyDescriptors [

	dependencies := dependencyDescriptors ifNil: [ #(  ) ] ifNotNil: [ dependencyDescriptors asArray ]
]

{ #category : 'testing' }
MooseNexusResolvedDependencySet >> isEmpty [

	^ dependencies isEmpty
]

{ #category : 'accessing' }
MooseNexusResolvedDependencySet >> size [

	^ dependencies size
]
