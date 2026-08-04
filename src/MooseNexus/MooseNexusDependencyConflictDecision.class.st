"
I describe the decision made for one dependency conflict.

I keep the structured conflict that was resolved and the dependency descriptor selected by the resolver. The conflict id and candidates remain available through delegated accessors so callers can inspect a decision without losing the conflict object itself.
"
Class {
	#name : 'MooseNexusDependencyConflictDecision',
	#superclass : 'Object',
	#instVars : [
		'conflict',
		'selectedDependency'
	],
	#category : 'MooseNexus-Dependency',
	#package : 'MooseNexus',
	#tag : 'Dependency'
}

{ #category : 'instance creation' }
MooseNexusDependencyConflictDecision class >> conflict: aMooseNexusDependencyConflict selectedDependency: aMooseNexusDependencyDescriptor [

	^ self new
		  initializeConflict: aMooseNexusDependencyConflict selectedDependency: aMooseNexusDependencyDescriptor;
		  yourself
]

{ #category : 'instance creation' }
MooseNexusDependencyConflictDecision class >> fromDictionary: aDictionary [

	^ self
		  conflict: (MooseNexusDependencyConflict fromDictionary: (aDictionary at: 'conflict'))
		  selectedDependency: (MooseNexusDependencyDescriptor fromDictionary: (aDictionary at: 'selectedDependency'))
]

{ #category : 'comparing' }
MooseNexusDependencyConflictDecision >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ anObject conflict = conflict and: [ anObject selectedDependency = selectedDependency ]
]

{ #category : 'converting' }
MooseNexusDependencyConflictDecision >> asDictionary [

	^ Dictionary new
		  add: 'conflict' -> conflict asDictionary;
		  add: 'selectedDependency' -> selectedDependency asDictionary;
		  yourself
]

{ #category : 'accessing' }
MooseNexusDependencyConflictDecision >> candidates [

	^ conflict candidates
]

{ #category : 'accessing' }
MooseNexusDependencyConflictDecision >> conflict [

	^ conflict
]

{ #category : 'accessing' }
MooseNexusDependencyConflictDecision >> conflictId [

	^ conflict conflictId
]

{ #category : 'comparing' }
MooseNexusDependencyConflictDecision >> hash [

	^ conflict hash bitXor: selectedDependency hash
]

{ #category : 'initialization' }
MooseNexusDependencyConflictDecision >> initializeConflict: aMooseNexusDependencyConflict selectedDependency: aMooseNexusDependencyDescriptor [

	conflict := aMooseNexusDependencyConflict.
	selectedDependency := aMooseNexusDependencyDescriptor
]

{ #category : 'accessing' }
MooseNexusDependencyConflictDecision >> selectedDependency [

	^ selectedDependency
]
