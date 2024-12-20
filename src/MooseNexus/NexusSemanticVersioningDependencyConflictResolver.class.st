Class {
	#name : 'NexusSemanticVersioningDependencyConflictResolver',
	#superclass : 'NexusDependencyConflictResolverWithFallback',
	#instVars : [
		'useLatest'
	],
	#category : 'MooseNexus-Strategy',
	#package : 'MooseNexus',
	#tag : 'Strategy'
}

{ #category : 'comparing' }
NexusSemanticVersioningDependencyConflictResolver >> compareDependency: groupAndName between: leftVersion and: rightVersion [
	"Compare two versions for sorting. A version is an array: { MAJOR. MINOR. PATCH }, with a potential fourth element for the suffix."

	"check if one could be parsed and not the other, prioritize the parsable version(?)"
	leftVersion ifNil: [ ^ false ].
	rightVersion ifNil: [ ^ true ].

	"comparing major"
	leftVersion first > rightVersion first ifTrue: [ ^ false ].
	leftVersion first < rightVersion first ifTrue: [ ^ true ].

	"minor"
	leftVersion second > rightVersion second ifTrue: [ ^ false ].
	leftVersion second < rightVersion second ifTrue: [ ^ true ].

	"patch"
	leftVersion third > rightVersion third ifTrue: [ ^ false ].
	leftVersion third < rightVersion third ifTrue: [ ^ true ].

	"comparing suffix, usually something like '-alpha', '-beta' or '-rc' (release candidate)
	for now we prefer a version without suffix, submit an issue if there are special cases"
	leftVersion size > rightVersion size ifTrue: [ ^ false ].
	leftVersion size < rightVersion size ifTrue: [ ^ true ].

	"at this point, only the suffix is different, and we don't know how to compare them
	however it is guaranteed that there is the same version without a suffix, so this can be resolved"
	^ true
]

{ #category : 'resolving' }
NexusSemanticVersioningDependencyConflictResolver >> dependency: groupAndName sortOnVersion: conflictList [

	| versionSet versionsWithSuffix listWithVersion |
	versionSet := Set new.
	versionsWithSuffix := Bag new.
	listWithVersion := conflictList
		                   collect: [ :descriptor |
			                   | version |
			                   version := self parseVersion:
				                              (descriptor at: #version).
			                   versionSet add: version.
			                   version size = 4 ifTrue: [
				                   versionsWithSuffix add: version allButLast ].
			                   version -> descriptor ]
		                   as: Array.

	"This resolver considers it is unable to choose a version correctly if one of the following holds:"
	"If at least two versions were equally not parsable"
	versionSet size = listWithVersion size ifFalse: [ ^ nil ].

	"If at least two versions have equal major.minor.patch with different suffixes,
	and there is no equal version without a suffix"
	versionsWithSuffix doWithOccurrences: [ :version :count |
		((versionSet includes: version) not and: [ count > 1 ]) ifTrue: [
			^ nil ] ].

	"This dependency conflict can be resolved normally"
	listWithVersion sort: [ :a :b |
		self compareDependency: groupAndName between: a key and: b key ].
	^ listWithVersion
]

{ #category : 'initialization' }
NexusSemanticVersioningDependencyConflictResolver >> initialize [

	self useLatest
]

{ #category : 'parsing' }
NexusSemanticVersioningDependencyConflictResolver >> parseVersion: aString [
	"Lenient parsing of a semantic version string into an array of integers.
	Accepts that minor and patch are omitted, and includes any remaining suffix as the fourth element."

	aString first isDigit ifFalse: [ ^ '???' ].

	aString readStreamDo: [ :s |
		| parser major minor patch |
		parser := NumberParser on: s.
		"parser failBlock: [
			^ {
				  (major ifNotNil: [ major ] ifNil: [ $? ]).
				  (minor ifNotNil: [ minor ] ifNil: [ $? ]).
				  $? } ]."

		major := parser nextUnsignedIntegerBase: 10 ifFail: [ ^ '???' ].
		(s atEnd or: [ s next ~~ $. ]) ifTrue: [
			^ {
				  major.
				  $?.
				  $? } ].

		minor := parser nextUnsignedIntegerBase: 10 ifFail: [
			         ^ {
				           major.
				           $?.
				           $? } ].
		(s atEnd or: [ s next ~~ $. ]) ifTrue: [
			^ {
				  major.
				  minor.
				  $? } ].

		patch := parser nextUnsignedIntegerBase: 10 ifFail: [
			         ^ {
				           major.
				           minor.
				           $? } ].
		s atEnd ifTrue: [
			^ {
				  major.
				  minor.
				  patch } ].

		^ {
			  major.
			  minor.
			  patch.
			  s upToEnd } ]
]

{ #category : 'resolving' }
NexusSemanticVersioningDependencyConflictResolver >> resolveConflict: groupAndName between: conflictList [
	"Parse all versions and sort them from oldest to latest."

	^ (self dependency: groupAndName sortOnVersion: conflictList)
		  ifNotNil: [ :listWithVersion |
			  (listWithVersion at: (useLatest
					    ifTrue: [ listWithVersion size ]
					    ifFalse: [ 1 ])) value ]
]

{ #category : 'resolving' }
NexusSemanticVersioningDependencyConflictResolver >> resolveConflicts: conflicts on: dependencies [

	| remaining |
	remaining := Dictionary new.

	conflicts keysAndValuesDo: [ :groupAndName :conflictList |
		(self resolveConflict: groupAndName between: conflictList)
			ifNotNil: [ :chosen | dependencies at: groupAndName put: chosen ]
			ifNil: [ remaining at: groupAndName put: conflictList ] ].

	remaining ifNotEmpty: [
		self resolveRemainingConflicts: remaining on: dependencies ]
]

{ #category : 'configuring' }
NexusSemanticVersioningDependencyConflictResolver >> useLatest [

	useLatest := true
]

{ #category : 'configuring' }
NexusSemanticVersioningDependencyConflictResolver >> useOldest [

	useLatest := false
]
