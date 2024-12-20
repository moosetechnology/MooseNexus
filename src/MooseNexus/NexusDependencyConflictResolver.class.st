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

{ #category : 'instance creation' }
NexusDependencyConflictResolver class >> newDefaultResolver [

	^ NexusFirstFoundDependencyConflictResolver new
]

{ #category : 'resolving' }
NexusDependencyConflictResolver >> resolveConflicts: conflicts [

	| choices |
	choices := Dictionary new.
	self resolveConflicts: conflicts on: choices.
	^ choices
]

{ #category : 'resolving' }
NexusDependencyConflictResolver >> resolveConflicts: conflicts on: dependencies [

	self subclassResponsibility
]
