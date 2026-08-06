"
I test local-first artifact resolution for chained MooseNexus repository backends.
"
Class {
	#name : 'MooseNexusRepositoryChainBackendTest',
	#superclass : 'TestCase',
	#instVars : [
		'rootDirectory',
		'localBackend'
	],
	#category : 'MooseNexus-Tests',
	#package : 'MooseNexus-Tests'
}

{ #category : 'running' }
MooseNexusRepositoryChainBackendTest >> setUp [

	super setUp.
	rootDirectory := FileLocator temp / ('MooseNexus-' , UUID new asString).
	rootDirectory ensureCreateDirectory.
	localBackend := MooseNexusLocalRepositoryBackend directory: rootDirectory / 'local'
]

{ #category : 'running' }
MooseNexusRepositoryChainBackendTest >> tearDown [

	rootDirectory ifNotNil: [ rootDirectory ifExists: [ rootDirectory deleteAll ] ].
	super tearDown
]

{ #category : 'tests' }
MooseNexusRepositoryChainBackendTest >> testArtifactExistsChecksRemotesWithoutFetching [

	| remote chain repositoryRelativePath |
	repositoryRelativePath := 'repository/com.example/demo/1.0.0/artifacts/models/demo.json'.
	remote := MooseNexusTestRemoteRepositoryBackend new.
	remote artifactAt: repositoryRelativePath contents: '{ }'.
	chain := MooseNexusRepositoryChainBackend local: localBackend remotes: { remote }.

	self assert: (chain artifactExistsAt: repositoryRelativePath).
	self assert: remote fetchCount equals: 0.
	self deny: (localBackend artifactExistsAt: repositoryRelativePath)
]

{ #category : 'tests' }
MooseNexusRepositoryChainBackendTest >> testChainFetchesMissingArtifactFromFirstRemoteAndCachesItLocally [

	| remote chain artifact |
	remote := MooseNexusTestRemoteRepositoryBackend new.
	remote artifactAt: 'repository/com.example/demo/1.0.0/artifacts/models/demo.json' contents: '{ }'.
	chain := MooseNexusRepositoryChainBackend local: localBackend remotes: { remote }.

	artifact := chain artifactAt: 'repository/com.example/demo/1.0.0/artifacts/models/demo.json'.

	self assert: artifact contents equals: '{ }'.
	self assert: remote fetchCount equals: 1.
	self assert: (localBackend artifactExistsAt: 'repository/com.example/demo/1.0.0/artifacts/models/demo.json')
]

{ #category : 'tests' }
MooseNexusRepositoryChainBackendTest >> testChainHonorsLocalOnlyPolicy [

	| remote chain |
	remote := MooseNexusTestRemoteRepositoryBackend new.
	remote artifactAt: 'repository/com.example/demo/1.0.0/artifacts/models/demo.json' contents: '{ }'.
	chain := MooseNexusRepositoryChainBackend local: localBackend remotes: { remote }.
	chain beLocalOnly.

	self deny: (chain artifactExistsAt: 'repository/com.example/demo/1.0.0/artifacts/models/demo.json').
	self should: [ chain artifactAt: 'repository/com.example/demo/1.0.0/artifacts/models/demo.json' ] raise: NotFound.
	self assert: remote fetchCount equals: 0
]

{ #category : 'tests' }
MooseNexusRepositoryChainBackendTest >> testChainReturnsLocalArtifactWithoutFetchingRemote [

	| remote sourceFile chain artifact |
	remote := MooseNexusTestRemoteRepositoryBackend new.
	remote artifactAt: 'repository/com.example/demo/1.0.0/artifacts/models/demo.json' contents: 'remote'.
	sourceFile := rootDirectory / 'source.json'.
	sourceFile writeStreamDo: [ :stream | stream nextPutAll: 'local' ].
	localBackend storeArtifactAt: 'repository/com.example/demo/1.0.0/artifacts/models/demo.json' from: sourceFile.
	chain := MooseNexusRepositoryChainBackend local: localBackend remotes: { remote }.

	artifact := chain artifactAt: 'repository/com.example/demo/1.0.0/artifacts/models/demo.json'.

	self assert: artifact contents equals: 'local'.
	self assert: remote fetchCount equals: 0
]

{ #category : 'tests' }
MooseNexusRepositoryChainBackendTest >> testChainTriesRemotesInOrder [

	| firstRemote secondRemote chain artifact |
	firstRemote := MooseNexusTestRemoteRepositoryBackend new.
	secondRemote := MooseNexusTestRemoteRepositoryBackend new.
	secondRemote artifactAt: 'repository/com.example/demo/1.0.0/artifacts/models/demo.json' contents: 'second'.
	chain := MooseNexusRepositoryChainBackend local: localBackend remotes: {
			         firstRemote.
			         secondRemote }.

	artifact := chain artifactAt: 'repository/com.example/demo/1.0.0/artifacts/models/demo.json'.

	self assert: artifact contents equals: 'second'.
	self assert: firstRemote fetchCount equals: 1.
	self assert: secondRemote fetchCount equals: 1
]

{ #category : 'tests' }
MooseNexusRepositoryChainBackendTest >> testRemoteBackendBuildsUrlsFromRepositoryRelativePaths [

	| remote |
	remote := MooseNexusRemoteRepositoryBackend baseUrl: 'https://repo.example.com/repository/moosenexus'.

	self
		assert: (remote urlForArtifactAt: 'repository/com.example/demo/1.0.0/artifacts/models/demo.json')
		equals: 'https://repo.example.com/repository/moosenexus/repository/com.example/demo/1.0.0/artifacts/models/demo.json'
]

{ #category : 'tests' }
MooseNexusRepositoryChainBackendTest >> testRemoteBackendDoesNotDuplicateTrailingSlash [

	| remote |
	remote := MooseNexusRemoteRepositoryBackend baseUrl: 'https://repo.example.com/repository/moosenexus/'.

	self
		assert: (remote urlForArtifactAt: 'repository/com.example/demo/1.0.0/artifacts/models/demo.json')
		equals: 'https://repo.example.com/repository/moosenexus/repository/com.example/demo/1.0.0/artifacts/models/demo.json'
]

{ #category : 'tests' }
MooseNexusRepositoryChainBackendTest >> testRemoteBackendFetchCachesDownloadedArtifactLocally [

	| remote artifact |
	remote := MooseNexusTestHttpRemoteRepositoryBackend new.
	remote artifactAt: 'repository/com.example/demo/1.0.0/artifacts/models/demo.json' contents: '{ }'.

	artifact := remote
		            fetchArtifactAt: 'repository/com.example/demo/1.0.0/artifacts/models/demo.json'
		            into: localBackend
		            ifAbsent: [ self fail ].

	self assert: artifact contents equals: '{ }'.
	self assert: remote downloadCount equals: 1.
	self assert: (localBackend artifactExistsAt: 'repository/com.example/demo/1.0.0/artifacts/models/demo.json')
]

{ #category : 'tests' }
MooseNexusRepositoryChainBackendTest >> testRemoteBackendFetchEvaluatesAbsentBlockWhenDownloadFails [

	| remote absentValue result |
	remote := MooseNexusTestHttpRemoteRepositoryBackend new.
	absentValue := Object new.

	result := remote
		          fetchArtifactAt: 'repository/com.example/demo/1.0.0/artifacts/models/missing.json'
		          into: localBackend
		          ifAbsent: [ absentValue ].

	self assert: result identicalTo: absentValue.
	self assert: remote downloadCount equals: 1.
	self deny: (localBackend artifactExistsAt: 'repository/com.example/demo/1.0.0/artifacts/models/missing.json')
]

{ #category : 'tests' }
MooseNexusRepositoryChainBackendTest >> testRepositoryFacadeCanUseAChainedBackend [

	| remote repository artifact |
	remote := MooseNexusTestRemoteRepositoryBackend new.
	remote artifactAt: 'repository/com.example/demo/1.0.0/artifacts/models/demo.json' contents: '{ }'.
	repository := MooseNexusRepository localDirectory: rootDirectory / 'local' remotes: { remote }.

	artifact := repository artifactAt: 'repository/com.example/demo/1.0.0/artifacts/models/demo.json'.

	self assert: artifact contents equals: '{ }'.
	self assert: (repository artifactExistsAt: 'repository/com.example/demo/1.0.0/artifacts/models/demo.json')
]

{ #category : 'tests' }
MooseNexusRepositoryChainBackendTest >> testRepositoryFacadeRecordsProjectsThroughChainLocalBackend [

	| repository sourceDirectory project spec recordedProject projectDirectory |
	sourceDirectory := rootDirectory / 'source'.
	sourceDirectory ensureCreateDirectory.
	sourceDirectory / 'README.txt' writeStreamDo: [ :stream | stream nextPutAll: 'test source project' ].
	repository := MooseNexusRepository localDirectory: rootDirectory / 'local' remotes: #(  ).
	project := MooseNexusTestProject new.
	spec := MooseNexusProjectSpec
		        coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0')
		        sourceDirectory: sourceDirectory.

	recordedProject := repository recordLoadedProject: project describedBy: spec.
	projectDirectory := rootDirectory / 'local' / 'repository' / 'com.example' / 'demo' / '1.0.0'.

	self assert: recordedProject identicalTo: project.
	self assert: projectDirectory exists.
	self assert: repository projects size equals: 1.
	self assert: repository directory equals: rootDirectory / 'local'
]
