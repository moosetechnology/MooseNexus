"
I merge a portable MooseNexus project directory into a local repository.

I preserve existing project sources and merge models and image artifacts by their recorded names. A conflicting artifact is rejected by default. Callers may explicitly force replacement of the recorded artifact with the same name.
"
Class {
	#name : 'MooseNexusProjectDirectoryInstaller',
	#superclass : 'Object',
	#category : 'MooseNexus',
	#package : 'MooseNexus'
}

{ #category : 'private' }
MooseNexusProjectDirectoryInstaller >> copyFile: sourceFile to: targetFile [

	sourceFile exists ifFalse: [ Error signal: 'Cannot install missing MooseNexus artifact payload: ' , sourceFile pathString ].
	targetFile parent ensureCreateDirectory.
	targetFile ifExists: [ targetFile delete ].
	sourceFile copyTo: targetFile
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

	shouldForce ifTrue: [
			targetImageDirectory ifExists: [ targetImageDirectory deleteAll ].
			targetImageDirectory ensureCreateDirectory.
			sourceImageDirectory copyAllTo: targetImageDirectory ]
]

{ #category : 'private' }
MooseNexusProjectDirectoryInstaller >> installModelManifest: incomingManifest from: incomingDirectory in: project force: shouldForce [

	| existingManifest modelArtifact |
	modelArtifact := incomingManifest modelArtifact.
	existingManifest := project modelManifestNamed: modelArtifact name.

	existingManifest ifNil: [
			self copyFile: incomingDirectory / modelArtifact path to: project repositoryDirectory / modelArtifact path.
			project addModelManifest: incomingManifest.
			^ self ].

	(shouldForce or: [ existingManifest hasSameMetadataAs: incomingManifest ]) ifFalse: [
		Error signal: 'Cannot merge MooseNexus model artifact with a different manifest: ' , modelArtifact name ].

	shouldForce ifFalse: [ ^ self ].

	self copyFile: incomingDirectory / modelArtifact path to: project repositoryDirectory / modelArtifact path.
	project replaceModelManifest: incomingManifest
]

{ #category : 'installing' }
MooseNexusProjectDirectoryInstaller >> installProjectDirectory: incomingDirectory in: aMooseNexusRepository [

	^ self installProjectDirectory: incomingDirectory in: aMooseNexusRepository force: false
]

{ #category : 'installing' }
MooseNexusProjectDirectoryInstaller >> installProjectDirectory: incomingDirectory in: aMooseNexusRepository force: shouldForce [

	| sourceDirectory projectProperties projectDirectory project |
	sourceDirectory := incomingDirectory asFileReference.
	projectProperties := self projectPropertiesFrom: sourceDirectory.
	projectDirectory := self projectDirectoryForProperties: projectProperties in: aMooseNexusRepository.

	projectDirectory exists ifFalse: [
			projectDirectory ensureCreateDirectory.
			sourceDirectory copyAllTo: projectDirectory.
			^ MooseNexusProject fromNexusDirectory: projectDirectory inBackend: aMooseNexusRepository localProjectBackend ].

	self validateProjectAt: projectDirectory matchesProperties: projectProperties in: aMooseNexusRepository.
	project := MooseNexusProject fromNexusDirectory: projectDirectory inBackend: aMooseNexusRepository localProjectBackend.

	self mergeProjectDirectory: sourceDirectory into: project force: shouldForce.
	^ project
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
MooseNexusProjectDirectoryInstaller >> validateProjectAt: projectDirectory matchesProperties: projectProperties in: aMooseNexusRepository [

	| project |
	project := MooseNexusProject fromNexusDirectory: projectDirectory inBackend: aMooseNexusRepository localProjectBackend.
	project properties = projectProperties ifFalse: [
		Error signal: 'Incoming MooseNexus project properties do not match the installed project' ]
]
