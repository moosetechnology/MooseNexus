"
I describe one dependency conflict detected during dependency resolution.

The conflict id identifies the dependency artifact being resolved, usually by group and name. Candidates are the dependency descriptors that cannot all be kept together because they refer to different artifacts or versions. Conflict resolvers consume me and answer explicit MooseNexusDependencyConflictDecision objects.
"
Class {
	#name : 'MooseNexusDependencyConflict',
	#superclass : 'Object',
	#instVars : [
		'conflictId',
		'candidates'
	],
	#category : 'MooseNexus-Dependency',
	#package : 'MooseNexus',
	#tag : 'Dependency'
}

{ #category : 'instance creation' }
MooseNexusDependencyConflict class >> conflictId: aString candidates: dependencyDescriptors [

	^ self new
		  initializeConflictId: aString candidates: dependencyDescriptors;
		  yourself
]

{ #category : 'comparing' }
MooseNexusDependencyConflict >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ anObject conflictId = conflictId and: [ anObject candidates = candidates ]
]

{ #category : 'accessing' }
MooseNexusDependencyConflict >> candidates [

	^ candidates
]

{ #category : 'accessing' }
MooseNexusDependencyConflict >> conflictId [

	^ conflictId
]

{ #category : 'comparing' }
MooseNexusDependencyConflict >> hash [

	^ conflictId hash bitXor: candidates hash
]

{ #category : 'initialization' }
MooseNexusDependencyConflict >> initializeConflictId: aString candidates: dependencyDescriptors [

	conflictId := aString.
	candidates := dependencyDescriptors asArray
]
