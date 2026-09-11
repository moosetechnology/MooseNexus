"
I represent a source project whose npm lockfile supplies its resolved dependency metadata.

I record the npm lockfile format and determine its source language through the shared language detectors after sources are recorded.
"
Class {
	#name : 'MooseNexusNpmProject',
	#superclass : 'MooseNexusProject',
	#instVars : [
		'language',
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
MooseNexusNpmProject >> language [

	^ language ifNil: [ language := (MooseNexusLanguageDetector detectIn: self mainSourceDirectory) language ]
]

{ #category : 'accessing' }
MooseNexusNpmProject >> language: aString [

	language := aString
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
	self language: (properties at: #language).
	self packageLockVersion: (properties at: #packageLockVersion)
]
