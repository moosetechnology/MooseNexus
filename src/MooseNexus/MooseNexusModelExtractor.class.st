Class {
	#name : 'MooseNexusModelExtractor',
	#superclass : 'MooseNexusToolRequirementsValidator',
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

{ #category : 'capabilities' }
MooseNexusModelExtractor class >> language [

	self subclassResponsibility
]

{ #category : 'capabilities' }
MooseNexusModelExtractor class >> metamodel [

	self subclassResponsibility
]

{ #category : 'capabilities' }
MooseNexusModelExtractor class >> modelFormats [

	self subclassResponsibility
]

{ #category : 'capabilities' }
MooseNexusModelExtractor class >> toolRequirements [

	^ #(  )
]

{ #category : 'capabilities' }
MooseNexusModelExtractor >> language [

	^ self class language
]

{ #category : 'capabilities' }
MooseNexusModelExtractor >> metamodel [

	^ self class metamodel
]

{ #category : 'capabilities' }
MooseNexusModelExtractor >> modelFormats [

	^ self class modelFormats
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

{ #category : 'capabilities' }
MooseNexusModelExtractor >> toolRequirements [

	^ self class toolRequirements
]
