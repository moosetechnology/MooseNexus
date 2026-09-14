"
I am responsible for finding dependencies in a local Maven repository.
"
Class {
	#name : 'MooseNexusMavenRepository',
	#superclass : 'MooseNexusDependencyRepository',
	#classInstVars : [
		'default'
	],
	#category : 'MooseNexus-Java-Dependency',
	#package : 'MooseNexus-Java',
	#tag : 'Dependency'
}

{ #category : 'accessing' }
MooseNexusMavenRepository class >> default [

	default ifNil: [ default := self new ].
	default directory: FileLocator home / '.m2' / 'repository'.
	^ default
]

{ #category : 'parsing' }
MooseNexusMavenRepository >> coordinatesOf: descriptor [

	| parts |
	parts := $: split: descriptor.
	^ MooseNexusCoordinates group: parts first name: parts second version: (parts at: 4)
]

{ #category : 'resolving' }
MooseNexusMavenRepository >> resolve: descriptor [
	"Attempts to find the local path to an artifact based on the descriptor."

	| parts group name type version scope theDirectory pathString coordinates |
	parts := $: split: descriptor.
	group := parts at: 1.
	name := parts at: 2.
	type := parts at: 3.
	version := parts at: 4.
	scope := parts at: 5.
	coordinates := MooseNexusCoordinates group: group name: name version: version.

	pathString := String streamContents: [ :s | s << (group copyReplaceAll: '.' with: '/') << '/' << name << '/' << version ].
	(theDirectory := directory asFileReference / pathString) ifAbsent: [ ^ nil ].

	^ theDirectory / (name , '-' , version , '.' , type)
		  ifExists: [ :file |
				  group -> (MooseNexusLocalDependencyDescriptor
					   coordinates: coordinates
					   type: type
					   scopes: { scope }
					   path: file pathString) ]
		  ifAbsent: [ nil ]
]

{ #category : 'parsing' }
MooseNexusMavenRepository >> scopeOf: descriptor [

	^ ($: split: descriptor) at: 5
]
