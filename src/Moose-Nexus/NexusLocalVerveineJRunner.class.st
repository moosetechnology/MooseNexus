Class {
	#name : 'NexusLocalVerveineJRunner',
	#superclass : 'NexusVerveineJRunner',
	#instVars : [
		'directory'
	],
	#category : 'Moose-Nexus-Modeling',
	#package : 'Moose-Nexus',
	#tag : 'Modeling'
}

{ #category : 'accessing' }
NexusLocalVerveineJRunner >> directory [

	^ directory
]

{ #category : 'accessing' }
NexusLocalVerveineJRunner >> directory: anObject [

	directory := anObject
]

{ #category : 'running' }
NexusLocalVerveineJRunner >> run [

	self shouldBeImplemented.
	"TODO add the arguments"
	LibC runCommand: 'cd ' , directory , ' && ./verveinej.sh '
]
