"
I aggregate language-detection evidence for one source tree.

I answer a language only when exactly one language has evidence. Empty and ambiguous results signal clear errors rather than silently selecting an arbitrary candidate.
"
Class {
	#name : 'MooseNexusLanguageDetectionResult',
	#superclass : 'Object',
	#instVars : [
		'evidenceByLanguage'
	],
	#category : 'MooseNexus-Project',
	#package : 'MooseNexus',
	#tag : 'Project'
}

{ #category : 'instance creation' }
MooseNexusLanguageDetectionResult class >> evidenceByLanguage: aDictionary [

	^ self new initializeEvidenceByLanguage: aDictionary
]

{ #category : 'instance creation' }
MooseNexusLanguageDetectionResult class >> fromDirectory: aDirectory [

	| evidence |
	evidence := OrderedDictionary new.
	MooseNexusLanguageDetector allDetectors do: [ :detector |
			| detectorEvidence |
			detectorEvidence := detector evidenceIn: aDirectory.
			detectorEvidence ifNotEmpty: [ evidence at: detector language put: detectorEvidence ] ].
	^ self evidenceByLanguage: evidence
]

{ #category : 'accessing' }
MooseNexusLanguageDetectionResult >> evidenceByLanguage [

	^ evidenceByLanguage copy
]

{ #category : 'accessing' }
MooseNexusLanguageDetectionResult >> evidenceForLanguage: aLanguage [

	^ evidenceByLanguage at: aLanguage ifAbsent: [ #(  ) ]
]

{ #category : 'initialization' }
MooseNexusLanguageDetectionResult >> initializeEvidenceByLanguage: aDictionary [

	evidenceByLanguage := aDictionary copy
]

{ #category : 'testing' }
MooseNexusLanguageDetectionResult >> isAmbiguous [

	^ self languages size > 1
]

{ #category : 'testing' }
MooseNexusLanguageDetectionResult >> isEmpty [

	^ evidenceByLanguage isEmpty
]

{ #category : 'querying' }
MooseNexusLanguageDetectionResult >> language [

	self isEmpty ifTrue: [ Error signal: 'Could not determine language automatically' ].
	self isAmbiguous ifTrue: [
			Error signal: (String streamContents: [ :stream |
						 stream
							 << 'Multiple languages detected: ';
							 << (', ' join: self languages);
							 << '. Configure MooseNexusBuildSpec language explicitly.' ]) ].
	^ self languages anyOne
]

{ #category : 'accessing' }
MooseNexusLanguageDetectionResult >> languages [

	^ evidenceByLanguage keys asArray sorted
]
