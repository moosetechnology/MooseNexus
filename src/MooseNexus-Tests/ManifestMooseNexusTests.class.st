"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestMooseNexusTests',
	#superclass : 'PackageManifest',
	#category : 'MooseNexus-Tests-Manifest',
	#package : 'MooseNexus-Tests',
	#tag : 'Manifest'
}

{ #category : 'formatting' }
ManifestMooseNexusTests class >> formatter [

	^ ManifestBaselineOfMooseNexus formatter
]
