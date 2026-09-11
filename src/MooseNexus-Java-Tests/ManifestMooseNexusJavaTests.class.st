"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestMooseNexusJavaTests',
	#superclass : 'PackageManifest',
	#category : 'MooseNexus-Java-Tests-Manifest',
	#package : 'MooseNexus-Java-Tests',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestMooseNexusJavaTests class >> formatter [

	^ ManifestBaselineOfMooseNexus formatter
]
