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
MooseNexusDependencyResolutionResult class >> fromDictionary: aDictionary [

	^ self
		  project: nil
		  dependencies: ((aDictionary at: 'resolvedDependencies')
				   collect: [ :dependency | MooseNexusDependencyDescriptor fromDictionary: dependency ]
				   as: Array)
		  warnings: (aDictionary at: 'warnings')
		  decisions:
		  ((aDictionary at: 'decisions')
			   collect: [ :decision | MooseNexusDependencyConflictDecision fromDictionary: decision ]
			   as: Array)
]

{ #category : 'instance creation' }
MooseNexusDependencyResolutionResult class >> project: aMooseNexusProject dependencies: dependencies warnings: warnings decisions: decisions [

	^ self new
		  initializeProject: aMooseNexusProject
		  dependencies: dependencies
		  warnings: warnings
		  decisions: decisions
]

{ #category : 'comparing' }
MooseNexusDependencyResolutionResult >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ anObject dependencies = dependencies and: [ anObject warnings = warnings and: [ anObject decisions = decisions ] ]
]

{ #category : 'converting' }
MooseNexusDependencyResolutionResult >> asDictionary [

	^ Dictionary new
		  add: 'resolvedDependencies' -> (dependencies collect: [ :dependency | dependency asDictionary ] as: Array);
		  add: 'warnings' -> warnings asArray;
		  add: 'decisions' -> (decisions collect: [ :decision | decision asDictionary ] as: Array);
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

{ #category : 'comparing' }
MooseNexusDependencyResolutionResult >> hash [

	^ dependencies hash bitXor: (warnings hash bitXor: decisions hash)
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
