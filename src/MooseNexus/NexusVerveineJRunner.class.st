"
[VerveineJ](https://modularmoose.org/moose-wiki/Developers/Parsers/VerveineJ.html) is a tool written in java that create a json or a mse file from Java source code.
"
Class {
	#name : 'NexusVerveineJRunner',
	#superclass : 'NexusModelExtractor',
	#instVars : [
		'format',
		'summary',
		'allLocals',
		'anchor',
		'excludePaths',
		'javaVersion',
		'jvmArgs'
	],
	#category : 'MooseNexus-ModelExtraction',
	#package : 'MooseNexus',
	#tag : 'ModelExtraction'
}

{ #category : 'testing' }
NexusVerveineJRunner class >> canHandle: language [

	^ language = 'java'
]

{ #category : 'instance creation' }
NexusVerveineJRunner class >> defaultImplementation [

	^ NexusDockerVerveineJRunner new
]

{ #category : 'testing' }
NexusVerveineJRunner class >> isAbstract [

	^ self == NexusVerveineJRunner
]

{ #category : 'accessing' }
NexusVerveineJRunner >> allLocals [

	^ allLocals ifNil: [ allLocals := false ]
]

{ #category : 'accessing' }
NexusVerveineJRunner >> allLocals: aBoolean [

	allLocals := aBoolean
]

{ #category : 'accessing' }
NexusVerveineJRunner >> anchor [

	^ anchor
]

{ #category : 'accessing' }
NexusVerveineJRunner >> anchor: aSymbol [

	| expected |
	expected := #( none entity default assoc ).
	(expected includes: aSymbol) ifFalse: [
		Error signal:
			'Invalid anchor argument `' , aSymbol , '`, expects one of: '
			, expected asCommaString ].
	anchor := aSymbol
]

{ #category : 'accessing' }
NexusVerveineJRunner >> excludePaths [

	^ excludePaths ifNil: [ excludePaths := #(  ) ]
]

{ #category : 'accessing' }
NexusVerveineJRunner >> excludePaths: aPathStringCollection [
	"Paths are globbing expressions and match any part of the target paths."

	excludePaths := aPathStringCollection
]

{ #category : 'accessing' }
NexusVerveineJRunner >> format [

	^ format ifNil: [ format := #json ]
]

{ #category : 'accessing' }
NexusVerveineJRunner >> format: aSymbol [

	| expected |
	expected := #( json mse ).
	(expected includes: aSymbol) ifFalse: [
		Error signal:
			'Invalid format argument `' , aSymbol , '`, expects one of: '
			, expected asCommaString ].
	format := aSymbol
]

{ #category : 'accessing' }
NexusVerveineJRunner >> javaVersion [

	^ javaVersion
]

{ #category : 'accessing' }
NexusVerveineJRunner >> javaVersion: aString [
	"Expects a Java version such as: 1.1 | 1 | 1.2 | 2 | ... | 1.7 | 7"

	javaVersion := aString
]

{ #category : 'accessing' }
NexusVerveineJRunner >> jvmArgs [

	^ jvmArgs
]

{ #category : 'accessing' }
NexusVerveineJRunner >> jvmArgs: aString [
	"Arguments for the JVM, given all at once in a single string.
	Useful to set a particular encoding, e.g. -Dfile.encoding=ISO-8859-1"

	jvmArgs := aString
]

{ #category : 'printing' }
NexusVerveineJRunner >> printOptionsOn: stream [

	self jvmArgs ifNotNil: [ :args | stream << args << ' ' ].
	stream << '-format ' << self format.
	self allLocals ifTrue: [ stream << ' -alllocals' ].
	self anchor ifNotNil: [ :a | stream << ' -anchor ' << a ].
	self javaVersion ifNotNil: [ :v | stream << ' -' << v ].
	self summary ifTrue: [ stream << ' -summary' ].
	self excludePaths ifNotEmpty: [ :paths |
		paths do: [ :path | stream << ' -excludepath ' << path ] ]
]

{ #category : 'accessing' }
NexusVerveineJRunner >> summary [

	^ summary ifNil: [ summary := false ]
]

{ #category : 'accessing' }
NexusVerveineJRunner >> summary: aBoolean [

	summary := aBoolean
]
