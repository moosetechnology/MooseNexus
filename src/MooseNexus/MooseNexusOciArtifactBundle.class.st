"
I describe a MooseNexus artifact bundle ready to be published as one OCI artifact.
"
Class {
	#name : 'MooseNexusOciArtifactBundle',
	#superclass : 'Object',
	#instVars : [
		'reference',
		'artifactType',
		'configFile',
		'configMediaType',
		'layers',
		'annotations'
	],
	#category : 'MooseNexus-Artifact',
	#package : 'MooseNexus',
	#tag : 'Artifact'
}

{ #category : 'instance creation' }
MooseNexusOciArtifactBundle class >> artifactType: artifactType configFile: configFile configMediaType: configMediaType layers: layers annotations: annotations [

	^ self new
		  initializeArtifactType: artifactType
		  configFile: configFile
		  configMediaType: configMediaType
		  layers: layers
		  annotations: annotations
]

{ #category : 'accessing' }
MooseNexusOciArtifactBundle >> annotations [

	^ annotations
]

{ #category : 'enumerating' }
MooseNexusOciArtifactBundle >> annotationsDo: aBlock [

	self sortedAnnotations do: aBlock
]

{ #category : 'accessing' }
MooseNexusOciArtifactBundle >> artifactType [

	^ artifactType
]

{ #category : 'accessing' }
MooseNexusOciArtifactBundle >> configArgument [

	^ String streamContents: [ :stream |
			  stream
				  nextPutAll: configFile pathString;
				  nextPut: $:;
				  nextPutAll: configMediaType ]
]

{ #category : 'accessing' }
MooseNexusOciArtifactBundle >> configFile [

	^ configFile
]

{ #category : 'accessing' }
MooseNexusOciArtifactBundle >> configMediaType [

	^ configMediaType
]

{ #category : 'initialization' }
MooseNexusOciArtifactBundle >> initializeArtifactType: aType configFile: aConfigFile configMediaType: aConfigMediaType layers: artifactLayers annotations: artifactAnnotations [

	artifactType := aType.
	configFile := aConfigFile asFileReference.
	configMediaType := aConfigMediaType.
	layers := artifactLayers asArray.
	annotations := artifactAnnotations ifNil: [ Dictionary new ]
]

{ #category : 'accessing' }
MooseNexusOciArtifactBundle >> layers [

	^ layers
]

{ #category : 'accessing' }
MooseNexusOciArtifactBundle >> reference [

	^ reference
]

{ #category : 'accessing' }
MooseNexusOciArtifactBundle >> reference: aString [

	reference := aString
]

{ #category : 'private' }
MooseNexusOciArtifactBundle >> sortedAnnotations [

	^ annotations associations sorted: [ :left :right | left key <= right key ]
]
