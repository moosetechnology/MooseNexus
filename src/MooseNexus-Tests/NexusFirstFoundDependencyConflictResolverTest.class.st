Class {
	#name : 'NexusFirstFoundDependencyConflictResolverTest',
	#superclass : 'TestCase',
	#instVars : [
		'resolver'
	],
	#category : 'MooseNexus-Tests',
	#package : 'MooseNexus-Tests'
}

{ #category : 'running' }
NexusFirstFoundDependencyConflictResolverTest >> setUp [

	super setUp.
	resolver := NexusFirstFoundDependencyConflictResolver new
]

{ #category : 'tests' }
NexusFirstFoundDependencyConflictResolverTest >> testResolveConflictsOn [

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

	resolver resolveConflicts: conflicts on: (resolved := Dictionary new).

	self assert: resolved equals: (Dictionary
			 with:
			 'org:example' -> (Dictionary with: #version -> 'awfulVersion')
			 with:
			 'com:potato' -> (Dictionary with: #version -> '2b.39.451e-rc'))
]
