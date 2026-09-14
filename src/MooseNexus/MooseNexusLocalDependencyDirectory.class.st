"
I describe a local directory whose contents are added to an extractor classpath.

I preserve the directory tree while staging it temporarily for model extraction. Unlike a local dependency descriptor, I do not represent a single artifact and therefore do not require coordinates.
"
Class {
	#name : 'MooseNexusLocalDependencyDirectory',
	#superclass : 'Object',
	#instVars : [
		'path'
	],
	#category : 'MooseNexus-Dependency',
	#package : 'MooseNexus',
	#tag : 'Dependency'
}

{ #category : 'testing' }
MooseNexusLocalDependencyDirectory class >> canReadDictionary: aDictionary [

	^ (aDictionary at: #kind ifAbsent: [ nil ]) = 'local-directory'
]

{ #category : 'instance creation' }
MooseNexusLocalDependencyDirectory class >> fromDictionary: aDictionary [

	^ self path: (aDictionary at: #path)
]

{ #category : 'instance creation' }
MooseNexusLocalDependencyDirectory class >> path: aPath [

	^ self new initializePath: aPath
]

{ #category : 'comparing' }
MooseNexusLocalDependencyDirectory >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ path = anObject path
]

{ #category : 'converting' }
MooseNexusLocalDependencyDirectory >> asDictionary [

	^ Dictionary with: #kind -> 'local-directory' with: #path -> path
]

{ #category : 'comparing' }
MooseNexusLocalDependencyDirectory >> hash [

	^ path hash
]

{ #category : 'initialization' }
MooseNexusLocalDependencyDirectory >> initializePath: aPath [

	path := aPath
]

{ #category : 'testing' }
MooseNexusLocalDependencyDirectory >> isLocal [

	^ true
]

{ #category : 'building' }
MooseNexusLocalDependencyDirectory >> materializationDirectoryName [

	^ 'directory-' , (SHA256 hashMessage: path) hex
]

{ #category : 'building' }
MooseNexusLocalDependencyDirectory >> materializeInto: dependenciesDirectory using: project [

	^ project materializeLocalDependencyDirectory: self into: dependenciesDirectory
]

{ #category : 'accessing' }
MooseNexusLocalDependencyDirectory >> path [

	^ path
]

{ #category : 'accessing' }
MooseNexusLocalDependencyDirectory >> scopes [

	^ #( 'compile' )
]

{ #category : 'testing' }
MooseNexusLocalDependencyDirectory >> supportsClasspathMaterialization [

	^ true
]
