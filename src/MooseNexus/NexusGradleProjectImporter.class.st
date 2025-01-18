"
I am responsible for importing a project that uses Gradle to manage dependencies.

Gradle has the `dependencies` option to print the full dependency tree, which contains redundancies and is difficult to parse. However, it also allows the definition of custom tasks, which are used to efficiently obtain the project description.

This freedom also means that the project definition does not follow a strict standard. In particular, the group, name, and version can be omitted or defined in different ways. To overcome this, users can write custom code to retrieve this data.
"
Class {
	#name : 'NexusGradleProjectImporter',
	#superclass : 'NexusManagedProjectImporter',
	#instVars : [
		'groupCode',
		'nameCode',
		'versionCode'
	],
	#category : 'MooseNexus-Importer',
	#package : 'MooseNexus',
	#tag : 'Importer'
}

{ #category : 'testing' }
NexusGradleProjectImporter class >> canHandle: directory [

	| directoryReference |
	directoryReference := directory asFileReference.
	directoryReference / 'build.gradle' ifExists: [ ^ true ].
	directoryReference / 'build.gradle.kts' ifExists: [ ^ true ].
	^ false
]

{ #category : 'constants' }
NexusGradleProjectImporter class >> taskName [

	^ 'mooseNexusListDependencies'
]

{ #category : 'enumerating' }
NexusGradleProjectImporter >> findBuildFile [

	directory / 'build.gradle' ifExists: [ :file | ^ file ].
	directory / 'build.gradle.kts' ifExists: [ :file | ^ file ].
	Error signal: 'Cannot find gradle build file'
]

{ #category : 'enumerating' }
NexusGradleProjectImporter >> findGradleCommand [
	"Return the name of the gradle executable, can be a wrapper or the global 'gradle' command."

	OSPlatform current isWindows
		ifTrue: [ directory / 'gradlew.bat' ifExists: [ ^ 'gradlew.bat' ] ]
		ifFalse: [ "assume *nix"
		directory / 'gradlew' ifExists: [ ^ './gradlew' ] ].
	"assume gradle is installed"
	^ 'gradle'
]

{ #category : 'constants' }
NexusGradleProjectImporter >> groovyCodeForDependencies [
	"Code to insert into a build.gradle file to get the flat list of dependencies."

	^ String streamContents: [ :s |
		  s << 'tasks.register("' << self class taskName << '") {
	doLast {
		def rootDirPath = rootDir.canonicalPath
		allprojects.findAll { it.projectDir.canonicalPath.startsWith(rootDirPath) }.each { project ->
			println "-${' << self groupCode << '}:${' << self nameCode
		  << '}:${' << self versionCode << '}"
			def projectDirPath = project.projectDir.canonicalPath
			if (projectDirPath.equals(rootDirPath)) {
				println "."
			} else {
				println(projectDirPath.substring(rootDirPath.length() + 1))
			}
			configurations.findAll { it.canBeResolved }.each { configuration ->
				def scope = configuration.name
				configuration.resolvedConfiguration.resolvedArtifacts.each { artifact ->
					def group = artifact.moduleVersion.id.group
					def name = artifact.name
					def type = artifact.extension ?: "jar"
					def version = artifact.moduleVersion.id.version
					def path = artifact.file.absolutePath // forces artifact download
					println "$group:$name:$type:$version:$scope:$path"
				}
			}
		}
	}
}' ]
]

{ #category : 'accessing' }
NexusGradleProjectImporter >> groupCode [

	^ groupCode ifNil: [ groupCode := 'project.group' ]
]

{ #category : 'accessing' }
NexusGradleProjectImporter >> groupCode: aString [
	"Define the code that returns the group string of a project."

	groupCode := aString
]

{ #category : 'initialization' }
NexusGradleProjectImporter >> initialize [

	localRepositories := {
		                     NexusGradleRepository default.
		                     NexusMavenRepository default }
]

{ #category : 'constants' }
NexusGradleProjectImporter >> kotlinCodeForDependencies [
	"Code to insert into a build.gradle.kts file to get the flat list of dependencies.
	Kotlin is sensitive to line endings, so they are removed for convenience."

	^ String streamContents: [ :s |
		  s << 'tasks.register("' << self class taskName
		  <<
		  '") { doLast { val rootDirPath = rootDir.canonicalPath; allprojects.filter { it.projectDir.canonicalPath.startsWith(rootDirPath) }.forEach { project -> println("-${'
		  << self groupCode << '}:${' << self nameCode << '}:${'
		  << self versionCode
		  <<
		  '}"); val projectDirPath = project.projectDir.canonicalPath; if (projectDirPath.equals(rootDirPath)) { println(".") } else { println(projectDirPath.substring(rootDirPath.length + 1)) }; configurations.filter { it.isCanBeResolved }.forEach { configuration -> val scope = configuration.name; configuration.resolvedConfiguration.resolvedArtifacts.forEach { artifact -> val group = artifact.moduleVersion.id.group; val name = artifact.name; val type = artifact.extension ?: "jar"; val version = artifact.moduleVersion.id.version; val path = artifact.file.absolutePath; /* forces artifact download */ println("$group:$name:$type:$version:$scope:$path") }}}}}' ]
]

{ #category : 'accessing' }
NexusGradleProjectImporter >> nameCode [

	^ nameCode ifNil: [ nameCode := 'project.name' ]
]

{ #category : 'accessing' }
NexusGradleProjectImporter >> nameCode: aString [
	"Define the code that returns the name string of a project."

	nameCode := aString
]

{ #category : 'instance creation' }
NexusGradleProjectImporter >> newProject [

	^ NexusGradleProject new
]

{ #category : 'parsing' }
NexusGradleProjectImporter >> parse: raw [
	"Parses the result of the command listing the dependencies.
	Resolves each dependency to obtain the path to its local location.
	The result of the command is formatted as follows for each project:
-group:name:version
directory
(group:name:type:version:scope:path)*"

	| lines line index |
	lines := raw lines.

	"project info starts at third line at the earliest, after the line '> Task ...'"
	index := 2.
	[
	(line := lines at: (index := index + 1) - 1) isNotEmpty and: [
		line first == $> ] ] whileFalse.

	[ (line := lines at: index) isNotEmpty ] whileTrue: [
		| group name version descriptor dependencies |
		"read project descriptor"
		descriptor := $: split: line allButFirst.
		group := descriptor first.
		name := descriptor second.
		version := descriptor third.

		"register the project with its version; project name is unique so this never overwrites"
		descriptor := Dictionary with: #version -> version.
		project projects at: group at: name put: descriptor.

		"read project location, relative to the directory"
		descriptor at: #path put: (lines at: (index := index + 1)).

		"read dependencies per scope"
		dependencies := Dictionary new.
		[
		(line := lines at: (index := index + 1)) isEmpty or: [
			line first == $- ] ] whileFalse: [ "resolve the descriptor: 'group:name:type:version:scope:path'"
			| mapping |
			mapping := self resolve: line.
			dependencies
				at: mapping key
				ifPresent: [ :descriptors | descriptors add: mapping value ]
				ifAbsentPut: [ OrderedCollection with: mapping value ] ].

		"the current project has been fully parsed
		save the dependencies as arrays for JSON compatibility"
		descriptor at: #dependencies put: (dependencies collect: #asArray) ]
]

{ #category : 'reading' }
NexusGradleProjectImporter >> read [
	"Gradle does not provide a command to output flat dependencies.
	Instead of implementing dark magic parsing, we add a task to the build file and run it.
	Either use the global 'gradle' command or a local 'gradlew' wrapper."

	| buildFile gradleCmd originalSize |
	buildFile := self findBuildFile.
	gradleCmd := self findGradleCommand.
	originalSize := buildFile size. "to restore it later"

	^ [ "append code to the build file for a task to extract resolved dependencies"
	  buildFile writeStreamDo: [ :ws |
		  ws setToEnd crlf << (buildFile extension = 'kts'
			   ifTrue: [ self kotlinCodeForDependencies ]
			   ifFalse: [ self groovyCodeForDependencies ]) ].

	  "execute the task we inserted and return the raw terminal output"
	  LibC resultOfCommand:
		  'cd "' , directory pathString , '" && ' , gradleCmd , ' '
		  , self class taskName ] ensure: [ "restore the original build file"
		  (File named: buildFile fullName) writeStreamDo: [ :ws |
			  ws truncate: originalSize ] ]
]

{ #category : 'accessing' }
NexusGradleProjectImporter >> versionCode [

	^ versionCode ifNil: [ versionCode := 'project.version' ]
]

{ #category : 'accessing' }
NexusGradleProjectImporter >> versionCode: aString [
	"Define the code that returns the version string of a project."

	versionCode := aString
]
