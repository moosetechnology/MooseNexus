"
I describe the MooseNexus, Moose, and Pharo runtime that produced a model artifact.

I am persisted in a model artifact manifest so a client can provision a known compatible runtime before installing the artifact. I derive every version from the running image, keeping recorded provenance aligned with the runtime that actually built the model.
"
Class {
	#name : 'MooseNexusBuildProvenance',
	#superclass : 'Object',
	#instVars : [
		'mooseNexusVersion',
		'mooseVersion',
		'pharoVersion'
	],
	#category : 'MooseNexus-Artifact',
	#package : 'MooseNexus',
	#tag : 'Artifact'
}

{ #category : 'instance creation' }
MooseNexusBuildProvenance class >> current [

	^ self
		  mooseNexusVersion: MooseNexusVersion current
		  mooseVersion: MooseVersion current versionNumber
		  pharoVersion: SystemVersion current major asString
]

{ #category : 'instance creation' }
MooseNexusBuildProvenance class >> fromDictionary: aDictionary [

	^ self
		  mooseNexusVersion: (aDictionary at: 'mooseNexusVersion')
		  mooseVersion: (aDictionary at: 'mooseVersion')
		  pharoVersion: (aDictionary at: 'pharoVersion')
]

{ #category : 'instance creation' }
MooseNexusBuildProvenance class >> mooseNexusVersion: aMooseNexusVersion mooseVersion: aMooseVersion pharoVersion: aPharoVersion [

	^ self new initializeMooseNexusVersion: aMooseNexusVersion mooseVersion: aMooseVersion pharoVersion: aPharoVersion
]

{ #category : 'comparing' }
MooseNexusBuildProvenance >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].

	^ anObject mooseNexusVersion = mooseNexusVersion and: [
		  anObject mooseVersion = mooseVersion and: [ anObject pharoVersion = pharoVersion ] ]
]

{ #category : 'converting' }
MooseNexusBuildProvenance >> asDictionary [

	^ Dictionary new
		  add: 'mooseNexusVersion' -> mooseNexusVersion;
		  add: 'mooseVersion' -> mooseVersion;
		  add: 'pharoVersion' -> pharoVersion;
		  yourself
]

{ #category : 'comparing' }
MooseNexusBuildProvenance >> hash [

	^ mooseNexusVersion hash bitXor: (mooseVersion hash bitXor: pharoVersion hash)
]

{ #category : 'initialization' }
MooseNexusBuildProvenance >> initializeMooseNexusVersion: aMooseNexusVersion mooseVersion: aMooseVersion pharoVersion: aPharoVersion [

	mooseNexusVersion := aMooseNexusVersion.
	mooseVersion := aMooseVersion.
	pharoVersion := aPharoVersion
]

{ #category : 'accessing' }
MooseNexusBuildProvenance >> mooseNexusVersion [

	^ mooseNexusVersion
]

{ #category : 'accessing' }
MooseNexusBuildProvenance >> mooseVersion [

	^ mooseVersion
]

{ #category : 'accessing' }
MooseNexusBuildProvenance >> pharoVersion [

	^ pharoVersion
]
