"
I import one recorded MooseNexus model artifact into its declared Famix metamodel.

Concrete importers own metamodel-specific requirements and JSON import behavior. I select them from a persisted metamodel identifier.
"
Class {
	#name : 'MooseNexusModelImporter',
	#superclass : 'Object',
	#category : 'MooseNexus-ModelExtraction',
	#package : 'MooseNexus',
	#tag : 'ModelExtraction'
}

{ #category : 'testing' }
MooseNexusModelImporter class >> canHandle: aMetamodelName [

	^ aMetamodelName = self metamodel
]

{ #category : 'instance creation' }
MooseNexusModelImporter class >> forMetamodel: aMetamodelName [

	self allSubclassesDo: [ :subclass | (subclass canHandle: aMetamodelName) ifTrue: [ ^ subclass new ] ].
	Error signal: 'No MooseNexus model importer for metamodel: ' , aMetamodelName
]

{ #category : 'capabilities' }
MooseNexusModelImporter class >> metamodel [

	self subclassResponsibility
]

{ #category : 'importing' }
MooseNexusModelImporter >> importArtifact: aMooseNexusModelArtifact fromProject: aMooseNexusProject [

	self subclassResponsibility
]

{ #category : 'capabilities' }
MooseNexusModelImporter >> modelImportRequirements [

	self subclassResponsibility
]

{ #category : 'importing' }
MooseNexusModelImporter >> sourceRootForProject: aMooseNexusProject [

	self subclassResponsibility
]
