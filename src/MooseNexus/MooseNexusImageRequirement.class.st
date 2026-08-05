"
I describe a requirement that is validated inside the running Pharo image.

I use the same validation storage as MooseNexusToolRequirement, but evaluate image-side blocks instead of shell commands. This is used for Moose/Famix compatibility checks that cannot be represented as external tool availability.
"
Class {
	#name : 'MooseNexusImageRequirement',
	#superclass : 'MooseNexusRequirement',
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

{ #category : 'comparing' }
MooseNexusImageRequirement >> hash [

	^ self identityHash
]

{ #category : 'initialization' }
MooseNexusImageRequirement >> initializeName: aName availabilityBlock: availabilityBlockClosure versionBlock: versionBlockClosure expectedVersionDescription: expectedVersionDescriptionString [

	self
		initializeName: aName
		availabilityValidation: availabilityBlockClosure
		versionValidation: versionBlockClosure
		expectedVersionDescription: expectedVersionDescriptionString
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
	available := availabilityValidation value.
	versionDetails := available ifTrue: [ versionValidation value asString ] ifFalse: [ '' ].
	^ self
		  validationResultAvailable: available
		  details: available asString
		  versionDetails: versionDetails
]

{ #category : 'accessing' }
MooseNexusImageRequirement >> versionCommand [

	^ '<image>'
]
