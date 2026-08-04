"
If a subclass is unable to make a decision on some conflicts, it will defer to another resolver.
All conflicts will inevitably be resolved when finally deferring to a resolver that is not part of my subclass hierarchy.
The default fallback resolver is `MooseNexusFirstFoundDependencyConflictResolver`.
"
Class {
	#name : 'MooseNexusDependencyConflictResolverWithFallback',
	#superclass : 'MooseNexusDependencyConflictResolver',
	#instVars : [
		'fallbackResolver'
	],
	#category : 'MooseNexus-ConflictResolver',
	#package : 'MooseNexus',
	#tag : 'ConflictResolver'
}

{ #category : 'testing' }
MooseNexusDependencyConflictResolverWithFallback class >> isAbstract [

	^ self == MooseNexusDependencyConflictResolverWithFallback
]

{ #category : 'accessing' }
MooseNexusDependencyConflictResolverWithFallback >> fallbackResolver [

	^ fallbackResolver ifNil: [ fallbackResolver := self class newDefaultResolver ]
]

{ #category : 'accessing' }
MooseNexusDependencyConflictResolverWithFallback >> fallbackResolver: aMooseNexusDependencyConflictResolver [

	fallbackResolver := aMooseNexusDependencyConflictResolver
]

{ #category : 'resolving' }
MooseNexusDependencyConflictResolverWithFallback >> resolveRemainingConflict: aMooseNexusDependencyConflict [
	"If a resolver is unable to make a decision on a conflict, it defers to another resolver."

	^ self fallbackResolver resolveConflict: aMooseNexusDependencyConflict
]
