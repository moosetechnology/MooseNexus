"
I describe a requirement that can be validated before MooseNexus imports or extracts a model.

Subclasses decide how the validation values are evaluated. I keep the shared requirement identity, expected version description, and result creation protocol.
"
Class {
	#name : 'MooseNexusRequirement',
	#superclass : 'Object',
	#instVars : [
		'name',
		'availabilityValidation',
		'versionValidation',
		'expectedVersionDescription'
	],
	#category : 'MooseNexus-Build',
	#package : 'MooseNexus',
	#tag : 'Build'
}

{ #category : 'testing' }
MooseNexusRequirement class >> isAbstract [

	^ self == MooseNexusRequirement
]

{ #category : 'accessing' }
MooseNexusRequirement >> availabilityValidation [

	^ availabilityValidation
]

{ #category : 'accessing' }
MooseNexusRequirement >> expectedVersionDescription [

	^ expectedVersionDescription
]

{ #category : 'initialization' }
MooseNexusRequirement >> initializeName: aName availabilityValidation: availabilityValidationObject versionValidation: versionValidationObject expectedVersionDescription: expectedVersionDescriptionString [

	name := aName.
	availabilityValidation := availabilityValidationObject.
	versionValidation := versionValidationObject.
	expectedVersionDescription := expectedVersionDescriptionString
]

{ #category : 'accessing' }
MooseNexusRequirement >> name [

	^ name
]

{ #category : 'validating' }
MooseNexusRequirement >> validate [

	self subclassResponsibility
]

{ #category : 'validating' }
MooseNexusRequirement >> validationResultAvailable: aBoolean details: detailsString versionDetails: versionDetailsString [

	^ MooseNexusRequirementValidationResult
		  requirement: self
		  available: aBoolean
		  details: detailsString
		  versionDetails: versionDetailsString
]

{ #category : 'accessing' }
MooseNexusRequirement >> versionValidation [

	^ versionValidation
]
