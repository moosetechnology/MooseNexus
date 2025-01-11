"
I am responsible for importing a project that uses a build automation tool to manage dependencies.
Each of my subclasses knows how to interact with a specific tool to get them.
"
Class {
	#name : 'NexusManagedProjectImporter',
	#superclass : 'NexusProjectImporter',
	#instVars : [
		'localRepositories',
		'dependencyConflictResolver'
	],
	#category : 'MooseNexus-Importer',
	#package : 'MooseNexus',
	#tag : 'Importer'
}

{ #category : 'testing' }
NexusManagedProjectImporter class >> isAbstract [

	^ self == NexusManagedProjectImporter
]

{ #category : 'adding' }
NexusManagedProjectImporter >> addLocalRepository: pathString [

	localRepositories add: pathString
]

{ #category : 'parsing' }
NexusManagedProjectImporter >> analyze [
	"Attempts to read the group, name, version, and dependencies of all managed projects."

	self parse: self read
]

{ #category : 'accessing' }
NexusManagedProjectImporter >> dependencyConflictResolver [

	^ dependencyConflictResolver
]

{ #category : 'accessing' }
NexusManagedProjectImporter >> dependencyConflictResolver: aNexusDependencyConflictResolver [

	dependencyConflictResolver := aNexusDependencyConflictResolver
]

{ #category : 'querying' }
NexusManagedProjectImporter >> flatDependencies [
	"Resolve all dependencies of this project into a flat list.
	A conflict can occur if two projects define the same dependency with different versions."

	| dependencies conflicts |
	dependencies := Dictionary new.
	conflicts := Dictionary new.

	project projectDependenciesDo: [ :dependencyGroup :descriptor |
		| key |
		key := dependencyGroup , ':' , (descriptor at: #name).
		conflicts
			at: key
			ifPresent: [ :conflictList | conflictList add: descriptor ]
			ifAbsent: [
				dependencies
					at: key
					ifPresent: [ :exisiting |
						(exisiting at: #version) = (descriptor at: #version) ifFalse: [ "new conflict"
							conflicts at: key put: (OrderedCollection
									 with: (dependencies removeKey: key)
									 with: descriptor) ] ]
					ifAbsentPut: [ descriptor copyWith: #group -> dependencyGroup ] ] ].

	conflicts ifNotEmpty: [
		self resolveDependencyConflicts: conflicts on: dependencies ].

	^ dependencies asArray
]

{ #category : 'importing' }
NexusManagedProjectImporter >> import [

	project ifNil: [ project := self newProject ].
	self analyze.
	project dependencies: self flatDependencies.
	^ project
]

{ #category : 'accessing' }
NexusManagedProjectImporter >> localRepositories [
	"The directories containing the local repositories of project managers."

	^ localRepositories
]

{ #category : 'accessing' }
NexusManagedProjectImporter >> localRepositories: pathStringCollection [
	"Define the local repositories of the project managers to use for this project.
	All paths must be relative to the home directory (result of `FileLocator home pathString`)."

	localRepositories := pathStringCollection
]

{ #category : 'versions' }
NexusManagedProjectImporter >> mediateExisting: existing incoming: incoming [
	"Decide which version of the dependency to include in the model.
	The terms 'existing' and 'incoming' are arbitrary, as the order is irrelevant.
	The existing dependency has already been processed, and the incoming dependency is the one being processed.
	If they are the same, the existing dependency should be returned to avoid unnecessary computations.
	If they are different, we have to decide which one to use, which is complicated."

	| existingVersion incomingVersion |
	(existingVersion := existing at: #version)
	= (incomingVersion := incoming at: #version) ifTrue: [ ^ existing ].

	"This is a difficult problem: a managed project can have multiple projects, each declaring their own dependencies (and versions).
	The user wants to create a model of the managed project, thus of all the projects it contains.
	However, if two projects declare the same dependency but with different versions, which one should be included in the model?"
	Warning signal: (String streamContents: [ :s |
			 s << 'The dependency ' << (existing at: #group) << ':'
			 << (existing at: #name)
			 << ' is declared with different versions: ' << existingVersion
			 << ' and ' << incomingVersion << ', proceed to use the first one' ]).
	^ existing
]

{ #category : 'parsing' }
NexusManagedProjectImporter >> parse: commandOutputString [
	"Parse the result of the 'read' method, which contains the project data obtained from the project manager."

	self subclassResponsibility
]

{ #category : 'reading' }
NexusManagedProjectImporter >> read [
	"Read project data from the project manager."

	self subclassResponsibility
]

{ #category : 'resolving' }
NexusManagedProjectImporter >> resolve: descriptor [
	"Attempts to find the local path to an artifact based on the descriptor."

	localRepositories do: [ :repository |
		(repository resolve: descriptor) ifNotNil: [ :mapping | ^ mapping ] ].
	Error signal: 'Could not find dependency: ' , descriptor
]

{ #category : 'querying' }
NexusManagedProjectImporter >> resolveDependencyConflicts: conflicts on: dependencies [

	dependencyConflictResolver
		ifNotNil: [
			dependencyConflictResolver
				resolveConflicts: conflicts
				on: dependencies ]
		ifNil: [
			self shouldBeImplemented.
			"TODO link presenter choices with actual result"
			(NexusDependencySelectionPresenter on: conflicts) open ]
]
