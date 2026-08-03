"
I import a source project from a local directory.

A new MooseNexusProject is created unless an existing one is given to update. MooseNexusBuildSpec creates and configures importers through MooseNexusBuildPlan.
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

{ #category : 'testing' }
MooseNexusProjectImporter class >> isAbstract [

	^ self == MooseNexusProjectImporter
]

{ #category : 'configuring' }
MooseNexusProjectImporter >> configureFromBuildSpec: aMooseNexusBuildSpec [
	"Default importers do not need build-spec configuration."

	
]

{ #category : 'querying' }
MooseNexusProjectImporter >> dependencyResolutionResult [

	^ MooseNexusDependencyResolutionResult forProject: project
]

{ #category : 'accessing' }
MooseNexusProjectImporter >> directory [

	^ directory
]

{ #category : 'accessing' }
MooseNexusProjectImporter >> directory: fileReference [

	directory := fileReference asFileReference
]

{ #category : 'importing' }
MooseNexusProjectImporter >> import [

	self subclassResponsibility
]

{ #category : 'importing' }
MooseNexusProjectImporter >> importWithCoordinates: aMooseNexusCoordinates [

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
