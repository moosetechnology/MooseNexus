"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestMooseNexusTestResources',
	#superclass : 'PackageManifest',
	#category : 'MooseNexus-TestResources-Manifest',
	#package : 'MooseNexus-TestResources',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestMooseNexusTestResources class >> formatter [

	^ ManifestBaselineOfMooseNexus formatter
]
