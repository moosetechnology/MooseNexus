"
I describe one project managed by an external build tool, such as a Maven module or Gradle subproject.

I carry the managed project's declared version, source path relative to the imported root, and dependency descriptors grouped by dependency group. MooseNexus uses me internally as a value-like object. Repository serialization writes dictionaries at the boundary so properties files remain easy to inspect.
"
Class {
	#name : 'MooseNexusManagedProjectDescriptor',
	#superclass : 'Object',
	#instVars : [
		'version',
		'path',
		'dependencies'
	],
	#category : 'MooseNexus-Project',
	#package : 'MooseNexus',
	#tag : 'Project'
}

{ #category : 'properties' }
MooseNexusManagedProjectDescriptor class >> dependencyGroupsFromDictionary: dependencyGroups [

	^ dependencyGroups collect: [ :dependencyDictionaries |
		  dependencyDictionaries collect: [ :dependency | MooseNexusDependencyDescriptor fromDictionary: dependency ] ]
]

{ #category : 'instance creation' }
MooseNexusManagedProjectDescriptor class >> fromDictionary: aDictionary [

	^ self
		  version: (aDictionary at: #version ifAbsent: [ nil ])
		  path: (aDictionary at: #path ifAbsent: [ nil ])
		  dependencies: (self dependencyGroupsFromDictionary: (aDictionary at: #dependencies ifAbsent: [ Dictionary new ]))
]

{ #category : 'instance creation' }
MooseNexusManagedProjectDescriptor class >> version: aVersion path: aPath dependencies: dependencyGroups [

	^ self new
		  initializeVersion: aVersion path: aPath dependencies: dependencyGroups;
		  yourself
]

{ #category : 'comparing' }
MooseNexusManagedProjectDescriptor >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ anObject version = version and: [ anObject path = path and: [ anObject dependencies = dependencies ] ]
]

{ #category : 'converting' }
MooseNexusManagedProjectDescriptor >> asDictionary [

	| dictionary serializedDependencies |
	serializedDependencies := dependencies collect: [ :descriptors |
			                          descriptors
				                          collect: [ :descriptor |
						                          descriptor asDictionary
							                          removeKey: #group ifAbsent: [ nil ];
							                          yourself ]
				                          as: Array ].
	dictionary := Dictionary with: #version -> version with: #dependencies -> serializedDependencies.
	path ifNotNil: [ dictionary at: #path put: path ].
	^ dictionary
]

{ #category : 'accessing' }
MooseNexusManagedProjectDescriptor >> dependencies [

	^ dependencies
]

{ #category : 'comparing' }
MooseNexusManagedProjectDescriptor >> hash [

	^ version hash bitXor: (path hash bitXor: dependencies hash)
]

{ #category : 'initialization' }
MooseNexusManagedProjectDescriptor >> initializeVersion: aVersion path: aPath dependencies: dependencyGroups [

	version := aVersion.
	path := aPath.
	dependencies := dependencyGroups ifNil: [ Dictionary new ]
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
		nextPutAll: version asString;
		nextPut: $)
]

{ #category : 'accessing' }
MooseNexusManagedProjectDescriptor >> version [

	^ version
]
