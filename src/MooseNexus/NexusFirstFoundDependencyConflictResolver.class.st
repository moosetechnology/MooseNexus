Class {
	#name : 'NexusFirstFoundDependencyConflictResolver',
	#superclass : 'NexusDependencyConflictResolver',
	#category : 'MooseNexus-Strategy',
	#package : 'MooseNexus',
	#tag : 'Strategy'
}

{ #category : 'resolving' }
NexusFirstFoundDependencyConflictResolver >> resolveConflicts: conflicts on: dependencies [

	conflicts keysAndValuesDo: [ :groupAndName :conflictList |
		dependencies at: groupAndName put: conflictList first ]
]
