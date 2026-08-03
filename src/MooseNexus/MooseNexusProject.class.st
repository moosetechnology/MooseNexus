"
I represent a MooseNexus project loaded in memory or recorded in a repository.

My properties follow this mapping:
```text
language: <language>
nature:   <subclassOfMooseNexusProject>
group:    <group>
name:     <name>
version:  <version>
dependencies:
	- path: <localPath>
```
The nature corresponds to the concrete subclass of MooseNexusProject that handles the source project.
The group, name, and version are the coordinates that identify the source project as modeled by MooseNexus.

Use MooseNexusProjectSpec to describe the intent to create or record a project. Coordinate inference belongs to importers; this object only carries the coordinates it was initialized with.
"
Class {
	#name : 'MooseNexusProject',
	#superclass : 'Object',
	#instVars : [
		'coordinates',
		'directory',
		'dependencies'
	],
	#category : 'MooseNexus-Project',
	#package : 'MooseNexus',
	#tag : 'Project'
}

{ #category : 'instance creation' }
MooseNexusProject class >> coordinates: aMooseNexusCoordinates [

	^ self new
		  initializeCoordinates: aMooseNexusCoordinates;
		  yourself
]

{ #category : 'instance creation' }
MooseNexusProject class >> fromNexusDirectory: directory [

	^ (self fromProperties: directory / 'properties.json') directory: (directory relativeTo: FileLocator home) pathString
]

{ #category : 'instance creation' }
MooseNexusProject class >> fromProperties: file [
	"Read the project data from the properties file recorded in the repository."

	| properties |
	properties := file readStreamDo: [ :s | STON fromStream: s ].
	^ ((properties at: #nature) asClassInEnvironment: self environment) new readProperties: properties
]

{ #category : 'testing' }
MooseNexusProject class >> isAbstract [

	^ self == MooseNexusProject
]

{ #category : 'adding' }
MooseNexusProject >> addModel: modelDescription [
	"Add a model to the list of models for this project, overwriting any with the same name"

	| modelName models |
	modelName := modelDescription at: 'name'.
	models := self models reject: [ :desc | (desc at: 'name') = modelName ].
	models := models copyWith: modelDescription.

	FileLocator home / directory / 'models.json' writeStreamDo: [ :s | STON put: models asJsonOnStream: s ]
]

{ #category : 'building' }
MooseNexusProject >> buildModel [
	"Build a model with default attributes. Use the model builder API for more control."

	self modelBuilder build
]

{ #category : 'accessing' }
MooseNexusProject >> coordinates [

	^ coordinates
]

{ #category : 'accessing' }
MooseNexusProject >> dependencies [

	^ dependencies ifNil: [ dependencies := #(  ) ]
]

{ #category : 'accessing' }
MooseNexusProject >> dependencies: aCollection [

	dependencies := aCollection
]

{ #category : 'properties' }
MooseNexusProject >> dependencyDescriptorsFromProperties: dependencyDictionaries [

	^ dependencyDictionaries collect: [ :dependency | MooseNexusDependencyDescriptor fromDictionary: dependency ]
]

{ #category : 'accessing' }
MooseNexusProject >> directory [

	^ directory
]

{ #category : 'accessing' }
MooseNexusProject >> directory: pathString [

	directory := pathString
]

{ #category : 'accessing' }
MooseNexusProject >> group [

	^ self coordinates group
]

{ #category : 'setup' }
MooseNexusProject >> importModel [
	"There can be multiple models with different settings for the same project."

	self models ifEmpty: [ self inform: 'No models to import' ] ifNotEmpty: [ :models |
			models size = 1 ifTrue: [ ^ self importModel: models first ].

			"Open a presenter to choose a model to import."
			(MooseNexusModelSelectionPresenter on: self) open ]
]

{ #category : 'setup' }
MooseNexusProject >> importModel: modelDescription [
	"modelDescription = { 'name': fileName, 'description', 'comment', 'timestamp', 'famixVersion' }"

	| model |
	model := FamixJavaModel new.

	FamixJSONFileImporter new
		model: model;
		inputFile: FileLocator home / directory / 'models' / (modelDescription at: 'name') , (modelDescription at: 'format');
		runFilteredBy: FamixJavaImportingContext new importMaximum.

	model install. "add to MooseModel root"
	model rootFolder: (FileLocator home / directory / 'sources') absolutePath pathString.
	^ model
]

{ #category : 'initialization' }
MooseNexusProject >> initializeCoordinates: aMooseNexusCoordinates [

	self isRecorded ifTrue: [ Error signal: 'Cannot change project coordinates after recording the project in a repository' ].
	coordinates ifNotNil: [ Error signal: 'Cannot change project coordinates after initialization' ].
	coordinates := aMooseNexusCoordinates
]

{ #category : 'testing' }
MooseNexusProject >> isManagedProject [

	^ false
]

{ #category : 'testing' }
MooseNexusProject >> isRecorded [

	^ directory notNil
]

{ #category : 'accessing' }
MooseNexusProject >> language [
	"Subclasses must return a lowercase string of the project's language name."

	self subclassResponsibility
]

{ #category : 'building' }
MooseNexusProject >> modelBuilder [

	^ MooseNexusModelBuilder on: self
]

{ #category : 'enumerating' }
MooseNexusProject >> models [

	^ FileLocator home / directory / 'models.json' readStreamDo: [ :s | STON fromStream: s ]
]

{ #category : 'accessing' }
MooseNexusProject >> name [

	^ self coordinates name
]

{ #category : 'printing' }
MooseNexusProject >> printOn: stream [

	super printOn: stream.
	stream nextPut: $(.
	coordinates ifNil: [ stream nextPutAll: '<coordinates>' ] ifNotNil: [ coordinates printOn: stream ].
	stream nextPut: $)
]

{ #category : 'enumerating' }
MooseNexusProject >> projectSourceDirectory [
	"The directory containing all of the original project sources."

	^ self sourceDirectory / 'project'
]

{ #category : 'enumerating' }
MooseNexusProject >> properties [
	"Gather all of the properties of this project in a dictionary"

	^ Dictionary
		  with: #language -> self language
		  with: #nature -> self className
		  with: #group -> self group
		  with: #name -> self name
		  with: #version -> self version
		  with: #dependencies -> self serializedDependencies
]

{ #category : 'properties' }
MooseNexusProject >> readProperties: properties [

	self initializeCoordinates:
		(MooseNexusCoordinates group: (properties at: #group) name: (properties at: #name) version: (properties at: #version)).
	properties at: #dependencies ifPresent: [ :deps | self dependencies: (self dependencyDescriptorsFromProperties: deps) ]
]

{ #category : 'enumerating' }
MooseNexusProject >> serializedDependencies [

	^ self dependencies collect: [ :dependency | dependency asDictionary ]
]

{ #category : 'enumerating' }
MooseNexusProject >> sourceDirectory [
	"The directory containing all of the sources for this project.
	This includes the original project sources, and additional sources from dependencies."

	^ FileLocator home / directory / 'sources'
]

{ #category : 'accessing' }
MooseNexusProject >> version [

	^ self coordinates version
]

{ #category : 'properties' }
MooseNexusProject >> writePropertiesOn: stream [

	STON put: self properties asJsonOnStream: stream
]
