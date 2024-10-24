"
I represent a project managed with Maven.

The `mvn` command is used to get the projects and dependencies declared in a `pom.xml` file.
This means that a `NexusProject` and its Moose model can be recorded in a `NexusRepository` based on a pom file only, without the need to have the sources locally.

### Specification
Maven descriptors are structured as: `group:artifact:type:version:scope`.
The type is one of: pom, jar, maven-plugin, ejb, war, ear, rar.
The scope is one of: compile, provided, runtime, test, system, import.
"
Class {
	#name : 'NexusMavenProject',
	#superclass : 'NexusManagedProject',
	#category : 'MooseNexus-Project',
	#package : 'MooseNexus',
	#tag : 'Project'
}

{ #category : 'error handling' }
NexusMavenProject class >> canHandle: directory [

	FileSystem disk
		fileNamesAt: directory
		do: [ :filename | filename = 'pom.xml' ifTrue: [ ^ true ] ].
	^ false
]

{ #category : 'testing' }
NexusMavenProject class >> fromDirectory: directory [

	^ self new directory: directory
]

{ #category : 'private' }
NexusMavenProject >> analyze [
	"Attempts to read the group, artifact, version, and dependencies of all managed projects.
	Only relevant if this project has not yet been recorded."

	self parse: self read
]

{ #category : 'initialization' }
NexusMavenProject >> initialize [
	"Set the default home of all Maven projects"

	home := FileLocator home pathString , '/.m2'
]

{ #category : 'private' }
NexusMavenProject >> parse: raw [
	"Parses the result of the command listing the dependencies.
	Resolves each dependency to obtain the path to its local location.
	The result of the command is formatted as follows:
[INFO] ---------------------< `group`:`artifact` >----------------------
[INFO] Building `projectName` `version`                               [`i`/`n`]
[INFO]   from `path/`pom.xml
[INFO] -------------------------------[ `type` ]-------------------------------
[INFO] 
[INFO] --- dependency:`pluginVersion`:list (default-cli) @ `artifact` ---
[INFO] 
[INFO] The following files have been resolved:
[INFO]    `none | (group:artifact:type:version:scope)+`"

	| start newLines |
	newLines := {
		            Character lf.
		            Character cr }.
	start := 39. "= '[INFO] Scanning for projects...\n[INFO] ' size"
	[ (start := raw indexOf: $< startingAt: start) == 0 ] whileFalse: [
		| end projectGroup projectArtifact projectVersion projectDependencies |
		"find the group and artifact declaring the dependencies"
		end := raw indexOf: $: startingAt: start + 3. "= '< .' size"
		projectGroup := raw copyFrom: start + 2 to: end - 1.
		end := raw indexOf: $> startingAt: (start := end + 1) + 1.
		projectArtifact := raw copyFrom: start to: end - 2.

		"find the version"
		start := end := raw indexOfSubCollection: '  ' startingAt: end + 1.
		[ (raw at: (start := start - 1)) == Character space ] whileFalse.
		projectVersion := raw copyFrom: start + 1 to: end - 1.

		"register the project with its version"
		self projects at: projectGroup at: projectArtifact put: (Dictionary
				 with: #version -> projectVersion
				 with: #dependencies -> (projectDependencies := Dictionary new)).

		"find the first line with the dependencies"
		start := (raw indexOfSubCollection: ']    ' startingAt: end + 1) + 5. "= ']    ' size"
		[
		| dependency |
		end := raw indexOfAnyOf: newLines startingAt: start + 1.
		dependency := raw copyFrom: start to: end - 1.
		dependency = 'none' ifFalse: [
			projectDependencies add: (self resolve: dependency) ].

		"skip over '[INFO] ' and check if new line, indicating the end of the list
		else start of next dependency is 3 spaces later"
		newLines includes: (raw at: (start := end + 11) - 3) ] whileFalse ]
]

{ #category : 'private' }
NexusMavenProject >> read [
	"Run the `mvn` command using the `dependency:list` plugin.
	Requires Maven to be installed."

	^ LibC resultOfCommand: 'cd ' , directory , ' && mvn dependency:list'
]

{ #category : 'private' }
NexusMavenProject >> resolve: descriptor [
	"Attempts to find the local path to an artifact based on the descriptor."

	| parts theGroup theArtifact theType theVersion theScope theDirectory pathString |
	parts := $: split: descriptor.
	theGroup := parts at: 1.
	theArtifact := parts at: 2.
	theType := parts at: 3.
	theVersion := parts at: 4.
	theScope := parts at: 5.
	(theDirectory := self home asFileReference / 'repository'
	                 / (theGroup copyReplaceAll: '.' with: '/')
	                 / theArtifact / theVersion) ifAbsent: [
		Error signal: 'Could not find dependency: ' , descriptor ].

	theDirectory
	/ ((pathString := theArtifact , '-' , theVersion) , '.' , theType)
		ifExists: [ :file | pathString := file pathString ]
		ifAbsent: [ "try to look for the sources, although that's unlikely"
			theDirectory / (pathString , '-sources.' , theType)
				ifExists: [ :file | pathString := file pathString ]
				ifAbsent: [
					Error signal:
						'Dependency `' , descriptor , '` found in `'
						, theDirectory pathString , '` but the artifact is missing.' ] ].

	^ theGroup -> (Dictionary
		   with: #artifact -> theArtifact
		   with: #version -> theVersion
		   with: #type -> theType
		   with: #scope -> theScope
		   with: #directory -> pathString)
]
