"
I represent a MooseNexus project whose metadata is supplied explicitly instead of being discovered from an external build tool.

Use me for source projects that do not have Maven, Gradle, or another managed-project importer. My coordinates come from the build specification, my language is configured explicitly, and my resolved dependencies are inherited from MooseNexusProject.
"
Class {
	#name : 'MooseNexusUnmanagedProject',
	#superclass : 'MooseNexusProject',
	#instVars : [
		'language'
	],
	#category : 'MooseNexus-Project',
	#package : 'MooseNexus',
	#tag : 'Project'
}

{ #category : 'accessing' }
MooseNexusUnmanagedProject >> language [

	^ language
]

{ #category : 'accessing' }
MooseNexusUnmanagedProject >> language: aString [

	language := aString
]

{ #category : 'properties' }
MooseNexusUnmanagedProject >> readProperties: properties [

	super readProperties: properties.
	self language: (properties at: #language)
]
