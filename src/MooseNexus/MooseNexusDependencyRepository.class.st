"
I represent a local dependency repository of a build automation tool.
Each of my subclasses knows how to resolve a dependency based on a descriptor string based on the indexing of a specific tool.
"
Class {
	#name : 'MooseNexusDependencyRepository',
	#superclass : 'Object',
	#instVars : [
		'directory'
	],
	#category : 'MooseNexus-Repository',
	#package : 'MooseNexus',
	#tag : 'Repository'
}

{ #category : 'testing' }
MooseNexusDependencyRepository class >> isAbstract [

	^ self == MooseNexusDependencyRepository
]

{ #category : 'accessing' }
MooseNexusDependencyRepository >> directory [

	^ directory
]

{ #category : 'accessing' }
MooseNexusDependencyRepository >> directory: pathString [

	directory := pathString
]

{ #category : 'resolving' }
MooseNexusDependencyRepository >> resolve: descriptor [

	self subclassResponsibility
]

{ #category : 'ston persistence' }
MooseNexusDependencyRepository >> stonOn: aSTONWriter [

	aSTONWriter
		encodeCharacter: ${;
		encodeKey: 'type' value: self className;
		mapElementSeparator;
		encodeKey: 'directory' value: self directory;
		encodeCharacter: $}
]
