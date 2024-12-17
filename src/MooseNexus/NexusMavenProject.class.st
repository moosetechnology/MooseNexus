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
	"Attempts to read the group, name, version, and dependencies of all managed projects.
	Only relevant if this project has not yet been recorded."

	self parse: self read
]

{ #category : 'initialization' }
NexusMavenProject >> initialize [
	"Set the default home of all Maven projects."

	home := '.m2'
]

{ #category : 'private' }
NexusMavenProject >> parse: raw [
	"Parses the result of the command listing the dependencies.
	Resolves each dependency to obtain the path to its local location.
	The result of the command is formatted as follows:
[INFO] ---------------------< `group`:`name` >----------------------
[INFO] Building `projectName` `version`                               [`i`/`n`]
[INFO]   from `path/`pom.xml
[INFO] -------------------------------[ `type` ]-------------------------------
[INFO] 
[INFO] --- dependency:`pluginVersion`:resolve (default-cli) @ `name` ---
[INFO] 
[INFO] The following files have been resolved:
[INFO]    `none | (group:name:type:version:scope)+`"

	| newLines start |
	newLines := {
		            Character cr.
		            Character lf }.
	start := 1.
	[ (start := raw indexOf: $< startingAt: start) == 0 ] whileFalse: [
		| end projectGroup projectName projectVersion descriptor projectDependencies |
		"find the group and name declaring the dependencies"
		end := raw indexOf: $: startingAt: start + 3. "= '< .' size"
		projectGroup := raw copyFrom: start + 2 to: end - 1.
		end := raw indexOf: $> startingAt: (start := end + 1) + 1.
		projectName := raw copyFrom: start to: end - 2.

		"find the version"
		start := end := raw indexOfSubCollection: '  ' startingAt: end + 1.
		[ (raw at: (start := start - 1)) == Character space ] whileFalse.
		projectVersion := raw copyFrom: start + 1 to: end - 1.

		"register the project with its version; projectName is unique so this never overwrites"
		descriptor := Dictionary with: #version -> projectVersion.
		self projects at: projectGroup at: projectName put: descriptor.

		"find the first line with the dependencies"
		start := (raw indexOfSubCollection: ']    ' startingAt: end + 1) + 5. "= ']    ' size"
		projectDependencies := Dictionary new.
		[ "collect all the dependencies of a project"
		| dependency |
		end := raw indexOfAnyOf: newLines startingAt: start + 1.
		dependency := raw copyFrom: start to: end - 1.
		dependency = 'none' ifFalse: [ "resolve the descriptor: 'group:name:type:version:scope'"
			| mapping |
			mapping := self resolve: dependency. "returns group -> (descriptor \ group)"
			projectDependencies
				at: mapping key
				ifPresent: [ :descriptors | descriptors add: mapping value ]
				ifAbsentPut: [ OrderedCollection with: mapping value ] ].

		"skip over '[INFO] ' (11 chars) and check if new line, indicating the end of the list
		else start of next dependency descriptor is 3 spaces later"
		newLines includes: (raw at: (start := end + 11) - 3) ] whileFalse.

		"the current project has been fully parsed
		save the dependencies as arrays for JSON compatibility"
		descriptor
			at: #dependencies
			put: (projectDependencies collect: #asArray) ]
]

{ #category : 'private' }
NexusMavenProject >> read [
	"Runs the `mvn` command using the `dependency:resolve` plugin.
	Requires Maven to be installed."

	^ LibC resultOfCommand: 'cd ' , directory , ' && mvn -B dependency:resolve'
]

{ #category : 'private' }
NexusMavenProject >> resolve: descriptor [
	"Attempts to find the local path to an artifact based on the descriptor."

	| parts theGroup theName theType theVersion theScope theDirectory pathString fileName |
	parts := $: split: descriptor.
	theGroup := parts at: 1.
	theName := parts at: 2.
	theType := parts at: 3.
	theVersion := parts at: 4.
	theScope := parts at: 5.

	"search for the directory"
	pathString := String streamContents: [ :s |
		              s << 'repository/'
		              << (theGroup copyReplaceAll: '.' with: '/') << '/'
		              << theName << '/' << theVersion ].
	(theDirectory := FileLocator home / home / pathString) ifAbsent: [
		Error signal: 'Could not find dependency: ' , descriptor ].

	"search for the artifact"
	fileName := theName , '-' , theVersion , '.' , theType.
	theDirectory / fileName ifAbsent: [
		Error signal:
			'Dependency `' , descriptor , '` found in `'
			, theDirectory pathString , '` but the artifact is missing.' ].

	^ theGroup -> (Dictionary
		   with: #name -> theName
		   with: #version -> theVersion
		   with: #type -> theType
		   with: #scope -> theScope
		   with: #path -> (pathString , '/' , fileName))
]
