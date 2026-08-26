"
I decide what an importer should do when a declared dependency cannot be resolved to a local artifact.

The default policy fails immediately. Explicit policies can warn and continue, or ignore unresolved dependencies whose descriptor scopes are known to be optional for the build.
"
Class {
	#name : 'MooseNexusUnresolvedDependencyPolicy',
	#superclass : 'Object',
	#instVars : [
		'mode',
		'ignoredScopes'
	],
	#category : 'MooseNexus-Dependency',
	#package : 'MooseNexus',
	#tag : 'Dependency'
}

{ #category : 'instance creation' }
MooseNexusUnresolvedDependencyPolicy class >> fail [

	^ self mode: #fail ignoredScopes: #(  )
]

{ #category : 'instance creation' }
MooseNexusUnresolvedDependencyPolicy class >> ignoreScopes: scopes [

	^ self mode: #ignoreScopes ignoredScopes: scopes
]

{ #category : 'instance creation' }
MooseNexusUnresolvedDependencyPolicy class >> mode: aSymbol ignoredScopes: scopes [

	^ self new initializeMode: aSymbol ignoredScopes: scopes
]

{ #category : 'instance creation' }
MooseNexusUnresolvedDependencyPolicy class >> warnAndContinue [

	^ self mode: #warn ignoredScopes: #(  )
]

{ #category : 'resolving' }
MooseNexusUnresolvedDependencyPolicy >> handleUnresolvedDescriptor: descriptor repository: repository warnings: warnings [

	| scope message |
	scope := repository scopeOf: descriptor.
	(self shouldIgnoreScope: scope) ifTrue: [ ^ nil ].
	message := String streamContents: [ :stream |
			           stream
				           nextPutAll: 'Could not resolve dependency ';
				           nextPutAll: (repository coordinatesOf: descriptor) printString;
				           nextPutAll: ' in scope ';
				           nextPutAll: scope ].
	mode = #warn ifTrue: [
			warnings add: message.
			^ nil ].
	Error signal: message
]

{ #category : 'accessing' }
MooseNexusUnresolvedDependencyPolicy >> ignoredScopes [

	^ ignoredScopes
]

{ #category : 'initialization' }
MooseNexusUnresolvedDependencyPolicy >> initializeMode: aSymbol ignoredScopes: scopes [

	mode := aSymbol.
	ignoredScopes := scopes asSet
]

{ #category : 'accessing' }
MooseNexusUnresolvedDependencyPolicy >> mode [

	^ mode
]

{ #category : 'testing' }
MooseNexusUnresolvedDependencyPolicy >> shouldIgnoreScope: scope [

	^ mode = #ignoreScopes and: [ ignoredScopes includes: scope ]
]
