"
I describe the result of checking one external tool requirement.

I am intentionally small so importers and extractors can report headless preflight information without coupling themselves to a UI or to a specific process execution mechanism.
"
Class {
	#name : 'MooseNexusToolValidationResult',
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
MooseNexusToolValidationResult class >> requirement: aMooseNexusToolRequirement available: aBoolean details: aString [

	^ self
		  requirement: aMooseNexusToolRequirement
		  available: aBoolean
		  details: aString
		  versionDetails: ''
]

{ #category : 'instance creation' }
MooseNexusToolValidationResult class >> requirement: aMooseNexusToolRequirement available: aBoolean details: aString versionDetails: versionString [

	^ self new
		  initializeRequirement: aMooseNexusToolRequirement available: aBoolean details: aString versionDetails: versionString;
		  yourself
]

{ #category : 'comparing' }
MooseNexusToolValidationResult >> = anObject [

	^ self class = anObject class and: [
		  anObject requirement = requirement and: [
			  anObject available = available and: [ anObject details = details and: [ anObject versionDetails = versionDetails ] ] ] ]
]

{ #category : 'accessing' }
MooseNexusToolValidationResult >> available [

	^ available
]

{ #category : 'accessing' }
MooseNexusToolValidationResult >> details [

	^ details
]

{ #category : 'accessing' }
MooseNexusToolValidationResult >> errorMessage [

	^ String streamContents: [ :stream |
		  stream
			  nextPutAll: self toolName;
			  nextPutAll: ' is not available. Availability command `';
			  nextPutAll: requirement availabilityCommand;
			  nextPutAll: '` returned: ';
			  nextPutAll: details ]
]

{ #category : 'comparing' }
MooseNexusToolValidationResult >> hash [

	^ requirement hash bitXor: (available hash bitXor: (details hash bitXor: versionDetails hash))
]

{ #category : 'initialization' }
MooseNexusToolValidationResult >> initializeRequirement: aMooseNexusToolRequirement available: aBoolean details: aString versionDetails: versionString [

	requirement := aMooseNexusToolRequirement.
	available := aBoolean.
	details := aString.
	versionDetails := versionString
]

{ #category : 'testing' }
MooseNexusToolValidationResult >> isAvailable [

	^ available
]

{ #category : 'accessing' }
MooseNexusToolValidationResult >> requirement [

	^ requirement
]

{ #category : 'accessing' }
MooseNexusToolValidationResult >> toolName [

	^ requirement name
]

{ #category : 'accessing' }
MooseNexusToolValidationResult >> versionDetails [

	^ versionDetails
]
