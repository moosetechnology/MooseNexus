"
I represent a project to analyze with Moose.

My properties follows this mapping:
```text
language: <language>
nature:   <subclassOfNexusProject>
group:    <group>
name:     <name>
version:  <version>
dependencies:
	- path: <localPath>
```
The nature corresponds to the concrete subclass of `NexusProject` that handles the project.
The group, name, and version are the same concept used by other project managers (e.g. Maven).
They are used to uniquely identify a project to be modeled.
"
Class {
	#name : 'NexusProject',
	#superclass : 'Object',
	#instVars : [
		'directory',
		'group',
		'version',
		'dependencies',
		'name'
	],
	#category : 'MooseNexus-Project',
	#package : 'MooseNexus',
	#tag : 'Project'
}

{ #category : 'error handling' }
NexusProject class >> canHandle: directory [
	"Subclasses define whether they can manage the project in the specified directory."

	^ false
]

{ #category : 'testing' }
NexusProject class >> fromDirectory: directory [
	"Expects the path string of a directory containing the sources of a project.
	Attempts to determine the type of project in the directory.
	Returns an instance of the appropriate class for managing the project."

	self allSubclassesDo: [ :subclass |
		(subclass isAbstract not and: [ subclass canHandle: directory ])
			ifTrue: [ ^ subclass fromDirectory: directory ] ].
	Error signal:
		'Cannot figure out nature of project in directory: ' , directory
]

{ #category : 'instance creation' }
NexusProject class >> fromNexusDirectory: directory [

	^ (self fromProperties: directory / 'properties.json') directory:
		  directory pathString
]

{ #category : 'instance creation' }
NexusProject class >> fromProperties: file [
	"Read the project data from the properties file recorded in the repository."

	| properties |
	properties := file readStreamDo: [ :s | STON fromStream: s ].
	^ ((properties at: #nature) asClassInEnvironment:
		   self class environment) new readProperties: properties
]

{ #category : 'testing' }
NexusProject class >> isAbstract [

	^ self == NexusProject
]

{ #category : 'building' }
NexusProject >> buildModel [

	self modelBuilder build
]

{ #category : 'accessing' }
NexusProject >> dependencies [

	^ dependencies ifNil: [ dependencies := self determineDependencies ]
]

{ #category : 'accessing' }
NexusProject >> dependencies: aDictionary [

	dependencies := aDictionary
]

{ #category : 'querying' }
NexusProject >> determineDependencies [

	^ #(  )
]

{ #category : 'querying' }
NexusProject >> determineGroup [

	Error signal: 'Instance of ' , self className
		, ' ignores how to determine the group'
]

{ #category : 'querying' }
NexusProject >> determineName [

	Error signal:
		'Instance of ' , self className
		, ' ignores how to determine the name'
]

{ #category : 'querying' }
NexusProject >> determineVersion [

	Error signal: 'Instance of ' , self className
		, ' ignores how to determine the version'
]

{ #category : 'accessing' }
NexusProject >> directory [

	^ directory
]

{ #category : 'accessing' }
NexusProject >> directory: pathString [

	directory := pathString
]

{ #category : 'accessing' }
NexusProject >> group [

	^ group ifNil: [ group := self determineGroup ]
]

{ #category : 'accessing' }
NexusProject >> group: aSymbol [

	group := aSymbol
]

{ #category : 'accessing' }
NexusProject >> language [
	"Subclasses must return a lowercase string of the project's language name."

	self subclassResponsibility
]

{ #category : 'accessing' }
NexusProject >> language: aString [
	"Subclasses that need to figure out their language can use this hook."
]

{ #category : 'building' }
NexusProject >> modelBuilder [

	^ NexusModelBuilder new
		  extractor: (NexusModelExtractor forLanguage: self language);
		  project: self;
		  yourself
]

{ #category : 'accessing' }
NexusProject >> name [

	^ name ifNil: [ name := self determineName ]
]

{ #category : 'accessing' }
NexusProject >> name: aSymbol [

	name := aSymbol
]

{ #category : 'printing' }
NexusProject >> printOn: stream [

	super printOn: stream.
	stream nextPut: $(.
	group
		ifNil: [ stream nextPutAll: '<group>' ]
		ifNotNil: [ stream nextPutAll: group ].
	stream nextPut: $:.
	name
		ifNil: [ stream nextPutAll: '<project>' ]
		ifNotNil: [ stream nextPutAll: name ].
	stream nextPut: $:.
	version
		ifNil: [ stream nextPutAll: '<version>' ]
		ifNotNil: [ stream nextPutAll: version ].
	stream nextPut: $)
]

{ #category : 'enumerating' }
NexusProject >> properties [
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
NexusProject >> readProperties: properties [

	properties keysAndValuesDo: [ :key :value |
		key = #nature ifFalse: [
			self perform: key asSymbol asMutator with: value ] ]
]

{ #category : 'accessing' }
NexusProject >> version [

	^ version ifNil: [ version := self determineVersion ]
]

{ #category : 'accessing' }
NexusProject >> version: aString [

	version := aString
]

{ #category : 'properties' }
NexusProject >> writePropertiesOn: stream [

	STON put: self properties asJsonOnStream: stream
]
