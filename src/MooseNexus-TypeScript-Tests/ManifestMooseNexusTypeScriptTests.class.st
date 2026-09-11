"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestMooseNexusTypeScriptTests',
	#superclass : 'PackageManifest',
	#category : 'MooseNexus-TypeScript-Tests-Manifest',
	#package : 'MooseNexus-TypeScript-Tests',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestMooseNexusTypeScriptTests class >> formatter [

	^ ManifestBaselineOfMooseNexus formatter
]
