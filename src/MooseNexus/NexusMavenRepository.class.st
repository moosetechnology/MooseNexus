"
I am responsible for finding dependencies in a local Maven repository.
"
Class {
	#name : 'NexusMavenRepository',
	#superclass : 'NexusDependencyRepository',
	#classInstVars : [
		'default'
	],
	#category : 'MooseNexus-Repository',
	#package : 'MooseNexus',
	#tag : 'Repository'
}

{ #category : 'accessing' }
NexusMavenRepository class >> default [

	^ default ifNil: [ default := self new directory: '.m2/repository' ]
]

{ #category : 'resolving' }
NexusMavenRepository >> resolve: descriptor [
	"Attempts to find the local path to an artifact based on the descriptor."

	| parts group name type version scope homeDirectory theDirectory pathString |
	parts := $: split: descriptor.
	group := parts at: 1.
	name := parts at: 2.
	type := parts at: 3.
	version := parts at: 4.
	scope := parts at: 5.

	"search for the directory"
	pathString := String streamContents: [ :s |
		              s << (group copyReplaceAll: '.' with: '/') << '/'
		              << name << '/' << version ].
	homeDirectory := FileLocator home.
	(theDirectory := homeDirectory / directory / pathString) ifAbsent: [
		^ nil ].

	"search for the artifact"
	^ theDirectory / (name , '-' , version , '.' , type)
		  ifExists: [ :file |
			  group -> (Dictionary
				   with: #name -> name
				   with: #version -> version
				   with: #type -> type
				   with: #scope -> scope
				   with: #path -> (file relativeTo: homeDirectory) pathString) ]
		  ifAbsent: [ nil ]
]
