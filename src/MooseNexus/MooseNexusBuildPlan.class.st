"
I am an executable plan produced from a MooseNexusBuildSpec for one repository.

I split the build lifecycle into explicit steps: import project metadata and dependencies, record the project, execute model extraction, and answer result objects. I keep orchestration out of repositories, importers, builders, and UI presenters.
"
Class {
	#name : 'MooseNexusBuildPlan',
	#superclass : 'Object',
	#instVars : [
		'buildSpec',
		'repository',
		'projectImporter',
		'project',
		'dependencyResolutionResult',
		'modelBuildResult'
	],
	#category : 'MooseNexus-Project',
	#package : 'MooseNexus',
	#tag : 'Project'
}

{ #category : 'instance creation' }
MooseNexusBuildPlan class >> buildSpec: aMooseNexusBuildSpec repository: aMooseNexusRepository [

	^ self new initializeBuildSpec: aMooseNexusBuildSpec repository: aMooseNexusRepository
]

{ #category : 'accessing' }
MooseNexusBuildPlan >> buildSpec [

	^ buildSpec
]

{ #category : 'execution' }
MooseNexusBuildPlan >> configureProjectMetadata [

	buildSpec validateForRecording.
	projectImporter := buildSpec projectImporter.
	buildSpec configureImporter: projectImporter.
	projectImporter validateRequirements.
	project := projectImporter importWithCoordinates: buildSpec coordinates.
	^ project
]

{ #category : 'accessing' }
MooseNexusBuildPlan >> dependencyResolutionResult [

	^ dependencyResolutionResult
]

{ #category : 'execution' }
MooseNexusBuildPlan >> execute [

	self recordProject: self configureProjectMetadata.
	self resolveDependencies.
	^ self executeExtraction
]

{ #category : 'execution' }
MooseNexusBuildPlan >> executeExtraction [

	| modelBuilder modelArtifact |
	modelBuilder := MooseNexusModelBuilder on: project.
	buildSpec configureModelBuilder: modelBuilder.
	modelBuilder dependencyResolutionResult: dependencyResolutionResult.
	modelArtifact := modelBuilder build.
	modelBuildResult := MooseNexusModelBuildResult
		                    project: project
		                    modelArtifact: modelArtifact
		                    dependencyResolutionResult: dependencyResolutionResult.
	^ modelBuildResult
]

{ #category : 'initialization' }
MooseNexusBuildPlan >> initializeBuildSpec: aMooseNexusBuildSpec repository: aMooseNexusRepository [

	buildSpec := aMooseNexusBuildSpec.
	repository := aMooseNexusRepository
]

{ #category : 'accessing' }
MooseNexusBuildPlan >> modelBuildResult [

	^ modelBuildResult
]

{ #category : 'accessing' }
MooseNexusBuildPlan >> project [

	^ project
]

{ #category : 'accessing' }
MooseNexusBuildPlan >> projectImporter [

	^ projectImporter
]

{ #category : 'execution' }
MooseNexusBuildPlan >> recordProject: aMooseNexusProject [

	project := repository recordLoadedProject: aMooseNexusProject describedBy: buildSpec.
	^ project
]

{ #category : 'accessing' }
MooseNexusBuildPlan >> repository [

	^ repository
]

{ #category : 'execution' }
MooseNexusBuildPlan >> resolveDependencies [

	dependencyResolutionResult := projectImporter
		                              ifNil: [ MooseNexusDependencyResolutionResult forProject: project ]
		                              ifNotNil: [ projectImporter dependencyResolutionResult ].
	^ dependencyResolutionResult
]
