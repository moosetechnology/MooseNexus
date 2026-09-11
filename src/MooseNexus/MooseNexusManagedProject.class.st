"
I represent a source project whose dependency metadata is managed by an external build tool.

I provide managed-project semantics and shared language handling. Subclasses that represent a build composed of modules or subprojects use MooseNexusMultiModuleManagedProject to preserve those individual dependency graphs.
"
Class {
	#name : 'MooseNexusManagedProject',
	#superclass : 'MooseNexusProject',
	#instVars : [
		'language'
	],
	#category : 'MooseNexus-Project',
	#package : 'MooseNexus',
	#tag : 'Project'
}

{ #category : 'testing' }
MooseNexusManagedProject class >> isAbstract [

	^ self == MooseNexusManagedProject
]

{ #category : 'querying' }
MooseNexusManagedProject >> determineLanguage [

	^ (MooseNexusLanguageDetector detectIn: self mainSourceDirectory) language
]

{ #category : 'testing' }
MooseNexusManagedProject >> isGradleProject [

	^ false
]

{ #category : 'testing' }
MooseNexusManagedProject >> isManagedProject [

	^ true
]

{ #category : 'testing' }
MooseNexusManagedProject >> isMavenProject [

	^ false
]

{ #category : 'accessing' }
MooseNexusManagedProject >> language [
	"Build automation tools are language-agnostic, so it has to be determined."

	^ language ifNil: [ language := self determineLanguage ]
]

{ #category : 'accessing' }
MooseNexusManagedProject >> language: aString [

	language := aString
]

{ #category : 'properties' }
MooseNexusManagedProject >> readProperties: properties [

	super readProperties: properties.
	properties at: #language ifPresent: [ :lang | self language: lang ]
]
