Class {
	#name : 'MooseNexusDependencyDescriptorTest',
	#superclass : 'TestCase',
	#category : 'MooseNexus-Tests-Dependency',
	#package : 'MooseNexus-Tests',
	#tag : 'Dependency'
}

{ #category : 'tests' }
MooseNexusDependencyDescriptorTest >> testDependencyClasspathSelectionPolicyExcludesNonMatchingScopes [

	| dependency policy |
	dependency := MooseNexusDependencyDescriptor
		              coordinates: (MooseNexusCoordinates group: 'org.example' name: 'dep' version: '1.0.0')
		              type: 'jar'
		              scopes: #( 'test' )
		              path: 'repository/dep-1.0.0.jar'.
	policy := MooseNexusDependencyClasspathSelectionPolicy includedScopes: #( 'compile' 'runtime' ).

	self deny: (policy includesDependency: dependency)
]

{ #category : 'tests' }
MooseNexusDependencyDescriptorTest >> testDependencyClasspathSelectionPolicyIncludesMatchingScopes [

	| dependency policy |
	dependency := MooseNexusDependencyDescriptor
		              coordinates: (MooseNexusCoordinates group: 'org.example' name: 'dep' version: '1.0.0')
		              type: 'jar'
		              scopes: #( 'compile' 'runtime' )
		              path: 'repository/dep-1.0.0.jar'.
	policy := MooseNexusDependencyClasspathSelectionPolicy includedScopes: #( 'runtime' ).

	self assert: (policy includesDependency: dependency)
]

{ #category : 'tests' }
MooseNexusDependencyDescriptorTest >> testDependencyGraphDictionaryRoundTrip [

	| dependency graph sameGraph |
	dependency := MooseNexusDependencyDescriptor
		              coordinates: (MooseNexusCoordinates group: 'org.example' name: 'lib' version: '1.0.0')
		              type: 'jar'
		              scopes: #( 'compile' )
		              path: '.m2/repository/org/example/lib/1.0.0/lib-1.0.0.jar'.
	graph := MooseNexusDependencyGraph dependencies: { dependency }.

	sameGraph := MooseNexusDependencyGraph fromDictionary: graph asDictionary.

	self assert: sameGraph equals: graph.
	self assert: sameGraph dependencies equals: { dependency }
]

{ #category : 'tests' }
MooseNexusDependencyDescriptorTest >> testDependencyResolutionResultPreservesMaterializationAudit [

	| dependency materialization result reloadedResult |
	dependency := MooseNexusDependencyDescriptor
		              coordinates: (MooseNexusCoordinates group: 'org.example' name: 'dep' version: '1.0.0')
		              type: 'jar'
		              scopes: #( 'compile' ).
	materialization := MooseNexusDependencyMaterializationResult
		                   dependency: dependency
		                   path: 'dependencies/staged-dependency.jar'
		                   source: 'maven'.
	result := MooseNexusDependencyResolutionResult
		          project: nil
		          dependencies: { dependency }
		          warnings: #(  )
		          decisions: #(  )
		          materializations: { materialization }.

	reloadedResult := MooseNexusDependencyResolutionResult fromDictionary: result asDictionary.

	self assert: reloadedResult equals: result.
	self assert: reloadedResult materializations equals: { materialization }
]

{ #category : 'tests' }
MooseNexusDependencyDescriptorTest >> testDescriptorCopiesPreserveKindAndArtifactIdentity [

	| remote local copiedRemote copiedLocal |
	remote := MooseNexusDependencyDescriptor
		          coordinates: (MooseNexusCoordinates group: 'org.example' name: 'lib' version: '1.0.0')
		          type: 'jar'
		          scopes: #( 'compile' ).
	local := MooseNexusLocalDependencyDescriptor
		         coordinates: remote coordinates
		         type: remote type
		         scopes: remote scopes
		         path: 'repository/lib.jar'.

	copiedRemote := remote withScopes: #( 'runtime' ).
	copiedLocal := local withGroup: 'org.other'.

	self assert: (remote hasSameArtifactAs: copiedRemote).
	self assert: copiedRemote scopes equals: #( 'runtime' ).
	self assert: copiedLocal class equals: MooseNexusLocalDependencyDescriptor.
	self assert: copiedLocal group equals: 'org.other'.
	self assert: copiedLocal path equals: local path.
	self deny: (remote hasSameArtifactAs: local)
]

{ #category : 'tests' }
MooseNexusDependencyDescriptorTest >> testDescriptorIsValueObject [

	| coordinates descriptor sameDescriptor otherDescriptor |
	coordinates := MooseNexusCoordinates group: 'org.example' name: 'lib' version: '1.0.0'.
	descriptor := MooseNexusDependencyDescriptor
		              coordinates: coordinates
		              type: 'jar'
		              scopes: #( 'compile' )
		              path: '.m2/repository/org/example/lib/1.0.0/lib-1.0.0.jar'.
	sameDescriptor := MooseNexusDependencyDescriptor
		                  coordinates: coordinates
		                  type: 'jar'
		                  scopes: #( 'compile' )
		                  path: '.m2/repository/org/example/lib/1.0.0/lib-1.0.0.jar'.
	otherDescriptor := MooseNexusDependencyDescriptor
		                   coordinates: (MooseNexusCoordinates group: 'org.example' name: 'lib' version: '2.0.0')
		                   type: 'jar'
		                   scopes: #( 'compile' )
		                   path: '.m2/repository/org/example/lib/2.0.0/lib-2.0.0.jar'.

	self assert: descriptor equals: sameDescriptor.
	self deny: descriptor equals: otherDescriptor.
	self assert: descriptor coordinates equals: coordinates.
	self assert: descriptor printString equals: 'org.example:lib:1.0.0'
]

{ #category : 'tests' }
MooseNexusDependencyDescriptorTest >> testDictionaryRoundTrip [

	| dictionary descriptor |
	dictionary := Dictionary
		              with: #group -> 'org.example'
		              with: #name -> 'lib'
		              with: #version -> '1.0.0'
		              with: #type -> 'jar'
		              with: #scopes -> #( 'compile' )
		              with: #path -> '.m2/repository/org/example/lib/1.0.0/lib-1.0.0.jar'.
	descriptor := MooseNexusDependencyDescriptor fromDictionary: dictionary.

	self assert: descriptor asDictionary equals: dictionary
]

{ #category : 'tests' }
MooseNexusDependencyDescriptorTest >> testLocalDescriptorSerializesItsPathSeparately [

	| descriptor reloadedDescriptor |
	descriptor := MooseNexusLocalDependencyDescriptor
		              coordinates: (MooseNexusCoordinates group: 'org.example' name: 'lib' version: '1.0.0')
		              type: 'jar'
		              scopes: #( 'compile' )
		              path: '.m2/repository/org/example/lib/1.0.0/lib-1.0.0.jar'.

	reloadedDescriptor := MooseNexusDependencyDescriptor fromDictionary: descriptor asDictionary.

	self assert: descriptor isLocal.
	self assert: (descriptor asDictionary at: #path) equals: descriptor path.
	self assert: reloadedDescriptor class equals: MooseNexusLocalDependencyDescriptor.
	self assert: reloadedDescriptor equals: descriptor
]

{ #category : 'tests' }
MooseNexusDependencyDescriptorTest >> testMaterializationFileNamesDifferentiateArtifactCoordinates [

	| first second |
	first := MooseNexusDependencyDescriptor
		         coordinates: (MooseNexusCoordinates group: 'org.first' name: 'shared' version: '1.0.0')
		         type: 'jar'
		         scopes: #( 'compile' ).
	second := MooseNexusDependencyDescriptor
		          coordinates: (MooseNexusCoordinates group: 'org.second' name: 'shared' version: '1.0.0')
		          type: 'jar'
		          scopes: #( 'compile' ).

	self deny: first materializationFileName equals: second materializationFileName.
	self assert: first materializationFileName equals: '9-org.first6-shared5-1.0.0.jar'
]

{ #category : 'tests' }
MooseNexusDependencyDescriptorTest >> testMaterializationResultIsValueObjectAndRoundTrips [

	| dependency result reloadedResult |
	dependency := MooseNexusDependencyDescriptor
		              coordinates: (MooseNexusCoordinates group: 'org.example' name: 'lib' version: '1.0.0')
		              type: 'jar'
		              scopes: #( 'compile' ).
	result := MooseNexusDependencyMaterializationResult dependency: dependency path: 'dependencies/lib.jar' source: 'maven'.

	reloadedResult := MooseNexusDependencyMaterializationResult fromDictionary: result asDictionary.

	self assert: result equals: reloadedResult.
	self assert: result hash equals: reloadedResult hash.
	self assert: result dependency equals: dependency.
	self assert: result path equals: 'dependencies/lib.jar'.
	self assert: result source equals: 'maven'
]

{ #category : 'tests' }
MooseNexusDependencyDescriptorTest >> testMergeAggregatesScopes [

	| coordinates compile runtime mergedDescriptor |
	coordinates := MooseNexusCoordinates group: 'org.example' name: 'lib' version: '1.0.0'.
	compile := MooseNexusDependencyDescriptor
		           coordinates: coordinates
		           type: 'jar'
		           scopes: #( 'compile' )
		           path: '.m2/repository/org/example/lib/1.0.0/lib-1.0.0.jar'.
	runtime := MooseNexusDependencyDescriptor
		           coordinates: coordinates
		           type: 'jar'
		           scopes: #( 'runtime' )
		           path: '.m2/repository/org/example/lib/1.0.0/lib-1.0.0.jar'.

	mergedDescriptor := compile mergedWith: runtime.

	self assert: mergedDescriptor coordinates equals: coordinates.
	self assert: mergedDescriptor scopes equals: #( 'compile' 'runtime' )
]

{ #category : 'tests' }
MooseNexusDependencyDescriptorTest >> testRemoteDescriptorDoesNotSerializeLocalPath [

	| descriptor reloadedDescriptor |
	descriptor := MooseNexusDependencyDescriptor
		              coordinates: (MooseNexusCoordinates group: 'org.example' name: 'lib' version: '1.0.0')
		              type: 'jar'
		              scopes: #( 'compile' ).

	reloadedDescriptor := MooseNexusDependencyDescriptor fromDictionary: descriptor asDictionary.

	self deny: descriptor isLocal.
	self deny: (descriptor asDictionary includesKey: #path).
	self assert: reloadedDescriptor class equals: MooseNexusDependencyDescriptor.
	self assert: reloadedDescriptor equals: descriptor
]

{ #category : 'tests' }
MooseNexusDependencyDescriptorTest >> testResolvedDependencySetDictionaryRoundTrip [

	| dependency resolvedSet sameSet |
	dependency := MooseNexusDependencyDescriptor
		              coordinates: (MooseNexusCoordinates group: 'org.example' name: 'lib' version: '1.0.0')
		              type: 'jar'
		              scopes: #( 'runtime' )
		              path: '.m2/repository/org/example/lib/1.0.0/lib-1.0.0.jar'.
	resolvedSet := MooseNexusResolvedDependencySet dependencies: { dependency }.

	sameSet := MooseNexusResolvedDependencySet fromDictionaries: resolvedSet asDictionaries.

	self assert: sameSet equals: resolvedSet.
	self assert: sameSet dependencies equals: { dependency }
]

{ #category : 'tests' }
MooseNexusDependencyDescriptorTest >> testUnresolvedDependencyPolicyWarnsAndContinues [

	| policy warnings result |
	policy := MooseNexusUnresolvedDependencyPolicy warnAndContinue.
	warnings := OrderedCollection new.

	result := policy
		          handleUnresolvedDescriptor: 'org.example:dep:jar:1.0.0:compile'
		          repository: MooseNexusMavenRepository default
		          warnings: warnings.

	self assert: result equals: nil.
	self assert: warnings size equals: 1.
	self assert: (warnings first includesSubstring: 'org.example:dep:1.0.0')
]

{ #category : 'tests' }
MooseNexusDependencyDescriptorTest >> testWithGroupAnswersCopy [

	| descriptor groupedDescriptor |
	descriptor := MooseNexusDependencyDescriptor
		              coordinates: (MooseNexusCoordinates group: nil name: 'lib' version: '1.0.0')
		              type: 'jar'
		              scopes: #( 'compile' )
		              path: 'repository/lib-1.0.0.jar'.
	groupedDescriptor := descriptor withGroup: 'org.example'.

	self assert: descriptor group equals: nil.
	self assert: groupedDescriptor group equals: 'org.example'.
	self assert: groupedDescriptor name equals: descriptor name
]

{ #category : 'tests' }
MooseNexusDependencyDescriptorTest >> testWorkspaceDescriptorIsValueObjectAndRoundTrips [

	| coordinates descriptor reloadedDescriptor |
	coordinates := MooseNexusCoordinates group: 'org.example' name: 'workspace-lib' version: '1.0.0'.
	descriptor := MooseNexusWorkspaceDependencyDescriptor coordinates: coordinates scopes: { 'compile'. nil. 'compile'. 'runtime' }.

	reloadedDescriptor := MooseNexusWorkspaceDependencyDescriptor fromDictionary: descriptor asDictionary.

	self assert: descriptor equals: reloadedDescriptor.
	self assert: descriptor hash equals: reloadedDescriptor hash.
	self assert: descriptor coordinates equals: coordinates.
	self assert: descriptor scopes equals: #( 'compile' 'runtime' ).
	self assert: descriptor printString equals: 'org.example:workspace-lib:1.0.0'
]
