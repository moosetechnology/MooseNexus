"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestMooseNexusTypeScriptIntegrationTests',
	#superclass : 'PackageManifest',
	#category : 'MooseNexus-TypeScript-IntegrationTests-Manifest',
	#package : 'MooseNexus-TypeScript-IntegrationTests',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestMooseNexusTypeScriptIntegrationTests class >> formatter [

	^ ManifestBaselineOfMooseNexus formatter
]

{ #category : 'code-critics' }
ManifestMooseNexusTypeScriptIntegrationTests class >> ruleReTestClassNotInPackageWithTestEndingNameRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #( #( #( #RGPackageDefinition #( #'MooseNexus-TypeScript-IntegrationTests' ) )
	        #'2026-09-11T00:00:00+00:00' ) )
]
