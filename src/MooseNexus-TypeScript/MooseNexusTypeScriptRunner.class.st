"
I define common TypeScript extraction behavior.

Concrete runners execute ts2famix locally or in Docker. I require a tsconfig.json in the recorded source root and own a temporary JSON output directory.
"
Class {
	#name : 'MooseNexusTypeScriptRunner',
	#superclass : 'MooseNexusModelExtractor',
	#category : 'MooseNexus-TypeScript-ModelExtraction',
	#package : 'MooseNexus-TypeScript',
	#tag : 'ModelExtraction'
}

{ #category : 'testing' }
MooseNexusTypeScriptRunner class >> canHandle: language [

	^ language = self language
]

{ #category : 'instance creation' }
MooseNexusTypeScriptRunner class >> defaultImplementation [

	^ MooseNexusDockerTypeScriptRunner new
]

{ #category : 'testing' }
MooseNexusTypeScriptRunner class >> isAbstract [

	^ self == MooseNexusTypeScriptRunner
]

{ #category : 'capabilities' }
MooseNexusTypeScriptRunner class >> language [

	^ 'typescript'
]

{ #category : 'capabilities' }
MooseNexusTypeScriptRunner class >> metamodel [

	^ 'Famix-TypeScript'
]

{ #category : 'capabilities' }
MooseNexusTypeScriptRunner class >> modelFormats [

	^ #( json )
]

{ #category : 'constants' }
MooseNexusTypeScriptRunner class >> outputFilename [

	^ 'mooseNexusTypeScriptModel.json'
]

{ #category : 'cleanup' }
MooseNexusTypeScriptRunner >> cleanUp [

	self outputDirectory ensureDeleteAll
]

{ #category : 'accessing' }
MooseNexusTypeScriptRunner >> outputDirectory [

	^ self projectDirectory / 'temporary' / 'typescript-extraction'
]

{ #category : 'accessing' }
MooseNexusTypeScriptRunner >> outputFile [

	^ self outputDirectory / self class outputFilename
]

{ #category : 'accessing' }
MooseNexusTypeScriptRunner >> outputPath [

	^ (self outputFile relativeTo: self projectDirectory) pathString
]

{ #category : 'setup' }
MooseNexusTypeScriptRunner >> prepareOutput [

	self outputDirectory ensureCreateDirectory.
	self outputFile deleteIfAbsent: [ ]
]

{ #category : 'accessing' }
MooseNexusTypeScriptRunner >> projectDirectory [

	^ target asFileReference
]

{ #category : 'running' }
MooseNexusTypeScriptRunner >> runCommand: aCommand [

	^ LibC runCommand: aCommand
]

{ #category : 'printing' }
MooseNexusTypeScriptRunner >> shellQuoted: aString [

	^ '"' , (aString copyReplaceAll: '"' with: '\\"') , '"'
]

{ #category : 'accessing' }
MooseNexusTypeScriptRunner >> sourceDirectory [

	^ self projectDirectory / 'sources' / 'main'
]

{ #category : 'accessing' }
MooseNexusTypeScriptRunner >> tsConfigFile [

	| file |
	file := self sourceDirectory / 'tsconfig.json'.
	file exists ifFalse: [ Error signal: 'TypeScript extraction requires sources/main/tsconfig.json' ].
	^ file
]
