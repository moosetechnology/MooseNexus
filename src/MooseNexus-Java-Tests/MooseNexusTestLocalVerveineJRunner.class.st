Class {
	#name : 'MooseNexusTestLocalVerveineJRunner',
	#superclass : 'MooseNexusLocalVerveineJRunner',
	#instVars : [
		'returnCode',
		'executedCommand'
	],
	#category : 'MooseNexus-Java-Tests-ModelExtraction',
	#package : 'MooseNexus-Java-Tests',
	#tag : 'ModelExtraction'
}

{ #category : 'accessing' }
MooseNexusTestLocalVerveineJRunner >> executedCommand [

	^ executedCommand
]

{ #category : 'accessing' }
MooseNexusTestLocalVerveineJRunner >> returnCode [

	^ returnCode ifNil: [ 0 ]
]

{ #category : 'accessing' }
MooseNexusTestLocalVerveineJRunner >> returnCode: anInteger [

	returnCode := anInteger
]

{ #category : 'running' }
MooseNexusTestLocalVerveineJRunner >> runCommand: aCommand [

	executedCommand := aCommand.
	^ self returnCode
]
