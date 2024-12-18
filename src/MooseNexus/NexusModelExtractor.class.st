Class {
	#name : 'NexusModelExtractor',
	#superclass : 'Object',
	#instVars : [
		'target'
	],
	#category : 'MooseNexus-ModelExtraction',
	#package : 'MooseNexus',
	#tag : 'ModelExtraction'
}

{ #category : 'testing' }
NexusModelExtractor class >> canHandle: language [

	self subclassResponsibility
]

{ #category : 'instance creation' }
NexusModelExtractor class >> defaultImplementation [

	^ self new
]

{ #category : 'instance creation' }
NexusModelExtractor class >> forLanguage: language [

	self allSubclassesDo: [ :subclass |
		(subclass canHandle: language) ifTrue: [
			^ subclass defaultImplementation ] ].
	Error signal: 'No NexusModelCreator for this language: ' , language
]

{ #category : 'testing' }
NexusModelExtractor class >> isAbstract [

	^ self == NexusModelExtractor
]

{ #category : 'accessing' }
NexusModelExtractor >> target [

	^ target
]

{ #category : 'accessing' }
NexusModelExtractor >> target: pathString [

	target := pathString
]
