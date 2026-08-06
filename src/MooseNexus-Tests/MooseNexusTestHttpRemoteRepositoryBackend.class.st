"
I am a test remote backend that exercises MooseNexusRemoteRepositoryBackend fetch behavior without network access.

I override only the HTTP download boundary and keep the inherited fetch-and-cache implementation under test.
"
Class {
	#name : 'MooseNexusTestHttpRemoteRepositoryBackend',
	#superclass : 'MooseNexusRemoteRepositoryBackend',
	#instVars : [
		'artifacts',
		'downloadCount'
	],
	#category : 'MooseNexus-Tests',
	#package : 'MooseNexus-Tests'
}

{ #category : 'adding' }
MooseNexusTestHttpRemoteRepositoryBackend >> artifactAt: repositoryRelativePath contents: artifactContents [

	artifacts at: repositoryRelativePath put: artifactContents
]

{ #category : 'artifacts' }
MooseNexusTestHttpRemoteRepositoryBackend >> downloadArtifactAt: repositoryRelativePath to: targetFile [

	downloadCount := downloadCount + 1.
	(artifacts includesKey: repositoryRelativePath) ifFalse: [ ^ false ].
	targetFile writeStreamDo: [ :stream | stream nextPutAll: (artifacts at: repositoryRelativePath) ].
	^ true
]

{ #category : 'accessing' }
MooseNexusTestHttpRemoteRepositoryBackend >> downloadCount [

	^ downloadCount
]

{ #category : 'initialization' }
MooseNexusTestHttpRemoteRepositoryBackend >> initialize [

	super initialize.
	artifacts := Dictionary new.
	downloadCount := 0
]
