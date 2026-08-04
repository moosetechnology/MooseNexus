"
I am a simple dependency conflict resolver that selects the first version I find.
While I have little (if any) semantic value, I guarantee to resolve all conflicts.
"
Class {
	#name : 'MooseNexusFirstFoundDependencyConflictResolver',
	#superclass : 'MooseNexusDependencyConflictResolver',
	#category : 'MooseNexus-ConflictResolver',
	#package : 'MooseNexus',
	#tag : 'ConflictResolver'
}

{ #category : 'accessing' }
MooseNexusFirstFoundDependencyConflictResolver >> displayName [

	^ 'First Found'
]

{ #category : 'resolving' }
MooseNexusFirstFoundDependencyConflictResolver >> resolveConflict: aMooseNexusDependencyConflict [

	^ MooseNexusDependencyConflictDecision
		  conflict: aMooseNexusDependencyConflict
		  selectedDependency: aMooseNexusDependencyConflict candidates first
]
