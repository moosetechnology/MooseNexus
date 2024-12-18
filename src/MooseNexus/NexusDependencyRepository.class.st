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
