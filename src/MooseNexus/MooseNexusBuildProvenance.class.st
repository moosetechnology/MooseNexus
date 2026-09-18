"
I describe the runtime and extractor configuration that produced a model artifact.

I am persisted in a model artifact manifest so a client can provision a known compatible runtime and inspect the selected model extractor. I derive runtime versions from the running image and receive extractor provenance from the configured model builder.
"
Class {
	#name : 'MooseNexusBuildProvenance',
	#superclass : 'Object',
	#instVars : [
		'mooseNexusVersion',
		'mooseVersion',
		'pharoVersion',
		'extractorProvenance'
	],
	#category : 'MooseNexus-Artifact',
	#package : 'MooseNexus',
	#tag : 'Artifact'
}

{ #category : 'instance creation' }
MooseNexusBuildProvenance class >> current [

	^ self
		  mooseNexusVersion: MooseNexusVersion current
		  mooseVersion: MooseVersion current versionNumber
		  pharoVersion: SystemVersion current major asString
]

{ #category : 'instance creation' }
MooseNexusBuildProvenance class >> fromDictionary: aDictionary [

	^ self
		  mooseNexusVersion: (aDictionary at: 'mooseNexusVersion')
		  mooseVersion: (aDictionary at: 'mooseVersion')
		  pharoVersion: (aDictionary at: 'pharoVersion')
		  extractorProvenance: (aDictionary
				   at: 'extractor'
				   ifPresent: [ :extractorDictionary | MooseNexusExtractorProvenance fromDictionary: extractorDictionary ]
				   ifAbsent: [ MooseNexusExtractorProvenance unknown ])
]

{ #category : 'instance creation' }
MooseNexusBuildProvenance class >> mooseNexusVersion: aMooseNexusVersion mooseVersion: aMooseVersion pharoVersion: aPharoVersion [

	^ self
		  mooseNexusVersion: aMooseNexusVersion
		  mooseVersion: aMooseVersion
		  pharoVersion: aPharoVersion
		  extractorProvenance: MooseNexusExtractorProvenance unknown
]

{ #category : 'instance creation' }
MooseNexusBuildProvenance class >> mooseNexusVersion: aMooseNexusVersion mooseVersion: aMooseVersion pharoVersion: aPharoVersion extractorProvenance: aMooseNexusExtractorProvenance [

	^ self new
		  initializeMooseNexusVersion: aMooseNexusVersion
		  mooseVersion: aMooseVersion
		  pharoVersion: aPharoVersion
		  extractorProvenance: aMooseNexusExtractorProvenance
]

{ #category : 'comparing' }
MooseNexusBuildProvenance >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].

	^ anObject mooseNexusVersion = mooseNexusVersion and: [
			  anObject mooseVersion = mooseVersion and: [
				  anObject pharoVersion = pharoVersion and: [ anObject extractorProvenance = extractorProvenance ] ] ]
]

{ #category : 'converting' }
MooseNexusBuildProvenance >> asDictionary [

	^ Dictionary new
		  add: 'mooseNexusVersion' -> mooseNexusVersion;
		  add: 'mooseVersion' -> mooseVersion;
		  add: 'pharoVersion' -> pharoVersion;
		  add: 'extractor' -> extractorProvenance asDictionary;
		  yourself
]

{ #category : 'accessing' }
MooseNexusBuildProvenance >> extractorProvenance [

	^ extractorProvenance
]

{ #category : 'comparing' }
MooseNexusBuildProvenance >> hash [

	^ mooseNexusVersion hash bitXor: (mooseVersion hash bitXor: (pharoVersion hash bitXor: extractorProvenance hash))
]

{ #category : 'initialization' }
MooseNexusBuildProvenance >> initializeMooseNexusVersion: aMooseNexusVersion mooseVersion: aMooseVersion pharoVersion: aPharoVersion extractorProvenance: aMooseNexusExtractorProvenance [

	super initialize.
	mooseNexusVersion := aMooseNexusVersion.
	mooseVersion := aMooseVersion.
	pharoVersion := aPharoVersion.
	extractorProvenance := aMooseNexusExtractorProvenance
]

{ #category : 'accessing' }
MooseNexusBuildProvenance >> mooseNexusVersion [

	^ mooseNexusVersion
]

{ #category : 'accessing' }
MooseNexusBuildProvenance >> mooseVersion [

	^ mooseVersion
]

{ #category : 'accessing' }
MooseNexusBuildProvenance >> pharoVersion [

	^ pharoVersion
]

{ #category : 'accessing' }
MooseNexusBuildProvenance >> withExtractorProvenance: aMooseNexusExtractorProvenance [

	^ self class
		  mooseNexusVersion: mooseNexusVersion
		  mooseVersion: mooseVersion
		  pharoVersion: pharoVersion
		  extractorProvenance: aMooseNexusExtractorProvenance
]
