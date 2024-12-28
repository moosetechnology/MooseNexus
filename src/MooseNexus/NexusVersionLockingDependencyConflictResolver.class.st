"
I resolve dependencies using a given table that maps the group and name of a dependency to a selected version.
"
Class {
	#name : 'NexusVersionLockingDependencyConflictResolver',
	#superclass : 'NexusDependencyConflictResolverWithFallback',
	#instVars : [
		'locks'
	],
	#category : 'MooseNexus-ConflictResolver',
	#package : 'MooseNexus',
	#tag : 'ConflictResolver'
}

{ #category : 'adding' }
NexusVersionLockingDependencyConflictResolver >> addLock: anAssociation [
	"anAssociation = 'group:name' -> 'version'"

	self locks add: anAssociation
]

{ #category : 'accessing' }
NexusVersionLockingDependencyConflictResolver >> displayName [

	^ 'Version Locking'
]

{ #category : 'accessing' }
NexusVersionLockingDependencyConflictResolver >> locks [

	^ locks ifNil: [ locks := Dictionary new ]
]

{ #category : 'accessing' }
NexusVersionLockingDependencyConflictResolver >> locks: aDictionary [
	"Expects a dictionary with 'group:name' strings as keys and version strings as values.
	e.g. { 'org.domain:example': '1.2.3' }"

	locks := aDictionary
]

{ #category : 'removing' }
NexusVersionLockingDependencyConflictResolver >> removeLock: aString [
	"aString = 'group:name'"

	self locks removeKey: aString ifAbsent: [ "do nothing!" ]
]

{ #category : 'resolving' }
NexusVersionLockingDependencyConflictResolver >> resolveConflicts: conflicts on: dependencies [

	| remaining |
	remaining := Dictionary new.

	conflicts keysAndValuesDo: [ :groupAndName :descriptors |
		self locks
			at: groupAndName
			ifPresent: [ :version |
				descriptors
					detect: [ :descriptor | version = (descriptor at: #version) ]
					ifFound: [ :descriptor |
					dependencies at: groupAndName put: descriptor ]
					ifNone: [ remaining at: groupAndName put: descriptors ] ]
			ifAbsent: [ remaining at: groupAndName put: descriptors ] ].

	remaining ifNotEmpty: [
		self resolveRemainingConflicts: remaining on: dependencies ]
]
