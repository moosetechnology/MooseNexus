Class {
	#name : 'NexusDependencyConflictResolver',
	#superclass : 'Object',
	#category : 'MooseNexus-Strategy',
	#package : 'MooseNexus',
	#tag : 'Strategy'
}

{ #category : 'testing' }
NexusDependencyConflictResolver class >> isAbstract [

	^ self == NexusDependencyConflictResolver
]

{ #category : 'resolving' }
NexusDependencyConflictResolver >> resolveConflicts: conflicts on: dependencies [

	self subclassResponsibility
]
