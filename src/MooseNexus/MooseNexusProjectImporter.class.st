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

{ #category : 'capabilities' }
MooseNexusProjectImporter class >> buildToolName [

	^ self subclassResponsibility
]

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

{ #category : 'capabilities' }
MooseNexusProjectImporter class >> supportedLanguages [

	^ #(  )
]

{ #category : 'capabilities' }
MooseNexusProjectImporter >> buildToolName [

	^ self class buildToolName
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

{ #category : 'capabilities' }
MooseNexusProjectImporter >> supportedLanguages [

	^ self class supportedLanguages
]

{ #category : 'capabilities' }
MooseNexusProjectImporter >> toolRequirements [

	^ #(  )
]

{ #category : 'validating' }
MooseNexusProjectImporter >> validateToolRequirements [

	self validateToolRequirements: (self
			 validateToolRequirementsAvailabilityUsing: [ :command | LibC runCommand: command ]
			 versionUsing: [ :command | LibC resultOfCommand: command ])
]

{ #category : 'validating' }
MooseNexusProjectImporter >> validateToolRequirements: validationResults [

	validationResults
		detect: [ :result | result isAvailable not ]
		ifFound: [ :result | Error signal: result errorMessage ].
	^ validationResults
]

{ #category : 'validating' }
MooseNexusProjectImporter >> validateToolRequirementsAvailabilityUsing: availabilityRunner versionUsing: versionRunner [

	^ self toolRequirements collect: [ :requirement |
		  requirement validateAvailabilityUsing: availabilityRunner versionUsing: versionRunner ]
]

{ #category : 'validating' }
MooseNexusProjectImporter >> validateToolRequirementsUsing: aCommandRunner [

	^ self toolRequirements collect: [ :requirement | requirement validateUsing: aCommandRunner ]
]
