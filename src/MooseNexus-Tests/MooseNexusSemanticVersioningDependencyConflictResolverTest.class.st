Class {
	#name : 'MooseNexusSemanticVersioningDependencyConflictResolverTest',
	#superclass : 'MooseNexusDependencyConflictResolverTest',
	#category : 'MooseNexus-Tests',
	#package : 'MooseNexus-Tests'
}

{ #category : 'running' }
MooseNexusSemanticVersioningDependencyConflictResolverTest >> setUp [

	super setUp.
	resolver := MooseNexusSemanticVersioningDependencyConflictResolver new
]

{ #category : 'tests' }
MooseNexusSemanticVersioningDependencyConflictResolverTest >> testCheckAndSortByVersion [

	| descriptors sorted |
	descriptors := self descriptorsWithVersions: #( '0.0.0' '0.0.1' '0.1.0' '1.0.0' '1.0.1' '1.1.0' '1.1.1' ).

	sorted := (resolver checkAndSortByVersion: descriptors reversed) collect: #value.

	self assert: sorted equals: descriptors
]

{ #category : 'tests' }
MooseNexusSemanticVersioningDependencyConflictResolverTest >> testCheckAndSortByVersionComplex [

	| descriptors sorted |
	descriptors := self descriptorsWithVersions: #( '12.3.0' '12.3.0-alpha' '9.5.1' '9.5.1-rc' '9.5' '12e' ).

	sorted := (resolver checkAndSortByVersion: descriptors) collect: [ :descriptor | descriptor value version ].

	self assert: sorted equals: { '9.5'. '9.5.1'. '12e'. '12.3.0' } asOrderedCollection
]

{ #category : 'tests' }
MooseNexusSemanticVersioningDependencyConflictResolverTest >> testCheckAndSortByVersionEquallyPartiallyUnparsable [
	"Versions with the same missing parts cannot be resolved against each other."

	| descriptors |
	descriptors := self descriptorsWithVersions: #( '1.0' '1.0-alpha' '1.0-rc' ).

	self assert: (resolver checkAndSortByVersion: descriptors) equals: nil
]

{ #category : 'tests' }
MooseNexusSemanticVersioningDependencyConflictResolverTest >> testCheckAndSortByVersionFullyUnparsable [
	"Refuse to choose among equally unparsable versions."

	| descriptors |
	descriptors := self descriptorsWithVersions: #( 'alpha' 'beta' 'rc' ).

	self assert: (resolver checkAndSortByVersion: descriptors) equals: nil
]

{ #category : 'tests' }
MooseNexusSemanticVersioningDependencyConflictResolverTest >> testCheckAndSortByVersionOnlyWithSuffixes [
	"Should refuse to select a version if all major.minor.patch match but the suffix does not."

	| descriptors |
	descriptors := self descriptorsWithVersions: #( '1.0.0-alpha' '1.0.0-beta' '1.0.0-rc' ).

	self assert: (resolver checkAndSortByVersion: descriptors) equals: nil
]

{ #category : 'tests' }
MooseNexusSemanticVersioningDependencyConflictResolverTest >> testCheckAndSortByVersionWithPartiallyUnparsable [

	| descriptors sorted |
	descriptors := self descriptorsWithVersions: #( '0.1' '1.0.1' '1.1.a' '1.1.0' ).

	sorted := (resolver checkAndSortByVersion: descriptors) collect: #value.

	self assert: sorted equals: descriptors
]

{ #category : 'tests' }
MooseNexusSemanticVersioningDependencyConflictResolverTest >> testCheckAndSortByVersionWithSuffixes [
	"Can select a version if all major.minor.patch match and one does not have a suffix."

	| descriptors sorted |
	descriptors := self descriptorsWithVersions: #( '1.0.0-alpha' '1.0.0-beta' '1.0.0' ).

	sorted := (resolver checkAndSortByVersion: descriptors) collect: #value.

	self assert: sorted equals: { descriptors last } asOrderedCollection
]

{ #category : 'tests' }
MooseNexusSemanticVersioningDependencyConflictResolverTest >> testCompareTo [

	| left right |
	left := resolver parseVersion: '1.0.0'.
	right := resolver parseVersion: '2.0.0'.

	self assert: (resolver compare: left to: right).
	self deny: (resolver compare: right to: left)
]

{ #category : 'tests' }
MooseNexusSemanticVersioningDependencyConflictResolverTest >> testCompareToWithUnparsableMajor [

	| left right |
	left := resolver parseVersion: 'alpha'.
	right := resolver parseVersion: '4.2.0'.

	self assert: (resolver compare: left to: right).
	self deny: (resolver compare: right to: left)
]

{ #category : 'tests' }
MooseNexusSemanticVersioningDependencyConflictResolverTest >> testCompareToWithUnparsableMinor [

	| left right |
	left := resolver parseVersion: '5_alpha'.
	right := resolver parseVersion: '4.2.0'.

	self deny: (resolver compare: left to: right).
	self assert: (resolver compare: right to: left)
]

{ #category : 'tests' }
MooseNexusSemanticVersioningDependencyConflictResolverTest >> testCompareToWithUnparsablePatch [

	| left right |
	left := resolver parseVersion: '5.1.rc'.
	right := resolver parseVersion: '4.2.0'.

	self deny: (resolver compare: left to: right).
	self assert: (resolver compare: right to: left)
]

{ #category : 'tests' }
MooseNexusSemanticVersioningDependencyConflictResolverTest >> testParseVersion [

	self assert: (resolver parseVersion: '1.2.3') equals: { 1. 2. 3 }
]

{ #category : 'tests' }
MooseNexusSemanticVersioningDependencyConflictResolverTest >> testParseVersionWithSuffix [

	self assert: (resolver parseVersion: '1.2.3-alpha') equals: { 1. 2. 3. '-alpha' }
]

{ #category : 'tests' }
MooseNexusSemanticVersioningDependencyConflictResolverTest >> testParseVersionWithUnparsableMajor [

	self assert: (resolver parseVersion: 'a') equals: '???'
]

{ #category : 'tests' }
MooseNexusSemanticVersioningDependencyConflictResolverTest >> testParseVersionWithUnparsableMinor [

	self assert: (resolver parseVersion: '1') equals: { 1. $?. $? }
]

{ #category : 'tests' }
MooseNexusSemanticVersioningDependencyConflictResolverTest >> testParseVersionWithUnparsablePatch [

	self assert: (resolver parseVersion: '1.2') equals: { 1. 2. $? }
]

{ #category : 'tests' }
MooseNexusSemanticVersioningDependencyConflictResolverTest >> testResolveConflicts [

	self
		assertResolverDecisionsFrom: (Dictionary
				 with: 'net:versioned' -> #( '8.7.5' '5.3.9' '10.2.0-rc' )
				 with: 'org:example' -> #( '1.0.0' '2.0.0' '1.1.0' )
				 with: 'com:potato' -> #( '2.39.451e-rc' '2.39.452e-rc' ))
		selectVersions:
		(Dictionary with: 'net:versioned' -> '10.2.0-rc' with: 'org:example' -> '2.0.0' with: 'com:potato' -> '2.39.452e-rc')
]

{ #category : 'tests' }
MooseNexusSemanticVersioningDependencyConflictResolverTest >> testResolveConflictsUsingOldest [

	resolver useOldest.
	self
		assertResolverDecisionsFrom: (Dictionary
				 with: 'net:versioned' -> #( '8.7.5' '5.3.9' '10.2.0-rc' )
				 with: 'org:example' -> #( '1.0.0' '2.0.0' '1.1.0' )
				 with: 'com:potato' -> #( '2.39.451e-rc' '2.39.452e-rc' ))
		selectVersions:
		(Dictionary with: 'net:versioned' -> '5.3.9' with: 'org:example' -> '1.0.0' with: 'com:potato' -> '2.39.451e-rc')
]

{ #category : 'tests' }
MooseNexusSemanticVersioningDependencyConflictResolverTest >> testResolveConflictsWithFallback [

	self
		assertResolverDecisionsFrom: (Dictionary
				 with: 'net:versioned' -> #( '8.7.5' '5.3.9' '10.2.0-rc' )
				 with: 'org:example' -> #( 'awfulVersion' 'awesomeVersion' 'worstVersion' )
				 with: 'com:potato' -> #( '2b.39.451e-rc' '2a.39.451e-rc' ))
		selectVersions:
		(Dictionary with: 'net:versioned' -> '10.2.0-rc' with: 'org:example' -> 'awfulVersion' with: 'com:potato' -> '2b.39.451e-rc')
]
