"
I am responsible for importing a project that uses a build automation tool to manage dependencies.
Each of my subclasses knows how to interact with a specific tool to get them.
"
Class {
	#name : 'MooseNexusManagedProjectImporter',
	#superclass : 'MooseNexusProjectImporter',
	#instVars : [
		'localRepositories',
		'dependencyConflictResolver'
	],
	#category : 'MooseNexus-Importer',
	#package : 'MooseNexus',
	#tag : 'Importer'
}

{ #category : 'testing' }
MooseNexusManagedProjectImporter class >> isAbstract [

	^ self == MooseNexusManagedProjectImporter
]

{ #category : 'adding' }
MooseNexusManagedProjectImporter >> addLocalRepository: pathString [

	localRepositories add: pathString
]

{ #category : 'parsing' }
MooseNexusManagedProjectImporter >> analyze [
	"Attempts to read the group, name, version, and dependencies of all managed projects."

	self parse: self read
]

{ #category : 'accessing' }
MooseNexusManagedProjectImporter >> dependencyConflictResolver [

	^ dependencyConflictResolver
]

{ #category : 'accessing' }
MooseNexusManagedProjectImporter >> dependencyConflictResolver: aMooseNexusDependencyConflictResolver [

	dependencyConflictResolver := aMooseNexusDependencyConflictResolver
]

{ #category : 'querying' }
MooseNexusManagedProjectImporter >> flatDependencies [
	"Resolve all dependencies of this project into a flat list.
	A conflict can occur if two projects define the same dependency with different versions."

	| dependencies conflicts |
	dependencies := Dictionary new.
	conflicts := Dictionary new.

	project projectDependenciesDo: [ :dependencyGroup :descriptor |
			| key |
			key := dependencyGroup , ':' , (descriptor at: #name).
			conflicts at: key ifPresent: [ :conflictList | conflictList add: descriptor ] ifAbsent: [
					dependencies
						at: key
						ifPresent: [ :exisiting |
								(exisiting at: #version) = (descriptor at: #version) ifFalse: [ "new conflict"
									conflicts at: key put: (OrderedCollection with: (dependencies removeKey: key) with: descriptor) ] ]
						ifAbsentPut: [ descriptor copyWith: #group -> dependencyGroup ] ] ].

	conflicts ifNotEmpty: [ self resolveDependencyConflicts: conflicts on: dependencies ].

	^ dependencies asArray
]

{ #category : 'importing' }
MooseNexusManagedProjectImporter >> import [

	project ifNil: [ project := self newProject ].
	self analyze.
	project dependencies: self flatDependencies.
	^ project
]

{ #category : 'accessing' }
MooseNexusManagedProjectImporter >> localRepositories [
	"The directories containing the local repositories of build automation tools."

	^ localRepositories
]

{ #category : 'accessing' }
MooseNexusManagedProjectImporter >> localRepositories: pathStringCollection [
	"Define the local repositories of the build automation tools to use for this project.
	All paths must be relative to the home directory (result of `FileLocator home pathString`)."

	localRepositories := pathStringCollection
]

{ #category : 'parsing' }
MooseNexusManagedProjectImporter >> parse: commandOutputString [
	"Parse the result of the 'read' method, which contains the project data obtained from the build automation tool."

	self subclassResponsibility
]

{ #category : 'reading' }
MooseNexusManagedProjectImporter >> read [
	"Read project data from the build automation tool."

	self subclassResponsibility
]

{ #category : 'resolving' }
MooseNexusManagedProjectImporter >> resolve: descriptor [
	"Attempts to find the local path to an artifact based on the descriptor."

	localRepositories do: [ :repository | (repository resolve: descriptor) ifNotNil: [ :mapping | ^ mapping ] ].
	Error signal: 'Could not find dependency: ' , descriptor
]

{ #category : 'querying' }
MooseNexusManagedProjectImporter >> resolveDependencyConflicts: conflicts on: dependencies [

	dependencyConflictResolver ifNotNil: [ dependencyConflictResolver resolveConflicts: conflicts on: dependencies ] ifNil: [
			self shouldBeImplemented.
			"TODO link presenter choices with actual result"
			(MooseNexusDependencySelectionPresenter on: conflicts) open ]
]
