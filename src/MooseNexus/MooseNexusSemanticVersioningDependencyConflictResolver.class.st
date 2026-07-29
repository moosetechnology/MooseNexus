"
I try to resolve dependency version conflicts using semantic versioning.
The declared version of each dependency descriptor is parsed into an array containing the major, minor and patch versions, plus an optional fourth element for any suffix.
These versions are then sorted to select either the latest or the oldest version, depending on the configuration.
"
Class {
	#name : 'MooseNexusSemanticVersioningDependencyConflictResolver',
	#superclass : 'MooseNexusDependencyConflictResolverWithFallback',
	#instVars : [
		'useLatest'
	],
	#category : 'MooseNexus-ConflictResolver',
	#package : 'MooseNexus',
	#tag : 'ConflictResolver'
}

{ #category : 'resolving' }
MooseNexusSemanticVersioningDependencyConflictResolver >> checkAndSortByVersion: descriptors [
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
			                   version := self parseVersion: (descriptor at: #version).
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
	(indicesToRemove sort: [ :a :b | a > b ]) do: [ :i | listWithVersion removeAt: i ].

	"This dependency conflict can be resolved normally"
	^ listWithVersion sort: [ :a :b | self compare: a key to: b key ]
]

{ #category : 'comparing' }
MooseNexusSemanticVersioningDependencyConflictResolver >> compare: leftVersion to: rightVersion [
	"Compare two versions for sorting. A version is an integer array: { MAJOR. MINOR. PATCH },
	with a potential fourth element for the suffix, e.g. 1.2.3-alpha => { 1. 2. 3. '-alpha' }.
	Any part can also be unparsable and replaced with a character."

	| leftPart rightPart |
	"major"
	leftPart := leftVersion first.
	rightPart := rightVersion first.
	(leftPart isCharacter not and: [ rightPart isCharacter ]) ifTrue: [ ^ false ].
	(leftPart isCharacter and: [ rightPart isCharacter not ]) ifTrue: [ ^ true ].
	leftVersion first > rightVersion first ifTrue: [ ^ false ].
	leftVersion first < rightVersion first ifTrue: [ ^ true ].

	"minor"
	leftPart := leftVersion second.
	rightPart := rightVersion second.
	(leftPart isCharacter not and: [ rightPart isCharacter ]) ifTrue: [ ^ false ].
	(leftPart isCharacter and: [ rightPart isCharacter not ]) ifTrue: [ ^ true ].
	leftPart > rightPart ifTrue: [ ^ false ].
	leftPart < rightPart ifTrue: [ ^ true ].

	"patch"
	leftPart := leftVersion third.
	rightPart := rightVersion third.
	(leftPart isCharacter not and: [ rightPart isCharacter ]) ifTrue: [ ^ false ].
	(leftPart isCharacter and: [ rightPart isCharacter not ]) ifTrue: [ ^ true ].
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

{ #category : 'accessing' }
MooseNexusSemanticVersioningDependencyConflictResolver >> displayName [

	^ 'Semantic Versioning'
]

{ #category : 'initialization' }
MooseNexusSemanticVersioningDependencyConflictResolver >> initialize [

	self useLatest
]

{ #category : 'parsing' }
MooseNexusSemanticVersioningDependencyConflictResolver >> parseVersion: aString [
	"Lenient parsing semantic version string into array integers.
	Accepts minor patch omitted, includes any remaining suffix fourth element."

	| stream major minor patch |
	aString ifEmpty: [ ^ '???' ].
	aString first isDigit ifFalse: [ ^ '???' ].

	stream := aString readStream.
	major := self parseVersionNumberFrom: stream ifAbsent: [ ^ '???' ].
	(stream atEnd or: [ stream next ~~ $. ]) ifTrue: [
			^ {
				  major.
				  $?.
				  $? } ].

	minor := self parseVersionNumberFrom: stream ifAbsent: [
			         ^ {
				           major.
				           $?.
				           $? } ].
	(stream atEnd or: [ stream next ~~ $. ]) ifTrue: [
			^ {
				  major.
				  minor.
				  $? } ].

	patch := self parseVersionNumberFrom: stream ifAbsent: [
			         ^ {
				           major.
				           minor.
				           $? } ].
	stream atEnd ifTrue: [
			^ {
				  major.
				  minor.
				  patch } ].

	^ {
		  major.
		  minor.
		  patch.
		  stream upToEnd }
]

{ #category : 'parsing' }
MooseNexusSemanticVersioningDependencyConflictResolver >> parseVersionNumberFrom: aStream ifAbsent: absentBlock [
	"Read a numeric version component without requiring the following character to be valid Smalltalk number syntax."

	| number |
	(aStream atEnd or: [ aStream peek isDigit not ]) ifTrue: [ ^ absentBlock value ].

	number := 0.
	[ aStream atEnd not and: [ aStream peek isDigit ] ] whileTrue: [ number := number * 10 + aStream next digitValue ].

	^ number
]

{ #category : 'resolving' }
MooseNexusSemanticVersioningDependencyConflictResolver >> resolveConflictBetween: descriptors [

	^ (self checkAndSortByVersion: descriptors) ifNotNil: [ :listWithVersion |
			  (listWithVersion at: (useLatest
					    ifTrue: [ listWithVersion size ]
					    ifFalse: [ 1 ])) value ]
]

{ #category : 'resolving' }
MooseNexusSemanticVersioningDependencyConflictResolver >> resolveConflicts: conflicts on: dependencies [
	"For each dependency conflict, try to select a version based on semantic versioning."

	| remaining |
	remaining := Dictionary new.

	conflicts keysAndValuesDo: [ :groupAndName :descriptors |
			(self resolveConflictBetween: descriptors)
				ifNotNil: [ :chosen | dependencies at: groupAndName put: chosen ]
				ifNil: [ remaining at: groupAndName put: descriptors ] ].

	remaining ifNotEmpty: [ self resolveRemainingConflicts: remaining on: dependencies ]
]

{ #category : 'configuring' }
MooseNexusSemanticVersioningDependencyConflictResolver >> useLatest [

	useLatest := true
]

{ #category : 'configuring' }
MooseNexusSemanticVersioningDependencyConflictResolver >> useOldest [

	useLatest := false
]
