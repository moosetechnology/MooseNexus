"
I am a test extractor used to exercise build-spec execution without invoking external model extraction tools.
"
Class {
	#name : 'MooseNexusTestModelExtractor',
	#superclass : 'Object',
	#instVars : [
		'target'
	],
	#category : 'MooseNexus-Tests',
	#package : 'MooseNexus-Tests'
}

{ #category : 'running' }
MooseNexusTestModelExtractor >> run [

	| modelPath modelFile |
	modelPath := 'sources/mooseNexusModel.json'.
	modelFile := target asFileReference / modelPath.
	modelFile ensureCreateFile writeStreamDo: [ :stream | stream nextPutAll: '{ }' ].
	^ modelPath
]

{ #category : 'accessing' }
MooseNexusTestModelExtractor >> target [

	^ target
]

{ #category : 'accessing' }
MooseNexusTestModelExtractor >> target: pathString [

	target := pathString
]
