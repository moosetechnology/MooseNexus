"
I am a simple dependency conflict resolver that selects the first version I find.
While I have little (if any) semantic value, I guarantee to resolve all conflicts.
"
Class {
	#name : 'NexusFirstFoundDependencyConflictResolver',
	#superclass : 'NexusDependencyConflictResolver',
	#category : 'MooseNexus-ConflictResolver',
	#package : 'MooseNexus',
	#tag : 'ConflictResolver'
}

{ #category : 'resolving' }
NexusFirstFoundDependencyConflictResolver >> resolveConflicts: conflicts on: dependencies [

	conflicts keysAndValuesDo: [ :groupAndName :descriptors |
		dependencies at: groupAndName put: descriptors first ]
]
