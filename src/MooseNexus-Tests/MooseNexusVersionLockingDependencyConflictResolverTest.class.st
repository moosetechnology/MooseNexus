Class {
	#name : 'MooseNexusVersionLockingDependencyConflictResolverTest',
	#superclass : 'MooseNexusDependencyConflictResolverTest',
	#category : 'MooseNexus-Tests',
	#package : 'MooseNexus-Tests'
}

{ #category : 'running' }
MooseNexusVersionLockingDependencyConflictResolverTest >> setUp [

	super setUp.
	resolver := MooseNexusVersionLockingDependencyConflictResolver new
]

{ #category : 'tests' }
MooseNexusVersionLockingDependencyConflictResolverTest >> testRememberDecisionAddsVersionLock [

	| conflict decision |
	conflict := self conflictId: 'org:example' versions: #( 'awfulVersion' 'awesomeVersion' ).
	decision := MooseNexusDependencyConflictDecision conflict: conflict selectedDependency: conflict candidates second.

	resolver rememberDecision: decision.

	self assert: (resolver locks at: 'org:example') equals: 'awesomeVersion'
]

{ #category : 'tests' }
MooseNexusVersionLockingDependencyConflictResolverTest >> testResolveConflicts [

	resolver locks: (Dictionary with: 'org:example' -> 'awesomeVersion' with: 'com:potato' -> '2a.39.451e-rc').
	self
		assertResolverDecisionsFrom: (Dictionary
				 with: 'org:example' -> #( 'awfulVersion' 'awesomeVersion' 'worstVersion' )
				 with: 'com:potato' -> #( '2b.39.451e-rc' '2a.39.451e-rc' ))
		selectVersions: (Dictionary with: 'org:example' -> 'awesomeVersion' with: 'com:potato' -> '2a.39.451e-rc')
]

{ #category : 'tests' }
MooseNexusVersionLockingDependencyConflictResolverTest >> testResolveConflictsWithFallback [

	resolver locks: (Dictionary with: 'org:example' -> 'awesomeVersion').
	self
		assertResolverDecisionsFrom: (Dictionary
				 with: 'org:example' -> #( 'awfulVersion' 'awesomeVersion' 'worstVersion' )
				 with: 'com:potato' -> #( '2b.39.451e-rc' '2a.39.451e-rc' ))
		selectVersions: (Dictionary with: 'org:example' -> 'awesomeVersion' with: 'com:potato' -> '2b.39.451e-rc')
]
