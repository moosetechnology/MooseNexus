"
I describe the result of checking one MooseNexus requirement.

I am intentionally small so importers, extractors, and model import steps can report headless preflight information without coupling themselves to a UI or to a specific validation mechanism.
"
Class {
	#name : 'MooseNexusRequirementValidationResult',
	#superclass : 'Object',
	#instVars : [
		'requirement',
		'available',
		'details',
		'versionDetails'
	],
	#category : 'MooseNexus-Build',
	#package : 'MooseNexus',
	#tag : 'Build'
}

{ #category : 'instance creation' }
MooseNexusRequirementValidationResult class >> requirement: aMooseNexusRequirement available: aBoolean details: aString [

	^ self
		  requirement: aMooseNexusRequirement
		  available: aBoolean
		  details: aString
		  versionDetails: ''
]

{ #category : 'instance creation' }
MooseNexusRequirementValidationResult class >> requirement: aMooseNexusRequirement available: aBoolean details: aString versionDetails: versionString [

	^ self new
		  initializeRequirement: aMooseNexusRequirement
		  available: aBoolean
		  details: aString
		  versionDetails: versionString;
		  yourself
]

{ #category : 'comparing' }
MooseNexusRequirementValidationResult >> = anObject [

	^ self class = anObject class and: [
		  anObject requirement = requirement and: [
			  anObject available = available and: [ anObject details = details and: [ anObject versionDetails = versionDetails ] ] ] ]
]

{ #category : 'accessing' }
MooseNexusRequirementValidationResult >> available [

	^ available
]

{ #category : 'accessing' }
MooseNexusRequirementValidationResult >> details [

	^ details
]

{ #category : 'accessing' }
MooseNexusRequirementValidationResult >> errorMessage [

	^ String streamContents: [ :stream |
			  stream
				  nextPutAll: self requirementName;
				  nextPutAll: ' is not available. Availability validation `';
				  nextPutAll: requirement availabilityValidation asString;
				  nextPutAll: '` returned: ';
				  nextPutAll: details ]
]

{ #category : 'comparing' }
MooseNexusRequirementValidationResult >> hash [

	^ requirement hash bitXor: (available hash bitXor: (details hash bitXor: versionDetails hash))
]

{ #category : 'initialization' }
MooseNexusRequirementValidationResult >> initializeRequirement: aMooseNexusRequirement available: aBoolean details: aString versionDetails: versionString [

	requirement := aMooseNexusRequirement.
	available := aBoolean.
	details := aString.
	versionDetails := versionString
]

{ #category : 'testing' }
MooseNexusRequirementValidationResult >> isAvailable [

	^ available
]

{ #category : 'accessing' }
MooseNexusRequirementValidationResult >> requirement [

	^ requirement
]

{ #category : 'accessing' }
MooseNexusRequirementValidationResult >> requirementName [

	^ requirement name
]

{ #category : 'accessing' }
MooseNexusRequirementValidationResult >> versionDetails [

	^ versionDetails
]
