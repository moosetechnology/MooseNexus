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
		'dependencyGraph'
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
]

{ #category : 'instance creation' }
MooseNexusManagedProjectDescriptor class >> version: aVersion path: aPath dependencyGraph: aMooseNexusDependencyGraph [

	^ self new initializeVersion: aVersion path: aPath dependencyGraph: aMooseNexusDependencyGraph
]

{ #category : 'comparing' }
MooseNexusManagedProjectDescriptor >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ anObject version = version and: [ anObject path = path and: [ anObject dependencyGraph = dependencyGraph ] ]
]

{ #category : 'converting' }
MooseNexusManagedProjectDescriptor >> asDictionary [

	| dictionary |
	dictionary := Dictionary with: #version -> version with: #dependencyGraph -> dependencyGraph asDictionary.
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

	^ version hash bitXor: (path hash bitXor: dependencyGraph hash)
]

{ #category : 'initialization' }
MooseNexusManagedProjectDescriptor >> initializeVersion: aVersion path: aPath dependencyGraph: aMooseNexusDependencyGraph [

	version := aVersion.
	path := aPath.
	dependencyGraph := aMooseNexusDependencyGraph ifNil: [ MooseNexusDependencyGraph empty ]
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
