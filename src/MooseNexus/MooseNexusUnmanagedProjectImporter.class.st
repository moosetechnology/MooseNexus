"
I import an unmanaged source project from explicit MooseNexus configuration.

I do not inspect Maven, Gradle, or another external build tool. The build specification provides the source directory and coordinates, while clients configure me with the project language and dependency descriptors to record.
"
Class {
	#name : 'MooseNexusUnmanagedProjectImporter',
	#superclass : 'MooseNexusProjectImporter',
	#instVars : [
		'language',
		'dependencies'
	],
	#category : 'MooseNexus-Importer',
	#package : 'MooseNexus',
	#tag : 'Importer'
}

{ #category : 'capabilities' }
MooseNexusUnmanagedProjectImporter class >> buildToolName [

	^ 'unmanaged'
]

{ #category : 'accessing' }
MooseNexusUnmanagedProjectImporter >> dependencies [

	^ dependencies ifNil: [ dependencies := #(  ) ]
]

{ #category : 'accessing' }
MooseNexusUnmanagedProjectImporter >> dependencies: dependencyDescriptors [

	dependencies := dependencyDescriptors ifNil: [ #(  ) ] ifNotNil: [ dependencyDescriptors asArray ]
]

{ #category : 'importing' }
MooseNexusUnmanagedProjectImporter >> import [

	Error signal: 'Unmanaged project imports require explicit MooseNexus coordinates'
]

{ #category : 'importing' }
MooseNexusUnmanagedProjectImporter >> importWithCoordinates: aMooseNexusCoordinates [

	self validateConfiguration.
	aMooseNexusCoordinates ifNil: [ Error signal: 'Unmanaged project imports require explicit MooseNexus coordinates' ].
	project ifNil: [ project := self newProject ].
	project initializeCoordinates: aMooseNexusCoordinates.
	project
		language: language;
		dependencies: self dependencies.
	^ project
]

{ #category : 'accessing' }
MooseNexusUnmanagedProjectImporter >> language [

	^ language
]

{ #category : 'accessing' }
MooseNexusUnmanagedProjectImporter >> language: aString [

	language := aString
]

{ #category : 'instance creation' }
MooseNexusUnmanagedProjectImporter >> newProject [

	^ MooseNexusUnmanagedProject new
]

{ #category : 'validating' }
MooseNexusUnmanagedProjectImporter >> validateConfiguration [

	language ifNil: [ Error signal: 'Unmanaged project language must be configured explicitly' ]
]
