"
I represent a local dependency repository of a build automation tool.
Each of my subclasses knows how to resolve a dependency based on a descriptor string based on the indexing of a specific tool.
"
Class {
	#name : 'NexusDependencyRepository',
	#superclass : 'Object',
	#instVars : [
		'directory'
	],
	#category : 'MooseNexus-Repository',
	#package : 'MooseNexus',
	#tag : 'Repository'
}

{ #category : 'testing' }
NexusDependencyRepository class >> isAbstract [

	^ self == NexusDependencyRepository
]

{ #category : 'accessing' }
NexusDependencyRepository >> directory [

	^ directory
]

{ #category : 'accessing' }
NexusDependencyRepository >> directory: pathString [

	directory := pathString
]

{ #category : 'resolving' }
NexusDependencyRepository >> resolve: descriptor [

	self subclassResponsibility
]

{ #category : 'ston persistence' }
NexusDependencyRepository >> stonOn: aSTONWriter [

	aSTONWriter
		encodeCharacter: ${;
		encodeKey: 'type' value: self className;
		mapElementSeparator;
		encodeKey: 'directory' value: self directory;
		encodeCharacter: $}
]
