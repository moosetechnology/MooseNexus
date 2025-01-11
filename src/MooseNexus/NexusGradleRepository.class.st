"
I am responsible for finding dependencies in a local Gradle repository.
"
Class {
	#name : 'NexusGradleRepository',
	#superclass : 'NexusDependencyRepository',
	#classInstVars : [
		'default'
	],
	#category : 'MooseNexus-Repository',
	#package : 'MooseNexus',
	#tag : 'Repository'
}

{ #category : 'accessing' }
NexusGradleRepository class >> default [

	^ default ifNil: [
		  default := self new directory:
			             '.gradle/caches/modules-2/files-2.1' ]
]

{ #category : 'resolving' }
NexusGradleRepository >> findGroup: group name: name version: version type: type [
	"Search for an artifact (a file) based on its descriptor."

	| artifactDirectory fileName |
	(artifactDirectory := FileLocator home / directory / group / name
	                      / version) ifAbsent: [ ^ nil ].
	fileName := name , '-' , version , '.' , type.

	"Gradle can have multiple directories named with a UUID at this level,
	any will do (make an issue if not!) as long as it contains the artifact."
	artifactDirectory directories do: [ :dir |
		dir / fileName ifExists: [ :artifact | ^ artifact ] ].
	^ nil
]

{ #category : 'resolving' }
NexusGradleRepository >> resolve: descriptor [

	| parts group name type version scope path artifact |
	parts := $: split: descriptor.
	group := parts at: 1.
	name := parts at: 2.
	type := parts at: 3.
	version := parts at: 4.
	scope := parts at: 5.
	path := parts at: 6.

	artifact := path asFileReference ifAbsent: [
		            (self
			             findGroup: group
			             name: name
			             version: version
			             type: type) ifNil: [ ^ nil ] ].

	^ group -> (Dictionary
		   with: #name -> name
		   with: #version -> version
		   with: #type -> type
		   with: #scope -> scope
		   with: #path -> (artifact relativeTo: FileLocator home) pathString)
]
