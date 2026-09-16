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

	^ self installBundleFrom: bundleDirectory in: aMooseNexusRepository force: false
]

{ #category : 'installing' }
MooseNexusOciArtifactInstaller >> installBundleFrom: bundleDirectory in: aMooseNexusRepository force: shouldForce [

	| sourceDirectory manifest projectProperties stagedProjectDirectory |
	sourceDirectory := bundleDirectory asFileReference.
	manifest := self manifestFrom: sourceDirectory.
	projectProperties := self projectPropertiesFrom: sourceDirectory.
	self validateManifest: manifest matchesProperties: projectProperties.

	stagedProjectDirectory := self materializeProjectFrom: sourceDirectory manifest: manifest properties: projectProperties.
	^ [
		  MooseNexusProjectDirectoryInstaller new
			  installProjectDirectory: stagedProjectDirectory
			  in: aMooseNexusRepository
			  force: shouldForce ] ensure: [ stagedProjectDirectory exists ifTrue: [ stagedProjectDirectory deleteAll ] ]
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
MooseNexusOciArtifactInstaller >> materializeProjectFrom: bundleDirectory manifest: manifest properties: projectProperties [

	| projectDirectory modelFile modelTargetFile |
	projectDirectory := FileLocator temp / ('moosenexus-oci-install-' , UUID new asString).
	projectDirectory ensureCreateDirectory.

	^ [
		  self extractSourcesFrom: bundleDirectory to: projectDirectory / 'sources'.

		  (projectDirectory / 'metadata') ensureCreateDirectory.
		  projectDirectory / 'metadata' / 'properties.json' writeStreamDo: [ :stream |
			  STON put: projectProperties asJsonOnStream: stream ].
		  projectDirectory / 'metadata' / 'models.json' writeStreamDo: [ :stream |
			  STON put: { manifest asDictionary } asJsonOnStream: stream ].

		  modelFile := bundleDirectory / ('model.' , manifest modelArtifact format).
		  manifest validateModelPayload: modelFile.
		  modelTargetFile := projectDirectory / manifest modelArtifact path.
		  modelTargetFile parent ensureCreateDirectory.
		  modelFile copyTo: modelTargetFile.

		  projectDirectory ]
		  on: Error
		  do: [ :error |
				  projectDirectory deleteAll.
				  error pass ]
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
