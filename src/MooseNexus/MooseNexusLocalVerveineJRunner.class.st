Class {
	#name : 'MooseNexusLocalVerveineJRunner',
	#superclass : 'MooseNexusVerveineJRunner',
	#instVars : [
		'directory'
	],
	#category : 'MooseNexus-ModelExtraction',
	#package : 'MooseNexus',
	#tag : 'ModelExtraction'
}

{ #category : 'accessing' }
MooseNexusLocalVerveineJRunner >> directory [

	^ directory
]

{ #category : 'accessing' }
MooseNexusLocalVerveineJRunner >> directory: pathString [

	directory := pathString
]

{ #category : 'running' }
MooseNexusLocalVerveineJRunner >> run [

	self shouldBeImplemented.
	"TODO add the arguments"
	LibC runCommand: 'cd ' , directory , ' && ./verveinej.sh '
]
