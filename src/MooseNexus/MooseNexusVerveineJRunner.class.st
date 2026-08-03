"
[VerveineJ](https://modularmoose.org/moose-wiki/Developers/Parsers/VerveineJ.html) is a tool written in Java that creates a JSON or MSE file from Java source code.
"
Class {
	#name : 'MooseNexusVerveineJRunner',
	#superclass : 'MooseNexusModelExtractor',
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
MooseNexusVerveineJRunner class >> canHandle: language [

	^ language = 'java'
]

{ #category : 'instance creation' }
MooseNexusVerveineJRunner class >> defaultImplementation [

	^ MooseNexusDockerVerveineJRunner new
]

{ #category : 'testing' }
MooseNexusVerveineJRunner class >> isAbstract [

	^ self == MooseNexusVerveineJRunner
]

{ #category : 'constants' }
MooseNexusVerveineJRunner class >> outputFilename [
	"This is the filename of the VerveineJ output, meant to avoid conflicts with an existing source file.
	Its final name will be given afterwards."

	^ 'mooseNexusModel'
]

{ #category : 'accessing' }
MooseNexusVerveineJRunner >> allLocals [

	^ allLocals ifNil: [ allLocals := false ]
]

{ #category : 'accessing' }
MooseNexusVerveineJRunner >> allLocals: aBoolean [

	allLocals := aBoolean
]

{ #category : 'accessing' }
MooseNexusVerveineJRunner >> anchor [

	^ anchor
]

{ #category : 'accessing' }
MooseNexusVerveineJRunner >> anchor: aSymbol [

	| expected |
	expected := #( none entity default assoc ).
	(expected includes: aSymbol) ifFalse: [
		Error signal: 'Invalid anchor argument `' , aSymbol , '`, expects one of: ' , expected asCommaString ].
	anchor := aSymbol
]

{ #category : 'accessing' }
MooseNexusVerveineJRunner >> excludePaths [

	^ excludePaths ifNil: [ excludePaths := #(  ) ]
]

{ #category : 'accessing' }
MooseNexusVerveineJRunner >> excludePaths: aPathStringCollection [
	"Paths are globbing expressions and match any part of the target paths."

	excludePaths := aPathStringCollection
]

{ #category : 'accessing' }
MooseNexusVerveineJRunner >> format [

	^ format ifNil: [ format := #json ]
]

{ #category : 'accessing' }
MooseNexusVerveineJRunner >> format: aSymbol [

	| expected |
	expected := #( json mse ).
	(expected includes: aSymbol) ifFalse: [
		Error signal: 'Invalid format argument `' , aSymbol , '`, expects one of: ' , expected asCommaString ].
	format := aSymbol
]

{ #category : 'accessing' }
MooseNexusVerveineJRunner >> javaVersion [

	^ javaVersion
]

{ #category : 'accessing' }
MooseNexusVerveineJRunner >> javaVersion: aString [
	"Expects a Java version such as: 1.1 | 1 | 1.2 | 2 | ... | 1.7 | 7"

	javaVersion := aString
]

{ #category : 'accessing' }
MooseNexusVerveineJRunner >> jvmArgs [

	^ jvmArgs
]

{ #category : 'accessing' }
MooseNexusVerveineJRunner >> jvmArgs: aString [
	"Arguments for the JVM, given all at once in a single string.
	Useful to set a particular encoding, e.g. -Dfile.encoding=ISO-8859-1"

	jvmArgs := aString
]

{ #category : 'accessing' }
MooseNexusVerveineJRunner >> outputPath [

	^ 'sources/' , self class outputFilename , '.' , self format
]

{ #category : 'printing' }
MooseNexusVerveineJRunner >> printOptionsOn: stream [

	self printOptionsOn: stream outputFile: self class outputFilename , '.' , self format
]

{ #category : 'printing' }
MooseNexusVerveineJRunner >> printOptionsOn: stream outputFile: outputFileName [

	self jvmArgs ifNotNil: [ :args | stream << args << ' ' ].
	stream << '-o ' << outputFileName << ' -format ' << self format.
	self allLocals ifTrue: [ stream << ' -alllocals' ].
	self anchor ifNotNil: [ :a | stream << ' -anchor ' << a ].
	self javaVersion ifNotNil: [ :v | stream << ' -' << v ].
	self summary ifTrue: [ stream << ' -summary' ].
	self excludePaths ifNotEmpty: [ :paths | paths do: [ :path | stream << ' -excludepath ' << path ] ]
]

{ #category : 'running' }
MooseNexusVerveineJRunner >> runCommand: aCommand [

	^ LibC runCommand: aCommand
]

{ #category : 'accessing' }
MooseNexusVerveineJRunner >> summary [

	^ summary ifNil: [ summary := false ]
]

{ #category : 'accessing' }
MooseNexusVerveineJRunner >> summary: aBoolean [

	summary := aBoolean
]
