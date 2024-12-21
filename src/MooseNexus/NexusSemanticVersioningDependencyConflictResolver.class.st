"
I try to resolve dependency version conflicts using semantic versioning.
The declared version of each dependency descriptor is parsed into an array containing the major, minor and patch versions, plus an optional fourth element for any suffix.
These versions are then sorted to select either the latest or the oldest version, depending on the configuration.
"
Class {
	#name : 'NexusSemanticVersioningDependencyConflictResolver',
	#superclass : 'NexusDependencyConflictResolverWithFallback',
	#instVars : [
		'useLatest'
	],
	#category : 'MooseNexus-ConflictResolver',
	#package : 'MooseNexus',
	#tag : 'ConflictResolver'
}

{ #category : 'resolving' }
NexusSemanticVersioningDependencyConflictResolver >> checkAndSortByVersion: descriptors [
	"Parse all versions, check integrity and sort them from oldest to latest."

	| uniqueVersions versionsWithSuffix suffixedVersionIndices indicesToRemove listWithVersion |
	uniqueVersions := Set new.
	versionsWithSuffix := Bag new.
	suffixedVersionIndices := Dictionary new.
	indicesToRemove := OrderedCollection new.

	"Descriptors are associated with their parsed versions in listWithVersion.
	Versions are added to a set to ensure uniqueness after parsing.
	Versions with a suffix are added to a bag without the suffix to count them."
	listWithVersion := descriptors collectWithIndex: [ :descriptor :index |
		                   | version |
		                   version := self parseVersion:
			                              (descriptor at: #version).
		                   uniqueVersions add: version.
		                   version size = 4 ifTrue: [ "version has suffix"
			                   | suffixless |
			                   suffixless := version allButLast.
			                   versionsWithSuffix add: suffixless.
			                   suffixedVersionIndices
				                   at: suffixless
				                   ifPresent: [ :list | list add: index ]
				                   ifAbsentPut: [ OrderedCollection with: index ] ].
		                   version -> descriptor ].

	"This resolver considers itself unable to correctly select a version
	if either of the two following conditions is true:"

	"If at least two versions are equal,
	which only happens for fully or partially unparsable versions.
	e.g. '1.a' => 1.?.? cannot be compared to '1.b' => 1.?.?"
	uniqueVersions size = listWithVersion size ifFalse: [ ^ nil ].

	"If at least two versions have equal major.minor.patch with different suffixes,
	and there is no equivalent major.minor.patch version without a suffix.
	e.g. '1.0.0-alpha' cannot be compared to '1.0.0-beta'
	this dependency can only be resolved if '1.0.0' also exists"
	versionsWithSuffix doWithOccurrences: [ :version :count |
		(uniqueVersions includes: version)
			ifFalse: [ count > 1 ifTrue: [ ^ nil ] ]
			ifTrue: [ "Gather the indices of the suffixed versions if the base version exists"
				indicesToRemove addAll: (suffixedVersionIndices at: version) ] ].

	"Remove all suffixed versions from the choices,
	this resolver should never pick one when a suffixless version is available."
	(indicesToRemove sort: [ :a :b | a > b ]) do: [ :i |
		listWithVersion removeAtIndex: i ].

	"This dependency conflict can be resolved normally"
	^ listWithVersion sort: [ :a :b | self compare: a key to: b key ]
]

{ #category : 'comparing' }
NexusSemanticVersioningDependencyConflictResolver >> compare: leftVersion to: rightVersion [
	"Compare two versions for sorting. A version is an integer array: { MAJOR. MINOR. PATCH },
	with a potential fourth element for the suffix, e.g. 1.2.3-alpha => { 1. 2. 3. '-alpha' }.
	Any part can also be unparsable and replaced with a character."

	| leftPart rightPart |
	"major"
	leftPart := leftVersion first.
	rightPart := rightVersion first.
	(leftPart isCharacter not and: [ rightPart isCharacter ]) ifTrue: [
		^ false ].
	(leftPart isCharacter and: [ rightPart isCharacter not ]) ifTrue: [
		^ true ].
	leftVersion first > rightVersion first ifTrue: [ ^ false ].
	leftVersion first < rightVersion first ifTrue: [ ^ true ].

	"minor"
	leftPart := leftVersion second.
	rightPart := rightVersion second.
	(leftPart isCharacter not and: [ rightPart isCharacter ]) ifTrue: [
		^ false ].
	(leftPart isCharacter and: [ rightPart isCharacter not ]) ifTrue: [
		^ true ].
	leftPart > rightPart ifTrue: [ ^ false ].
	leftPart < rightPart ifTrue: [ ^ true ].

	"patch"
	leftPart := leftVersion third.
	rightPart := rightVersion third.
	(leftPart isCharacter not and: [ rightPart isCharacter ]) ifTrue: [
		^ false ].
	(leftPart isCharacter and: [ rightPart isCharacter not ]) ifTrue: [
		^ true ].
	leftPart > rightPart ifTrue: [ ^ false ].
	leftPart < rightPart ifTrue: [ ^ true ].

	"comparing suffix, usually something like '-alpha', '-beta' or '-rc' (release candidate)
	for now we prefer a version without suffix, submit an issue if there are special cases"
	leftVersion size > rightVersion size ifTrue: [ ^ false ].
	leftVersion size < rightVersion size ifTrue: [ ^ true ].

	"at this point, only the suffix is different, and this resolver doesn't know how to compare them
	however, it is guaranteed that there exists a dependency with the same version without a suffix
	because of the check in #dependency:sortOnVersion:, so this can ultimately be resolved:
	all versions triggering this last return will never be considered `oldest` or `latest`"
	^ true
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
NexusSemanticVersioningDependencyConflictResolver >> resolveConflictBetween: descriptors [

	^ (self checkAndSortByVersion: descriptors) ifNotNil: [
		  :listWithVersion |
		  (listWithVersion at: (useLatest
				    ifTrue: [ listWithVersion size ]
				    ifFalse: [ 1 ])) value ]
]

{ #category : 'resolving' }
NexusSemanticVersioningDependencyConflictResolver >> resolveConflicts: conflicts on: dependencies [
	"For each dependency conflict, try to select a version based on semantic versioning."

	| remaining |
	remaining := Dictionary new.

	conflicts keysAndValuesDo: [ :groupAndName :descriptors |
		(self resolveConflictBetween: descriptors)
			ifNotNil: [ :chosen | dependencies at: groupAndName put: chosen ]
			ifNil: [ remaining at: groupAndName put: descriptors ] ].

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
