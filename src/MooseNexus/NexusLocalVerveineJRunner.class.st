Class {
	#name : 'NexusLocalVerveineJRunner',
	#superclass : 'NexusVerveineJRunner',
	#instVars : [
		'directory'
	],
	#category : 'MooseNexus-ModelExtraction',
	#package : 'MooseNexus',
	#tag : 'ModelExtraction'
}

{ #category : 'accessing' }
NexusLocalVerveineJRunner >> directory [

	^ directory
]

{ #category : 'accessing' }
NexusLocalVerveineJRunner >> directory: pathString [

	directory := pathString
]

{ #category : 'running' }
NexusLocalVerveineJRunner >> run [

	self shouldBeImplemented.
	"TODO add the arguments"
	LibC runCommand: 'cd ' , directory , ' && ./verveinej.sh '
]
