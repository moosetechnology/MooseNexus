"
I define the storage protocol used by MooseNexusRepository.

Concrete backends decide how projects and model artifacts are persisted and queried. The local filesystem backend is the first implementation; a remote artifact repository can implement the same protocol later without changing build plans.
"
Class {
	#name : 'MooseNexusRepositoryBackend',
	#superclass : 'Object',
	#category : 'MooseNexus-Repository',
	#package : 'MooseNexus',
	#tag : 'Repository'
}

{ #category : 'testing' }
MooseNexusRepositoryBackend class >> isAbstract [

	^ self == MooseNexusRepositoryBackend
]

{ #category : 'artifacts' }
MooseNexusRepositoryBackend >> artifactAt: repositoryRelativePath [

	self subclassResponsibility
]

{ #category : 'artifacts' }
MooseNexusRepositoryBackend >> artifactExistsAt: repositoryRelativePath [

	self subclassResponsibility
]

{ #category : 'accessing' }
MooseNexusRepositoryBackend >> directory [

	self subclassResponsibility
]

{ #category : 'accessing' }
MooseNexusRepositoryBackend >> directory: aFileReference [

	self subclassResponsibility
]

{ #category : 'artifacts' }
MooseNexusRepositoryBackend >> fetchArtifactAt: repositoryRelativePath into: aMooseNexusLocalRepositoryBackend ifAbsent: absentBlock [

	self subclassResponsibility
]

{ #category : 'enumerating' }
MooseNexusRepositoryBackend >> group: group project: project version: version [

	self subclassResponsibility
]

{ #category : 'adding' }
MooseNexusRepositoryBackend >> prepareDirectoryFor: aMooseNexusProjectSpec [

	self subclassResponsibility
]

{ #category : 'printing' }
MooseNexusRepositoryBackend >> printProjectProperties: propertiesFile on: writeStream [

	self subclassResponsibility
]

{ #category : 'printing' }
MooseNexusRepositoryBackend >> printProjects [

	self subclassResponsibility
]

{ #category : 'enumerating' }
MooseNexusRepositoryBackend >> projectProperties [

	self subclassResponsibility
]

{ #category : 'enumerating' }
MooseNexusRepositoryBackend >> projects [

	self subclassResponsibility
]

{ #category : 'recording' }
MooseNexusRepositoryBackend >> recordLoadedProject: aMooseNexusProject describedBy: aMooseNexusProjectSpec [

	self subclassResponsibility
]

{ #category : 'enumerating' }
MooseNexusRepositoryBackend >> resolveDirectoryFor: aMooseNexusProjectSpec [

	self subclassResponsibility
]

{ #category : 'artifacts' }
MooseNexusRepositoryBackend >> storeArtifactAt: repositoryRelativePath from: sourceFileReference [

	self subclassResponsibility
]
