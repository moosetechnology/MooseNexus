"
I describe the dependency-resolution result used by a MooseNexus build.

I capture the resolved dependency descriptors, warnings, conflict decisions, and temporary materialization audit produced while importing and building a project. The descriptors are portable references; materialization paths are not durable artifact locations.
"
Class {
	#name : 'MooseNexusDependencyResolutionResult',
	#superclass : 'Object',
	#instVars : [
		'project',
		'dependencies',
		'warnings',
		'decisions',
		'materializations'
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
		  materializations: ((aDictionary at: 'materializations')
				   collect: [ :each | MooseNexusDependencyMaterializationResult fromDictionary: each ]
				   as: Array)
]

{ #category : 'instance creation' }
MooseNexusDependencyResolutionResult class >> project: aMooseNexusProject dependencies: dependencies warnings: warnings decisions: decisions [

	^ self
		  project: aMooseNexusProject
		  dependencies: dependencies
		  warnings: warnings
		  decisions: decisions
		  materializations: #(  )
]

{ #category : 'instance creation' }
MooseNexusDependencyResolutionResult class >> project: aMooseNexusProject dependencies: dependencies warnings: warnings decisions: decisions materializations: materializationResults [

	^ self new
		  initializeProject: aMooseNexusProject
		  dependencies: dependencies
		  warnings: warnings
		  decisions: decisions
		  materializations: materializationResults
]

{ #category : 'comparing' }
MooseNexusDependencyResolutionResult >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ anObject dependencies = dependencies and: [
		  anObject warnings = warnings and: [ anObject decisions = decisions and: [ anObject materializations = materializations ] ] ]
]

{ #category : 'converting' }
MooseNexusDependencyResolutionResult >> asDictionary [

	^ Dictionary new
		  add: 'resolvedDependencies' -> (dependencies collect: [ :dependency | dependency asDictionary ] as: Array);
		  add: 'warnings' -> warnings asArray;
		  add: 'decisions' -> (decisions collect: [ :decision | decision asDictionary ] as: Array);
		  add: 'materializations' -> (materializations collect: #asDictionary as: Array);
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

	^ dependencies hash bitXor: (warnings hash bitXor: (decisions hash bitXor: materializations hash))
]

{ #category : 'initialization' }
MooseNexusDependencyResolutionResult >> initializeProject: aMooseNexusProject dependencies: dependencyDescriptors warnings: buildWarnings decisions: buildDecisions [

	project := aMooseNexusProject.
	dependencies := dependencyDescriptors.
	warnings := buildWarnings.
	decisions := buildDecisions
]

{ #category : 'initialization' }
MooseNexusDependencyResolutionResult >> initializeProject: aMooseNexusProject dependencies: dependencyDescriptors warnings: buildWarnings decisions: buildDecisions materializations: materializationResults [

	project := aMooseNexusProject.
	dependencies := dependencyDescriptors.
	warnings := buildWarnings.
	decisions := buildDecisions.
	materializations := materializationResults asArray
]

{ #category : 'accessing' }
MooseNexusDependencyResolutionResult >> materializations [

	^ materializations
]

{ #category : 'accessing' }
MooseNexusDependencyResolutionResult >> project [

	^ project
]

{ #category : 'accessing' }
MooseNexusDependencyResolutionResult >> warnings [

	^ warnings
]

{ #category : 'copying' }
MooseNexusDependencyResolutionResult >> withMaterializations: materializationResults [

	^ self class
		  project: project
		  dependencies: dependencies
		  warnings: warnings
		  decisions: decisions
		  materializations: materializationResults
]
