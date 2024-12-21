Class {
	#name : 'NexusSemanticVersioningDependencyConflictResolverTest',
	#superclass : 'TestCase',
	#instVars : [
		'resolver'
	],
	#category : 'MooseNexus-Tests',
	#package : 'MooseNexus-Tests'
}

{ #category : 'running' }
NexusSemanticVersioningDependencyConflictResolverTest >> setUp [

	super setUp.
	resolver := NexusSemanticVersioningDependencyConflictResolver new
]

{ #category : 'tests' }
NexusSemanticVersioningDependencyConflictResolverTest >> testCheckAndSortByVersion [

	| descriptors sorted |
	descriptors := {
		               (Dictionary with: #version -> '0.0.0').
		               (Dictionary with: #version -> '0.0.1').
		               (Dictionary with: #version -> '0.1.0').
		               (Dictionary with: #version -> '1.0.0').
		               (Dictionary with: #version -> '1.0.1').
		               (Dictionary with: #version -> '1.1.0').
		               (Dictionary with: #version -> '1.1.1') }
		               asOrderedCollection.

	sorted := (resolver checkAndSortByVersion: descriptors reversed)
		          collect: #value.

	self assert: sorted equals: descriptors
]

{ #category : 'tests' }
NexusSemanticVersioningDependencyConflictResolverTest >> testCheckAndSortByVersionComplex [

	| descriptors sorted |
	descriptors := {
		               (Dictionary with: #version -> '12.3.0').
		               (Dictionary with: #version -> '12.3.0-alpha').
		               (Dictionary with: #version -> '9.5.1').
		               (Dictionary with: #version -> '9.5.1-rc').
		               (Dictionary with: #version -> '9.5').
		               (Dictionary with: #version -> '12e') }
		               asOrderedCollection.

	sorted := (resolver checkAndSortByVersion: descriptors) collect: [
		          :descriptor | descriptor value at: #version ].

	self
		assert: sorted
		equals: { '9.5'. '9.5.1'. '12e'. '12.3.0' } asOrderedCollection
]

{ #category : 'tests' }
NexusSemanticVersioningDependencyConflictResolverTest >> testCheckAndSortByVersionEquallyPartiallyUnparsable [
	"Versions with the same missing parts cannot be resolved against each other."

	| descriptors |
	descriptors := {
		               (Dictionary with: #version -> '1.0').
		               (Dictionary with: #version -> '1.0-alpha').
		               (Dictionary with: #version -> '1.0-rc') }
		               asOrderedCollection.

	self
		assert: (resolver checkAndSortByVersion: descriptors)
		equals: nil
]

{ #category : 'tests' }
NexusSemanticVersioningDependencyConflictResolverTest >> testCheckAndSortByVersionFullyUnparsable [
	"Refuse to choose among equally unparsable versions."

	| descriptors |
	descriptors := {
		               (Dictionary with: #version -> 'alpha').
		               (Dictionary with: #version -> 'beta').
		               (Dictionary with: #version -> 'rc') }
		               asOrderedCollection.

	self
		assert: (resolver checkAndSortByVersion: descriptors)
		equals: nil
]

{ #category : 'tests' }
NexusSemanticVersioningDependencyConflictResolverTest >> testCheckAndSortByVersionOnlyWithSuffixes [
	"Should refuse to select a version if all major.minor.patch match but the suffix does not."

	| descriptors |
	descriptors := {
		               (Dictionary with: #version -> '1.0.0-alpha').
		               (Dictionary with: #version -> '1.0.0-beta').
		               (Dictionary with: #version -> '1.0.0-rc') }
		               asOrderedCollection.

	self
		assert: (resolver checkAndSortByVersion: descriptors)
		equals: nil
]

{ #category : 'tests' }
NexusSemanticVersioningDependencyConflictResolverTest >> testCheckAndSortByVersionWithPartiallyUnparsable [

	| descriptors sorted |
	descriptors := {
		               (Dictionary with: #version -> '0.1').
		               (Dictionary with: #version -> '1.0.1').
		               (Dictionary with: #version -> '1.1.a').
		               (Dictionary with: #version -> '1.1.0') }
		               asOrderedCollection.

	sorted := (resolver checkAndSortByVersion: descriptors) collect:
		          #value.

	self assert: sorted equals: descriptors
]

{ #category : 'tests' }
NexusSemanticVersioningDependencyConflictResolverTest >> testCheckAndSortByVersionWithSuffixes [
	"Can select a version if all major.minor.patch match and one does not have a suffix."

	| descriptors sorted |
	descriptors := {
		               (Dictionary with: #version -> '1.0.0-alpha').
		               (Dictionary with: #version -> '1.0.0-beta').
		               (Dictionary with: #version -> '1.0.0') }
		               asOrderedCollection.

	sorted := (resolver checkAndSortByVersion: descriptors) collect:
		          #value.

	self assert: sorted equals: { descriptors last } asOrderedCollection
]

{ #category : 'tests' }
NexusSemanticVersioningDependencyConflictResolverTest >> testCompareTo [

	| left right |
	left := resolver parseVersion: '1.0.0'.
	right := resolver parseVersion: '2.0.0'.

	self assert: (resolver compare: left to: right).
	self deny: (resolver compare: right to: left)
]

{ #category : 'tests' }
NexusSemanticVersioningDependencyConflictResolverTest >> testCompareToWithUnparsableMajor [

	| left right |
	left := resolver parseVersion: 'alpha'.
	right := resolver parseVersion: '4.2.0'.

	self assert: (resolver compare: left to: right).
	self deny: (resolver compare: right to: left)
]

{ #category : 'tests' }
NexusSemanticVersioningDependencyConflictResolverTest >> testCompareToWithUnparsableMinor [

	| left right |
	left := resolver parseVersion: '5_alpha'.
	right := resolver parseVersion: '4.2.0'.

	self deny: (resolver compare: left to: right).
	self assert: (resolver compare: right to: left)
]

{ #category : 'tests' }
NexusSemanticVersioningDependencyConflictResolverTest >> testCompareToWithUnparsablePatch [

	| left right |
	left := resolver parseVersion: '5.1.rc'.
	right := resolver parseVersion: '4.2.0'.

	self deny: (resolver compare: left to: right).
	self assert: (resolver compare: right to: left)
]

{ #category : 'tests' }
NexusSemanticVersioningDependencyConflictResolverTest >> testParseVersion [

	self assert: (resolver parseVersion: '1.2.3') equals: { 1. 2. 3 }
]

{ #category : 'tests' }
NexusSemanticVersioningDependencyConflictResolverTest >> testParseVersionWithSuffix [

	self
		assert: (resolver parseVersion: '1.2.3-alpha')
		equals: { 1. 2. 3. '-alpha' }
]

{ #category : 'tests' }
NexusSemanticVersioningDependencyConflictResolverTest >> testParseVersionWithUnparsableMajor [

	self assert: (resolver parseVersion: 'a') equals: '???'
]

{ #category : 'tests' }
NexusSemanticVersioningDependencyConflictResolverTest >> testParseVersionWithUnparsableMinor [

	self assert: (resolver parseVersion: '1') equals: { 1. $?. $? }
]

{ #category : 'tests' }
NexusSemanticVersioningDependencyConflictResolverTest >> testParseVersionWithUnparsablePatch [

	self assert: (resolver parseVersion: '1.2') equals: { 1. 2. $? }
]

{ #category : 'tests' }
NexusSemanticVersioningDependencyConflictResolverTest >> testResolveConflictsOn [

	| conflicts resolved |
	conflicts := Dictionary
		             with: 'net:versioned' -> {
				             (Dictionary with: #version -> '8.7.5').
				             (Dictionary with: #version -> '5.3.9').
				             (Dictionary with: #version -> '10.2.0-rc') }
				             asOrderedCollection
		             with: 'org:example' -> {
				             (Dictionary with: #version -> '1.0.0').
				             (Dictionary with: #version -> '2.0.0').
				             (Dictionary with: #version -> '1.1.0') }
				             asOrderedCollection
		             with: 'com:potato' -> {
				             (Dictionary with: #version -> '2.39.451e-rc').
				             (Dictionary with: #version -> '2.39.452e-rc') }
				             asOrderedCollection.

	resolver resolveConflicts: conflicts on: (resolved := Dictionary new).

	self assert: resolved equals: (Dictionary
			 with:
			 'net:versioned' -> (Dictionary with: #version -> '10.2.0-rc')
			 with: 'org:example' -> (Dictionary with: #version -> '2.0.0')
			 with:
			 'com:potato' -> (Dictionary with: #version -> '2.39.452e-rc'))
]

{ #category : 'tests' }
NexusSemanticVersioningDependencyConflictResolverTest >> testResolveConflictsOnWithFallback [

	| conflicts resolved |
	conflicts := Dictionary
		             with: 'net:versioned' -> {
				             (Dictionary with: #version -> '8.7.5').
				             (Dictionary with: #version -> '5.3.9').
				             (Dictionary with: #version -> '10.2.0-rc') }
				             asOrderedCollection
		             with: 'org:example' -> {
				             (Dictionary with: #version -> 'awfulVersion').
				             (Dictionary with: #version -> 'awesomeVersion').
				             (Dictionary with: #version -> 'worstVersion') }
				             asOrderedCollection
		             with: 'com:potato' -> {
				             (Dictionary with: #version -> '2b.39.451e-rc').
				             (Dictionary with: #version -> '2a.39.451e-rc') }
				             asOrderedCollection.

	resolver resolveConflicts: conflicts on: (resolved := Dictionary new).

	self assert: resolved equals: (Dictionary
			 with:
			 'net:versioned' -> (Dictionary with: #version -> '10.2.0-rc')
			 with:
			 'org:example' -> (Dictionary with: #version -> 'awfulVersion')
			 with:
			 'com:potato' -> (Dictionary with: #version -> '2b.39.451e-rc'))
]
