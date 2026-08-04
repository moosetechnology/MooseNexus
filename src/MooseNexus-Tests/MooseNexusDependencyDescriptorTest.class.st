Class {
	#name : 'MooseNexusDependencyDescriptorTest',
	#superclass : 'TestCase',
	#category : 'MooseNexus-Tests-Dependency',
	#package : 'MooseNexus-Tests',
	#tag : 'Dependency'
}

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
