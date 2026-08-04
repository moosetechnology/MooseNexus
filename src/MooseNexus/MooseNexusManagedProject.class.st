"
A project with managed dependencies, such as one using Maven or Gradle.

My properties define the additional mapping:
```text
projects: <projects>
```
A managed project can encompass multiple projects and subprojects.
The `projects` property has the following mapping:
```text
<projectGroup>:
	<projectName>:
		version: <projectVersion>
		dependencyGraph:
			dependencies:
				- group:   <dependencyGroup>
				  name:    <dependencyName>
				  version: <dependencyVersion>
				  scopes:  <dependencyScopes>
				  type:    <dependencyType>
				  path:    <localPath>
```
Managed project dependency graphs preserve the declarations read from the external build tool. The inherited `resolvedDependencies` property records the flattened dependencies selected for the MooseNexus build.
"
Class {
	#name : 'MooseNexusManagedProject',
	#superclass : 'MooseNexusProject',
	#instVars : [
		'projects',
		'language'
	],
	#category : 'MooseNexus-Project',
	#package : 'MooseNexus',
	#tag : 'Project'
}

{ #category : 'testing' }
MooseNexusManagedProject class >> isAbstract [

	^ self == MooseNexusManagedProject
]

{ #category : 'known names' }
MooseNexusManagedProject class >> knownLanguages [

	^ #( java )
]

{ #category : 'querying' }
MooseNexusManagedProject >> determineLanguage [

	| knownLanguages candidates sourceDirectory |
	knownLanguages := self class knownLanguages.
	(projects isEmpty or: [ projects anyOne isEmpty ]) ifTrue: [ Error signal: 'Cannot determine language without any project' ].
	candidates := Set new.
	sourceDirectory := self projectSourceDirectory.

	"check if this project directory has sources"
	sourceDirectory / 'src/main' ifExists: [ :mainDirectory |
		knownLanguages do: [ :lang | mainDirectory / lang ifExists: [ candidates add: lang ] ] ].

	"check the sources of each project"
	projects do: [ :projectGroup |
			projectGroup keysDo: [ :projectName |
					sourceDirectory / projectName ifExists: [ :projectDirectory |
							projectDirectory / 'src/main' ifExists: [ :mainDirectory |
								knownLanguages do: [ :lang | mainDirectory / lang ifExists: [ candidates add: lang ] ] ] ] ] ].

	candidates ifEmpty: [ Error signal: 'Could not determine language automatically' ].
	candidates size == 1 ifFalse: [
			Warning signal: (String streamContents: [ :s |
						 s << 'Multiple languages detected: `'.
						 candidates do: [ :candidate | s << candidate ] separatedBy: [ s << ', ' ].
						 s << '`, proceed to choose the first one' ]) ].
	^ candidates anyOne
]

{ #category : 'testing' }
MooseNexusManagedProject >> isGradleProject [

	^ false
]

{ #category : 'testing' }
MooseNexusManagedProject >> isManagedProject [

	^ true
]

{ #category : 'testing' }
MooseNexusManagedProject >> isMavenProject [

	^ false
]

{ #category : 'accessing' }
MooseNexusManagedProject >> language [
	"Build automation tools are language-agnostic, so it has to be determined."

	^ language ifNil: [ language := self determineLanguage ]
]

{ #category : 'accessing' }
MooseNexusManagedProject >> language: aString [

	language := aString
]

{ #category : 'enumerating' }
MooseNexusManagedProject >> projectDependenciesDo: aBlock [
	"Iterate over dependency descriptors declared by managed projects."

	self projects do: [ :projectGroup |
			projectGroup do: [ :projectDescriptor |
				projectDescriptor dependencyGraph do: [ :descriptor | aBlock value: descriptor group value: descriptor ] ] ]
]

{ #category : 'properties' }
MooseNexusManagedProject >> projectDescriptorFromProperties: projectDescriptor [

	^ MooseNexusManagedProjectDescriptor fromDictionary: projectDescriptor
]

{ #category : 'accessing' }
MooseNexusManagedProject >> projects [
	"Returns the dictionary of the projects that were analyzed.
	See the class comment for the mapping."

	^ projects ifNil: [ projects := Dictionary new ]
]

{ #category : 'accessing' }
MooseNexusManagedProject >> projects: aDictionary [
	"This should only be handled by the internal API"

	projects := aDictionary
]

{ #category : 'properties' }
MooseNexusManagedProject >> projectsFromProperties: projectGroups [

	^ projectGroups collect: [ :projectGroup |
		  projectGroup collect: [ :projectDescriptor | self projectDescriptorFromProperties: projectDescriptor ] ]
]

{ #category : 'enumerating' }
MooseNexusManagedProject >> properties [

	^ super properties
		  add: #projects -> self serializedProjects;
		  yourself
]

{ #category : 'properties' }
MooseNexusManagedProject >> readProperties: properties [

	super readProperties: properties.
	properties at: #language ifPresent: [ :lang | self language: lang ].
	properties at: #projects ifPresent: [ :data | self projects: (self projectsFromProperties: data) ]
]

{ #category : 'enumerating' }
MooseNexusManagedProject >> serializedProjectDescriptor: projectDescriptor [

	^ projectDescriptor asDictionary
]

{ #category : 'enumerating' }
MooseNexusManagedProject >> serializedProjects [

	^ self projects collect: [ :projectGroup |
		  projectGroup collect: [ :projectDescriptor | self serializedProjectDescriptor: projectDescriptor ] ]
]
