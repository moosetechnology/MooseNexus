"
I resolve repository artifact paths through a local backend first, then through configured remotes when remote access is enabled.

This mirrors Maven and Gradle client behavior: local artifacts are reused without network access, and remote repositories are consulted only for missing paths. Fetched artifacts are stored in the local backend before being returned.
"
Class {
	#name : 'MooseNexusRepositoryChainBackend',
	#superclass : 'MooseNexusRepositoryBackend',
	#instVars : [
		'localBackend',
		'remoteBackends',
		'remoteEnabled'
	],
	#category : 'MooseNexus-Repository',
	#package : 'MooseNexus',
	#tag : 'Repository'
}

{ #category : 'instance creation' }
MooseNexusRepositoryChainBackend class >> local: aMooseNexusRepositoryBackend remotes: remoteRepositoryBackends [

	^ self new
		  initializeLocal: aMooseNexusRepositoryBackend remotes: remoteRepositoryBackends;
		  yourself
]

{ #category : 'artifacts' }
MooseNexusRepositoryChainBackend >> artifactAt: repositoryRelativePath [

	^ self
		  artifactAt: repositoryRelativePath
		  ifAbsent: [ NotFound signal: 'Artifact `' , repositoryRelativePath , '` not found in configured repositories' ]
]

{ #category : 'artifacts' }
MooseNexusRepositoryChainBackend >> artifactAt: repositoryRelativePath ifAbsent: absentBlock [

	| missingMarker artifactFile |
	(localBackend artifactExistsAt: repositoryRelativePath) ifTrue: [ ^ localBackend artifactAt: repositoryRelativePath ].
	remoteEnabled ifFalse: [ ^ absentBlock value ].
	missingMarker := Object new.
	remoteBackends do: [ :remoteBackend |
			artifactFile := remoteBackend fetchArtifactAt: repositoryRelativePath into: localBackend ifAbsent: [ missingMarker ].
			artifactFile == missingMarker ifFalse: [ ^ artifactFile ] ].
	^ absentBlock value
]

{ #category : 'artifacts' }
MooseNexusRepositoryChainBackend >> artifactExistsAt: repositoryRelativePath [

	(localBackend artifactExistsAt: repositoryRelativePath) ifTrue: [ ^ true ].
	remoteEnabled ifFalse: [ ^ false ].
	^ remoteBackends anySatisfy: [ :remoteBackend | remoteBackend artifactExistsAt: repositoryRelativePath ]
]

{ #category : 'configuring' }
MooseNexusRepositoryChainBackend >> beLocalOnly [

	remoteEnabled := false
]

{ #category : 'configuring' }
MooseNexusRepositoryChainBackend >> beRemoteEnabled [

	remoteEnabled := true
]

{ #category : 'accessing' }
MooseNexusRepositoryChainBackend >> directory [

	^ localBackend directory
]

{ #category : 'accessing' }
MooseNexusRepositoryChainBackend >> directory: aFileReference [

	localBackend directory: aFileReference
]

{ #category : 'artifacts' }
MooseNexusRepositoryChainBackend >> fetchArtifactAt: repositoryRelativePath into: aMooseNexusLocalRepositoryBackend ifAbsent: absentBlock [

	| artifactFile |
	artifactFile := self artifactAt: repositoryRelativePath ifAbsent: [ ^ absentBlock value ].
	^ aMooseNexusLocalRepositoryBackend storeArtifactAt: repositoryRelativePath from: artifactFile
]

{ #category : 'enumerating' }
MooseNexusRepositoryChainBackend >> group: group project: project version: version [

	^ localBackend group: group project: project version: version
]

{ #category : 'initialization' }
MooseNexusRepositoryChainBackend >> initialize [

	super initialize.
	remoteBackends := #(  ).
	remoteEnabled := true
]

{ #category : 'initialization' }
MooseNexusRepositoryChainBackend >> initializeLocal: aMooseNexusRepositoryBackend remotes: remoteRepositoryBackends [

	localBackend := aMooseNexusRepositoryBackend.
	remoteBackends := remoteRepositoryBackends asArray.
	remoteEnabled := true
]

{ #category : 'accessing' }
MooseNexusRepositoryChainBackend >> localBackend [

	^ localBackend
]

{ #category : 'adding' }
MooseNexusRepositoryChainBackend >> prepareDirectoryFor: aMooseNexusProjectSpec [

	^ localBackend prepareDirectoryFor: aMooseNexusProjectSpec
]

{ #category : 'printing' }
MooseNexusRepositoryChainBackend >> printOn: stream [

	super printOn: stream.
	stream nextPut: $(.
	localBackend printOn: stream.
	remoteBackends ifNotEmpty: [
			stream
				nextPutAll: ', remotes: ';
				print: remoteBackends size ].
	remoteEnabled ifFalse: [ stream nextPutAll: ', local only' ].
	stream nextPut: $)
]

{ #category : 'printing' }
MooseNexusRepositoryChainBackend >> printProjectProperties: propertiesFile on: writeStream [

	^ localBackend printProjectProperties: propertiesFile on: writeStream
]

{ #category : 'printing' }
MooseNexusRepositoryChainBackend >> printProjects [

	^ localBackend printProjects
]

{ #category : 'enumerating' }
MooseNexusRepositoryChainBackend >> projectProperties [

	^ localBackend projectProperties
]

{ #category : 'enumerating' }
MooseNexusRepositoryChainBackend >> projects [

	^ localBackend projects
]

{ #category : 'recording' }
MooseNexusRepositoryChainBackend >> recordLoadedProject: aMooseNexusProject describedBy: aMooseNexusProjectSpec [

	^ localBackend recordLoadedProject: aMooseNexusProject describedBy: aMooseNexusProjectSpec
]

{ #category : 'accessing' }
MooseNexusRepositoryChainBackend >> remoteBackends [

	^ remoteBackends
]

{ #category : 'accessing' }
MooseNexusRepositoryChainBackend >> remoteEnabled [

	^ remoteEnabled
]

{ #category : 'enumerating' }
MooseNexusRepositoryChainBackend >> resolveDirectoryFor: aMooseNexusProjectSpec [

	^ localBackend resolveDirectoryFor: aMooseNexusProjectSpec
]

{ #category : 'artifacts' }
MooseNexusRepositoryChainBackend >> storeArtifactAt: repositoryRelativePath from: sourceFileReference [

	^ localBackend storeArtifactAt: repositoryRelativePath from: sourceFileReference
]
