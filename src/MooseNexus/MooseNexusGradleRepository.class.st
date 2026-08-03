"
I am responsible for finding dependencies in a local Gradle repository.
"
Class {
	#name : 'MooseNexusGradleRepository',
	#superclass : 'MooseNexusDependencyRepository',
	#classInstVars : [
		'default'
	],
	#category : 'MooseNexus-Repository',
	#package : 'MooseNexus',
	#tag : 'Repository'
}

{ #category : 'accessing' }
MooseNexusGradleRepository class >> default [

	^ default ifNil: [ default := self new directory: '.gradle/caches/modules-2/files-2.1' ]
]

{ #category : 'resolving' }
MooseNexusGradleRepository >> findGroup: group name: name version: version type: type [
	"Search for an artifact (a file) based on its descriptor."

	| artifactDirectory fileName |
	(artifactDirectory := FileLocator home / directory / group / name / version) ifAbsent: [ ^ nil ].
	fileName := name , '-' , version , '.' , type.

	"Gradle can have multiple directories named with a UUID at this level,
	any will do (make an issue if not!) as long as it contains the artifact."
	artifactDirectory directories do: [ :dir | dir / fileName ifExists: [ :artifact | ^ artifact ] ].
	^ nil
]

{ #category : 'resolving' }
MooseNexusGradleRepository >> resolve: descriptor [

	| parts group name type version scope path artifact coordinates |
	parts := $: split: descriptor.
	group := parts at: 1.
	name := parts at: 2.
	type := parts at: 3.
	version := parts at: 4.
	scope := parts at: 5.
	path := parts at: 6.
	coordinates := MooseNexusCoordinates group: group name: name version: version.

	artifact := path asFileReference ifAbsent: [
			            (self
				             findGroup: group
				             name: name
				             version: version
				             type: type) ifNil: [ ^ nil ] ].

	^ group -> (MooseNexusDependencyDescriptor
		   coordinates: coordinates
		   type: type
		   scopes: { scope }
		   path: (artifact relativeTo: FileLocator home) pathString)
]
