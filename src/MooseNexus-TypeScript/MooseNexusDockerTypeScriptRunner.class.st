"
I run a versioned ts2famix Docker image.

I mount recorded sources read-only and mount only my temporary output directory writable, leaving the imported project sources unchanged.
"
Class {
	#name : 'MooseNexusDockerTypeScriptRunner',
	#superclass : 'MooseNexusTypeScriptRunner',
	#instVars : [
		'imageVersion'
	],
	#category : 'MooseNexus-TypeScript-ModelExtraction',
	#package : 'MooseNexus-TypeScript',
	#tag : 'ModelExtraction'
}

{ #category : 'accessing' }
MooseNexusDockerTypeScriptRunner >> imageReference [

	^ self imageRepository , ':' , self imageVersion
]

{ #category : 'accessing' }
MooseNexusDockerTypeScriptRunner >> imageRepository [

	^ 'ghcr.io/moosetechnology/moosenexus-ts2famix'
]

{ #category : 'accessing' }
MooseNexusDockerTypeScriptRunner >> imageVersion [

	^ imageVersion ifNil: [ imageVersion := '3.2.0-679f54e' ]
]

{ #category : 'accessing' }
MooseNexusDockerTypeScriptRunner >> imageVersion: aString [

	imageVersion := aString
]

{ #category : 'capabilities' }
MooseNexusDockerTypeScriptRunner >> requirements [

	^ { (MooseNexusToolRequirement
		   name: 'Docker'
		   availabilityValidation: 'docker --version'
		   versionValidation: 'docker --version'
		   expectedVersionDescription: 'Docker CLI capable of running ' , self imageReference) }
]

{ #category : 'running' }
MooseNexusDockerTypeScriptRunner >> run [

	| returnCode |
	self prepareOutput.
	returnCode := self runCommand: self writeCommand.
	returnCode == 0 ifFalse: [
			returnCode == 32000 ifTrue: [ Error signal: 'Docker must be running' ].
			Error signal: 'Failed to create the TypeScript model, error code: ' , returnCode asString ].
	self outputFile exists ifFalse: [ Error signal: 'ts2famix completed without creating a model file' ].
	^ self outputPath
]

{ #category : 'writing' }
MooseNexusDockerTypeScriptRunner >> writeCommand [

	^ String streamContents: [ :stream |
			  stream << 'docker run --rm'.
			  stream << ' -v ' << (self shellQuoted: self sourceDirectory pathString , ':/source:ro').
			  stream << ' -v ' << (self shellQuoted: self outputDirectory pathString , ':/output').
			  stream << ' ' << self imageReference.
			  stream << ' -i /source/tsconfig.json -o /output/' << self class outputFilename ]
]
