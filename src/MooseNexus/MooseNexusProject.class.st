"
I represent a project to analyze with Moose.

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
The nature corresponds to the concrete subclass of `MooseNexusProject` that handles the project.
The group, name, and version are the same concept used by other project managers (e.g. Maven).
They are used to uniquely identify a project to be modeled.
"
Class {
	#name : 'MooseNexusProject',
	#superclass : 'Object',
	#instVars : [
		'name',
		'group',
		'version',
		'directory',
		'dependencies'
	],
	#category : 'MooseNexus-Project',
	#package : 'MooseNexus',
	#tag : 'Project'
}

{ #category : 'instance creation' }
MooseNexusProject class >> fromNexusDirectory: directory [

	^ (self fromProperties: directory / 'properties.json') directory: (directory relativeTo: FileLocator home) pathString
]

{ #category : 'instance creation' }
MooseNexusProject class >> fromProperties: file [
	"Read the project data from the properties file recorded in the repository."

	| properties |
	properties := file readStreamDo: [ :s | STON fromStream: s ].
	^ ((properties at: #nature) asClassInEnvironment: self class environment) new readProperties: properties
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

	^ MooseNexusProjectCoordinates group: self group name: self name version: self version
]

{ #category : 'accessing' }
MooseNexusProject >> coordinates: aMooseNexusProjectCoordinates [

	self isRecorded ifTrue: [ Error signal: 'Cannot change project coordinates after recording the project in a repository' ].
	group := aMooseNexusProjectCoordinates group.
	name := aMooseNexusProjectCoordinates name.
	version := aMooseNexusProjectCoordinates version
]

{ #category : 'accessing' }
MooseNexusProject >> dependencies [

	^ dependencies ifNil: [ dependencies := #(  ) ]
]

{ #category : 'accessing' }
MooseNexusProject >> dependencies: aDictionary [

	dependencies := aDictionary
]

{ #category : 'querying' }
MooseNexusProject >> determineGroup [

	Error signal: 'Instance of ' , self className , ' ignores how to determine the group'
]

{ #category : 'querying' }
MooseNexusProject >> determineName [

	Error signal: 'Instance of ' , self className , ' ignores how to determine the name'
]

{ #category : 'querying' }
MooseNexusProject >> determineVersion [

	Error signal: 'Instance of ' , self className , ' ignores how to determine the version'
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

	^ group ifNil: [ group := self determineGroup ]
]

{ #category : 'accessing' }
MooseNexusProject >> group: aString [

	self coordinates: (MooseNexusProjectCoordinates group: aString name: name version: version)
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

{ #category : 'accessing' }
MooseNexusProject >> language: aString [
	"Subclasses that need to figure out their language can use this hook."
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

	^ name ifNil: [ name := self determineName ]
]

{ #category : 'accessing' }
MooseNexusProject >> name: aString [

	self coordinates: (MooseNexusProjectCoordinates group: group name: aString version: version)
]

{ #category : 'printing' }
MooseNexusProject >> printOn: stream [

	super printOn: stream.
	stream nextPut: $(.
	group ifNil: [ stream nextPutAll: '<group>' ] ifNotNil: [ stream nextPutAll: group ].
	stream nextPut: $:.
	name ifNil: [ stream nextPutAll: '<project>' ] ifNotNil: [ stream nextPutAll: name ].
	stream nextPut: $:.
	version ifNil: [ stream nextPutAll: '<version>' ] ifNotNil: [ stream nextPutAll: version ].
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
		  with: #dependencies -> self dependencies
]

{ #category : 'properties' }
MooseNexusProject >> readProperties: properties [

	properties keysAndValuesDo: [ :key :value | key = #nature ifFalse: [ self perform: key asSymbol asMutator with: value ] ]
]

{ #category : 'enumerating' }
MooseNexusProject >> sourceDirectory [
	"The directory containing all of the sources for this project.
	This includes the original project sources, and additional sources from dependencies."

	^ FileLocator home / directory / 'sources'
]

{ #category : 'accessing' }
MooseNexusProject >> version [

	^ version ifNil: [ version := self determineVersion ]
]

{ #category : 'accessing' }
MooseNexusProject >> version: aString [

	self coordinates: (MooseNexusProjectCoordinates group: group name: name version: aString)
]

{ #category : 'properties' }
MooseNexusProject >> writePropertiesOn: stream [

	STON put: self properties asJsonOnStream: stream
]
