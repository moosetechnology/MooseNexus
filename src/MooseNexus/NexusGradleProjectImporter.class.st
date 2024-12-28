Class {
	#name : 'NexusGradleProjectImporter',
	#superclass : 'NexusManagedProjectImporter',
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
NexusGradleProjectImporter class >> groovyCodeForDependencies [
	"Code to insert in a build.gradle file to obtain flat list of dependencies."

	^ 'tasks.register("' , self taskName , '") {
	doLast {
		def rootDirPath = rootDir.canonicalPath
		allprojects.findAll { it.projectDir.canonicalPath.startsWith(rootDirPath) }.each { project ->
			println "-${project.group}:${project.name}:${project.version}"
			println(project.projectDir.canonicalPath)
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
}'
]

{ #category : 'constants' }
NexusGradleProjectImporter class >> kotlinCodeForDependencies [
	"Code to insert in a build.gradle.kts file to obtain flat list of dependencies."

	^ 'tasks.register("' , self taskName , '") {
	doLast {
		val rootDirPath = rootDir.canonicalPath
		allprojects.filter { it.projectDir.canonicalPath.startsWith(rootDirPath) }.forEach { project ->
			println("-${project.group}:${project.name}:${project.version}")
			println(project.projectDir.canonicalPath)
			configurations.filter { it.isCanBeResolved }.forEach { configuration ->
				val scope = configuration.name
				configuration.resolvedConfiguration.resolvedArtifacts.forEach { artifact ->
					val group = artifact.moduleVersion.id.group
					val name = artifact.name
					val type = artifact.extension ?: "jar"
					val version = artifact.moduleVersion.id.version
					val path = artifact.file.absolutePath // forces artifact download
					println("$group:$name:$type:$version:$scope:$path")
				}
			}
		}
	}
}'
]

{ #category : 'constants' }
NexusGradleProjectImporter class >> taskName [

	^ 'mooseNexusListDependencies'
]

{ #category : 'enumerating' }
NexusGradleProjectImporter >> findBuildFile [

	| directoryReference |
	directoryReference := directory asFileReference.
	directoryReference / 'build.gradle' ifExists: [ :file | ^ file ].
	directoryReference / 'build.gradle.kts' ifExists: [ :file | ^ file ].
	Error signal: 'Cannot find gradle build file'
]

{ #category : 'enumerating' }
NexusGradleProjectImporter >> findGradleCommand [
	"Return the name of the gradle executable, can be a wrapper or the global 'gradle' command."

	OSPlatform current isWindows
		ifTrue: [
			directory asFileReference / 'gradlew.bat' ifExists: [
				^ 'gradlew.bat' ] ]
		ifFalse: [ "assume *nix"
			directory asFileReference / 'gradlew' ifExists: [ ^ './gradlew' ] ].
	"assume gradle is installed"
	^ 'gradle'
]

{ #category : 'initialization' }
NexusGradleProjectImporter >> initialize [

	localRepositories := {
		                     NexusGradleRepository default.
		                     NexusMavenRepository default }
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
	index := 3. "relevant info starts at third line"

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

		"read project location"
		descriptor
			at: #path
			put: ((lines at: (index := index + 1)) asFileReference relativeTo:
					 FileLocator home) pathString.

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

	| buildFile isKotlin gradleCmd tempFile |
	buildFile := self findBuildFile.
	isKotlin := buildFile extension = 'kts'.

	"find the gradle executable, can be a local wrapper file"
	gradleCmd := self findGradleCommand.

	"preserve the original build file in a temp file"
	tempFile := FileReference
		            newTempFilePrefix: 'mooseNexus'
		            suffix: '-build.gradle'.
	buildFile copyTo: tempFile.

	^ [ "append code to the build file for a task to extract flat dependencies"
	  buildFile writeStreamDo: [ :ws |
		  ws setToEnd crlf << (isKotlin
			   ifTrue: [ self class kotlinCodeForDependencies ]
			   ifFalse: [ self class groovyCodeForDependencies ]) ].

	  "execute the task we inserted and return the raw terminal output"
	  LibC resultOfCommand:
		  'cd "' , directory , '" && ' , gradleCmd , ' '
		  , self class taskName ] ensure: [ "make sure the original build file is preserved"
		  buildFile ensureDelete.
		  tempFile copyTo: buildFile.
		  tempFile ensureDelete ]
]
