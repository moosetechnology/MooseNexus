"
I describe a dependency artifact available at an explicit path relative to the user's home directory.

I retain the local-artifact niche used by unmanaged imports. Remote managed-build references are represented by my pathless superclass and materialized by their owning build-tool project.
"
Class {
	#name : 'MooseNexusLocalDependencyDescriptor',
	#superclass : 'MooseNexusDependencyDescriptor',
	#instVars : [
		'path'
	],
	#category : 'MooseNexus-Dependency',
	#package : 'MooseNexus',
	#tag : 'Dependency'
}

{ #category : 'instance creation' }
MooseNexusLocalDependencyDescriptor class >> coordinates: aMooseNexusCoordinates type: aType scopes: aCollection path: aPath [

	^ self new
		  initializeCoordinates: aMooseNexusCoordinates
		  type: aType
		  scopes: aCollection
		  path: aPath
]

{ #category : 'comparing' }
MooseNexusLocalDependencyDescriptor >> = anObject [

	^ super = anObject and: [ anObject path = path ]
]

{ #category : 'comparing' }
MooseNexusLocalDependencyDescriptor >> artifactIdentity [

	^ super artifactIdentity , { path }
]

{ #category : 'converting' }
MooseNexusLocalDependencyDescriptor >> asDictionary [

	^ super asDictionary
		  at: #path put: path;
		  yourself
]

{ #category : 'comparing' }
MooseNexusLocalDependencyDescriptor >> hash [

	^ super hash bitXor: path hash
]

{ #category : 'initialization' }
MooseNexusLocalDependencyDescriptor >> initializeCoordinates: aMooseNexusCoordinates type: aType scopes: aCollection path: aPath [

	self initializeCoordinates: aMooseNexusCoordinates type: aType scopes: aCollection.
	path := aPath
]

{ #category : 'testing' }
MooseNexusLocalDependencyDescriptor >> isLocal [

	^ true
]

{ #category : 'building' }
MooseNexusLocalDependencyDescriptor >> materializeInto: dependenciesDirectory using: project [

	^ project materializeLocalDependency: self into: dependenciesDirectory
]

{ #category : 'accessing' }
MooseNexusLocalDependencyDescriptor >> path [

	^ path
]

{ #category : 'copying' }
MooseNexusLocalDependencyDescriptor >> withGroup: aGroup [

	^ self class
		  coordinates: (MooseNexusCoordinates group: aGroup name: self name version: self version)
		  type: self type
		  scopes: self scopes
		  path: path
]

{ #category : 'copying' }
MooseNexusLocalDependencyDescriptor >> withScopes: aCollection [

	^ self class
		  coordinates: self coordinates
		  type: self type
		  scopes: aCollection
		  path: path
]
