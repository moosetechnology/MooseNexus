"
During the import of a `NexusManagedProject`, there may be multiple declarations with different versions for the same dependency.
This does not happen for a single external project, because the dependency manager takes care of resolving these conflicts.
However, this can happen if the Nexus project contains multiple external projects, all declaring their own dependencies, which may come into conflict when the model is built.
The role of my subclasses is to provide strategies for resolving these conflicts between dependency versions.
"
Class {
	#name : 'NexusDependencyConflictResolver',
	#superclass : 'Object',
	#category : 'MooseNexus-ConflictResolver',
	#package : 'MooseNexus',
	#tag : 'ConflictResolver'
}

{ #category : 'testing' }
NexusDependencyConflictResolver class >> isAbstract [

	^ self == NexusDependencyConflictResolver
]

{ #category : 'instance creation' }
NexusDependencyConflictResolver class >> newDefaultResolver [

	^ NexusFirstFoundDependencyConflictResolver new
]

{ #category : 'accessing' }
NexusDependencyConflictResolver >> displayName [
	"The name of the resolver to display in a GUI."

	self subclassResponsibility
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
