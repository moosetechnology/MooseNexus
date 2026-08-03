Class {
	#name : 'MooseNexusFirstFoundDependencyConflictResolverTest',
	#superclass : 'TestCase',
	#instVars : [
		'resolver'
	],
	#category : 'MooseNexus-Tests',
	#package : 'MooseNexus-Tests'
}

{ #category : 'helpers' }
MooseNexusFirstFoundDependencyConflictResolverTest >> descriptorVersion: version [

	^ MooseNexusDependencyDescriptor
		  group: 'test'
		  name: 'dependency'
		  version: version
		  type: 'jar'
		  scopes: #( 'compile' )
		  path: 'repository/dependency-' , version , '.jar'
]

{ #category : 'helpers' }
MooseNexusFirstFoundDependencyConflictResolverTest >> descriptorsWithVersions: versions [

	^ versions collect: [ :version | self descriptorVersion: version ] as: OrderedCollection
]

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
