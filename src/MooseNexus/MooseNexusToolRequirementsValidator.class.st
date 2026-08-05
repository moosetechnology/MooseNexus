"
I provide the shared tool-requirement validation protocol for MooseNexus objects that need preflight checks.
"
Class {
	#name : 'MooseNexusToolRequirementsValidator',
	#superclass : 'Object',
	#category : 'MooseNexus-Build',
	#package : 'MooseNexus',
	#tag : 'Build'
}

{ #category : 'capabilities' }
MooseNexusToolRequirementsValidator >> toolRequirements [

	^ #(  )
]

{ #category : 'validating' }
MooseNexusToolRequirementsValidator >> validateToolRequirements [

	self validateToolRequirements: (self
			 validateToolRequirementsAvailabilityUsing: [ :command | LibC runCommand: command ]
			 versionUsing: [ :command | LibC resultOfCommand: command ])
]

{ #category : 'validating' }
MooseNexusToolRequirementsValidator >> validateToolRequirements: validationResults [

	validationResults
		detect: [ :result | result isAvailable not ]
		ifFound: [ :result | Error signal: result errorMessage ].
	^ validationResults
]

{ #category : 'validating' }
MooseNexusToolRequirementsValidator >> validateToolRequirementsAvailabilityUsing: availabilityRunner versionUsing: versionRunner [

	^ self toolRequirements collect: [ :requirement |
		  requirement validateAvailabilityUsing: availabilityRunner versionUsing: versionRunner ]
]
