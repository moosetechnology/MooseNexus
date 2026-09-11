"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestMooseNexusIntegrationTests',
	#superclass : 'PackageManifest',
	#category : 'MooseNexus-IntegrationTests-Manifest',
	#package : 'MooseNexus-IntegrationTests',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestMooseNexusIntegrationTests class >> formatter [

	^ ManifestBaselineOfMooseNexus formatter
]
