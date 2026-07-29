Class {
	#name : 'MooseNexusProjectVersionPolicyTest',
	#superclass : 'TestCase',
	#category : 'MooseNexus-Tests',
	#package : 'MooseNexus-Tests'
}

{ #category : 'helpers' }
MooseNexusProjectVersionPolicyTest >> projectWithVersion: version [

	| project |
	project := MooseNexusMavenProject new.
	project projects: (Dictionary with: 'com.example' -> (Dictionary with: 'demo' -> (Dictionary with: #version -> version))).
	^ project
]

{ #category : 'helpers' }
MooseNexusProjectVersionPolicyTest >> projectWithoutVersion [

	| project |
	project := MooseNexusMavenProject new.
	project projects: (Dictionary with: 'com.example' -> (Dictionary with: 'demo' -> Dictionary new)).
	^ project
]

{ #category : 'tests' }
MooseNexusProjectVersionPolicyTest >> testDetermineVersionAnswersDeclaredVersion [

	self assert: (self projectWithVersion: '1.0.0') determineVersion equals: '1.0.0'
]

{ #category : 'tests' }
MooseNexusProjectVersionPolicyTest >> testDetermineVersionAnswersLiteralUnspecifiedVersion [

	self assert: (self projectWithVersion: 'unspecified') determineVersion equals: 'unspecified'
]

{ #category : 'tests' }
MooseNexusProjectVersionPolicyTest >> testDetermineVersionFailsWhenVersionIsEmpty [

	self should: [ (self projectWithVersion: '') determineVersion ] raise: Error
]

{ #category : 'tests' }
MooseNexusProjectVersionPolicyTest >> testDetermineVersionFailsWhenVersionIsMissing [

	self should: [ self projectWithoutVersion determineVersion ] raise: Error
]

{ #category : 'tests' }
MooseNexusProjectVersionPolicyTest >> testGradleImporterRejectsUnspecifiedProjectVersion [

	| importer |
	importer := MooseNexusGradleProjectImporter new.
	importer project: MooseNexusGradleProject new.

	self
		should: [
				importer parse: 'header
> Task :mooseNexusListDependencies
-com.example:demo:unspecified
.
' ]
		raise: Error
]
