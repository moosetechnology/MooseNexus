"
I represent a local dependency repository of a build automation tool.

My directory is an explicit filesystem location. Each subclass knows how to resolve a dependency from the indexing of its specific tool.
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

{ #category : 'parsing' }
MooseNexusDependencyRepository >> coordinatesOf: descriptor [

	self subclassResponsibility
]

{ #category : 'accessing' }
MooseNexusDependencyRepository >> directory [

	^ directory
]

{ #category : 'accessing' }
MooseNexusDependencyRepository >> directory: aPath [

	directory := aPath asFileReference
]

{ #category : 'resolving' }
MooseNexusDependencyRepository >> resolve: descriptor [

	self subclassResponsibility
]

{ #category : 'parsing' }
MooseNexusDependencyRepository >> scopeOf: descriptor [

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
