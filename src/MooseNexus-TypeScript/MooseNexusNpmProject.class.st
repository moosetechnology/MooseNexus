"
I represent a managed source project whose npm lockfile supplies its resolved dependency metadata.

I record the npm lockfile format and determine its source language through the shared managed-project language handling after sources are recorded.
"
Class {
	#name : 'MooseNexusNpmProject',
	#superclass : 'MooseNexusManagedProject',
	#instVars : [
		'packageLockVersion'
	],
	#category : 'MooseNexus-TypeScript-Project',
	#package : 'MooseNexus-TypeScript',
	#tag : 'Project'
}

{ #category : 'testing' }
MooseNexusNpmProject >> isNpmProject [

	^ true
]

{ #category : 'accessing' }
MooseNexusNpmProject >> packageLockVersion [

	^ packageLockVersion
]

{ #category : 'accessing' }
MooseNexusNpmProject >> packageLockVersion: anInteger [

	packageLockVersion := anInteger
]

{ #category : 'enumerating' }
MooseNexusNpmProject >> properties [

	^ super properties
		  add: #packageLockVersion -> packageLockVersion;
		  yourself
]

{ #category : 'properties' }
MooseNexusNpmProject >> readProperties: properties [

	super readProperties: properties.
	self packageLockVersion: (properties at: #packageLockVersion)
]
