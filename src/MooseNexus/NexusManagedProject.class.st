"
A project with managed dependencies, such as using Maven or Gradle.

My properties define the additional mapping:
```text
projects: <projects>
dependencies:
	- group:   <dependencyGroup>
	  name:    <dependencyName>
	  version: <dependencyVersion>
	  scope:   <dependencyScope>
	  type:    <dependencyType>
```
The home is the path to the home directory of the project manager (e.g. `~/.m2` is the default Maven home).
The dependencies contain additional mappings for their own group, artifact, and version, as well as their type and scope.
The type is the file format of the dependency (e.g. usually `jar` for Java).
The scope is the application lifecycle that requires the dependency (e.g. `compile` or `runtime`).

A managed project can encompass multiple projects and subprojects.
The `projects` property has the following mapping:
```text
<projectGroup>:
	<projectName>:
		version: <projectVersion>
		dependencies:
			<dependencyGroup>:
				- name:      <dependencyName>
				  version:   <dependencyVersion>
				  directory: <localPath>
```
"
Class {
	#name : 'NexusManagedProject',
	#superclass : 'NexusProject',
	#instVars : [
		'projects',
		'language'
	],
	#category : 'MooseNexus-Project',
	#package : 'MooseNexus',
	#tag : 'Project'
}

{ #category : 'testing' }
NexusManagedProject class >> isAbstract [

	^ self == NexusManagedProject
]

{ #category : 'known names' }
NexusManagedProject class >> knownLanguages [

	^ #( java )
]

{ #category : 'querying' }
NexusManagedProject >> determineGroup [

	projects size == 1 ifFalse: [
		Error signal: 'Can only determine group if only one is declared' ].
	projects keysDo: [ :key | ^ key ]
]

{ #category : 'querying' }
NexusManagedProject >> determineLanguage [

	| knownLanguages candidates sourceDirectory |
	knownLanguages := self class knownLanguages.
	(projects isEmpty or: [ projects anyOne isEmpty ]) ifTrue: [
		Error signal: 'Cannot determine language without any project' ].
	candidates := Set new.
	sourceDirectory := self projectSourceDirectory.

	"check if this project directory has sources"
	sourceDirectory / 'src/main' ifExists: [ :mainDirectory |
		knownLanguages do: [ :lang |
			mainDirectory / lang ifExists: [ candidates add: lang ] ] ].

	"check the sources of each project"
	projects do: [ :projectGroup |
		projectGroup keysDo: [ :projectName |
			sourceDirectory / projectName ifExists: [ :projectDirectory |
				projectDirectory / 'src/main' ifExists: [ :mainDirectory |
					knownLanguages do: [ :lang |
						mainDirectory / lang ifExists: [ candidates add: lang ] ] ] ] ] ].

	candidates ifEmpty: [
		Error signal: 'Could not determine language automatically' ].
	candidates size == 1 ifFalse: [
		Warning signal: (String streamContents: [ :s |
				 s << 'Multiple languages detected: `'.
				 candidates
					 do: [ :candidate | s << candidate ]
					 separatedBy: [ s << ', ' ].
				 s << '`, proceed to choose the first one' ]) ].
	^ candidates anyOne
]

{ #category : 'querying' }
NexusManagedProject >> determineName [

	(projects size == 1 and: [ projects anyOne size == 1 ]) ifFalse: [
		Error signal: 'Can only determine name if only one is declared' ].
	projects anyOne keysDo: [ :key | ^ key ]
]

{ #category : 'querying' }
NexusManagedProject >> determineVersion [

	| theVersion |
	(projects isNotEmpty and: [ projects anyOne isNotEmpty ]) ifFalse: [
		Error signal:
			'Cannot determine version because there are no managed projects' ].
	"verify all managed projects declare the same version"
	theVersion := projects anyOne anyOne at: #version.
	projects do: [ :projectGroup |
		projectGroup do: [ :descriptor |
			(descriptor at: #version) = theVersion ifFalse: [
				Error signal:
					'Can only determine version if all managed projects declare the same one' ] ] ].
	^ theVersion
]

{ #category : 'testing' }
NexusManagedProject >> isGradleProject [

	^ false
]

{ #category : 'testing' }
NexusManagedProject >> isManagedProject [

	^ true
]

{ #category : 'testing' }
NexusManagedProject >> isMavenProject [

	^ false
]

{ #category : 'accessing' }
NexusManagedProject >> language [
	"Build automation tools are language-agnostic, so it has to be determined."

	^ language ifNil: [ language := self determineLanguage ]
]

{ #category : 'accessing' }
NexusManagedProject >> language: aString [

	language := aString
]

{ #category : 'enumerating' }
NexusManagedProject >> projectDependenciesDo: aBlock [
	"Iterate over the group, name and descriptor of all project dependencies"

	self projects do: [ :projectGroup |
		projectGroup do: [ :projectDescriptor |
			(projectDescriptor at: #dependencies) keysAndValuesDo: [
				:dependencyGroup
				:descriptors |
				descriptors do: [ :descriptor |
					aBlock value: dependencyGroup value: descriptor ] ] ] ]
]

{ #category : 'accessing' }
NexusManagedProject >> projects [
	"Returns the dictionary of the projects that were analyzed.
	See the class comment for the mapping."

	^ projects ifNil: [ projects := Dictionary new ]
]

{ #category : 'accessing' }
NexusManagedProject >> projects: aDictionary [
	"This should only be handled by the internal API"

	projects := aDictionary
]

{ #category : 'enumerating' }
NexusManagedProject >> properties [

	^ super properties
		  add: #projects -> self projects;
		  yourself
]
