"
I publish MooseNexus model artifact manifests as OCI artifact bundles.

I keep the client-side workflow explicit: build the bundle files locally, map MooseNexus artifact coordinates to a registry reference, then delegate the OCI transport to a pluggable transport object.
"
Class {
	#name : 'MooseNexusOciArtifactPublisher',
	#superclass : 'Object',
	#instVars : [
		'referenceMapper',
		'transport'
	],
	#category : 'MooseNexus-Repository',
	#package : 'MooseNexus',
	#tag : 'Repository'
}

{ #category : 'instance creation' }
MooseNexusOciArtifactPublisher class >> referenceMapper: aMooseNexusOciReferenceMapper transport: aMooseNexusOrasTransport [

	^ self new initializeReferenceMapper: aMooseNexusOciReferenceMapper transport: aMooseNexusOrasTransport
]

{ #category : 'initialization' }
MooseNexusOciArtifactPublisher >> initializeReferenceMapper: aMooseNexusOciReferenceMapper transport: aMooseNexusOrasTransport [

	referenceMapper := aMooseNexusOciReferenceMapper.
	transport := aMooseNexusOrasTransport
]

{ #category : 'publishing' }
MooseNexusOciArtifactPublisher >> publishManifest: aMooseNexusModelArtifactManifest of: aMooseNexusProject in: bundleDirectory [

	| bundle |
	bundle := (MooseNexusOciArtifactBundleBuilder
		           project: aMooseNexusProject
		           manifest: aMooseNexusModelArtifactManifest
		           directory: bundleDirectory) build.
	bundle reference: (referenceMapper referenceFor: aMooseNexusModelArtifactManifest modelArtifact artifactCoordinates).
	transport pushBundle: bundle.
	^ bundle
]

{ #category : 'accessing' }
MooseNexusOciArtifactPublisher >> referenceMapper [

	^ referenceMapper
]

{ #category : 'accessing' }
MooseNexusOciArtifactPublisher >> transport [

	^ transport
]
