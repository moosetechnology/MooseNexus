"
I run [VerveineJ-Docker](https://github.com/Evref-BL/VerveineJ-Docker).
Obtain the latest image using `docker pull ghcr.io/evref-bl/verveinej:latest`.
"
Class {
	#name : 'MooseNexusDockerVerveineJRunner',
	#superclass : 'MooseNexusVerveineJRunner',
	#instVars : [
		'version'
	],
	#category : 'MooseNexus-ModelExtraction',
	#package : 'MooseNexus',
	#tag : 'ModelExtraction'
}

{ #category : 'running' }
MooseNexusDockerVerveineJRunner >> run [

	| returnCode |
	returnCode := self runCommand: self writeCommand.
	returnCode == 0 ifFalse: [
			returnCode == 32000 ifTrue: [ Error signal: 'Docker must be running' ].
			"look for Docker or Shell error codes to understand your issue"
			Error signal: 'Failed to create the model, error code: ' , returnCode asString ].

	"VerveineJ-Docker outputs the file in the sources directory"
	^ self outputPath
]

{ #category : 'capabilities' }
MooseNexusDockerVerveineJRunner >> toolRequirements [

	^ super toolRequirements copyWith: (MooseNexusToolRequirement
		   name: 'Docker'
		   availabilityCommand: 'docker --version'
		   versionCommand: 'docker --version'
		   expectedVersionDescription: 'Docker CLI capable of running ghcr.io/evref-bl/verveinej:' , self version)
]

{ #category : 'accessing' }
MooseNexusDockerVerveineJRunner >> version [

	^ version ifNil: [ version := 'latest' ]
]

{ #category : 'accessing' }
MooseNexusDockerVerveineJRunner >> version: aString [
	"The VerveineJ version to use."

	version := aString
]

{ #category : 'writing' }
MooseNexusDockerVerveineJRunner >> writeCommand [

	^ String streamContents: [ :s |
			  s << 'docker run --rm -v ' << target << '/sources:/src -v ' << target
			  << '/dependencies:/dependency ghcr.io/evref-bl/verveinej:' << self version << ' '.
			  self printOptionsOn: s ]
]
