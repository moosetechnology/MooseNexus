"
I run [VerveineJ-Docker](https://github.com/Evref-BL/VerveineJ-Docker).
Obtain the latest image using `docker pull ghcr.io/evref-bl/verveinej:latest`.
"
Class {
	#name : 'NexusDockerVerveineJRunner',
	#superclass : 'NexusVerveineJRunner',
	#instVars : [
		'version'
	],
	#category : 'MooseNexus-ModelExtraction',
	#package : 'MooseNexus',
	#tag : 'ModelExtraction'
}

{ #category : 'running' }
NexusDockerVerveineJRunner >> run [

	| returnCode |
	returnCode := LibC runCommand: self writeCommand.
	returnCode == 0 ifFalse: [
		returnCode == 32000 ifTrue: [
			Error signal: 'Docker must be running' ].
		"look for Docker or Shell error codes to understand your issue"
		Error signal:
			'Failed to create the model, error code: ' , returnCode asString ].

	"VerveineJ-Docker outputs the file in the sources directory"
	^ 'sources/' , self class outputFilename , '.' , self format
]

{ #category : 'accessing' }
NexusDockerVerveineJRunner >> version [

	^ version ifNil: [ version := 'latest' ]
]

{ #category : 'accessing' }
NexusDockerVerveineJRunner >> version: aString [
	"The VerveineJ version to use."

	version := aString
]

{ #category : 'writing' }
NexusDockerVerveineJRunner >> writeCommand [

	^ String streamContents: [ :s |
		  s << 'docker run --rm -v ' << target << '/sources:/src -v '
		  << target
		  << '/dependencies:/dependency ghcr.io/evref-bl/verveinej:'
		  << self version << ' '.
		  self printOptionsOn: s ]
]
