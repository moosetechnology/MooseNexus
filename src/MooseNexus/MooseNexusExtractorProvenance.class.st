"
I describe the extractor configuration used to produce a model artifact.

I record the selected runner implementation, an optional configured tool or image reference, and the runner options that affect the produced model. I deliberately do not identify source-control state or machine-specific local runner paths.
"
Class {
	#name : 'MooseNexusExtractorProvenance',
	#superclass : 'Object',
	#instVars : [
		'runnerName',
		'identity',
		'options'
	],
	#category : 'MooseNexus-Artifact',
	#package : 'MooseNexus',
	#tag : 'Artifact'
}

{ #category : 'instance creation' }
MooseNexusExtractorProvenance class >> fromDictionary: aDictionary [

	^ self
		  runnerName: (aDictionary at: 'runner')
		  identity: (aDictionary at: 'identity' ifAbsent: [ nil ])
		  options: (aDictionary at: 'options' ifAbsent: [ Dictionary new ])
]

{ #category : 'instance creation' }
MooseNexusExtractorProvenance class >> runnerName: aRunnerName identity: anIdentity options: anOptions [

	^ self new initializeRunnerName: aRunnerName identity: anIdentity options: anOptions
]

{ #category : 'instance creation' }
MooseNexusExtractorProvenance class >> unknown [

	^ self runnerName: 'unknown' identity: nil options: Dictionary new
]

{ #category : 'comparing' }
MooseNexusExtractorProvenance >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].

	^ anObject runnerName = runnerName and: [ anObject identity = identity and: [ anObject options = options ] ]
]

{ #category : 'converting' }
MooseNexusExtractorProvenance >> asDictionary [

	| dictionary |
	dictionary := Dictionary with: 'runner' -> runnerName with: 'options' -> options copy.
	identity ifNotNil: [ :reference | dictionary at: 'identity' put: reference ].
	^ dictionary
]

{ #category : 'comparing' }
MooseNexusExtractorProvenance >> hash [

	^ runnerName hash bitXor: (identity hash bitXor: options hash)
]

{ #category : 'accessing' }
MooseNexusExtractorProvenance >> identity [

	^ identity
]

{ #category : 'initialization' }
MooseNexusExtractorProvenance >> initializeRunnerName: aRunnerName identity: anIdentity options: anOptions [

	super initialize.
	runnerName := aRunnerName.
	identity := anIdentity.
	options := anOptions copy
]

{ #category : 'accessing' }
MooseNexusExtractorProvenance >> options [

	^ options copy
]

{ #category : 'accessing' }
MooseNexusExtractorProvenance >> runnerName [

	^ runnerName
]
