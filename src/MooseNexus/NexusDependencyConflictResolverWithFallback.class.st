"
If a subclass is unable to make a decision on some conflicts, it will defer to another resolver.
All conflicts will inevitably be resolved when finally deferring to a resolver that is not part of my subclass hierarchy.
The default fallback resolver is `NexusFirstFoundDependencyConflictResolver`.
"
Class {
	#name : 'NexusDependencyConflictResolverWithFallback',
	#superclass : 'NexusDependencyConflictResolver',
	#instVars : [
		'fallbackResolver'
	],
	#category : 'MooseNexus-ConflictResolver',
	#package : 'MooseNexus',
	#tag : 'ConflictResolver'
}

{ #category : 'testing' }
NexusDependencyConflictResolverWithFallback class >> isAbstract [

	^ self == NexusDependencyConflictResolverWithFallback
]

{ #category : 'accessing' }
NexusDependencyConflictResolverWithFallback >> fallbackResolver [

	^ fallbackResolver ifNil: [
		  fallbackResolver := self class newDefaultResolver ]
]

{ #category : 'accessing' }
NexusDependencyConflictResolverWithFallback >> fallbackResolver: aNexusDependencyConflictResolver [

	fallbackResolver := aNexusDependencyConflictResolver
]

{ #category : 'resolving' }
NexusDependencyConflictResolverWithFallback >> resolveRemainingConflicts: conflicts on: dependencies [
	"If a resolver is unable to make a decision on some conflicts, it will defer to another resolver."

	self fallbackResolver resolveConflicts: conflicts on: dependencies
]
