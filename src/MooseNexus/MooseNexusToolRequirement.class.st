"
I describe one external tool required by a MooseNexus importer or extractor.

I keep the human-readable tool name and the shell command used for a lightweight availability/version check. The command can be evaluated through an injected runner in tests, or through the default operating-system runner in production.
"
Class {
	#name : 'MooseNexusToolRequirement',
	#superclass : 'MooseNexusRequirement',
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
			  anObject availabilityCommand = availabilityValidation and: [
				  anObject versionCommand = versionValidation and: [
					  anObject expectedVersionDescription = expectedVersionDescription ] ] ] ]
]

{ #category : 'accessing' }
MooseNexusToolRequirement >> availabilityCommand [

	^ availabilityValidation
]

{ #category : 'comparing' }
MooseNexusToolRequirement >> hash [

	^ name hash bitXor: (availabilityValidation hash bitXor: (versionValidation hash bitXor: expectedVersionDescription hash))
]

{ #category : 'initialization' }
MooseNexusToolRequirement >> initializeName: aName availabilityCommand: availabilityCommandString versionCommand: versionCommandString expectedVersionDescription: expectedVersionDescriptionString [

	self
		initializeName: aName
		availabilityValidation: availabilityCommandString
		versionValidation: versionCommandString
		expectedVersionDescription: expectedVersionDescriptionString
]

{ #category : 'printing' }
MooseNexusToolRequirement >> printOn: aStream [

	aStream
		nextPutAll: name;
		nextPutAll: ' (';
		nextPutAll: availabilityValidation;
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
	availabilityResult := availabilityRunner value: availabilityValidation.
	available := availabilityResult = 0.
	versionResult := available
		                 ifTrue: [ versionValidation ifNil: [ '' ] ifNotNil: [ versionRunner value: versionValidation ] ]
		                 ifFalse: [ '' ].
	^ self
		  validationResultAvailable: available
		  details: availabilityResult asString
		  versionDetails: versionResult asString
]

{ #category : 'accessing' }
MooseNexusToolRequirement >> versionCommand [

	^ versionValidation
]
