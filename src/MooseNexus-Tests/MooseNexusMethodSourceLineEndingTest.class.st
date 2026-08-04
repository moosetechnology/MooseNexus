"
I guard against Pharo method sources containing LF line separators.

Pharo method sources should use CR separators. LF can be introduced when methods are compiled from filesystem-oriented tooling instead of through Pharo-aware APIs.
"
Class {
	#name : 'MooseNexusMethodSourceLineEndingTest',
	#superclass : 'TestCase',
	#category : 'MooseNexus-Tests',
	#package : 'MooseNexus-Tests'
}

{ #category : 'private' }
MooseNexusMethodSourceLineEndingTest >> packageMethodsWithLinefeeds [

	| packages rule |
	packages := (IceRepository repositoryNamed: 'MooseNexus') workingCopy packages collect: [ :package | package package asPackage ].
	rule := ReMethodSourceContainsLinefeedsRule new.
	^ packages flatCollect: [ :package | package methods select: [ :method | (rule check: method) isNotEmpty ] ]
]

{ #category : 'tests' }
MooseNexusMethodSourceLineEndingTest >> testMooseNexusMethodSourcesDoNotContainLinefeeds [

	| methodsWithLinefeeds |
	methodsWithLinefeeds := self packageMethodsWithLinefeeds.
	self
		assert: methodsWithLinefeeds isEmpty
		description: (String streamContents: [ :stream |
				 stream nextPutAll: 'Methods with LF separators: '.
				 methodsWithLinefeeds
					 do: [ :method |
						 stream
							 nextPutAll: method methodClass name;
							 nextPutAll: '>>#';
							 nextPutAll: method selector ]
					 separatedBy: [ stream nextPutAll: ', ' ] ])
]
