"
I import Famix TypeScript JSON model artifacts through the metamodel's native JSON import protocol.
"
Class {
	#name : 'MooseNexusTypeScriptModelImporter',
	#superclass : 'MooseNexusModelImporter',
	#category : 'MooseNexus-TypeScript-ModelExtraction',
	#package : 'MooseNexus-TypeScript',
	#tag : 'ModelExtraction'
}

{ #category : 'capabilities' }
MooseNexusTypeScriptModelImporter class >> metamodel [

	^ 'Famix-TypeScript'
]

{ #category : 'importing' }
MooseNexusTypeScriptModelImporter >> importArtifact: aMooseNexusModelArtifact fromProject: aMooseNexusProject [

	| model |
	model := FamixTypeScriptModel named: aMooseNexusModelArtifact name.
	aMooseNexusProject repositoryDirectory / aMooseNexusModelArtifact path readStreamDo: [ :stream |
		model importFromJSONStream: stream ].
	model install.
	model rootFolder: (self sourceRootForProject: aMooseNexusProject).
	^ model
]

{ #category : 'capabilities' }
MooseNexusTypeScriptModelImporter >> modelImportRequirements [

	^ { (MooseNexusImageRequirement
		   name: 'Famix TypeScript JSON import'
		   availabilityValidation: [ Smalltalk globals includesKey: #FamixTypeScriptModel ]
		   versionValidation: [ '' ]
		   expectedVersionDescription: 'loaded Famix TypeScript JSON import support') }
]

{ #category : 'importing' }
MooseNexusTypeScriptModelImporter >> sourceRootForProject: aMooseNexusProject [

	^ aMooseNexusProject mainSourceDirectory
]
