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
MooseNexusUnavailableToolModelExtractor >> validateToolRequirements [

	Error signal: 'Unavailable test extractor tool'
]
