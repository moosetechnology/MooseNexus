"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestMooseNexusTypeScript',
	#superclass : 'PackageManifest',
	#category : 'MooseNexus-TypeScript-Manifest',
	#package : 'MooseNexus-TypeScript',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestMooseNexusTypeScript class >> formatter [

	^ ManifestBaselineOfMooseNexus formatter
]
