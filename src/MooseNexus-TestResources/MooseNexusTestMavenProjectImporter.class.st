"
I am a Maven importer test double that supplies reactor project paths without invoking Maven.
"
Class {
	#name : 'MooseNexusTestMavenProjectImporter',
	#superclass : 'MooseNexusMavenProjectImporter',
	#instVars : [
		'paths'
	],
	#category : 'MooseNexus-TestResources-ModelExtraction',
	#package : 'MooseNexus-TestResources',
	#tag : 'ModelExtraction'
}

{ #category : 'initialization' }
MooseNexusTestMavenProjectImporter >> initialize [

	super initialize.
	paths := Dictionary new
]

{ #category : 'private' }
MooseNexusTestMavenProjectImporter >> pathForProjectGroup: group name: name [

	^ paths at: {
			  group.
			  name }
]

{ #category : 'accessing' }
MooseNexusTestMavenProjectImporter >> paths: aDictionary [

	paths := aDictionary
]
