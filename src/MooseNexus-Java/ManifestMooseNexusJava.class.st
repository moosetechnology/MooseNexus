"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestMooseNexusJava',
	#superclass : 'PackageManifest',
	#category : 'MooseNexus-Java-Manifest',
	#package : 'MooseNexus-Java',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestMooseNexusJava class >> formatter [

	^ ManifestBaselineOfMooseNexus formatter
]

{ #category : 'code-critics' }
ManifestMooseNexusJava class >> ruleMissingSubclassResponsibilityRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #( #( #( #RGPackageDefinition #( #'MooseNexus-Java' ) ) #'2026-09-11T00:00:00+00:00' ) )
]
