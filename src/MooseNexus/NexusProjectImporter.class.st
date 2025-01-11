"
I am responsible for importing a project to analyze with Moose from a local directory.
A new `NexusProject` is created unless an existing one is given to update.
"
Class {
	#name : 'NexusProjectImporter',
	#superclass : 'Object',
	#instVars : [
		'project',
		'directory'
	],
	#category : 'MooseNexus-Importer',
	#package : 'MooseNexus',
	#tag : 'Importer'
}

{ #category : 'testing' }
NexusProjectImporter class >> canHandle: directory [
	"Subclasses define whether they can manage the project in the specified directory."

	^ false
]

{ #category : 'instance creation' }
NexusProjectImporter class >> fromDirectory: directory [
	"Expects the path string of a directory containing the sources of a project.
	Attempts to determine the type of project in the directory.
	Returns an instance of the appropriate class for importing the project."

	self allSubclassesDo: [ :subclass |
		(subclass isAbstract not and: [ subclass canHandle: directory ])
			ifTrue: [ ^ subclass new directory: directory ] ].
	Error signal:
		'Cannot figure out nature of project in directory: ' , directory
]

{ #category : 'instance creation' }
NexusProjectImporter class >> importFromDirectory: directory [
	"Expects the path string of a directory containing the sources of a project, imports it and returns it."

	^ (self fromDirectory: directory) import
]

{ #category : 'testing' }
NexusProjectImporter class >> isAbstract [

	^ self == NexusProjectImporter
]

{ #category : 'accessing' }
NexusProjectImporter >> directory [

	^ directory
]

{ #category : 'accessing' }
NexusProjectImporter >> directory: fileReference [

	directory := fileReference asFileReference
]

{ #category : 'querying' }
NexusProjectImporter >> flatDependencies [

	^ #(  )
]

{ #category : 'importing' }
NexusProjectImporter >> import [

	self subclassResponsibility
]

{ #category : 'instance creation' }
NexusProjectImporter >> newProject [

	self subclassResponsibility
]

{ #category : 'accessing' }
NexusProjectImporter >> project [

	^ project
]

{ #category : 'accessing' }
NexusProjectImporter >> project: aNexusProject [

	project := aNexusProject
]
