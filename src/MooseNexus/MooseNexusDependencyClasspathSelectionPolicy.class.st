"
I select which dependency classpath inputs are materialized for an extractor. I do not decide whether dependency classes are represented in a Moose model.
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
MooseNexusDependencyClasspathSelectionPolicy >> includesDependency: aClasspathInput [

	aClasspathInput supportsClasspathMaterialization ifFalse: [ ^ false ].
	includedScopes ifNil: [ ^ true ].
	includedScopes ifEmpty: [ ^ false ].
	^ aClasspathInput scopes anySatisfy: [ :scope | includedScopes includes: scope ]
]

{ #category : 'initialization' }
MooseNexusDependencyClasspathSelectionPolicy >> initializeIncludedScopes: scopes [

	includedScopes := scopes ifNotNil: [ scopes asSet ]
]
