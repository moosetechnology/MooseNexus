"
I am the abstract source-language detection strategy.

Concrete detectors answer evidence for one language from a project source directory. I do not choose between languages; MooseNexusLanguageDetectionResult owns aggregation and ambiguity handling.
"
Class {
	#name : 'MooseNexusLanguageDetector',
	#superclass : 'Object',
	#category : 'MooseNexus-Project',
	#package : 'MooseNexus',
	#tag : 'Project'
}

{ #category : 'accessing' }
MooseNexusLanguageDetector class >> allDetectors [

	^ (self allSubclasses reject: #isAbstract) sorted: [ :left :right | left language <= right language ]
]

{ #category : 'accessing' }
MooseNexusLanguageDetector class >> detectIn: aDirectory [

	^ MooseNexusLanguageDetectionResult fromDirectory: aDirectory
]

{ #category : 'detecting' }
MooseNexusLanguageDetector class >> evidenceIn: aDirectory [

	self subclassResponsibility
]

{ #category : 'testing' }
MooseNexusLanguageDetector class >> isAbstract [

	^ self == MooseNexusLanguageDetector
]

{ #category : 'capabilities' }
MooseNexusLanguageDetector class >> language [

	self subclassResponsibility
]
