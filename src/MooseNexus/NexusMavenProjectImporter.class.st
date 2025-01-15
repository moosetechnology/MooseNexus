"
I am responsible for importing a project that uses Maven to manage dependencies.
The `dependency:resolve` plugin is used to print the resolved dependencies of the project and its modules (subprojects).
"
Class {
	#name : 'NexusMavenProjectImporter',
	#superclass : 'NexusManagedProjectImporter',
	#category : 'MooseNexus-Importer',
	#package : 'MooseNexus',
	#tag : 'Importer'
}

{ #category : 'testing' }
NexusMavenProjectImporter class >> canHandle: directory [

	^ (directory asFileReference / 'pom.xml') exists
]

{ #category : 'enumerating' }
NexusMavenProjectImporter >> findMavenCommand [
	"Return the name of the maven executable, can be a wrapper or the global 'mvn' command."

	OSPlatform current isWindows
		ifTrue: [ directory / 'mvnw.cmd' ifExists: [ ^ 'mvnw.cmd' ] ]
		ifFalse: [ "assume *nix"
		directory / 'mvnw' ifExists: [ ^ './mvnw' ] ].
	"assume maven is installed"
	^ 'mvn'
]

{ #category : 'initialization' }
NexusMavenProjectImporter >> initialize [

	localRepositories := { NexusMavenRepository default }
]

{ #category : 'instance creation' }
NexusMavenProjectImporter >> newProject [

	^ NexusMavenProject new
]

{ #category : 'parsing' }
NexusMavenProjectImporter >> parse: raw [
	"Parses the result of the command listing the projects and their dependencies."

	| start |
	start := 1.
	[ (start := raw indexOf: $< startingAt: start) == 0 ] whileFalse: [
		start := self parseProject: raw startingAt: start ]
]

{ #category : 'parsing' }
NexusMavenProjectImporter >> parseProject: raw startingAt: initialStart [
	"Parses the description and dependencies of a single project (a Maven module).
	Resolves each dependency to obtain the path to its local location.
	The project can be from a different file hierarchy than the import directory,
	in which case it is still parsed to update the reading position, but not imported.
	The raw data of each project is formatted as follows:
[INFO] ---------------------< `group`:`name` >----------------------
[INFO] Building `projectName` `version`                               `([i/n])?`
[INFO]   from `path/`pom.xml
[INFO] -------------------------------[ `type` ]-------------------------------
[INFO] 
[INFO] --- dependency:`pluginVersion`:resolve (default-cli) @ `name` ---
[INFO] 
[INFO] The following files have been resolved:
[INFO]    `none | (group:name:type:version:scope)+`"

	| skip start end group name version path projectDependencies |
	skip := false.
	start := initialStart.

	"find the group and name declaring the dependencies"
	end := raw indexOf: $: startingAt: start + 3. "= '< .' size"
	group := raw copyFrom: start + 2 to: end - 1.
	end := raw indexOf: $> startingAt: (start := end + 1) + 1.
	name := raw copyFrom: start to: end - 2.

	"find the version which appears after the project name on the next line"
	end := start := end + name size + 45. "= size of string between name and version"
	[ (raw at: (end := end + 1)) isSeparator ] whileFalse.
	version := raw copyFrom: start to: end - 1.

	"read project location relative to the import directory"
	start := (raw indexOfSubCollection: 'from' startingAt: end + 1) + 5. "= 'from ' size"
	end := raw indexOfSubCollection: 'pom.xml' startingAt: start.
	start == end
		ifTrue: [ path := '.' ]
		ifFalse: [
			path := raw copyFrom: start to: end - 2.
			"a project path is always relative to the root pom.xml,
			but they can be from a different file hierarchy: ignore them"
			skip := (directory / path isContainedBy: directory) not ].

	"find the first line with the dependencies"
	start := (raw indexOfSubCollection: ']    ' startingAt: end + 1) + 5. "= ']    ' size"
	projectDependencies := Dictionary new.

	[ "collect and resolve all the dependencies"
	| dependency |
	"with Java >= 9, descriptors can be suffixed with ` -- module XYZ`, ignore it"
	end := raw indexOfAnyOf: String crlf , ' ' startingAt: start + 1.
	dependency := raw copyFrom: start to: end - 1. "= none | group:name:type:version:scope"
	(raw at: end) == Character space ifTrue: [ "skip module description (>= 11 chars)"
		end := raw indexOfAnyOf: String crlf startingAt: end + 11 ].
	(skip or: [ dependency = 'none' ]) ifFalse: [
		| mapping |
		mapping := self resolve: dependency. "returns group -> (descriptor \ group)"
		projectDependencies
			at: mapping key
			ifPresent: [ :descriptors | descriptors add: mapping value ]
			ifAbsentPut: [ OrderedCollection with: mapping value ] ].

	"skip over '[INFO] ' (8 chars) and check if new line, indicating the end of the list
	else start of next dependency descriptor is 3 spaces later"
	String crlf includes: (raw at: (start := end + 11) - 3) ] whileFalse.

	"register the project with its version; projectName is unique so this never overwrites
	save dependencies as arrays for JSON compatibility"
	skip ifFalse: [
		project projects at: group at: name put: (Dictionary
				 with: #path -> path
				 with: #version -> version
				 with: #dependencies -> (projectDependencies collect: #asArray)) ].

	"return the updated reading position"
	^ start
]

{ #category : 'reading' }
NexusMavenProjectImporter >> read [
	"Runs the `mvn` command using the `dependency:resolve` plugin.
	Requires Maven to be installed."

	^ LibC resultOfCommand:
		  'cd "' , directory pathString , '" && ' , self findMavenCommand
		  , ' --batch-mode dependency:resolve'
]
