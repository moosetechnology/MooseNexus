"
I merge a portable MooseNexus project directory into a local repository.

I preserve existing project sources and merge models and image artifacts by their recorded names. A conflicting artifact is rejected by default. Callers may explicitly force replacement of the recorded artifact with the same name.
"
Class {
	#name : 'MooseNexusProjectDirectoryInstaller',
	#superclass : 'Object',
	#category : 'MooseNexus-Repository',
	#package : 'MooseNexus',
	#tag : 'Repository'
}

{ #category : 'private' }
MooseNexusProjectDirectoryInstaller >> backupDirectoryFor: projectDirectory [

	^ projectDirectory parent / ('.moosenexus-backup-' , UUID new asString)
]

{ #category : 'private' }
MooseNexusProjectDirectoryInstaller >> copyFile: sourceFile to: targetFile [

	sourceFile exists ifFalse: [ Error signal: 'Cannot install missing MooseNexus artifact payload: ' , sourceFile pathString ].
	targetFile parent ensureCreateDirectory.
	targetFile ifExists: [ targetFile delete ].
	sourceFile copyTo: targetFile
]

{ #category : 'private' }
MooseNexusProjectDirectoryInstaller >> deleteTree: directory [

	self makeWritableRecursively: directory.
	directory deleteAll
]

{ #category : 'private' }
MooseNexusProjectDirectoryInstaller >> hasInstalledArtifactsFrom: incomingDirectory in: project [

	((self modelManifestsFrom: incomingDirectory) allSatisfy: [ :incomingManifest |
			 | existingManifest |
			 existingManifest := project modelManifestNamed: incomingManifest modelArtifact name.
			 existingManifest notNil and: [ existingManifest hasSameMetadataAs: incomingManifest ] ]) ifFalse: [ ^ false ].

	^ (self imageArtifactsFrom: incomingDirectory) allSatisfy: [ :incomingArtifact |
		  project imageArtifacts anySatisfy: [ :existingArtifact | existingArtifact = incomingArtifact ] ]
]

{ #category : 'private' }
MooseNexusProjectDirectoryInstaller >> imageArtifactsFrom: projectDirectory [

	| imagesFile |
	imagesFile := projectDirectory / 'metadata' / 'images.json'.
	imagesFile exists ifFalse: [ ^ #(  ) ].
	^ imagesFile readStreamDo: [ :stream |
		  (STON fromStream: stream) collect: [ :dictionary | MooseNexusImageArtifact fromDictionary: dictionary ] ]
]

{ #category : 'private' }
MooseNexusProjectDirectoryInstaller >> installImageArtifact: incomingArtifact from: incomingDirectory in: project force: shouldForce [

	| existingArtifact sourceImageDirectory targetImageDirectory |
	sourceImageDirectory := incomingDirectory / 'artifacts' / 'images' / incomingArtifact name.
	sourceImageDirectory exists ifFalse: [
		Error signal: 'Cannot install missing MooseNexus image artifact: ' , sourceImageDirectory pathString ].

	targetImageDirectory := project imageArtifactsDirectory / incomingArtifact name.
	existingArtifact := project imageArtifacts detect: [ :artifact | artifact name = incomingArtifact name ] ifNone: [ nil ].

	existingArtifact ifNil: [
			targetImageDirectory ensureCreateDirectory.
			sourceImageDirectory copyAllTo: targetImageDirectory.
			project addImageArtifact: incomingArtifact.
			^ self ].

	existingArtifact = incomingArtifact ifFalse: [
		Error signal: 'Cannot merge MooseNexus image artifact with a different model artifact: ' , incomingArtifact name ].

	shouldForce ifFalse: [ ^ self ].
	targetImageDirectory ifExists: [ :directory | self deleteTree: directory ].
	targetImageDirectory ensureCreateDirectory.
	sourceImageDirectory copyAllTo: targetImageDirectory
]

{ #category : 'private' }
MooseNexusProjectDirectoryInstaller >> installModelManifest: incomingManifest from: incomingDirectory in: project force: shouldForce [

	| existingManifest modelArtifact incomingModelFile targetModelFile |
	modelArtifact := incomingManifest modelArtifact.
	incomingModelFile := incomingDirectory / modelArtifact path.
	targetModelFile := modelArtifact fileReferenceIn: project.
	existingManifest := project modelManifestNamed: modelArtifact name.

	existingManifest ifNil: [
			self copyFile: incomingModelFile to: targetModelFile.
			project addModelManifest: incomingManifest.
			^ self ].

	(shouldForce or: [ existingManifest hasSameMetadataAs: incomingManifest ]) ifFalse: [
		Error signal: 'Cannot merge MooseNexus model artifact with a different manifest: ' , modelArtifact name ].

	shouldForce ifFalse: [ ^ self ].
	self copyFile: incomingModelFile to: targetModelFile.
	project replaceModelManifest: incomingManifest
]

{ #category : 'installing' }
MooseNexusProjectDirectoryInstaller >> installProjectDirectory: incomingDirectory in: aMooseNexusRepository [

	^ self installProjectDirectory: incomingDirectory in: aMooseNexusRepository force: false
]

{ #category : 'installing' }
MooseNexusProjectDirectoryInstaller >> installProjectDirectory: incomingDirectory in: aMooseNexusRepository force: shouldForce [

	| sourceDirectory projectProperties projectDirectory stagedDirectory stagingDirectoryPath stagedProject hasExistingProject |
	sourceDirectory := incomingDirectory asFileReference.
	projectProperties := self projectPropertiesFrom: sourceDirectory.
	self validateProjectDirectory: sourceDirectory.

	projectDirectory := self projectDirectoryForProperties: projectProperties in: aMooseNexusRepository.
	hasExistingProject := projectDirectory exists.
	hasExistingProject ifTrue: [
			self validateProjectAt: projectDirectory matchesProperties: projectProperties in: aMooseNexusRepository.
			stagedProject := MooseNexusProject fromNexusDirectory: projectDirectory inBackend: aMooseNexusRepository localProjectBackend.
			(shouldForce not and: [ self hasInstalledArtifactsFrom: sourceDirectory in: stagedProject ]) ifTrue: [ ^ stagedProject ] ].

	stagedDirectory := self stagingDirectoryFor: projectDirectory.
	stagingDirectoryPath := stagedDirectory pathString.
	[
		(hasExistingProject
			 ifTrue: [ projectDirectory ]
			 ifFalse: [ sourceDirectory ]) copyAllTo: stagedDirectory.

		hasExistingProject ifTrue: [
				stagedProject := MooseNexusProject fromNexusDirectory: stagedDirectory inBackend: aMooseNexusRepository localProjectBackend.
				self mergeProjectDirectory: sourceDirectory into: stagedProject force: shouldForce ].

		self replaceProjectDirectory: projectDirectory with: stagedDirectory ] ensure: [
		stagingDirectoryPath asFileReference ifExists: [ :directory | self deleteTree: directory ] ].

	^ MooseNexusProject fromNexusDirectory: projectDirectory inBackend: aMooseNexusRepository localProjectBackend
]

{ #category : 'private' }
MooseNexusProjectDirectoryInstaller >> makeWritableRecursively: fileReference [

	fileReference permissions: (FileSystemPermission posixPermissions: 8r700).
	fileReference isDirectory ifTrue: [ fileReference children do: [ :child | self makeWritableRecursively: child ] ]
]

{ #category : 'private' }
MooseNexusProjectDirectoryInstaller >> mergeProjectDirectory: incomingDirectory into: project force: shouldForce [

	(self modelManifestsFrom: incomingDirectory) do: [ :manifest |
			self
				installModelManifest: manifest
				from: incomingDirectory
				in: project
				force: shouldForce ].
	(self imageArtifactsFrom: incomingDirectory) do: [ :imageArtifact |
			self
				installImageArtifact: imageArtifact
				from: incomingDirectory
				in: project
				force: shouldForce ]
]

{ #category : 'private' }
MooseNexusProjectDirectoryInstaller >> modelManifestsFrom: projectDirectory [

	| modelsFile |
	modelsFile := projectDirectory / 'metadata' / 'models.json'.
	modelsFile exists ifFalse: [ Error signal: 'Cannot install MooseNexus project without model metadata: ' , modelsFile pathString ].
	^ modelsFile readStreamDo: [ :stream |
		  (STON fromStream: stream) collect: [ :dictionary | MooseNexusModelArtifactManifest fromDictionary: dictionary ] ]
]

{ #category : 'private' }
MooseNexusProjectDirectoryInstaller >> projectDirectoryForProperties: projectProperties in: aMooseNexusRepository [

	^ aMooseNexusRepository resolveDirectoryFor: (MooseNexusProjectSpec
			   coordinates: (MooseNexusCoordinates
					    group: (projectProperties at: #group)
					    name: (projectProperties at: #name)
					    version: (projectProperties at: #version))
			   sourceDirectory: FileLocator temp)
]

{ #category : 'private' }
MooseNexusProjectDirectoryInstaller >> projectPropertiesFrom: projectDirectory [

	| propertiesFile |
	propertiesFile := projectDirectory / 'metadata' / 'properties.json'.
	propertiesFile exists ifFalse: [
		Error signal: 'Cannot install MooseNexus project without project properties: ' , propertiesFile pathString ].
	^ propertiesFile readStreamDo: [ :stream | STON fromStream: stream ]
]

{ #category : 'private' }
MooseNexusProjectDirectoryInstaller >> replaceProjectDirectory: projectDirectory with: stagedDirectory [

	| backupDirectoryPath projectDirectoryPath stagedDirectoryPath |
	projectDirectoryPath := projectDirectory pathString.
	stagedDirectoryPath := stagedDirectory pathString.

	projectDirectoryPath asFileReference exists ifFalse: [
			stagedDirectoryPath asFileReference moveTo: projectDirectoryPath asFileReference.
			^ self ].

	backupDirectoryPath := (self backupDirectoryFor: projectDirectoryPath asFileReference) pathString.
	projectDirectoryPath asFileReference moveTo: backupDirectoryPath asFileReference.
	[ stagedDirectoryPath asFileReference moveTo: projectDirectoryPath asFileReference ]
		on: Error
		do: [ :error |
				backupDirectoryPath asFileReference moveTo: projectDirectoryPath asFileReference.
				error pass ].
	self deleteTree: backupDirectoryPath asFileReference
]

{ #category : 'private' }
MooseNexusProjectDirectoryInstaller >> stagingDirectoryFor: projectDirectory [

	| stagingDirectory |
	projectDirectory parent ensureCreateDirectory.
	stagingDirectory := projectDirectory parent / ('.moosenexus-install-' , UUID new asString).
	stagingDirectory ensureCreateDirectory.
	^ stagingDirectory
]

{ #category : 'private' }
MooseNexusProjectDirectoryInstaller >> validateProjectAt: projectDirectory matchesProperties: projectProperties in: aMooseNexusRepository [

	| project |
	project := MooseNexusProject fromNexusDirectory: projectDirectory inBackend: aMooseNexusRepository localProjectBackend.
	project properties = projectProperties ifFalse: [
		Error signal: 'Incoming MooseNexus project properties do not match the installed project' ]
]

{ #category : 'private' }
MooseNexusProjectDirectoryInstaller >> validateProjectDirectory: projectDirectory [

	(self modelManifestsFrom: projectDirectory) do: [ :manifest | manifest validateGeneratedFilesIn: projectDirectory ]
]
