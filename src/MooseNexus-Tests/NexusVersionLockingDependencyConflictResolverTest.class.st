Class {
	#name : 'NexusVersionLockingDependencyConflictResolverTest',
	#superclass : 'TestCase',
	#instVars : [
		'resolver'
	],
	#category : 'MooseNexus-Tests',
	#package : 'MooseNexus-Tests'
}

{ #category : 'running' }
NexusVersionLockingDependencyConflictResolverTest >> setUp [

	super setUp.
	resolver := NexusVersionLockingDependencyConflictResolver new
]

{ #category : 'tests' }
NexusVersionLockingDependencyConflictResolverTest >> testResolveConflictsOn [

	| conflicts resolved |
	conflicts := Dictionary
		             with: 'org:example' -> {
				             (Dictionary with: #version -> 'awfulVersion').
				             (Dictionary with: #version -> 'awesomeVersion').
				             (Dictionary with: #version -> 'worstVersion') }
				             asOrderedCollection
		             with: 'com:potato' -> {
				             (Dictionary with: #version -> '2b.39.451e-rc').
				             (Dictionary with: #version -> '2a.39.451e-rc') }
				             asOrderedCollection.
	resolver locks: (Dictionary
			 with: 'org:example' -> 'awesomeVersion'
			 with: 'com:potato' -> '2a.39.451e-rc').

	resolver resolveConflicts: conflicts on: (resolved := Dictionary new).

	self assert: resolved equals: (Dictionary
			 with:
			 'org:example' -> (Dictionary with: #version -> 'awesomeVersion')
			 with:
			 'com:potato' -> (Dictionary with: #version -> '2a.39.451e-rc'))
]

{ #category : 'tests' }
NexusVersionLockingDependencyConflictResolverTest >> testResolveConflictsOnWithFallback [

	| conflicts resolved |
	conflicts := Dictionary
		             with: 'org:example' -> {
				             (Dictionary with: #version -> 'awfulVersion').
				             (Dictionary with: #version -> 'awesomeVersion').
				             (Dictionary with: #version -> 'worstVersion') }
				             asOrderedCollection
		             with: 'com:potato' -> {
				             (Dictionary with: #version -> '2b.39.451e-rc').
				             (Dictionary with: #version -> '2a.39.451e-rc') }
				             asOrderedCollection.
	resolver locks: (Dictionary with: 'org:example' -> 'awesomeVersion').

	resolver resolveConflicts: conflicts on: (resolved := Dictionary new).

	self assert: resolved equals: (Dictionary
			 with:
			 'org:example' -> (Dictionary with: #version -> 'awesomeVersion')
			 with:
			 'com:potato' -> (Dictionary with: #version -> '2b.39.451e-rc'))
]
