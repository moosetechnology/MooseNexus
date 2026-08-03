Class {
	#name : 'MooseNexusFirstFoundDependencyConflictResolverTest',
	#superclass : 'MooseNexusDependencyConflictResolverTest',
	#category : 'MooseNexus-Tests',
	#package : 'MooseNexus-Tests'
}

{ #category : 'running' }
MooseNexusFirstFoundDependencyConflictResolverTest >> setUp [

	super setUp.
	resolver := MooseNexusFirstFoundDependencyConflictResolver new
]

{ #category : 'tests' }
MooseNexusFirstFoundDependencyConflictResolverTest >> testResolveConflictsOn [

	| conflicts resolved |
	conflicts := Dictionary
		             with: 'org:example' -> (self descriptorsWithVersions: #( 'awfulVersion' 'awesomeVersion' 'worstVersion' ))
		             with: 'com:potato' -> (self descriptorsWithVersions: #( '2b.39.451e-rc' '2a.39.451e-rc' )).

	resolver resolveConflicts: conflicts on: (resolved := Dictionary new).

	self assert: resolved equals: (Dictionary
			 with: 'org:example' -> (self descriptorVersion: 'awfulVersion')
			 with: 'com:potato' -> (self descriptorVersion: '2b.39.451e-rc'))
]
