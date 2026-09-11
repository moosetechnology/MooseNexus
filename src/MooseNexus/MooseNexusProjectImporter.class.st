"
I import a source project from a local directory.

A new MooseNexusProject is created unless an existing one is given to update. MooseNexusBuildSpec creates and configures importers through MooseNexusBuildPlan.
"
Class {
	#name : 'MooseNexusProjectImporter',
	#superclass : 'Object',
	#traits : 'TMooseNexusWithRequirements',
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
	"Determine a unique supported project nature from the source directory."

	^ self fromDirectory: directory language: nil
]

{ #category : 'instance creation' }
MooseNexusProjectImporter class >> fromDirectory: directory language: aLanguage [
	"Answer the uniquely matching importer. An explicit language narrows autodetection."

	| candidates natureNames |
	candidates := self allSubclasses select: [ :subclass |
			              subclass isAbstract not and: [
					              (subclass canHandle: directory) and: [
						              aLanguage isNil or: [
							              subclass supportedLanguages anySatisfy: [ :language | language asString = aLanguage asString ] ] ] ] ].
	candidates := candidates asSortedCollection: [ :left :right | left buildToolName <= right buildToolName ].
	candidates size = 1 ifTrue: [ ^ candidates anyOne new directory: directory ].
	candidates isEmpty ifTrue: [ Error signal: 'Cannot figure out nature of project in directory: ' , directory ].
	natureNames := ', ' join: (candidates collect: [ :each | each buildToolName ]).
	Error signal: 'Multiple project natures detected: ' , natureNames , '. Configure MooseNexusBuildSpec projectImporter explicitly.'
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

	self directory: aMooseNexusBuildSpec sourceDirectory
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
