"
I am responsible for importing a project to analyze with Moose from a local directory.
A new `MooseNexusProject` is created unless an existing one is given to update.
"
Class {
	#name : 'MooseNexusProjectImporter',
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
MooseNexusProjectImporter class >> canHandle: directory [
	"Subclasses define whether they can manage the project in the specified directory."

	^ false
]

{ #category : 'instance creation' }
MooseNexusProjectImporter class >> fromDirectory: directory [
	"Expects the path string of a directory containing the sources of a project.
	Attempts to determine the type of project in the directory.
	Returns an instance of the appropriate class for importing the project."

	self allSubclassesDo: [ :subclass |
		(subclass isAbstract not and: [ subclass canHandle: directory ]) ifTrue: [ ^ subclass new directory: directory ] ].
	Error signal: 'Cannot figure out nature of project in directory: ' , directory
]

{ #category : 'instance creation' }
MooseNexusProjectImporter class >> importFromDirectory: directory [
	"Expects the path string of a directory containing the sources of a project, imports it and returns it."

	^ (self fromDirectory: directory) import
]

{ #category : 'testing' }
MooseNexusProjectImporter class >> isAbstract [

	^ self == MooseNexusProjectImporter
]

{ #category : 'accessing' }
MooseNexusProjectImporter >> directory [

	^ directory
]

{ #category : 'accessing' }
MooseNexusProjectImporter >> directory: fileReference [

	directory := fileReference asFileReference
]

{ #category : 'querying' }
MooseNexusProjectImporter >> flatDependencies [

	^ #(  )
]

{ #category : 'importing' }
MooseNexusProjectImporter >> import [

	self subclassResponsibility
]

{ #category : 'importing' }
MooseNexusProjectImporter >> importWithCoordinates: aMooseNexusProjectCoordinates [

	self subclassResponsibility
]

{ #category : 'instance creation' }
MooseNexusProjectImporter >> newProject [

	self subclassResponsibility
]

{ #category : 'accessing' }
MooseNexusProjectImporter >> project [

	^ project
]

{ #category : 'accessing' }
MooseNexusProjectImporter >> project: aMooseNexusProject [

	project := aMooseNexusProject
]
