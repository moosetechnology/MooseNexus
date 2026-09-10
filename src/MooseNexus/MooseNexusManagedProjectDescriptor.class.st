"
I describe one project managed by an external build tool, such as a Maven module or Gradle subproject.

I carry the managed project's declared version, source path relative to the imported root, and declared dependency graph. MooseNexus uses me internally as a value-like object. Repository serialization writes dictionaries at the boundary so properties files remain easy to inspect.
"
Class {
	#name : 'MooseNexusManagedProjectDescriptor',
	#superclass : 'Object',
	#instVars : [
		'version',
		'path',
		'dependencyGraph',
		'workspaceDependencies'
	],
	#category : 'MooseNexus-Project',
	#package : 'MooseNexus',
	#tag : 'Project'
}

{ #category : 'instance creation' }
MooseNexusManagedProjectDescriptor class >> fromDictionary: aDictionary [

	^ self
		  version: (aDictionary at: #version ifAbsent: [ nil ])
		  path: (aDictionary at: #path ifAbsent: [ nil ])
		  dependencyGraph: (MooseNexusDependencyGraph fromDictionary: (aDictionary at: #dependencyGraph))
		  workspaceDependencies: ((aDictionary at: #workspaceDependencies) collect: [ :dependency |
				   MooseNexusWorkspaceDependencyDescriptor fromDictionary: dependency ])
]

{ #category : 'instance creation' }
MooseNexusManagedProjectDescriptor class >> version: aVersion path: aPath dependencyGraph: aMooseNexusDependencyGraph [

	^ self
		  version: aVersion
		  path: aPath
		  dependencyGraph: aMooseNexusDependencyGraph
		  workspaceDependencies: #(  )
]

{ #category : 'instance creation' }
MooseNexusManagedProjectDescriptor class >> version: aVersion path: aPath dependencyGraph: aMooseNexusDependencyGraph workspaceDependencies: workspaceDependencyDescriptors [

	^ self new
		  initializeVersion: aVersion
		  path: aPath
		  dependencyGraph: aMooseNexusDependencyGraph
		  workspaceDependencies: workspaceDependencyDescriptors
]

{ #category : 'comparing' }
MooseNexusManagedProjectDescriptor >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ anObject version = version and: [
			  anObject path = path and: [
				  anObject dependencyGraph = dependencyGraph and: [ anObject workspaceDependencies = workspaceDependencies ] ] ]
]

{ #category : 'converting' }
MooseNexusManagedProjectDescriptor >> asDictionary [

	| dictionary |
	dictionary := Dictionary
		              with: #version -> version
		              with: #dependencyGraph -> dependencyGraph asDictionary
		              with: #workspaceDependencies -> (workspaceDependencies collect: #asDictionary as: Array).
	path ifNotNil: [ dictionary at: #path put: path ].
	^ dictionary
]

{ #category : 'accessing' }
MooseNexusManagedProjectDescriptor >> dependencies [

	^ dependencyGraph dependencies
]

{ #category : 'accessing' }
MooseNexusManagedProjectDescriptor >> dependencyGraph [

	^ dependencyGraph
]

{ #category : 'comparing' }
MooseNexusManagedProjectDescriptor >> hash [

	^ version hash bitXor: (path hash bitXor: (dependencyGraph hash bitXor: workspaceDependencies hash))
]

{ #category : 'initialization' }
MooseNexusManagedProjectDescriptor >> initializeVersion: aVersion path: aPath dependencyGraph: aMooseNexusDependencyGraph [

	version := aVersion.
	path := aPath.
	dependencyGraph := aMooseNexusDependencyGraph ifNil: [ MooseNexusDependencyGraph empty ]
]

{ #category : 'initialization' }
MooseNexusManagedProjectDescriptor >> initializeVersion: aVersion path: aPath dependencyGraph: aMooseNexusDependencyGraph workspaceDependencies: workspaceDependencyDescriptors [

	version := aVersion.
	path := aPath.
	dependencyGraph := aMooseNexusDependencyGraph ifNil: [ MooseNexusDependencyGraph empty ].
	workspaceDependencies := workspaceDependencyDescriptors ifNil: [ #(  ) ] ifNotNil: [ workspaceDependencyDescriptors asArray ]
]

{ #category : 'accessing' }
MooseNexusManagedProjectDescriptor >> path [

	^ path
]

{ #category : 'printing' }
MooseNexusManagedProjectDescriptor >> printOn: aStream [

	aStream
		nextPutAll: self class name;
		nextPut: $(;
		print: version;
		nextPut: $)
]

{ #category : 'accessing' }
MooseNexusManagedProjectDescriptor >> version [

	^ version
]

{ #category : 'accessing' }
MooseNexusManagedProjectDescriptor >> workspaceDependencies [

	^ workspaceDependencies
]
