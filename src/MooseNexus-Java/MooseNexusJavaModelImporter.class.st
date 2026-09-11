"
I import Famix Java JSON model artifacts using the Java-specific filtered importer.
"
Class {
	#name : 'MooseNexusJavaModelImporter',
	#superclass : 'MooseNexusModelImporter',
	#category : 'MooseNexus-Java-ModelExtraction',
	#package : 'MooseNexus-Java',
	#tag : 'ModelExtraction'
}

{ #category : 'capabilities' }
MooseNexusJavaModelImporter class >> metamodel [

	^ 'Famix-Java'
]

{ #category : 'importing' }
MooseNexusJavaModelImporter >> importArtifact: aMooseNexusModelArtifact fromProject: aMooseNexusProject [

	| model |
	model := FamixJavaModel named: aMooseNexusModelArtifact name.
	FamixJSONFileImporter new
		model: model;
		inputFile: aMooseNexusProject repositoryDirectory / aMooseNexusModelArtifact path;
		runFilteredBy: FamixJavaImportingContext new importMaximum.
	model install.
	model rootFolder: (self sourceRootForProject: aMooseNexusProject).
	^ model
]

{ #category : 'capabilities' }
MooseNexusJavaModelImporter >> modelImportRequirements [

	^ { (MooseNexusImageRequirement
		   name: 'Famix Java JSON import'
		   availabilityValidation: [
				   (Smalltalk globals includesKey: #FamixJavaModel) and: [
					   (Smalltalk globals includesKey: #FamixJSONFileImporter) and: [ Smalltalk globals includesKey: #FamixJavaImportingContext ] ] ]
		   versionValidation: [ '' ]
		   expectedVersionDescription: 'loaded Famix Java JSON import support') }
]

{ #category : 'importing' }
MooseNexusJavaModelImporter >> sourceRootForProject: aMooseNexusProject [

	^ aMooseNexusProject sourceDirectory
]
