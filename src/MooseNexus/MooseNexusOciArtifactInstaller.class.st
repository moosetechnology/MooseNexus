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
	targetModelFile ifExists: [ targetModelFile delete ].

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

{ #category : 'private' }
MooseNexusOciArtifactInstaller >> initializeProjectDirectory: projectDirectory from: bundleDirectory properties: projectProperties [

	(projectDirectory / 'metadata') ensureCreateDirectory.
	(projectDirectory / 'sources') ensureCreateDirectory.
	(projectDirectory / 'artifacts' / 'models') ensureCreateDirectory.
	self extractSourcesFrom: bundleDirectory to: projectDirectory / 'sources'.
	projectDirectory / 'metadata' / 'properties.json' writeStreamDo: [ :stream | STON put: projectProperties asJsonOnStream: stream ].
	projectDirectory / 'metadata' / 'models.json' writeStreamDo: [ :stream | stream nextPutAll: '[]' ]
]

{ #category : 'installing' }
MooseNexusOciArtifactInstaller >> installBundleFrom: bundleDirectory in: aMooseNexusRepository [

	^ self installBundleFrom: bundleDirectory in: aMooseNexusRepository force: false
]

{ #category : 'installing' }
MooseNexusOciArtifactInstaller >> installBundleFrom: bundleDirectory in: aMooseNexusRepository force: shouldForce [

	| sourceDirectory manifest projectProperties projectDirectory project |
	sourceDirectory := bundleDirectory asFileReference.
	manifest := self manifestFrom: sourceDirectory.
	projectProperties := self projectPropertiesFrom: sourceDirectory.
	self validateManifest: manifest matchesProperties: projectProperties.
	projectDirectory := self projectDirectoryForProperties: projectProperties in: aMooseNexusRepository.

	projectDirectory exists
		ifTrue: [ self validateProjectAt: projectDirectory matchesProperties: projectProperties in: aMooseNexusRepository ]
		ifFalse: [ self initializeProjectDirectory: projectDirectory from: sourceDirectory properties: projectProperties ].
	project := MooseNexusProject fromNexusDirectory: projectDirectory inBackend: aMooseNexusRepository localProjectBackend.

	self
		installManifest: manifest
		from: sourceDirectory
		in: project
		force: shouldForce.
	^ project
]

{ #category : 'private' }
MooseNexusOciArtifactInstaller >> installManifest: incomingManifest from: bundleDirectory in: project force: shouldForce [

	| existingManifest |
	existingManifest := project modelManifestNamed: incomingManifest modelArtifact name.

	existingManifest ifNil: [
			self copyModelPayloadFrom: bundleDirectory describedBy: incomingManifest to: project repositoryDirectory.
			project addModelManifest: incomingManifest.
			^ self ].

	((existingManifest hasSameMetadataAs: incomingManifest) or: [ shouldForce ]) ifFalse: [
		Error signal: 'Cannot merge pulled MooseNexus model artifact with a different manifest: ' , incomingManifest modelArtifact name ].

	shouldForce ifFalse: [ ^ self ].

	self copyModelPayloadFrom: bundleDirectory describedBy: incomingManifest to: project repositoryDirectory.
	project replaceModelManifest: incomingManifest
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

{ #category : 'private' }
MooseNexusOciArtifactInstaller >> validateProjectAt: projectDirectory matchesProperties: projectProperties in: aMooseNexusRepository [

	| project |
	project := MooseNexusProject fromNexusDirectory: projectDirectory inBackend: aMooseNexusRepository localProjectBackend.
	project properties = projectProperties ifFalse: [
		Error signal: 'Pulled OCI artifact project properties do not match the installed project' ]
]
