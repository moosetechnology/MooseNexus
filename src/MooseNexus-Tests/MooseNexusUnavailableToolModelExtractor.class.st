"
I am a test extractor whose tool validation fails before extraction can run.
"
Class {
	#name : 'MooseNexusUnavailableToolModelExtractor',
	#superclass : 'Object',
	#instVars : [
		'target',
		'didRun'
	],
	#category : 'MooseNexus-Tests',
	#package : 'MooseNexus-Tests'
}

{ #category : 'testing' }
MooseNexusUnavailableToolModelExtractor >> didRun [

	^ didRun ifNil: [ false ]
]

{ #category : 'capabilities' }
MooseNexusUnavailableToolModelExtractor >> requirements [

	^ { MooseNexusImageRequirement
		    name: 'Unavailable test extractor tool'
		    availabilityValidation: [ false ]
		    versionValidation: [ '' ]
		    expectedVersionDescription: 'available test extractor tool' }
]

{ #category : 'running' }
MooseNexusUnavailableToolModelExtractor >> run [

	didRun := true.
	^ 'sources/mooseNexusModel.json'
]

{ #category : 'accessing' }
MooseNexusUnavailableToolModelExtractor >> target [

	^ target
]

{ #category : 'accessing' }
MooseNexusUnavailableToolModelExtractor >> target: pathString [

	target := pathString
]

{ #category : 'validating' }
MooseNexusUnavailableToolModelExtractor >> validateRequirements [

	| validationResults |
	validationResults := self requirements collect: [ :requirement | requirement validate ].
	validationResults detect: [ :result | result isAvailable not ] ifFound: [ :result | Error signal: result errorMessage ].
	^ validationResults
]
