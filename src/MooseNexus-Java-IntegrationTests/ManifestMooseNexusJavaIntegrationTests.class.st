"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestMooseNexusJavaIntegrationTests',
	#superclass : 'PackageManifest',
	#category : 'MooseNexus-Java-IntegrationTests-Manifest',
	#package : 'MooseNexus-Java-IntegrationTests',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestMooseNexusJavaIntegrationTests class >> formatter [

	^ ManifestBaselineOfMooseNexus formatter
]

{ #category : 'code-critics' }
ManifestMooseNexusJavaIntegrationTests class >> ruleReTestClassNotInPackageWithTestEndingNameRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #( #( #( #RGPackageDefinition #( #'MooseNexus-Java-IntegrationTests' ) )
	        #'2026-09-11T00:00:00+00:00' ) )
]
