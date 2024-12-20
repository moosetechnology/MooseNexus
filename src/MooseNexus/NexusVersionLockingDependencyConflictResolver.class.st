Class {
	#name : 'NexusVersionLockingDependencyConflictResolver',
	#superclass : 'NexusDependencyConflictResolverWithFallback',
	#instVars : [
		'locks'
	],
	#category : 'MooseNexus-Strategy',
	#package : 'MooseNexus',
	#tag : 'Strategy'
}

{ #category : 'adding' }
NexusVersionLockingDependencyConflictResolver >> addLock: anAssociation [

	self locks add: anAssociation
]

{ #category : 'accessing' }
NexusVersionLockingDependencyConflictResolver >> locks [

	^ locks ifNil: [ locks := Dictionary new ]
]

{ #category : 'accessing' }
NexusVersionLockingDependencyConflictResolver >> locks: aDictionary [
	"Expects a dictionary with 'group:name' as keys, and version as values.
	e.g. { 'org.domain:example': '1.2.3' }"

	locks := aDictionary
]

{ #category : 'adding' }
NexusVersionLockingDependencyConflictResolver >> removeLock: aString [

	self locks removeKey: aString ifAbsent: [ "do nothing!" ]
]

{ #category : 'resolving' }
NexusVersionLockingDependencyConflictResolver >> resolveConflicts: conflicts on: dependencies [

	| remaining |
	remaining := Dictionary new.

	conflicts keysAndValuesDo: [ :groupAndName :conflictList |
		self locks
			at: groupAndName
			ifPresent: [ :version |
				conflictList
					detect: [ :descriptor | version = (descriptor at: #version) ]
					ifFound: [ :descriptor |
					dependencies at: groupAndName put: descriptor ]
					ifNone: [ remaining at: groupAndName put: conflictList ] ]
			ifAbsent: [ remaining at: groupAndName put: conflictList ] ].

	remaining ifNotEmpty: [
		self resolveRemainingConflicts: remaining on: dependencies ]
]
