"
I build the local files that make up one MooseNexus OCI artifact bundle.
"
Class {
	#name : 'MooseNexusOciArtifactBundleBuilder',
	#superclass : 'Object',
	#instVars : [
		'project',
		'manifest',
		'directory'
	],
	#category : 'MooseNexus-Artifact',
	#package : 'MooseNexus',
	#tag : 'Artifact'
}

{ #category : 'constants' }
MooseNexusOciArtifactBundleBuilder class >> artifactType [

	^ 'application/vnd.moosenexus.build.alpha+json'
]

{ #category : 'constants' }
MooseNexusOciArtifactBundleBuilder class >> configMediaType [

	^ 'application/vnd.moosenexus.build.config.alpha+json'
]

{ #category : 'constants' }
MooseNexusOciArtifactBundleBuilder class >> manifestFileName [

	^ 'moosenexus-artifact-manifest.json'
]

{ #category : 'constants' }
MooseNexusOciArtifactBundleBuilder class >> modelMediaTypeFor: aMooseNexusModelArtifact [

	aMooseNexusModelArtifact format = 'json' ifTrue: [ ^ 'application/vnd.moose.famix+json' ].
	^ 'application/octet-stream'
]

{ #category : 'instance creation' }
MooseNexusOciArtifactBundleBuilder class >> project: aMooseNexusProject manifest: aMooseNexusModelArtifactManifest directory: aFileReference [

	^ self new initializeProject: aMooseNexusProject manifest: aMooseNexusModelArtifactManifest directory: aFileReference
]

{ #category : 'constants' }
MooseNexusOciArtifactBundleBuilder class >> projectPropertiesFileName [

	^ 'moosenexus-project-properties.json'
]

{ #category : 'constants' }
MooseNexusOciArtifactBundleBuilder class >> projectPropertiesMediaType [

	^ 'application/vnd.moosenexus.project-properties.alpha+json'
]

{ #category : 'constants' }
MooseNexusOciArtifactBundleBuilder class >> sourceArchiveFileName [

	^ 'sources.zip'
]

{ #category : 'constants' }
MooseNexusOciArtifactBundleBuilder class >> sourceArchiveMediaType [

	^ 'application/vnd.moosenexus.source.zip'
]

{ #category : 'private' }
MooseNexusOciArtifactBundleBuilder >> annotations [

	| modelArtifact coordinates |
	modelArtifact := manifest modelArtifact.
	coordinates := modelArtifact artifactCoordinates.
	^ Dictionary new
		  add: 'org.opencontainers.image.title' -> modelArtifact name;
		  add: 'org.opencontainers.image.created' -> manifest createdTimestamp;
		  add: 'org.opencontainers.image.description' -> modelArtifact comment;
		  add: 'org.moosenexus.project.group' -> coordinates group;
		  add: 'org.moosenexus.project.name' -> coordinates projectCoordinates name;
		  add: 'org.moosenexus.project.version' -> coordinates version;
		  add: 'org.moosenexus.model.name' -> coordinates name;
		  add: 'org.moosenexus.model.format' -> coordinates format;
		  add: 'org.moosenexus.model.metamodel' -> coordinates metamodel;
		  add: 'org.moosenexus.model.classifier' -> coordinates classifier;
		  yourself
]

{ #category : 'private' }
MooseNexusOciArtifactBundleBuilder >> archiveSourceTo: archiveFile [

	| archive |
	archive := ZipArchive new.
	archive addTree: project projectSourceDirectory relativeTo: project sourceDirectory match: [ :entry | true ].
	archive writeToFile: archiveFile.
	^ archiveFile
]

{ #category : 'building' }
MooseNexusOciArtifactBundleBuilder >> build [

	| manifestFile propertiesFile modelFile sourceArchiveFile modelArtifact |
	directory ensureCreateDirectory.
	manifestFile := self writeManifest.
	propertiesFile := self writeProjectProperties.
	modelArtifact := manifest modelArtifact.
	modelFile := self copyModelPayload: modelArtifact.
	sourceArchiveFile := self archiveSourceTo: directory / self class sourceArchiveFileName.
	^ MooseNexusOciArtifactBundle
		  artifactType: self class artifactType
		  configFile: manifestFile
		  configMediaType: self class configMediaType
		  layers: {
				  (MooseNexusOciArtifactLayer file: propertiesFile mediaType: self class projectPropertiesMediaType).
				  (MooseNexusOciArtifactLayer file: modelFile mediaType: (self class modelMediaTypeFor: modelArtifact)).
				  (MooseNexusOciArtifactLayer file: sourceArchiveFile mediaType: self class sourceArchiveMediaType) }
		  annotations: self annotations
]

{ #category : 'private' }
MooseNexusOciArtifactBundleBuilder >> copyModelPayload: aMooseNexusModelArtifact [

	| target |
	target := directory / ('model.' , aMooseNexusModelArtifact format).
	target ifExists: [ target delete ].
	project repositoryDirectory / aMooseNexusModelArtifact path copyTo: target.
	^ target
]

{ #category : 'initialization' }
MooseNexusOciArtifactBundleBuilder >> initializeProject: aMooseNexusProject manifest: aMooseNexusModelArtifactManifest directory: aFileReference [

	project := aMooseNexusProject.
	manifest := aMooseNexusModelArtifactManifest.
	directory := aFileReference asFileReference
]

{ #category : 'private' }
MooseNexusOciArtifactBundleBuilder >> writeManifest [

	| manifestFile |
	manifestFile := directory / self class manifestFileName.
	manifestFile writeStreamDo: [ :stream | STON put: manifest asDictionary asJsonOnStream: stream ].
	^ manifestFile
]

{ #category : 'private' }
MooseNexusOciArtifactBundleBuilder >> writeProjectProperties [

	| propertiesFile |
	propertiesFile := directory / self class projectPropertiesFileName.
	propertiesFile writeStreamDo: [ :stream | project writePropertiesOn: stream ].
	^ propertiesFile
]
