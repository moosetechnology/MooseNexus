"
I describe the result of building one model artifact.

I capture the recorded project, the model description written to models.json, and the dependency-resolution result that was used for the build.
"
Class {
	#name : 'MooseNexusModelBuildResult',
	#superclass : 'Object',
	#instVars : [
		'project',
		'modelDescription',
		'dependencyResolutionResult'
	],
	#category : 'MooseNexus-ModelExtraction',
	#package : 'MooseNexus',
	#tag : 'ModelExtraction'
}

{ #category : 'instance creation' }
MooseNexusModelBuildResult class >> project: aMooseNexusProject modelDescription: modelDescription dependencyResolutionResult: aMooseNexusDependencyResolutionResult [

	^ self new
		  initializeProject: aMooseNexusProject
		  modelDescription: modelDescription
		  dependencyResolutionResult: aMooseNexusDependencyResolutionResult;
		  yourself
]

{ #category : 'accessing' }
MooseNexusModelBuildResult >> dependencyResolutionResult [

	^ dependencyResolutionResult
]

{ #category : 'initialization' }
MooseNexusModelBuildResult >> initializeProject: aMooseNexusProject modelDescription: aDictionary dependencyResolutionResult: aMooseNexusDependencyResolutionResult [

	project := aMooseNexusProject.
	modelDescription := aDictionary.
	dependencyResolutionResult := aMooseNexusDependencyResolutionResult
]

{ #category : 'accessing' }
MooseNexusModelBuildResult >> modelDescription [

	^ modelDescription
]

{ #category : 'accessing' }
MooseNexusModelBuildResult >> modelFormat [

	^ modelDescription at: 'format'
]

{ #category : 'accessing' }
MooseNexusModelBuildResult >> modelName [

	^ modelDescription at: 'name'
]

{ #category : 'accessing' }
MooseNexusModelBuildResult >> project [

	^ project
]
