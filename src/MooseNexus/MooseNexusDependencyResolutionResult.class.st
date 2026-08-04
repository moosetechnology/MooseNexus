"
I describe the dependency-resolution result used by a MooseNexus build.

I capture the resolved dependency descriptors, warnings, and decisions produced while importing and resolving a project's dependencies.
"
Class {
	#name : 'MooseNexusDependencyResolutionResult',
	#superclass : 'Object',
	#instVars : [
		'project',
		'dependencies',
		'warnings',
		'decisions'
	],
	#category : 'MooseNexus-Dependency',
	#package : 'MooseNexus',
	#tag : 'Dependency'
}

{ #category : 'instance creation' }
MooseNexusDependencyResolutionResult class >> forProject: aMooseNexusProject [

	^ self
		  project: aMooseNexusProject
		  dependencies: aMooseNexusProject dependencies
		  warnings: #(  )
		  decisions: #(  )
]

{ #category : 'instance creation' }
MooseNexusDependencyResolutionResult class >> project: aMooseNexusProject dependencies: dependencies warnings: warnings decisions: decisions [

	^ self new
		  initializeProject: aMooseNexusProject
		  dependencies: dependencies
		  warnings: warnings
		  decisions: decisions;
		  yourself
]

{ #category : 'accessing' }
MooseNexusDependencyResolutionResult >> decisions [

	^ decisions
]

{ #category : 'accessing' }
MooseNexusDependencyResolutionResult >> dependencies [

	^ dependencies
]

{ #category : 'initialization' }
MooseNexusDependencyResolutionResult >> initializeProject: aMooseNexusProject dependencies: dependencyDescriptors warnings: buildWarnings decisions: buildDecisions [

	project := aMooseNexusProject.
	dependencies := dependencyDescriptors.
	warnings := buildWarnings.
	decisions := buildDecisions
]

{ #category : 'accessing' }
MooseNexusDependencyResolutionResult >> project [

	^ project
]

{ #category : 'accessing' }
MooseNexusDependencyResolutionResult >> warnings [

	^ warnings
]
