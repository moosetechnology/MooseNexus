"
I describe one locked npm package as a portable dependency reference.

I retain its native npm package name in my coordinates, plus its resolved tarball URL and integrity. I am metadata only in the first TypeScript delivery and cannot be materialized into a Java-style classpath.
"
Class {
	#name : 'MooseNexusNpmDependencyDescriptor',
	#superclass : 'MooseNexusDependencyDescriptor',
	#instVars : [
		'resolvedUrl',
		'integrity'
	],
	#category : 'MooseNexus-TypeScript-Dependency',
	#package : 'MooseNexus-TypeScript',
	#tag : 'Dependency'
}

{ #category : 'testing' }
MooseNexusNpmDependencyDescriptor class >> canReadDictionary: aDictionary [

	^ (aDictionary at: 'ecosystem' ifAbsent: [ nil ]) = 'npm'
]

{ #category : 'instance creation' }
MooseNexusNpmDependencyDescriptor class >> fromDictionary: aDictionary [

	^ self
		  packageName: (aDictionary at: 'name')
		  version: (aDictionary at: 'version')
		  scopes: (aDictionary at: 'scopes')
		  resolvedUrl: (aDictionary at: 'resolvedUrl' ifAbsent: [ nil ])
		  integrity: (aDictionary at: 'integrity' ifAbsent: [ nil ])
]

{ #category : 'instance creation' }
MooseNexusNpmDependencyDescriptor class >> packageName: aPackageName version: aVersion scopes: aCollection resolvedUrl: aResolvedUrl integrity: anIntegrity [

	^ self new
		  initializeCoordinates: (MooseNexusCoordinates group: 'npm' name: aPackageName version: aVersion)
		  type: 'npm'
		  scopes: aCollection
		  resolvedUrl: aResolvedUrl
		  integrity: anIntegrity
]

{ #category : 'comparing' }
MooseNexusNpmDependencyDescriptor >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ super = anObject and: [ resolvedUrl = anObject resolvedUrl and: [ integrity = anObject integrity ] ]
]

{ #category : 'comparing' }
MooseNexusNpmDependencyDescriptor >> artifactIdentity [

	^ super artifactIdentity , {
		  resolvedUrl.
		  integrity }
]

{ #category : 'converting' }
MooseNexusNpmDependencyDescriptor >> asDictionary [

	^ super asDictionary
		  add: 'ecosystem' -> 'npm';
		  add: 'resolvedUrl' -> resolvedUrl;
		  add: 'integrity' -> integrity;
		  yourself
]

{ #category : 'comparing' }
MooseNexusNpmDependencyDescriptor >> hash [

	^ super hash bitXor: (resolvedUrl hash bitXor: integrity hash)
]

{ #category : 'initialization' }
MooseNexusNpmDependencyDescriptor >> initializeCoordinates: aMooseNexusCoordinates type: aType scopes: aCollection resolvedUrl: aResolvedUrl integrity: anIntegrity [

	super initializeCoordinates: aMooseNexusCoordinates type: aType scopes: aCollection.
	resolvedUrl := aResolvedUrl.
	integrity := anIntegrity
]

{ #category : 'accessing' }
MooseNexusNpmDependencyDescriptor >> integrity [

	^ integrity
]

{ #category : 'accessing' }
MooseNexusNpmDependencyDescriptor >> resolvedUrl [

	^ resolvedUrl
]

{ #category : 'capabilities' }
MooseNexusNpmDependencyDescriptor >> supportsClasspathMaterialization [

	^ false
]
