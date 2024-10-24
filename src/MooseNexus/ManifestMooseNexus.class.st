"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestMooseNexus',
	#superclass : 'PackageManifest',
	#category : 'MooseNexus-Manifest',
	#package : 'MooseNexus',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestMooseNexus class >> ruleLongMethodsRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#MooseNexus)) #'2024-10-24T0:0:0+00:00') )
]
