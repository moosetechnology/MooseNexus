"
I decide which resolved dependencies should be copied as modelled sources before extraction.

A nil includedScopes value means every dependency is included. An empty includedScopes collection means no dependency is included. Otherwise a dependency is included when at least one of its scopes is present in includedScopes.
"
Class {
	#name : 'MooseNexusDependencySourceSelectionPolicy',
	#superclass : 'Object',
	#instVars : [
		'includedScopes'
	],
	#category : 'MooseNexus-Dependency',
	#package : 'MooseNexus',
	#tag : 'Dependency'
}

{ #category : 'instance creation' }
MooseNexusDependencySourceSelectionPolicy class >> all [

	^ self includedScopes: nil
]

{ #category : 'instance creation' }
MooseNexusDependencySourceSelectionPolicy class >> includedScopes: scopes [

	^ self new initializeIncludedScopes: scopes
]

{ #category : 'instance creation' }
MooseNexusDependencySourceSelectionPolicy class >> none [

	^ self includedScopes: #(  )
]

{ #category : 'accessing' }
MooseNexusDependencySourceSelectionPolicy >> includedScopes [

	^ includedScopes
]

{ #category : 'testing' }
MooseNexusDependencySourceSelectionPolicy >> includesDependency: aMooseNexusDependencyDescriptor [

	includedScopes ifNil: [ ^ true ].
	includedScopes ifEmpty: [ ^ false ].
	^ aMooseNexusDependencyDescriptor scopes anySatisfy: [ :scope | includedScopes includes: scope ]
]

{ #category : 'initialization' }
MooseNexusDependencySourceSelectionPolicy >> initializeIncludedScopes: scopes [

	includedScopes := scopes ifNotNil: [ scopes asSet ]
]
