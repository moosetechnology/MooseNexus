"
I describe the result of building one model artifact.

I capture the recorded project, the produced model artifact, and the dependency-resolution result that was used for the build. The artifact manifest persisted in models.json is owned by the project/model-builder recording path.
"
Class {
	#name : 'MooseNexusModelBuildResult',
	#superclass : 'Object',
	#instVars : [
		'project',
		'modelArtifact',
		'dependencyResolutionResult'
	],
	#category : 'MooseNexus-ModelExtraction',
	#package : 'MooseNexus',
	#tag : 'ModelExtraction'
}

{ #category : 'instance creation' }
MooseNexusModelBuildResult class >> project: aMooseNexusProject modelArtifact: aMooseNexusModelArtifact dependencyResolutionResult: aMooseNexusDependencyResolutionResult [

	^ self new
		  initializeProject: aMooseNexusProject
		  modelArtifact: aMooseNexusModelArtifact
		  dependencyResolutionResult: aMooseNexusDependencyResolutionResult
]

{ #category : 'accessing' }
MooseNexusModelBuildResult >> dependencyResolutionResult [

	^ dependencyResolutionResult
]

{ #category : 'initialization' }
MooseNexusModelBuildResult >> initializeProject: aMooseNexusProject modelArtifact: aMooseNexusModelArtifact dependencyResolutionResult: aMooseNexusDependencyResolutionResult [

	project := aMooseNexusProject.
	modelArtifact := aMooseNexusModelArtifact.
	dependencyResolutionResult := aMooseNexusDependencyResolutionResult
]

{ #category : 'accessing' }
MooseNexusModelBuildResult >> modelArtifact [

	^ modelArtifact
]

{ #category : 'accessing' }
MooseNexusModelBuildResult >> modelFormat [

	^ modelArtifact format
]

{ #category : 'accessing' }
MooseNexusModelBuildResult >> modelName [

	^ modelArtifact name
]

{ #category : 'accessing' }
MooseNexusModelBuildResult >> project [

	^ project
]
