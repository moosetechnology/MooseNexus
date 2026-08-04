"
I resolve dependencies using a given table that maps the group and name of a dependency to a selected version.
"
Class {
	#name : 'MooseNexusVersionLockingDependencyConflictResolver',
	#superclass : 'MooseNexusDependencyConflictResolverWithFallback',
	#instVars : [
		'locks'
	],
	#category : 'MooseNexus-ConflictResolver',
	#package : 'MooseNexus',
	#tag : 'ConflictResolver'
}

{ #category : 'adding' }
MooseNexusVersionLockingDependencyConflictResolver >> addLock: anAssociation [
	"anAssociation = 'group:name' -> 'version'"

	self locks add: anAssociation
]

{ #category : 'accessing' }
MooseNexusVersionLockingDependencyConflictResolver >> displayName [

	^ 'Version Locking'
]

{ #category : 'accessing' }
MooseNexusVersionLockingDependencyConflictResolver >> locks [

	^ locks ifNil: [ locks := Dictionary new ]
]

{ #category : 'accessing' }
MooseNexusVersionLockingDependencyConflictResolver >> locks: aDictionary [
	"Expects a dictionary with 'group:name' strings as keys and version strings as values.
	e.g. { 'org.domain:example': '1.2.3' }"

	locks := aDictionary
]

{ #category : 'adding' }
MooseNexusVersionLockingDependencyConflictResolver >> rememberDecision: aMooseNexusDependencyConflictDecision [

	self locks
		at: aMooseNexusDependencyConflictDecision conflictId
		put: aMooseNexusDependencyConflictDecision selectedDependency version
]

{ #category : 'adding' }
MooseNexusVersionLockingDependencyConflictResolver >> rememberDecisions: dependencyConflictDecisions [

	dependencyConflictDecisions do: [ :decision | self rememberDecision: decision ]
]

{ #category : 'removing' }
MooseNexusVersionLockingDependencyConflictResolver >> removeLock: aString [
	"aString = 'group:name'"

	self locks removeKey: aString ifAbsent: [ "do nothing!" ]
]

{ #category : 'resolving' }
MooseNexusVersionLockingDependencyConflictResolver >> resolveConflict: aMooseNexusDependencyConflict [

	self locks at: aMooseNexusDependencyConflict conflictId ifPresent: [ :version |
			aMooseNexusDependencyConflict candidates
				detect: [ :descriptor | version = descriptor version ]
				ifFound: [ :descriptor |
				^ MooseNexusDependencyConflictDecision conflict: aMooseNexusDependencyConflict selectedDependency: descriptor ]
				ifNone: [ nil ] ].
	^ self resolveRemainingConflict: aMooseNexusDependencyConflict
]
