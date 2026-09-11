"
I run an explicitly configured local ts2famix command.

I never install packages or fall back to a network command. Use me when Docker is not desired and a pinned local importer is already available.
"
Class {
	#name : 'MooseNexusLocalTypeScriptRunner',
	#superclass : 'MooseNexusTypeScriptRunner',
	#instVars : [
		'command'
	],
	#category : 'MooseNexus-TypeScript-ModelExtraction',
	#package : 'MooseNexus-TypeScript',
	#tag : 'ModelExtraction'
}

{ #category : 'accessing' }
MooseNexusLocalTypeScriptRunner >> command [

	^ command ifNil: [ Error signal: 'A local ts2famix command is required' ]
]

{ #category : 'accessing' }
MooseNexusLocalTypeScriptRunner >> command: aString [

	command := aString
]

{ #category : 'capabilities' }
MooseNexusLocalTypeScriptRunner >> requirements [

	^ {
		  (MooseNexusToolRequirement
			   name: 'Node.js'
			   availabilityValidation: 'node --version'
			   versionValidation: 'node --version'
			   expectedVersionDescription: 'Node.js runtime compatible with ts2famix').
		  (MooseNexusToolRequirement
			   name: 'ts2famix'
			   availabilityValidation: self command , ' --version'
			   versionValidation: self command , ' --version'
			   expectedVersionDescription: 'configured local ts2famix command') }
]

{ #category : 'running' }
MooseNexusLocalTypeScriptRunner >> run [

	| returnCode |
	self prepareOutput.
	returnCode := self runCommand: self writeCommand.
	returnCode == 0 ifFalse: [ Error signal: 'Failed to create the TypeScript model, error code: ' , returnCode asString ].
	self outputFile exists ifFalse: [ Error signal: 'ts2famix completed without creating a model file' ].
	^ self outputPath
]

{ #category : 'writing' }
MooseNexusLocalTypeScriptRunner >> writeCommand [

	^ String streamContents: [ :stream |
			  stream << self command.
			  stream << ' -i ' << (self shellQuoted: self tsConfigFile pathString).
			  stream << ' -o ' << (self shellQuoted: self outputFile pathString) ]
]
