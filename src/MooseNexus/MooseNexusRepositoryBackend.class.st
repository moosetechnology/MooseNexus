"
I am the common parent for MooseNexus repository backend objects.

Repository backends can play different roles. A local backend can record projects and store artifact payloads. A remote backend can fetch repository-relative artifact paths. A chain backend coordinates local-first lookup across those roles without forcing every backend to implement the same filesystem-oriented protocol.
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
