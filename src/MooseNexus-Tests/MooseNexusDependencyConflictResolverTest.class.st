"
I am the abstract superclass for dependency conflict resolver tests.

I provide common descriptor fixtures so concrete resolver tests can focus on their resolver policy.
"
Class {
	#name : 'MooseNexusDependencyConflictResolverTest',
	#superclass : 'TestCase',
	#instVars : [
		'resolver'
	],
	#category : 'MooseNexus-Tests',
	#package : 'MooseNexus-Tests'
}

{ #category : 'testing' }
MooseNexusDependencyConflictResolverTest class >> isAbstract [

	^ self == MooseNexusDependencyConflictResolverTest
]

{ #category : 'helpers' }
MooseNexusDependencyConflictResolverTest >> descriptorVersion: version [

	^ MooseNexusDependencyDescriptor
		  group: 'test'
		  name: 'dependency'
		  version: version
		  type: 'jar'
		  scopes: #( 'compile' )
		  path: 'repository/dependency-' , version , '.jar'
]

{ #category : 'helpers' }
MooseNexusDependencyConflictResolverTest >> descriptorsWithVersions: versions [

	^ versions collect: [ :version | self descriptorVersion: version ] as: OrderedCollection
]
