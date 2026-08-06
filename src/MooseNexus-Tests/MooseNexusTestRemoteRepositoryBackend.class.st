"
I am a deterministic remote repository test double.

Artifacts are stored as text by repository-relative path. Fetching an artifact writes it into the provided local backend, allowing repository-chain tests to exercise remote behavior without network access.
"
Class {
	#name : 'MooseNexusTestRemoteRepositoryBackend',
	#superclass : 'MooseNexusRepositoryBackend',
	#instVars : [
		'artifacts',
		'fetchCount'
	],
	#category : 'MooseNexus-Tests',
	#package : 'MooseNexus-Tests'
}

{ #category : 'artifacts' }
MooseNexusTestRemoteRepositoryBackend >> artifactAt: repositoryRelativePath [

	self shouldNotImplement
]

{ #category : 'adding' }
MooseNexusTestRemoteRepositoryBackend >> artifactAt: repositoryRelativePath contents: artifactContents [

	artifacts at: repositoryRelativePath put: artifactContents
]

{ #category : 'artifacts' }
MooseNexusTestRemoteRepositoryBackend >> artifactExistsAt: repositoryRelativePath [

	^ artifacts includesKey: repositoryRelativePath
]

{ #category : 'artifacts' }
MooseNexusTestRemoteRepositoryBackend >> fetchArtifactAt: repositoryRelativePath into: aMooseNexusLocalRepositoryBackend ifAbsent: absentBlock [

	| temporaryFile artifactFile |
	fetchCount := fetchCount + 1.
	(artifacts includesKey: repositoryRelativePath) ifFalse: [ ^ absentBlock value ].
	temporaryFile := FileLocator temp / ('moosenexus-test-' , UUID new asString).
	[
		temporaryFile writeStreamDo: [ :stream | stream nextPutAll: (artifacts at: repositoryRelativePath) ].
		artifactFile := aMooseNexusLocalRepositoryBackend storeArtifactAt: repositoryRelativePath from: temporaryFile.
		nil ] ensure: [ temporaryFile deleteIfAbsent: [ ] ].
	^ artifactFile
]

{ #category : 'accessing' }
MooseNexusTestRemoteRepositoryBackend >> fetchCount [

	^ fetchCount
]

{ #category : 'initialization' }
MooseNexusTestRemoteRepositoryBackend >> initialize [

	super initialize.
	artifacts := Dictionary new.
	fetchCount := 0
]
