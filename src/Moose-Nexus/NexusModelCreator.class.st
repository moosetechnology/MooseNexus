Class {
	#name : 'NexusModelCreator',
	#superclass : 'Object',
	#instVars : [
		'target'
	],
	#category : 'Moose-Nexus-Modeling',
	#package : 'Moose-Nexus',
	#tag : 'Modeling'
}

{ #category : 'testing' }
NexusModelCreator class >> canHandle: language [

	self subclassResponsibility
]

{ #category : 'instance creation' }
NexusModelCreator class >> defaultImplementation [

	^ self new
]

{ #category : 'instance creation' }
NexusModelCreator class >> forLanguage: language [

	self allSubclassesDo: [ :subclass |
		(subclass canHandle: language) ifTrue: [
			^ subclass defaultImplementation ] ].
	Error signal: 'No NexusModelCreator for this language: ' , language
]

{ #category : 'accessing' }
NexusModelCreator >> target [

	^ target
]

{ #category : 'accessing' }
NexusModelCreator >> target: pathString [

	target := pathString
]
