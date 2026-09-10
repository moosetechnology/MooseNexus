"
I select which dependency artifacts are materialized into the extractor classpath. I do not decide whether dependency classes are represented in a Moose model.
"
Class {
	#name : 'MooseNexusDependencyClasspathSelectionPolicy',
	#superclass : 'Object',
	#instVars : [
		'includedScopes'
	],
	#category : 'MooseNexus-Dependency',
	#package : 'MooseNexus',
	#tag : 'Dependency'
}

{ #category : 'instance creation' }
MooseNexusDependencyClasspathSelectionPolicy class >> all [

	^ self includedScopes: nil
]

{ #category : 'instance creation' }
MooseNexusDependencyClasspathSelectionPolicy class >> includedScopes: scopes [

	^ self new initializeIncludedScopes: scopes
]

{ #category : 'instance creation' }
MooseNexusDependencyClasspathSelectionPolicy class >> none [

	^ self includedScopes: #(  )
]

{ #category : 'accessing' }
MooseNexusDependencyClasspathSelectionPolicy >> includedScopes [

	^ includedScopes
]

{ #category : 'testing' }
MooseNexusDependencyClasspathSelectionPolicy >> includesDependency: aMooseNexusDependencyDescriptor [

	includedScopes ifNil: [ ^ true ].
	includedScopes ifEmpty: [ ^ false ].
	^ aMooseNexusDependencyDescriptor scopes anySatisfy: [ :scope | includedScopes includes: scope ]
]

{ #category : 'initialization' }
MooseNexusDependencyClasspathSelectionPolicy >> initializeIncludedScopes: scopes [

	includedScopes := scopes ifNotNil: [ scopes asSet ]
]
