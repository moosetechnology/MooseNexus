"
I fetch repository-relative artifact paths from a remote HTTP repository.

The remote is intentionally path-based. A Nexus raw repository, an Artifactory generic repository, a static HTTP server, or a custom MooseNexus service can all serve the same paths without MooseNexus depending on vendor-specific repository management APIs.
"
Class {
	#name : 'MooseNexusRemoteRepositoryBackend',
	#superclass : 'MooseNexusRepositoryBackend',
	#instVars : [
		'baseUrl'
	],
	#category : 'MooseNexus-Repository',
	#package : 'MooseNexus',
	#tag : 'Repository'
}

{ #category : 'instance creation' }
MooseNexusRemoteRepositoryBackend class >> baseUrl: aString [

	^ self new
		  baseUrl: aString;
		  yourself
]

{ #category : 'artifacts' }
MooseNexusRemoteRepositoryBackend >> artifactAt: repositoryRelativePath [

	NotFound signal: 'Remote artifact `' , repositoryRelativePath , '` must be fetched into a local backend before use'
]

{ #category : 'artifacts' }
MooseNexusRemoteRepositoryBackend >> artifactExistsAt: repositoryRelativePath [

	| client |
	client := self newClient.
	[
		client
			url: (self urlForArtifactAt: repositoryRelativePath);
			head.
		^ client isSuccess ]
		on: Error
		do: [ :exception | ^ false ]
]

{ #category : 'accessing' }
MooseNexusRemoteRepositoryBackend >> baseUrl [

	^ baseUrl
]

{ #category : 'accessing' }
MooseNexusRemoteRepositoryBackend >> baseUrl: aString [

	baseUrl := aString
]

{ #category : 'accessing' }
MooseNexusRemoteRepositoryBackend >> baseUrlWithTrailingSlash [

	(baseUrl endsWith: '/') ifTrue: [ ^ baseUrl ].
	^ baseUrl , '/'
]

{ #category : 'artifacts' }
MooseNexusRemoteRepositoryBackend >> downloadArtifactAt: repositoryRelativePath to: targetFile [

	| client |
	client := self newClient.
	[
		^ client
			  url: (self urlForArtifactAt: repositoryRelativePath);
			  downloadTo: targetFile ]
		on: Error
		do: [ :exception | ^ false ]
]

{ #category : 'artifacts' }
MooseNexusRemoteRepositoryBackend >> fetchArtifactAt: repositoryRelativePath into: aMooseNexusLocalRepositoryBackend ifAbsent: absentBlock [

	| temporaryFile downloaded artifactFile |
	temporaryFile := FileLocator temp / ('moosenexus-' , UUID new asString).
	downloaded := false.
	[
		downloaded := self downloadArtifactAt: repositoryRelativePath to: temporaryFile.
		downloaded ifTrue: [
			artifactFile := aMooseNexusLocalRepositoryBackend storeArtifactAt: repositoryRelativePath from: temporaryFile ] ] ensure: [
		temporaryFile deleteIfAbsent: [ ] ].
	downloaded ifFalse: [ ^ absentBlock value ].
	^ artifactFile
]

{ #category : 'private' }
MooseNexusRemoteRepositoryBackend >> newClient [

	^ ZnClient new
		  beOneShot;
		  enforceHttpSuccess: false;
		  yourself
]

{ #category : 'artifacts' }
MooseNexusRemoteRepositoryBackend >> storeArtifactAt: repositoryRelativePath from: sourceFileReference [

	Error signal: 'Remote repository publishing is not implemented by the path-based read backend yet'
]

{ #category : 'artifacts' }
MooseNexusRemoteRepositoryBackend >> urlForArtifactAt: repositoryRelativePath [

	^ self baseUrlWithTrailingSlash , repositoryRelativePath
]
