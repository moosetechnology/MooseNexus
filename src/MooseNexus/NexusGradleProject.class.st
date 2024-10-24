Class {
	#name : 'NexusGradleProject',
	#superclass : 'NexusManagedProject',
	#category : 'MooseNexus-Project',
	#package : 'MooseNexus',
	#tag : 'Project'
}

{ #category : 'error handling' }
NexusGradleProject class >> canHandle: directory [

	FileSystem disk
		fileNamesAt: directory
		do: [ :filename | filename = 'gradle.build' ifTrue: [ ^ true ] ].
	^ false
]

{ #category : 'testing' }
NexusGradleProject class >> fromDirectory: directory [

	^ self new directory: directory
]
