"
I run the released ts2famix npm package in a pinned official Node Docker image.

I mount recorded sources read-only and mount only my temporary output directory writable, leaving the imported project sources unchanged.
"
Class {
	#name : 'MooseNexusDockerTypeScriptRunner',
	#superclass : 'MooseNexusTypeScriptRunner',
	#category : 'MooseNexus-TypeScript-ModelExtraction',
	#package : 'MooseNexus-TypeScript',
	#tag : 'ModelExtraction'
}

{ #category : 'accessing' }
MooseNexusDockerTypeScriptRunner >> imageReference [

	^ self nodeImageReference
]

{ #category : 'accessing' }
MooseNexusDockerTypeScriptRunner >> nodeImageReference [

	^ 'node:20.19.4-bookworm-slim@sha256:6db5e436948af8f0244488a1f658c2c8e55a3ae51ca2e1686ed042be8f25f70a'
]

{ #category : 'capabilities' }
MooseNexusDockerTypeScriptRunner >> requirements [

	^ { (MooseNexusToolRequirement
		   name: 'Docker'
		   availabilityValidation: 'docker --version'
		   versionValidation: 'docker --version'
		   expectedVersionDescription:
		   'Docker CLI capable of running ' , self nodeImageReference , ' and ' , self ts2famixPackageReference) }
]

{ #category : 'running' }
MooseNexusDockerTypeScriptRunner >> run [

	| returnCode |
	self tsConfigFile.
	self prepareOutput.
	returnCode := self runCommand: self writeCommand.
	returnCode == 0 ifFalse: [
			returnCode == 32000 ifTrue: [ Error signal: 'Docker must be running' ].
			Error signal: 'Failed to create the TypeScript model, error code: ' , returnCode asString ].
	self outputFile exists ifFalse: [ Error signal: 'ts2famix completed without creating a model file' ].
	^ self outputPath
]

{ #category : 'accessing' }
MooseNexusDockerTypeScriptRunner >> ts2famixPackageReference [

	^ 'ts2famix@3.3.0'
]

{ #category : 'writing' }
MooseNexusDockerTypeScriptRunner >> writeCommand [

	^ String streamContents: [ :stream |
			  stream << 'docker run --rm'.
			  stream << ' -v ' << (self shellQuoted: self sourceDirectory pathString , ':/source:ro').
			  stream << ' -v ' << (self shellQuoted: self outputDirectory pathString , ':/output').
			  stream << ' ' << self nodeImageReference.
			  stream << ' npx --yes ' << self ts2famixPackageReference.
			  stream << ' -i /source/tsconfig.json -o /output/' << self class outputFilename ]
]
