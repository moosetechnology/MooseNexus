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
MooseNexusDependencyConflictResolverTest >> assertResolverDecisionsFrom: versionMap selectVersions: selectedVersions [

	| decisions selectedById |
	decisions := resolver resolveConflicts: (self conflictsFromVersionMap: versionMap).
	selectedById := Dictionary new.
	decisions do: [ :decision | selectedById at: decision conflictId put: decision selectedDependency version ].
	self assert: selectedById equals: selectedVersions
]

{ #category : 'helpers' }
MooseNexusDependencyConflictResolverTest >> conflictId: conflictId versions: versions [

	^ MooseNexusDependencyConflict conflictId: conflictId candidates: (self descriptorsWithVersions: versions)
]

{ #category : 'helpers' }
MooseNexusDependencyConflictResolverTest >> conflictsFromVersionMap: versionMap [

	^ versionMap associations collect: [ :association | self conflictId: association key versions: association value ] as: Array
]

{ #category : 'helpers' }
MooseNexusDependencyConflictResolverTest >> descriptorVersion: version [

	^ MooseNexusDependencyDescriptor
		  coordinates: (MooseNexusCoordinates group: 'test' name: 'dependency' version: version)
		  type: 'jar'
		  scopes: #( 'compile' )
		  path: 'repository/dependency-' , version , '.jar'
]

{ #category : 'helpers' }
MooseNexusDependencyConflictResolverTest >> descriptorsWithVersions: versions [

	^ versions collect: [ :version | self descriptorVersion: version ] as: OrderedCollection
]
