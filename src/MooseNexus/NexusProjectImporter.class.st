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

{ #category : 'testing' }
NexusProjectImporter class >> isAbstract [

	^ self == NexusProjectImporter
]

{ #category : 'accessing' }
NexusProjectImporter >> directory [

	^ directory
]

{ #category : 'accessing' }
NexusProjectImporter >> directory: pathString [

	directory := pathString
]

{ #category : 'querying' }
NexusProjectImporter >> flattenDependencies [

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
