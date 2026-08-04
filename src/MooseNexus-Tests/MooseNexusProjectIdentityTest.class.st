Class {
	#name : 'MooseNexusProjectIdentityTest',
	#superclass : 'TestCase',
	#instVars : [
		'repository',
		'sourceDirectory',
		'rootDirectory'
	],
	#category : 'MooseNexus-Tests',
	#package : 'MooseNexus-Tests'
}

{ #category : 'running' }
MooseNexusProjectIdentityTest >> setUp [

	super setUp.
	rootDirectory := FileLocator temp / ('MooseNexus-' , UUID new asString).
	sourceDirectory := rootDirectory / 'source'.
	sourceDirectory ensureCreateDirectory.
	sourceDirectory / 'README.txt' writeStreamDo: [ :stream | stream nextPutAll: 'test source project' ].
	repository := MooseNexusRepository new directory: rootDirectory / 'nexus'
]

{ #category : 'running' }
MooseNexusProjectIdentityTest >> tearDown [

	rootDirectory ifNotNil: [ rootDirectory ifExists: [ rootDirectory deleteAll ] ].
	super tearDown
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testBuildPlanRecordsProjectAndCapturesDependencyResolution [

	| project buildSpec plan dependencyResult |
	project := MooseNexusTestProject new.
	buildSpec := MooseNexusBuildSpec
		             coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0')
		             sourceDirectory: sourceDirectory.
	plan := buildSpec planIn: repository.

	plan recordProject: project.
	dependencyResult := plan resolveDependencies.

	self assert: plan project identicalTo: project.
	self assert: project isRecorded.
	self assert: dependencyResult project identicalTo: project.
	self assert: dependencyResult dependencies equals: project dependencies.
	self assert: dependencyResult warnings isEmpty.
	self assert: dependencyResult decisions isEmpty
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testBuildSpecCanBeCreatedFromCoordinatesAndSourceDirectory [

	| coordinates buildSpec |
	coordinates := MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	buildSpec := MooseNexusBuildSpec coordinates: coordinates sourceDirectory: sourceDirectory.

	self assert: buildSpec coordinates equals: coordinates.
	self assert: buildSpec sourceDirectory pathString equals: sourceDirectory pathString
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testBuildSpecComposesProjectSpec [

	| coordinates projectSpec buildSpec |
	coordinates := MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	projectSpec := MooseNexusProjectSpec coordinates: coordinates sourceDirectory: sourceDirectory.
	buildSpec := MooseNexusBuildSpec projectSpec: projectSpec.

	self assert: buildSpec projectSpec equals: projectSpec.
	self assert: buildSpec coordinates equals: coordinates.
	self assert: buildSpec group equals: 'com.example'.
	self assert: buildSpec name equals: 'demo'.
	self assert: buildSpec version equals: '1.0.0'.
	self assert: buildSpec sourceDirectory pathString equals: sourceDirectory pathString
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testBuildSpecConfiguresDependencyPolicies [

	| buildSpec importer unresolvedPolicy |
	unresolvedPolicy := MooseNexusUnresolvedDependencyPolicy warnAndContinue.
	buildSpec := MooseNexusBuildSpec
		             coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0')
		             sourceDirectory: sourceDirectory.
	buildSpec unresolvedDependencyPolicy: unresolvedPolicy.
	importer := MooseNexusMavenProjectImporter new.

	buildSpec configureImporter: importer.

	self assert: importer unresolvedDependencyPolicy identicalTo: unresolvedPolicy
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testBuildSpecConfiguresManagedImporter [

	| buildSpec importer localRepositories resolver |
	localRepositories := { (MooseNexusMavenRepository new directory: 'custom-maven-repository') }.
	resolver := MooseNexusFirstFoundDependencyConflictResolver new.
	buildSpec := MooseNexusBuildSpec
		             coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0')
		             sourceDirectory: sourceDirectory.
	buildSpec
		localRepositories: localRepositories;
		dependencyConflictResolver: resolver.
	importer := MooseNexusMavenProjectImporter new.

	buildSpec configureImporter: importer.

	self assert: importer localRepositories equals: localRepositories.
	self assert: importer dependencyConflictResolver identicalTo: resolver
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testBuildSpecCreatesBuildPlan [

	| buildSpec plan |
	buildSpec := MooseNexusBuildSpec
		             coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0')
		             sourceDirectory: sourceDirectory.

	plan := buildSpec planIn: repository.

	self assert: plan buildSpec identicalTo: buildSpec.
	self assert: plan repository identicalTo: repository
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testCoordinatesAreInitializedOnce [

	| project coordinates |
	coordinates := MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	project := MooseNexusTestProject coordinates: coordinates.

	self assert: project coordinates equals: coordinates.
	self assert: project group equals: 'com.example'.
	self assert: project name equals: 'demo'.
	self assert: project version equals: '1.0.0'.
	self
		should: [ project initializeCoordinates: (MooseNexusCoordinates group: 'org.example' name: 'demo' version: '1.0.0') ]
		raise: Error
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testCoordinatesAreValueObjects [

	| coordinates sameCoordinates otherCoordinates |
	coordinates := MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	sameCoordinates := MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	otherCoordinates := MooseNexusCoordinates group: 'com.example' name: 'demo' version: '2.0.0'.

	self assert: coordinates equals: sameCoordinates.
	self deny: coordinates equals: otherCoordinates.
	self assert: coordinates printString equals: 'com.example:demo:1.0.0'
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testManagedImporterCapturesDependencyConflictDecisions [

	| project importer dependency otherDependency projectDescriptor otherProjectDescriptor result decision |
	dependency := MooseNexusDependencyDescriptor
		              coordinates: (MooseNexusCoordinates group: 'org.example' name: 'dep' version: '1.0.0')
		              type: 'jar'
		              scopes: #( 'compile' )
		              path: 'repository/dep-1.0.0.jar'.
	otherDependency := MooseNexusDependencyDescriptor
		                   coordinates: (MooseNexusCoordinates group: 'org.example' name: 'dep' version: '2.0.0')
		                   type: 'jar'
		                   scopes: #( 'runtime' )
		                   path: 'repository/dep-2.0.0.jar'.
	projectDescriptor := MooseNexusManagedProjectDescriptor
		                     version: '1.0.0'
		                     path: '.'
		                     dependencyGraph: (MooseNexusDependencyGraph dependencies: { dependency }).
	otherProjectDescriptor := MooseNexusManagedProjectDescriptor
		                          version: '1.0.0'
		                          path: 'other'
		                          dependencyGraph: (MooseNexusDependencyGraph dependencies: { otherDependency }).
	project := MooseNexusMavenProject coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0').
	project projects:
		(Dictionary with: 'com.example' -> (Dictionary with: 'demo' -> projectDescriptor with: 'other' -> otherProjectDescriptor)).
	importer := MooseNexusMavenProjectImporter new.
	importer project: project.

	result := importer resolveDependencies.
	decision := result decisions first.

	self assert: result project identicalTo: project.
	self assert: result dependencies size equals: 1.
	self assert: result dependencies first version equals: '1.0.0'.
	self assert: result warnings isEmpty.
	self assert: result decisions size equals: 1.
	self assert: decision conflictId equals: 'org.example:dep'.
	self assert: decision candidates size equals: 2.
	self assert: decision selectedDependency equals: result dependencies first
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testManagedProjectDescriptorDictionaryRoundTrip [

	| dictionary descriptor dependencyGraph dependency |
	dictionary := Dictionary
		              with: #path -> '.'
		              with: #version -> '1.0.0'
		              with: #dependencyGraph -> (Dictionary with: #dependencies -> { (Dictionary
					                with: #group -> 'org.example'
					                with: #name -> 'dep'
					                with: #version -> '2.0.0'
					                with: #type -> 'jar'
					                with: #scopes -> #( 'compile' )
					                with: #path -> 'repository/dep-2.0.0.jar') }).
	descriptor := MooseNexusManagedProjectDescriptor fromDictionary: dictionary.
	dependencyGraph := descriptor dependencyGraph.
	dependency := dependencyGraph dependencies first.

	self assert: descriptor version equals: '1.0.0'.
	self assert: descriptor path equals: '.'.
	self assert: dependencyGraph size equals: 1.
	self assert: dependency group equals: 'org.example'.
	self assert: descriptor asDictionary equals: dictionary
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testManagedProjectDescriptorIsValueObject [

	| dependency dependencyGraph descriptor sameDescriptor otherDescriptor |
	dependency := MooseNexusDependencyDescriptor
		              coordinates: (MooseNexusCoordinates group: 'org.example' name: 'dep' version: '2.0.0')
		              type: 'jar'
		              scopes: #( 'compile' )
		              path: 'repository/dep-2.0.0.jar'.
	dependencyGraph := MooseNexusDependencyGraph dependencies: { dependency }.
	descriptor := MooseNexusManagedProjectDescriptor version: '1.0.0' path: '.' dependencyGraph: dependencyGraph.
	sameDescriptor := MooseNexusManagedProjectDescriptor version: '1.0.0' path: '.' dependencyGraph: dependencyGraph.
	otherDescriptor := MooseNexusManagedProjectDescriptor version: '2.0.0' path: '.' dependencyGraph: dependencyGraph.

	self assert: descriptor equals: sameDescriptor.
	self deny: descriptor equals: otherDescriptor.
	self assert: descriptor hash equals: sameDescriptor hash
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testManagedProjectPropertiesRoundTripFromFile [

	| project loadedProject propertiesFile projects dependency dependencyGraph descriptor |
	dependency := MooseNexusDependencyDescriptor
		              coordinates: (MooseNexusCoordinates group: 'org.example' name: 'dep' version: '2.0.0')
		              type: 'jar'
		              scopes: #( 'compile' )
		              path: 'repository/dep-2.0.0.jar'.
	dependencyGraph := MooseNexusDependencyGraph dependencies: { dependency }.
	descriptor := MooseNexusManagedProjectDescriptor version: '1.0.0' path: nil dependencyGraph: dependencyGraph.
	projects := Dictionary with: 'com.example' -> (Dictionary with: 'demo' -> descriptor).
	project := MooseNexusMavenProject coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0').
	project
		language: 'java';
		projects: projects;
		dependencies: #(  ).
	propertiesFile := rootDirectory / 'managed-properties.json'.
	propertiesFile writeStreamDo: [ :stream | project writePropertiesOn: stream ].

	loadedProject := MooseNexusProject fromProperties: propertiesFile.

	self assert: loadedProject class equals: MooseNexusMavenProject.
	self assert: loadedProject coordinates equals: project coordinates.
	self assert: loadedProject language equals: 'java'.
	self assert: loadedProject projects equals: project projects.
	self assert: loadedProject serializedProjects equals: project serializedProjects
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testProjectPropertiesFlattenCoordinates [

	| project properties |
	project := MooseNexusTestProject coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0').
	project dependencies: #(  ).
	properties := project properties.

	self assert: (properties at: #group) equals: 'com.example'.
	self assert: (properties at: #name) equals: 'demo'.
	self assert: (properties at: #version) equals: '1.0.0'.
	self assert: (properties includesKey: #resolvedDependencies).
	self deny: (properties includesKey: #dependencies).
	self deny: (properties includesKey: #coordinates)
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testProjectPropertiesIncludeSchemaVersion [

	| project properties |
	project := MooseNexusTestProject coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0').
	project dependencies: #(  ).
	properties := project properties.

	self assert: (properties at: #schemaVersion) equals: MooseNexusProject propertiesSchemaVersion
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testProjectPropertiesReadUnversionedDataAsCurrentSchema [

	| project properties |
	properties := Dictionary new
		              add: #group -> 'com.example';
		              add: #name -> 'demo';
		              add: #version -> '1.0.0';
		              yourself.

	project := MooseNexusTestProject new readProperties: properties.

	self assert: project coordinates equals: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0')
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testProjectPropertiesRejectUnsupportedSchemaVersion [

	| properties |
	properties := Dictionary new
		              add: #schemaVersion -> 'unsupported';
		              add: #group -> 'com.example';
		              add: #name -> 'demo';
		              add: #version -> '1.0.0';
		              yourself.

	self should: [ MooseNexusTestProject new readProperties: properties ] raise: Error
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testProjectPropertiesRoundTripFromFile [

	| project loadedProject propertiesFile dependency |
	project := MooseNexusTestProject coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0').
	dependency := MooseNexusDependencyDescriptor
		              coordinates: (MooseNexusCoordinates group: 'org.example' name: 'dep' version: '2.0.0')
		              type: 'jar'
		              scopes: #( 'compile' )
		              path: 'repository/dep-2.0.0.jar'.
	project dependencies: { dependency }.
	propertiesFile := rootDirectory / 'properties.json'.
	propertiesFile writeStreamDo: [ :stream | project writePropertiesOn: stream ].

	loadedProject := MooseNexusProject fromProperties: propertiesFile.

	self assert: loadedProject class equals: MooseNexusTestProject.
	self assert: loadedProject coordinates equals: project coordinates.
	self assert: loadedProject dependencies equals: project dependencies
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testProjectSpecHoldsRecordingIntent [

	| coordinates spec |
	coordinates := MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	spec := MooseNexusProjectSpec coordinates: coordinates sourceDirectory: sourceDirectory.

	self assert: spec coordinates equals: coordinates.
	self assert: spec group equals: 'com.example'.
	self assert: spec name equals: 'demo'.
	self assert: spec version equals: '1.0.0'.
	self assert: spec sourceDirectory pathString equals: sourceDirectory pathString
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testRecordedProjectRejectsCoordinateChanges [

	| project coordinates |
	coordinates := MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	project := MooseNexusTestProject coordinates: coordinates.
	project directory: 'nexus/repository/com.example/demo/1.0.0'.

	self
		should: [ project initializeCoordinates: (MooseNexusCoordinates group: 'org.example' name: 'demo' version: '1.0.0') ]
		raise: Error
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testRepositoryCreatesLayoutBeforeRecordingProject [

	| project spec projectDirectory |
	project := MooseNexusTestProject new.
	spec := MooseNexusProjectSpec
		        coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0')
		        sourceDirectory: sourceDirectory.
	projectDirectory := repository directory / 'repository' / 'com.example' / 'demo' / '1.0.0'.

	self deny: repository directory exists.
	repository recordLoadedProject: project describedBy: spec.

	self assert: projectDirectory exists.
	self assert: (projectDirectory / 'sources') exists.
	self assert: (projectDirectory / 'sources' / 'project') exists.
	self assert: (projectDirectory / 'sources' / 'project' / 'README.txt') exists.
	self assert: (projectDirectory / 'properties.json') exists.
	self assert: (projectDirectory / 'models.json') exists
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testRepositoryRecordFromSpecSetsIdentityBeforeRecording [

	| project spec recordedProject coordinates |
	project := MooseNexusTestProject new.
	coordinates := MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0'.
	spec := MooseNexusProjectSpec coordinates: coordinates sourceDirectory: sourceDirectory.
	recordedProject := repository recordLoadedProject: project describedBy: spec.

	self assert: recordedProject identicalTo: project.
	self assert: project coordinates equals: coordinates.
	self assert: project isRecorded.
	self assert: (repository directory / 'repository' / 'com.example' / 'demo' / '1.0.0' / 'properties.json') exists
]

{ #category : 'tests' }
MooseNexusProjectIdentityTest >> testRepositoryRejectsLoadedProjectWithDifferentCoordinatesThanBuildSpec [

	| project buildSpec |
	project := MooseNexusTestProject coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '2.0.0').
	buildSpec := MooseNexusBuildSpec
		             coordinates: (MooseNexusCoordinates group: 'com.example' name: 'demo' version: '1.0.0')
		             sourceDirectory: sourceDirectory.

	self should: [ repository recordLoadedProject: project describedBy: buildSpec ] raise: Error
]
