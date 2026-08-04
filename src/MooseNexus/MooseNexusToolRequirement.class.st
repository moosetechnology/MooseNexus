"
I describe one external tool required by a MooseNexus importer or extractor.

I keep the human-readable tool name and the shell command used for a lightweight availability/version check. The command can be evaluated through an injected runner in tests, or through the default operating-system runner in production.
"
Class {
	#name : 'MooseNexusToolRequirement',
	#superclass : 'Object',
	#instVars : [
		'name',
		'availabilityCommand',
		'versionCommand',
		'expectedVersionDescription'
	],
	#category : 'MooseNexus-Build',
	#package : 'MooseNexus',
	#tag : 'Build'
}

{ #category : 'instance creation' }
MooseNexusToolRequirement class >> name: aName availabilityCommand: availabilityCommandString versionCommand: versionCommandString expectedVersionDescription: expectedVersionDescriptionString [

	^ self new
		  initializeName: aName
		  availabilityCommand: availabilityCommandString
		  versionCommand: versionCommandString
		  expectedVersionDescription: expectedVersionDescriptionString;
		  yourself
]

{ #category : 'comparing' }
MooseNexusToolRequirement >> = anObject [

	^ self class = anObject class and: [
		  anObject name = name and: [
			  anObject availabilityCommand = availabilityCommand and: [
				  anObject versionCommand = versionCommand and: [
					  anObject expectedVersionDescription = expectedVersionDescription ] ] ] ]
]

{ #category : 'accessing' }
MooseNexusToolRequirement >> availabilityCommand [

	^ availabilityCommand
]

{ #category : 'accessing' }
MooseNexusToolRequirement >> expectedVersionDescription [

	^ expectedVersionDescription
]

{ #category : 'comparing' }
MooseNexusToolRequirement >> hash [

	^ name hash bitXor: (availabilityCommand hash bitXor: (versionCommand hash bitXor: expectedVersionDescription hash))
]

{ #category : 'initialization' }
MooseNexusToolRequirement >> initializeName: aName availabilityCommand: availabilityCommandString versionCommand: versionCommandString expectedVersionDescription: expectedVersionDescriptionString [

	name := aName.
	availabilityCommand := availabilityCommandString.
	versionCommand := versionCommandString.
	expectedVersionDescription := expectedVersionDescriptionString
]

{ #category : 'accessing' }
MooseNexusToolRequirement >> name [

	^ name
]

{ #category : 'printing' }
MooseNexusToolRequirement >> printOn: aStream [

	aStream
		nextPutAll: name;
		nextPutAll: ' (';
		nextPutAll: availabilityCommand;
		nextPutAll: ', expected: ';
		nextPutAll: expectedVersionDescription;
		nextPut: $)
]

{ #category : 'validating' }
MooseNexusToolRequirement >> validate [

	^ self
		  validateAvailabilityUsing: [ :command | LibC runCommand: command ]
		  versionUsing: [ :command | LibC resultOfCommand: command ]
]

{ #category : 'validating' }
MooseNexusToolRequirement >> validateAvailabilityUsing: availabilityRunner versionUsing: versionRunner [

	| availabilityResult available versionResult |
	availabilityResult := availabilityRunner value: availabilityCommand.
	available := availabilityResult = 0.
	versionResult := available
		                 ifTrue: [ versionCommand ifNil: [ '' ] ifNotNil: [ versionRunner value: versionCommand ] ]
		                 ifFalse: [ '' ].
	^ MooseNexusToolValidationResult
		  requirement: self
		  available: available
		  details: availabilityResult asString
		  versionDetails: versionResult asString
]

{ #category : 'validating' }
MooseNexusToolRequirement >> validateUsing: aCommandRunner [

	^ self validateAvailabilityUsing: aCommandRunner versionUsing: [ :command | aCommandRunner value: command ]
]

{ #category : 'accessing' }
MooseNexusToolRequirement >> versionCommand [

	^ versionCommand
]
