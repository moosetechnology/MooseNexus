Class {
	#name : 'MooseNexusProjectVersionPolicyTest',
	#superclass : 'TestCase',
	#category : 'MooseNexus-Tests',
	#package : 'MooseNexus-Tests'
}

{ #category : 'helpers' }
MooseNexusProjectVersionPolicyTest >> importerWithProjectVersion: version [

	| importer project |
	project := MooseNexusMavenProject new.
	project projects: (Dictionary with: 'com.example' -> (Dictionary with: 'demo' -> (Dictionary with: #version -> version))).
	importer := MooseNexusMavenProjectImporter new.
	importer project: project.
	^ importer
]

{ #category : 'helpers' }
MooseNexusProjectVersionPolicyTest >> importerWithProjectWithoutVersion [

	| importer project |
	project := MooseNexusMavenProject new.
	project projects: (Dictionary with: 'com.example' -> (Dictionary with: 'demo' -> Dictionary new)).
	importer := MooseNexusMavenProjectImporter new.
	importer project: project.
	^ importer
]

{ #category : 'tests' }
MooseNexusProjectVersionPolicyTest >> testDetermineVersionAnswersDeclaredVersion [

	self assert: (self importerWithProjectVersion: '1.0.0') determineVersion equals: '1.0.0'
]

{ #category : 'tests' }
MooseNexusProjectVersionPolicyTest >> testDetermineVersionAnswersLiteralUnspecifiedVersion [

	self assert: (self importerWithProjectVersion: 'unspecified') determineVersion equals: 'unspecified'
]

{ #category : 'tests' }
MooseNexusProjectVersionPolicyTest >> testDetermineVersionFailsWhenVersionIsEmpty [

	self should: [ (self importerWithProjectVersion: '') determineVersion ] raise: Error
]

{ #category : 'tests' }
MooseNexusProjectVersionPolicyTest >> testDetermineVersionFailsWhenVersionIsMissing [

	self should: [ self importerWithProjectWithoutVersion determineVersion ] raise: Error
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
