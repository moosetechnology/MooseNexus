"
I pull MooseNexus OCI artifacts into a local MooseNexus repository.

I keep remote access local-first by returning an already installed project when the reference maps to project coordinates present in the local repository. Use force when the caller explicitly wants to fetch and reinstall from the remote registry.
"
Class {
	#name : 'MooseNexusOciArtifactPuller',
	#superclass : 'Object',
	#instVars : [
		'referenceMapper',
		'transport',
		'repository'
	],
	#category : 'MooseNexus-Repository',
	#package : 'MooseNexus',
	#tag : 'Repository'
}

{ #category : 'instance creation' }
MooseNexusOciArtifactPuller class >> referenceMapper: aMooseNexusOciReferenceMapper transport: aMooseNexusOrasTransport repository: aMooseNexusRepository [

	^ self new
		  initializeReferenceMapper: aMooseNexusOciReferenceMapper
		  transport: aMooseNexusOrasTransport
		  repository: aMooseNexusRepository
]

{ #category : 'initialization' }
MooseNexusOciArtifactPuller >> initializeReferenceMapper: aMooseNexusOciReferenceMapper transport: aMooseNexusOrasTransport repository: aMooseNexusRepository [

	referenceMapper := aMooseNexusOciReferenceMapper.
	transport := aMooseNexusOrasTransport.
	repository := aMooseNexusRepository
]

{ #category : 'private' }
MooseNexusOciArtifactPuller >> installPulledBundleFrom: bundleDirectory [

	^ MooseNexusOciArtifactInstaller new installBundleFrom: bundleDirectory in: repository
]

{ #category : 'private' }
MooseNexusOciArtifactPuller >> localProjectForReference: reference ifPresent: presentBlock [

	| coordinates |
	coordinates := [ referenceMapper coordinatesFromReference: reference ]
		               on: Error
		               do: [ ^ nil ].
	^ [ presentBlock value: (repository group: coordinates group project: coordinates name version: coordinates version) ]
		  on: NotFound
		  do: [ nil ]
]

{ #category : 'pulling' }
MooseNexusOciArtifactPuller >> pull: reference [

	^ self pull: reference force: false
]

{ #category : 'pulling' }
MooseNexusOciArtifactPuller >> pull: reference force: shouldForce [

	shouldForce ifFalse: [ self localProjectForReference: reference ifPresent: [ :project | ^ project ] ].
	^ self installPulledBundleFrom: (transport pull: reference)
]

{ #category : 'accessing' }
MooseNexusOciArtifactPuller >> referenceMapper [

	^ referenceMapper
]

{ #category : 'accessing' }
MooseNexusOciArtifactPuller >> repository [

	^ repository
]

{ #category : 'accessing' }
MooseNexusOciArtifactPuller >> transport [

	^ transport
]
