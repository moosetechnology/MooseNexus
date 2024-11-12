"
A project with managed dependencies, such as using Maven or Gradle.

My properties define the additional mapping:
```text
home:     <home>
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

A managed project can encompass multiple projects and sub-projects.
Once analyzed, the following mapping can be read from the `projects` property:
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
		'home',
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
NexusManagedProject >> determineDependencies [
	"Resolve all dependencies of this project into a flat list.
	A problem can occur if two projects define the same dependency with different versions."

	| theDependencies |
	theDependencies := Dictionary new.
	self projectDependenciesDo: [ :dependencyGroup :descriptor |
		| key mustAdd |
		key := dependencyGroup , ':' , (descriptor at: #name).
		mustAdd := true.
		theDependencies at: key ifPresent: [ :existing |
			mustAdd := (self mediateExisting: existing incoming: descriptor)
			           == descriptor ].
		mustAdd ifTrue: [
			theDependencies
				at: key
				put: (descriptor copyWith: #group -> dependencyGroup) ] ].
	^ theDependencies asArray
]

{ #category : 'querying' }
NexusManagedProject >> determineGroup [

	projects size == 1 ifFalse: [
		Error signal: 'Can only determine group if only one is declared' ].
	projects keysDo: [ :key | ^ key ]
]

{ #category : 'querying' }
NexusManagedProject >> determineLanguage [

	| knownLanguages candidates |
	knownLanguages := self class knownLanguages.
	(projects isEmpty or: [ projects anyOne isEmpty ]) ifTrue: [
		Error signal: 'Cannot determine language without any project' ].
	candidates := Set new.

	"check if this project directory has sources"
	directory asFileReference / 'src/main' ifExists: [ :mainDirectory |
		FileSystem disk directoryNamesAt: mainDirectory do: [ :dirName |
			(knownLanguages includes: dirName) ifTrue: [
				candidates add: dirName ] ] ].

	"check the sources of each project"
	projects do: [ :projectGroup |
		projectGroup keysDo: [ :projectName |
			directory asFileReference / projectName ifExists: [
				:projectDirectory |
				projectDirectory / 'src/main' ifExists: [ :mainDirectory |
					FileSystem disk directoryNamesAt: mainDirectory do: [ :dirName |
						(knownLanguages includes: dirName) ifTrue: [
							candidates add: dirName ] ] ] ] ] ].

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

{ #category : 'accessing' }
NexusManagedProject >> home [
	"The home folder of the project manager."

	^ home
]

{ #category : 'accessing' }
NexusManagedProject >> home: pathString [
	"Define the home of the external project manager for this project.
	The path must be relative to the home directory (result of `FileLocator home pathString`)."

	home := pathString
]

{ #category : 'accessing' }
NexusManagedProject >> language [
	"Project managers are language-agnostic, so it has to be determined."

	^ language ifNil: [ language := self determineLanguage ]
]

{ #category : 'accessing' }
NexusManagedProject >> language: aString [

	language := aString
]

{ #category : 'versions' }
NexusManagedProject >> mediateExisting: existing incoming: incoming [
	"Decide which version of the dependency to include in the model.
	The terms 'existing' and 'incoming' are arbitrary, as the order is irrelevant.
	The existing dependency has already been processed, and the incoming dependency is the one being processed.
	If they are the same, the existing dependency should be returned to avoid unnecessary computations.
	If they are different, we have to decide which one to use, which is complicated."

	| existingVersion incomingVersion |
	(existingVersion := existing at: #version)
	= (incomingVersion := incoming at: #version) ifTrue: [ ^ existing ].

	"This is a difficult problem: a managed project can have multiple projects, each declaring their own dependencies (and versions).
	The user wants to create a model of the managed project, thus of all the projects it contains.
	However, if two projects declare the same dependency but with different versions, which one should be included in the model?"
	Warning signal: (String streamContents: [ :s |
			 s << 'The dependency ' << (existing at: #group) << ':'
			 << (existing at: #name)
			 << ' is declared with different versions: ' << existingVersion
			 << ' and ' << incomingVersion << ', proceed to use the first one' ]).
	^ existing
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
		  add: #home -> self home;
		  add: #projects -> self projects;
		  yourself
]
