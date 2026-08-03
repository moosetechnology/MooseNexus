Class {
	#name : 'MooseNexusVersionLockingDependencyConflictResolverTest',
	#superclass : 'TestCase',
	#instVars : [
		'resolver'
	],
	#category : 'MooseNexus-Tests',
	#package : 'MooseNexus-Tests'
}

{ #category : 'helpers' }
MooseNexusVersionLockingDependencyConflictResolverTest >> descriptorVersion: version [

	^ MooseNexusDependencyDescriptor
		  group: 'test'
		  name: 'dependency'
		  version: version
		  type: 'jar'
		  scope: 'compile'
		  path: 'repository/dependency-' , version , '.jar'
]

{ #category : 'helpers' }
MooseNexusVersionLockingDependencyConflictResolverTest >> descriptorsWithVersions: versions [

	^ versions collect: [ :version | self descriptorVersion: version ] as: OrderedCollection
]

{ #category : 'running' }
MooseNexusVersionLockingDependencyConflictResolverTest >> setUp [

	super setUp.
	resolver := MooseNexusVersionLockingDependencyConflictResolver new
]

{ #category : 'tests' }
MooseNexusVersionLockingDependencyConflictResolverTest >> testResolveConflictsOn [

	| conflicts resolved |
	conflicts := Dictionary
		             with: 'org:example' -> (self descriptorsWithVersions: #( 'awfulVersion' 'awesomeVersion' 'worstVersion' ))
		             with: 'com:potato' -> (self descriptorsWithVersions: #( '2b.39.451e-rc' '2a.39.451e-rc' )).
	resolver locks: (Dictionary with: 'org:example' -> 'awesomeVersion' with: 'com:potato' -> '2a.39.451e-rc').

	resolver resolveConflicts: conflicts on: (resolved := Dictionary new).

	self assert: resolved equals: (Dictionary
			 with: 'org:example' -> (self descriptorVersion: 'awesomeVersion')
			 with: 'com:potato' -> (self descriptorVersion: '2a.39.451e-rc'))
]

{ #category : 'tests' }
MooseNexusVersionLockingDependencyConflictResolverTest >> testResolveConflictsOnWithFallback [

	| conflicts resolved |
	conflicts := Dictionary
		             with: 'org:example' -> (self descriptorsWithVersions: #( 'awfulVersion' 'awesomeVersion' 'worstVersion' ))
		             with: 'com:potato' -> (self descriptorsWithVersions: #( '2b.39.451e-rc' '2a.39.451e-rc' )).
	resolver locks: (Dictionary with: 'org:example' -> 'awesomeVersion').

	resolver resolveConflicts: conflicts on: (resolved := Dictionary new).

	self assert: resolved equals: (Dictionary
			 with: 'org:example' -> (self descriptorVersion: 'awesomeVersion')
			 with: 'com:potato' -> (self descriptorVersion: '2b.39.451e-rc'))
]
