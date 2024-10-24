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
	#category : 'MooseNexus-Modeling',
	#package : 'MooseNexus',
	#tag : 'Modeling'
}

{ #category : 'running' }
NexusDockerVerveineJRunner >> run [

	| command returnCode targetFile |
	command := String streamContents: [ :s |
		           s << 'docker run --rm -v ' << target
		           << '/sources:/src -v ' << target
		           <<
		           '/dependencies:/dependency ghcr.io/evref-bl/verveinej:'
		           << self version << ' '.
		           self printOptionsOn: s ].

	returnCode := LibC runCommand: command.
	returnCode == 0 ifFalse: [
		returnCode == 32000 ifTrue: [
			Error signal: 'Docker must be running' ].
		"look for Docker or Shell error codes to understand your issue"
		Error signal:
			'Failed to create the model, error code: ' , returnCode asString ].

	(targetFile := target asFileReference) / 'sources/output.json'
		moveTo: targetFile / 'model.json'
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
