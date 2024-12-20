Class {
	#name : 'NexusDependencyConflictResolverWithFallback',
	#superclass : 'NexusDependencyConflictResolver',
	#instVars : [
		'fallbackResolver'
	],
	#category : 'MooseNexus-Strategy',
	#package : 'MooseNexus',
	#tag : 'Strategy'
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

{ #category : 'as yet unclassified' }
NexusDependencyConflictResolverWithFallback >> resolveRemainingConflicts: conflicts on: dependencies [

	self fallbackResolver resolveConflicts: conflicts on: dependencies
]
