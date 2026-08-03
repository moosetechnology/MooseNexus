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

{ #category : 'private' }
MooseNexusManagedProject >> dependencyDescriptorFrom: aDescriptor group: dependencyGroup [

	| descriptor |
	aDescriptor isString ifTrue: [
		Error signal: 'Invalid dependency descriptor for ' , dependencyGroup , ': ' , aDescriptor printString ].
	descriptor := aDescriptor isDictionary
		              ifTrue: [ MooseNexusDependencyDescriptor fromDictionary: aDescriptor ]
		              ifFalse: [
				              (self isArrayEncodedDependencyDescriptor: aDescriptor)
					              ifTrue: [ MooseNexusDependencyDescriptor fromArray: aDescriptor ]
					              ifFalse: [ aDescriptor ] ].
	^ descriptor group ifNil: [ descriptor withGroup: dependencyGroup ] ifNotNil: [ descriptor ]
]

{ #category : 'private' }
MooseNexusManagedProject >> dependencyDescriptorsFrom: descriptors group: dependencyGroup [

	(self isArrayEncodedDependencyDescriptor: descriptors) ifTrue: [
		^ { (self dependencyDescriptorFrom: descriptors group: dependencyGroup) } ].
	descriptors isDictionary ifTrue: [ ^ { (self dependencyDescriptorFrom: descriptors group: dependencyGroup) } ].
	^ descriptors collect: [ :descriptor | self dependencyDescriptorFrom: descriptor group: dependencyGroup ]
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
MooseNexusManagedProject >> isArrayEncodedDependencyDescriptor: anObject [

	^ anObject isString not and: [ anObject isCollection and: [ anObject isNotEmpty and: [ anObject first isString ] ] ]
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
					(projectDescriptor at: #dependencies) keysAndValuesDo: [ :dependencyGroup :descriptors |
							(self dependencyDescriptorsFrom: descriptors group: dependencyGroup) do: [ :descriptor |
								aBlock value: dependencyGroup value: descriptor ] ] ] ]
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
	properties at: #projects ifPresent: [ :data | self projects: data ]
]

{ #category : 'enumerating' }
MooseNexusManagedProject >> serializedDependenciesFrom: descriptors group: dependencyGroup [

	^ (self dependencyDescriptorsFrom: descriptors group: dependencyGroup) collect: [ :descriptor |
			  descriptor asDictionary
				  removeKey: #group ifAbsent: [ nil ];
				  yourself ]
]

{ #category : 'enumerating' }
MooseNexusManagedProject >> serializedProjectDescriptor: projectDescriptor [

	| serializedDescriptor serializedDependencies |
	serializedDescriptor := projectDescriptor copy.
	serializedDependencies := Dictionary new.
	(projectDescriptor at: #dependencies ifAbsent: [ Dictionary new ]) keysAndValuesDo: [ :dependencyGroup :descriptors |
		serializedDependencies at: dependencyGroup put: (self serializedDependenciesFrom: descriptors group: dependencyGroup) asArray ].
	serializedDescriptor at: #dependencies put: serializedDependencies.
	^ serializedDescriptor
]

{ #category : 'enumerating' }
MooseNexusManagedProject >> serializedProjects [

	^ self projects collect: [ :projectGroup |
		  projectGroup collect: [ :projectDescriptor | self serializedProjectDescriptor: projectDescriptor ] ]
]
