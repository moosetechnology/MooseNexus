"
During the import of a `MooseNexusManagedProject`, there may be multiple declarations with different versions for the same dependency.
This does not happen for a single external project, because the dependency manager takes care of resolving these conflicts.
However, this can happen if the Nexus project contains multiple external projects, all declaring their own dependencies, which may come into conflict when the model is built.
The role of my subclasses is to provide strategies for resolving these conflicts between dependency versions.
"
Class {
	#name : 'MooseNexusDependencyConflictResolver',
	#superclass : 'Object',
	#category : 'MooseNexus-ConflictResolver',
	#package : 'MooseNexus',
	#tag : 'ConflictResolver'
}

{ #category : 'testing' }
MooseNexusDependencyConflictResolver class >> isAbstract [

	^ self == MooseNexusDependencyConflictResolver
]

{ #category : 'instance creation' }
MooseNexusDependencyConflictResolver class >> newDefaultResolver [

	^ MooseNexusFirstFoundDependencyConflictResolver new
]

{ #category : 'accessing' }
MooseNexusDependencyConflictResolver >> displayName [
	"The name of the resolver to display in a GUI."

	self subclassResponsibility
]

{ #category : 'resolving' }
MooseNexusDependencyConflictResolver >> resolveConflict: aMooseNexusDependencyConflict [

	self subclassResponsibility
]

{ #category : 'resolving' }
MooseNexusDependencyConflictResolver >> resolveConflicts: conflicts [

	^ conflicts collect: [ :conflict | self resolveConflict: conflict ] as: Array
]
