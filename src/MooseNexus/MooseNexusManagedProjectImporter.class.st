"
I am responsible for importing a project that uses a build automation tool to manage dependencies.
Each of my subclasses knows how to interact with a specific tool to get them.
"
Class {
	#name : 'MooseNexusManagedProjectImporter',
	#superclass : 'MooseNexusProjectImporter',
	#instVars : [
		'localRepositories',
		'dependencyConflictResolver',
		'dependencyResolutionResult'
	],
	#category : 'MooseNexus-Importer',
	#package : 'MooseNexus',
	#tag : 'Importer'
}

{ #category : 'testing' }
MooseNexusManagedProjectImporter class >> isAbstract [

	^ self == MooseNexusManagedProjectImporter
]

{ #category : 'private' }
MooseNexusManagedProjectImporter >> addDependency: descriptor to: dependencies group: dependencyGroup [

	| key |
	key := {
		       descriptor coordinates.
		       descriptor type.
		       descriptor path }.
	dependencies
		at: dependencyGroup
		ifPresent: [ :descriptorsByArtifact |
				descriptorsByArtifact
					at: key
					ifPresent: [ :existing | descriptorsByArtifact at: key put: (existing mergedWith: descriptor) ]
					ifAbsentPut: [ descriptor ] ]
		ifAbsentPut: [ OrderedDictionary with: key -> descriptor ]
]

{ #category : 'adding' }
MooseNexusManagedProjectImporter >> addLocalRepository: pathString [

	localRepositories add: pathString
]

{ #category : 'parsing' }
MooseNexusManagedProjectImporter >> analyze [
	"Attempts to read the group, name, version, and dependencies of all managed projects."

	self parse: self read
]

{ #category : 'configuring' }
MooseNexusManagedProjectImporter >> configureFromBuildSpec: aMooseNexusBuildSpec [

	aMooseNexusBuildSpec localRepositories ifNotNil: [ :repositories | self localRepositories: repositories ].
	aMooseNexusBuildSpec dependencyConflictResolver ifNotNil: [ :resolver | self dependencyConflictResolver: resolver ]
]

{ #category : 'private' }
MooseNexusManagedProjectImporter >> dependencyConflictDecisionsFrom: conflicts resolvedOn: dependencies [

	^ conflicts associations
		  collect: [ :association |
				  MooseNexusDependencyConflictDecision
					  conflictId: association key
					  candidates: association value asArray
					  selectedDependency: (dependencies at: association key) ]
		  as: Array
]

{ #category : 'accessing' }
MooseNexusManagedProjectImporter >> dependencyConflictResolver [

	^ dependencyConflictResolver
]

{ #category : 'accessing' }
MooseNexusManagedProjectImporter >> dependencyConflictResolver: aMooseNexusDependencyConflictResolver [

	dependencyConflictResolver := aMooseNexusDependencyConflictResolver
]

{ #category : 'private' }
MooseNexusManagedProjectImporter >> dependencyGraphFrom: dependenciesByGroup [

	| dependencyDescriptors |
	dependencyDescriptors := OrderedCollection new.
	dependenciesByGroup do: [ :descriptorsByArtifact | dependencyDescriptors addAll: descriptorsByArtifact values ].
	^ MooseNexusDependencyGraph dependencies: (self sortedDependencyDescriptors: dependencyDescriptors)
]

{ #category : 'accessing' }
MooseNexusManagedProjectImporter >> dependencyResolutionResult [

	^ dependencyResolutionResult
]

{ #category : 'querying' }
MooseNexusManagedProjectImporter >> determineCoordinates [

	^ MooseNexusCoordinates group: self determineGroup name: self determineName version: self determineVersion
]

{ #category : 'querying' }
MooseNexusManagedProjectImporter >> determineGroup [

	project projects size == 1 ifFalse: [ Error signal: 'Can only determine group if only one is declared' ].
	project projects keysDo: [ :key | ^ key ]
]

{ #category : 'querying' }
MooseNexusManagedProjectImporter >> determineName [

	(project projects size == 1 and: [ project projects anyOne size == 1 ]) ifFalse: [
		Error signal: 'Can only determine name if only one is declared' ].
	project projects anyOne keysDo: [ :key | ^ key ]
]

{ #category : 'querying' }
MooseNexusManagedProjectImporter >> determineVersion [

	| theVersion |
	(project projects isNotEmpty and: [ project projects anyOne isNotEmpty ]) ifFalse: [
		Error signal: 'Cannot determine version because there are no managed projects' ].
	"verify all managed projects declare same version"
	theVersion := self validateProjectVersion: project projects anyOne anyOne version.
	project projects do: [ :projectGroup |
			projectGroup do: [ :descriptor |
					| descriptorVersion |
					descriptorVersion := self validateProjectVersion: descriptor version.
					descriptorVersion = theVersion ifFalse: [
						Error signal: 'Can only determine version if all managed projects declare the same one' ] ] ].
	^ theVersion
]

{ #category : 'private' }
MooseNexusManagedProjectImporter >> effectiveDependencyConflictResolver [

	^ dependencyConflictResolver ifNil: [ MooseNexusDependencyConflictResolver newDefaultResolver ]
]

{ #category : 'importing' }
MooseNexusManagedProjectImporter >> import [

	^ self importWithCoordinates: nil
]

{ #category : 'importing' }
MooseNexusManagedProjectImporter >> importWithCoordinates: aMooseNexusCoordinates [

	| projectCoordinates |
	project ifNil: [ project := self newProject ].
	self analyze.
	projectCoordinates := aMooseNexusCoordinates ifNil: [ self determineCoordinates ].
	project initializeCoordinates: projectCoordinates.
	dependencyResolutionResult := self resolveDependencies.
	project dependencies: dependencyResolutionResult dependencies.
	^ project
]

{ #category : 'accessing' }
MooseNexusManagedProjectImporter >> localRepositories [
	"The directories containing the local repositories of build automation tools."

	^ localRepositories
]

{ #category : 'accessing' }
MooseNexusManagedProjectImporter >> localRepositories: pathStringCollection [
	"Define the local repositories of the build automation tools to use for this project.
	All paths must be relative to the home directory (result of `FileLocator home pathString`)."

	localRepositories := pathStringCollection
]

{ #category : 'parsing' }
MooseNexusManagedProjectImporter >> parse: commandOutputString [
	"Parse the result of the 'read' method, which contains the project data obtained from the build automation tool."

	self subclassResponsibility
]

{ #category : 'reading' }
MooseNexusManagedProjectImporter >> read [
	"Read project data from the build automation tool."

	self subclassResponsibility
]

{ #category : 'resolving' }
MooseNexusManagedProjectImporter >> resolve: descriptor [
	"Attempts to find the local path to an artifact based on the descriptor."

	localRepositories do: [ :repository | (repository resolve: descriptor) ifNotNil: [ :mapping | ^ mapping ] ].
	Error signal: 'Could not find dependency: ' , descriptor
]

{ #category : 'querying' }
MooseNexusManagedProjectImporter >> resolveDependencies [
	"Resolve all dependencies of this project into a flat resolved dependency set.
	A conflict can occur if two managed projects declare the same dependency with different versions."

	| dependencies conflicts decisions |
	dependencies := Dictionary new.
	conflicts := Dictionary new.

	project projectDependenciesDo: [ :dependencyGroup :dependency |
			| key |
			key := dependency group , ':' , dependency name.
			conflicts at: key ifPresent: [ :conflictList | conflictList add: dependency ] ifAbsent: [
					dependencies
						at: key
						ifPresent: [ :existing |
								(existing hasSameArtifactAs: dependency)
									ifTrue: [ dependencies at: key put: (existing mergedWith: dependency) ]
									ifFalse: [ conflicts at: key put: (OrderedCollection with: (dependencies removeKey: key) with: dependency) ] ]
						ifAbsentPut: [ dependency ] ] ].

	decisions := conflicts ifEmpty: [ #(  ) ] ifNotEmpty: [ self resolveDependencyConflicts: conflicts on: dependencies ].
	dependencyResolutionResult := MooseNexusDependencyResolutionResult
		                              project: project
		                              dependencies: dependencies asArray
		                              warnings: #(  )
		                              decisions: decisions.
	^ dependencyResolutionResult
]

{ #category : 'querying' }
MooseNexusManagedProjectImporter >> resolveDependencyConflicts: conflicts on: dependencies [

	self effectiveDependencyConflictResolver resolveConflicts: conflicts on: dependencies.
	^ self dependencyConflictDecisionsFrom: conflicts resolvedOn: dependencies
]

{ #category : 'private' }
MooseNexusManagedProjectImporter >> sortedDependencyDescriptors: dependencyDescriptors [

	^ dependencyDescriptors asArray sort: [ :left :right |
		  left printString , ':' , left type , ':' , left path <= (right printString , ':' , right type , ':' , right path) ]
]

{ #category : 'validating' }
MooseNexusManagedProjectImporter >> validateProjectVersion: aString [

	(aString isNil or: [ aString isEmpty ]) ifTrue: [
		Error signal: 'Cannot determine version because a managed project does not declare one' ].
	^ aString
]
