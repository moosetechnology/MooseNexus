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
MooseNexusFirstFoundDependencyConflictResolverTest >> testResolveConflicts [

	self
		assertResolverDecisionsFrom: (Dictionary
				 with: 'org:example' -> #( 'awfulVersion' 'awesomeVersion' 'worstVersion' )
				 with: 'com:potato' -> #( '2b.39.451e-rc' '2a.39.451e-rc' ))
		selectVersions: (Dictionary with: 'org:example' -> 'awfulVersion' with: 'com:potato' -> '2b.39.451e-rc')
]
