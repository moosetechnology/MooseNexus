"
I describe the decision made for one dependency conflict.

The conflict id is the dependency artifact key used during resolution. Candidates are the descriptors considered by the resolver, and selectedDependency is the descriptor kept in the resolved dependency set.
"
Class {
	#name : 'MooseNexusDependencyConflictDecision',
	#superclass : 'Object',
	#instVars : [
		'conflictId',
		'candidates',
		'selectedDependency'
	],
	#category : 'MooseNexus-Dependency',
	#package : 'MooseNexus',
	#tag : 'Dependency'
}

{ #category : 'instance creation' }
MooseNexusDependencyConflictDecision class >> conflictId: aString candidates: candidateDescriptors selectedDependency: aMooseNexusDependencyDescriptor [

	^ self new
		  initializeConflictId: aString candidates: candidateDescriptors selectedDependency: aMooseNexusDependencyDescriptor;
		  yourself
]

{ #category : 'comparing' }
MooseNexusDependencyConflictDecision >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ anObject conflictId = conflictId and: [
		  anObject candidates = candidates and: [ anObject selectedDependency = selectedDependency ] ]
]

{ #category : 'accessing' }
MooseNexusDependencyConflictDecision >> candidates [

	^ candidates
]

{ #category : 'accessing' }
MooseNexusDependencyConflictDecision >> conflictId [

	^ conflictId
]

{ #category : 'comparing' }
MooseNexusDependencyConflictDecision >> hash [

	^ conflictId hash bitXor: (candidates hash bitXor: selectedDependency hash)
]

{ #category : 'initialization' }
MooseNexusDependencyConflictDecision >> initializeConflictId: aString candidates: candidateDescriptors selectedDependency: aMooseNexusDependencyDescriptor [

	conflictId := aString.
	candidates := candidateDescriptors.
	selectedDependency := aMooseNexusDependencyDescriptor
]

{ #category : 'accessing' }
MooseNexusDependencyConflictDecision >> selectedDependency [

	^ selectedDependency
]
