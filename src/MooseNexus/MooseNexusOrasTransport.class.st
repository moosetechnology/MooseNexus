"
I publish MooseNexus OCI artifact bundles by delegating transport work to ORAS.
"
Class {
	#name : 'MooseNexusOrasTransport',
	#superclass : 'Object',
	#instVars : [
		'executable',
		'commandRunner'
	],
	#category : 'MooseNexus-Repository',
	#package : 'MooseNexus',
	#tag : 'Repository'
}

{ #category : 'private' }
MooseNexusOrasTransport >> annotationArgumentFor: association [

	^ String streamContents: [ :stream |
			  stream
				  nextPutAll: association key;
				  nextPut: $=;
				  nextPutAll: association value asString ]
]

{ #category : 'accessing' }
MooseNexusOrasTransport >> commandRunner [

	^ commandRunner
]

{ #category : 'accessing' }
MooseNexusOrasTransport >> commandRunner: aBlock [

	commandRunner := aBlock
]

{ #category : 'accessing' }
MooseNexusOrasTransport >> executable [

	^ executable
]

{ #category : 'accessing' }
MooseNexusOrasTransport >> executable: aString [

	executable := aString
]

{ #category : 'initialization' }
MooseNexusOrasTransport >> initialize [

	executable := 'oras'.
	commandRunner := [ :arguments | self runCommandArguments: arguments ]
]

{ #category : 'fetching' }
MooseNexusOrasTransport >> pull: reference into: outputDirectory [

	^ commandRunner value: (self pullArgumentsFor: reference into: outputDirectory)
]

{ #category : 'fetching' }
MooseNexusOrasTransport >> pullArgumentsFor: reference into: outputDirectory [

	^ {
		  executable.
		  'pull'.
		  '--output'.
		  outputDirectory asFileReference pathString.
		  reference }
]

{ #category : 'publishing' }
MooseNexusOrasTransport >> pushArgumentsFor: aMooseNexusOciArtifactBundle [

	| arguments |
	arguments := OrderedCollection new.
	arguments
		add: executable;
		add: 'push';
		add: '--artifact-type';
		add: aMooseNexusOciArtifactBundle artifactType;
		add: '--config';
		add: aMooseNexusOciArtifactBundle configArgument.
	aMooseNexusOciArtifactBundle annotationsDo: [ :association |
			arguments addAll: {
					'--annotation'.
					(self annotationArgumentFor: association) } ].
	arguments add: aMooseNexusOciArtifactBundle reference.
	arguments addAll: (aMooseNexusOciArtifactBundle layers collect: [ :layer | layer asOrasArgument ]).
	^ arguments asArray
]

{ #category : 'publishing' }
MooseNexusOrasTransport >> pushBundle: aMooseNexusOciArtifactBundle [

	aMooseNexusOciArtifactBundle reference ifNil: [ Error signal: 'Cannot push an OCI artifact bundle without a reference' ].
	^ commandRunner value: (self pushArgumentsFor: aMooseNexusOciArtifactBundle)
]

{ #category : 'private' }
MooseNexusOrasTransport >> runCommandArguments: arguments [

	^ LibC runCommand: (self shellCommandFromArguments: arguments)
]

{ #category : 'private' }
MooseNexusOrasTransport >> shellCommandFromArguments: arguments [

	^ String streamContents: [ :stream |
		  arguments do: [ :argument | stream nextPutAll: (self shellQuote: argument) ] separatedBy: [ stream space ] ]
]

{ #category : 'private' }
MooseNexusOrasTransport >> shellQuote: aString [

	^ String streamContents: [ :stream |
			  stream nextPut: $'.
			  aString asString do: [ :character |
					  character = $'
						  ifTrue: [ stream nextPutAll: '''"''"''' ]
						  ifFalse: [ stream nextPut: character ] ].
			  stream nextPut: $' ]
]
