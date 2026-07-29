Class {
	#name : 'MooseNexusModelExtractor',
	#superclass : 'Object',
	#instVars : [
		'target'
	],
	#category : 'MooseNexus-ModelExtraction',
	#package : 'MooseNexus',
	#tag : 'ModelExtraction'
}

{ #category : 'testing' }
MooseNexusModelExtractor class >> canHandle: language [

	self subclassResponsibility
]

{ #category : 'instance creation' }
MooseNexusModelExtractor class >> defaultImplementation [

	self subclassResponsibility
]

{ #category : 'instance creation' }
MooseNexusModelExtractor class >> forLanguage: language [

	self allSubclassesDo: [ :subclass | (subclass canHandle: language) ifTrue: [ ^ subclass defaultImplementation ] ].
	Error signal: 'No MooseNexusModelExtractor for this language: ' , language
]

{ #category : 'testing' }
MooseNexusModelExtractor class >> isAbstract [

	^ self == MooseNexusModelExtractor
]

{ #category : 'running' }
MooseNexusModelExtractor >> run [
	"Execute the extractor and return the generated model file location."

	self subclassResponsibility
]

{ #category : 'accessing' }
MooseNexusModelExtractor >> target [

	^ target
]

{ #category : 'accessing' }
MooseNexusModelExtractor >> target: pathString [

	target := pathString
]
