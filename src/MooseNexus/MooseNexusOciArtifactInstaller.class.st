"
I install a pulled MooseNexus OCI artifact bundle into a local MooseNexus repository.

I read the MooseNexus artifact manifest and recorded project properties from the pulled bundle directory, restore source and model payload files to the local repository layout, and return the restored MooseNexus project.
"
Class {
	#name : 'MooseNexusOciArtifactInstaller',
	#superclass : 'Object',
	#category : 'MooseNexus-Repository',
	#package : 'MooseNexus',
	#tag : 'Repository'
}

{ #category : 'private' }
MooseNexusOciArtifactInstaller >> copyModelPayloadFrom: bundleDirectory describedBy: aMooseNexusModelArtifactManifest to: projectDirectory [

	| modelArtifact sourceModelFile targetModelFile |
	modelArtifact := aMooseNexusModelArtifactManifest modelArtifact.
	sourceModelFile := bundleDirectory / ('model.' , modelArtifact format).
	sourceModelFile exists ifFalse: [
		Error signal: 'Cannot install pulled OCI artifact without model payload: ' , sourceModelFile pathString ].
	targetModelFile := projectDirectory / modelArtifact path.
	targetModelFile parent ensureCreateDirectory.
	sourceModelFile copyTo: targetModelFile
]

{ #category : 'private' }
MooseNexusOciArtifactInstaller >> extractSourcesFrom: bundleDirectory to: sourceDirectory [

	| sourceArchive archive |
	sourceArchive := bundleDirectory / MooseNexusOciArtifactBundleBuilder sourceArchiveFileName.
	sourceArchive exists ifFalse: [
		Error signal: 'Cannot install pulled OCI artifact without source archive: ' , sourceArchive pathString ].
	archive := ZipArchive new.
	archive readFrom: sourceArchive.
	archive extractAllTo: sourceDirectory
]

{ #category : 'installing' }
MooseNexusOciArtifactInstaller >> installBundleFrom: bundleDirectory in: aMooseNexusRepository [

	| sourceDirectory manifest projectProperties projectDirectory |
	sourceDirectory := bundleDirectory asFileReference.
	manifest := self manifestFrom: sourceDirectory.
	projectProperties := self projectPropertiesFrom: sourceDirectory.
	self validateManifest: manifest matchesProperties: projectProperties.
	projectDirectory := self projectDirectoryForProperties: projectProperties in: aMooseNexusRepository.
	projectDirectory ifExists: [ projectDirectory deleteAll ].
	(projectDirectory / 'metadata') ensureCreateDirectory.
	(projectDirectory / 'sources') ensureCreateDirectory.
	(projectDirectory / 'artifacts' / 'models') ensureCreateDirectory.
	self extractSourcesFrom: sourceDirectory to: projectDirectory / 'sources'.
	self copyModelPayloadFrom: sourceDirectory describedBy: manifest to: projectDirectory.
	projectDirectory / 'metadata' / 'properties.json' writeStreamDo: [ :stream | STON put: projectProperties asJsonOnStream: stream ].
	projectDirectory / 'metadata' / 'models.json' writeStreamDo: [ :stream |
		STON put: { manifest asDictionary } asJsonOnStream: stream ].
	^ MooseNexusProject fromNexusDirectory: projectDirectory
]

{ #category : 'private' }
MooseNexusOciArtifactInstaller >> manifestFrom: bundleDirectory [

	| manifestFile |
	manifestFile := bundleDirectory / MooseNexusOciArtifactBundleBuilder manifestFileName.
	manifestFile exists ifFalse: [
		Error signal: 'Cannot install pulled OCI artifact without MooseNexus manifest: ' , manifestFile pathString ].
	^ MooseNexusModelArtifactManifest fromDictionary: (manifestFile readStreamDo: [ :stream | STON fromStream: stream ])
]

{ #category : 'private' }
MooseNexusOciArtifactInstaller >> projectDirectoryForProperties: projectProperties in: aMooseNexusRepository [

	^ aMooseNexusRepository resolveDirectoryFor: (MooseNexusProjectSpec
			   coordinates: (MooseNexusCoordinates
					    group: (projectProperties at: #group)
					    name: (projectProperties at: #name)
					    version: (projectProperties at: #version))
			   sourceDirectory: FileLocator temp)
]

{ #category : 'private' }
MooseNexusOciArtifactInstaller >> projectPropertiesFrom: bundleDirectory [

	| propertiesFile |
	propertiesFile := bundleDirectory / MooseNexusOciArtifactBundleBuilder projectPropertiesFileName.
	propertiesFile exists ifFalse: [
		Error signal: 'Cannot install pulled OCI artifact without MooseNexus project properties: ' , propertiesFile pathString ].
	^ propertiesFile readStreamDo: [ :stream | STON fromStream: stream ]
]

{ #category : 'private' }
MooseNexusOciArtifactInstaller >> validateManifest: aMooseNexusModelArtifactManifest matchesProperties: projectProperties [

	| coordinates |
	coordinates := aMooseNexusModelArtifactManifest modelArtifact coordinates.
	((projectProperties at: #group) = coordinates group and: [
		 (projectProperties at: #name) = coordinates name and: [ (projectProperties at: #version) = coordinates version ] ]) ifFalse: [
		Error signal: 'Pulled OCI artifact manifest does not match project properties coordinates' ]
]
