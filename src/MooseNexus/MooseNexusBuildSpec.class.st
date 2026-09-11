"
I describe how MooseNexus should import, build, and eventually record a model artifact.

I compose source project recording intent, dependency-resolution configuration, and model-building options. MooseNexusProjectSpec still owns source coordinates and source directory validation; I coordinate the import/build workflow around that intent.

Use me as the central configuration object for client-side builds. Importers, builders, repositories, and UI presenters should consume or configure me instead of hiding build policy in their own state.
"
Class {
	#name : 'MooseNexusBuildSpec',
	#superclass : 'Object',
	#instVars : [
		'projectSpec',
		'extractor',
		'modelName',
		'modelComment',
		'localRepositories',
		'dependencyConflictResolver',
		'unresolvedDependencyPolicy',
		'projectImporter',
		'language',
		'withDependencyClasspath',
		'dependencyClasspathSelectionPolicy'
	],
	#category : 'MooseNexus-Project',
	#package : 'MooseNexus',
	#tag : 'Project'
}

{ #category : 'instance creation' }
MooseNexusBuildSpec class >> coordinates: coordinates sourceDirectory: sourceDirectory [

	^ self projectSpec: (MooseNexusProjectSpec coordinates: coordinates sourceDirectory: sourceDirectory)
]

{ #category : 'instance creation' }
MooseNexusBuildSpec class >> projectSpec: aMooseNexusProjectSpec [

	^ self new projectSpec: aMooseNexusProjectSpec
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> buildProvenance [

	^ MooseNexusBuildProvenance current
]

{ #category : 'importing' }
MooseNexusBuildSpec >> configureImporter: aMooseNexusProjectImporter [

	aMooseNexusProjectImporter configureFromBuildSpec: self
]

{ #category : 'building' }
MooseNexusBuildSpec >> configureModelBuilder: aMooseNexusModelBuilder [

	aMooseNexusModelBuilder
		withDependencyClasspath: withDependencyClasspath;
		modelComment: self modelComment;
		buildProvenance: self buildProvenance.

	dependencyClasspathSelectionPolicy ifNotNil: [ :policy | aMooseNexusModelBuilder dependencyClasspathSelectionPolicy: policy ].
	modelName ifNotNil: [ aMooseNexusModelBuilder modelName: modelName ].
	extractor ifNotNil: [ aMooseNexusModelBuilder extractor: extractor ]
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> coordinates [

	^ projectSpec coordinates
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> dependencyClasspathSelectionPolicy [

	^ dependencyClasspathSelectionPolicy
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> dependencyClasspathSelectionPolicy: aMooseNexusDependencyClasspathSelectionPolicy [

	dependencyClasspathSelectionPolicy := aMooseNexusDependencyClasspathSelectionPolicy
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> dependencyConflictResolver [

	^ dependencyConflictResolver
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> dependencyConflictResolver: aMooseNexusDependencyConflictResolver [

	dependencyConflictResolver := aMooseNexusDependencyConflictResolver
]

{ #category : 'execution' }
MooseNexusBuildSpec >> execute [

	^ self executeIn: MooseNexusRepository default
]

{ #category : 'execution' }
MooseNexusBuildSpec >> executeIn: aMooseNexusRepository [

	^ (self planIn: aMooseNexusRepository) execute
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> extractor [

	^ extractor
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> extractor: aMooseNexusModelExtractor [

	extractor := aMooseNexusModelExtractor
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> group [

	^ projectSpec group
]

{ #category : 'initialization' }
MooseNexusBuildSpec >> initialize [

	super initialize.
	withDependencyClasspath := true
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> language [

	^ language
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> language: aString [

	language := aString
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> localRepositories [

	^ localRepositories
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> localRepositories: aCollection [

	localRepositories := aCollection
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> modelComment [

	^ modelComment ifNil: [ '' ]
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> modelComment: aString [

	modelComment := aString
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> modelName [

	^ modelName
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> modelName: aString [

	modelName := aString
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> name [

	^ projectSpec name
]

{ #category : 'planning' }
MooseNexusBuildSpec >> planIn: aMooseNexusRepository [

	^ MooseNexusBuildPlan buildSpec: self repository: aMooseNexusRepository
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> projectImporter [

	^ projectImporter ifNil: [ MooseNexusProjectImporter fromDirectory: self sourceDirectory pathString language: self language ]
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> projectImporter: aMooseNexusProjectImporter [

	projectImporter := aMooseNexusProjectImporter
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> projectSpec [

	^ projectSpec
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> projectSpec: aMooseNexusProjectSpec [

	projectSpec := aMooseNexusProjectSpec
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> sourceDirectory [

	^ projectSpec sourceDirectory
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> unresolvedDependencyPolicy [

	^ unresolvedDependencyPolicy
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> unresolvedDependencyPolicy: aMooseNexusUnresolvedDependencyPolicy [

	unresolvedDependencyPolicy := aMooseNexusUnresolvedDependencyPolicy
]

{ #category : 'validating' }
MooseNexusBuildSpec >> validateForRecording [

	projectSpec validateForRecording
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> version [

	^ projectSpec version
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> withDependencyClasspath [

	^ withDependencyClasspath
]

{ #category : 'accessing' }
MooseNexusBuildSpec >> withDependencyClasspath: aBoolean [

	withDependencyClasspath := aBoolean
]
