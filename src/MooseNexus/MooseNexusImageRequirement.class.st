"
I describe a requirement that is validated inside the running Pharo image.

I use the same validation protocol as MooseNexusToolRequirement, but I evaluate image-side blocks instead of shell commands. This is used for Moose/Famix compatibility checks that cannot be represented as external tool availability.
"
Class {
	#name : 'MooseNexusImageRequirement',
	#superclass : 'MooseNexusRequirement',
	#category : 'MooseNexus-Build',
	#package : 'MooseNexus',
	#tag : 'Build'
}

{ #category : 'instance creation' }
MooseNexusImageRequirement class >> name: aName availabilityValidation: availabilityValidationObject versionValidation: versionValidationObject expectedVersionDescription: expectedVersionDescriptionString [

	^ self new
		  initializeName: aName
		  availabilityValidation: availabilityValidationObject
		  versionValidation: versionValidationObject
		  expectedVersionDescription: expectedVersionDescriptionString
]

{ #category : 'comparing' }
MooseNexusImageRequirement >> = anObject [

	^ self == anObject
]

{ #category : 'comparing' }
MooseNexusImageRequirement >> hash [

	^ self identityHash
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

	| available versionDetails |
	available := availabilityValidation value.
	versionDetails := available ifTrue: [ versionValidation value asString ] ifFalse: [ '' ].
	^ self validationResultAvailable: available details: available asString versionDetails: versionDetails
]
