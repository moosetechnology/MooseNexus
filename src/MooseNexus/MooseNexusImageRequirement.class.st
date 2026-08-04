"
I describe a requirement that is validated inside the running Pharo image.

I use the same validation protocol as MooseNexusToolRequirement, but I evaluate image-side blocks instead of shell commands. This is used for Moose/Famix compatibility checks that cannot be represented as external tool availability.
"
Class {
	#name : 'MooseNexusImageRequirement',
	#superclass : 'Object',
	#instVars : [
		'name',
		'availabilityBlock',
		'versionBlock',
		'expectedVersionDescription'
	],
	#category : 'MooseNexus-Build',
	#package : 'MooseNexus',
	#tag : 'Build'
}

{ #category : 'instance creation' }
MooseNexusImageRequirement class >> name: aName availabilityBlock: availabilityBlockClosure versionBlock: versionBlockClosure expectedVersionDescription: expectedVersionDescriptionString [

	^ self new
		  initializeName: aName
		  availabilityBlock: availabilityBlockClosure
		  versionBlock: versionBlockClosure
		  expectedVersionDescription: expectedVersionDescriptionString;
		  yourself
]

{ #category : 'comparing' }
MooseNexusImageRequirement >> = anObject [

	^ self == anObject
]

{ #category : 'accessing' }
MooseNexusImageRequirement >> availabilityCommand [

	^ '<image>'
]

{ #category : 'accessing' }
MooseNexusImageRequirement >> expectedVersionDescription [

	^ expectedVersionDescription
]

{ #category : 'comparing' }
MooseNexusImageRequirement >> hash [

	^ self identityHash
]

{ #category : 'initialization' }
MooseNexusImageRequirement >> initializeName: aName availabilityBlock: availabilityBlockClosure versionBlock: versionBlockClosure expectedVersionDescription: expectedVersionDescriptionString [

	name := aName.
	availabilityBlock := availabilityBlockClosure.
	versionBlock := versionBlockClosure.
	expectedVersionDescription := expectedVersionDescriptionString
]

{ #category : 'accessing' }
MooseNexusImageRequirement >> name [

	^ name
]

{ #category : 'printing' }
MooseNexusImageRequirement >> printOn: aStream [

	aStream
		nextPutAll: name;
		nextPutAll: ' (image, expected: ';
		nextPutAll: expectedVersionDescription;
		nextPut: $)
]

{ #category : 'validating' }
MooseNexusImageRequirement >> validate [

	^ self validateAvailabilityUsing: nil versionUsing: nil
]

{ #category : 'validating' }
MooseNexusImageRequirement >> validateAvailabilityUsing: availabilityRunner versionUsing: versionRunner [

	| available versionDetails |
	available := availabilityBlock value.
	versionDetails := available ifTrue: [ versionBlock value asString ] ifFalse: [ '' ].
	^ MooseNexusToolValidationResult
		  requirement: self
		  available: available
		  details: available asString
		  versionDetails: versionDetails
]

{ #category : 'validating' }
MooseNexusImageRequirement >> validateUsing: aCommandRunner [

	^ self validateAvailabilityUsing: nil versionUsing: nil
]

{ #category : 'accessing' }
MooseNexusImageRequirement >> versionCommand [

	^ '<image>'
]
