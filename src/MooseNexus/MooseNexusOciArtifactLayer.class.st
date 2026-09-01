"
I describe one file layer that will be pushed as part of an OCI artifact bundle.
"
Class {
	#name : 'MooseNexusOciArtifactLayer',
	#superclass : 'Object',
	#instVars : [
		'file',
		'mediaType'
	],
	#category : 'MooseNexus-Artifact',
	#package : 'MooseNexus',
	#tag : 'Artifact'
}

{ #category : 'instance creation' }
MooseNexusOciArtifactLayer class >> file: aFileReference mediaType: aString [

	^ self new initializeFile: aFileReference mediaType: aString
]

{ #category : 'converting' }
MooseNexusOciArtifactLayer >> asOrasArgument [

	^ String streamContents: [ :stream |
			  stream
				  nextPutAll: file pathString;
				  nextPut: $:;
				  nextPutAll: mediaType ]
]

{ #category : 'accessing' }
MooseNexusOciArtifactLayer >> file [

	^ file
]

{ #category : 'initialization' }
MooseNexusOciArtifactLayer >> initializeFile: aFileReference mediaType: aString [

	file := aFileReference asFileReference.
	mediaType := aString
]

{ #category : 'accessing' }
MooseNexusOciArtifactLayer >> mediaType [

	^ mediaType
]
