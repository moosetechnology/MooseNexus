Class {
	#name : 'NexusGradleProjectImporter',
	#superclass : 'NexusManagedProjectImporter',
	#category : 'MooseNexus-Project',
	#package : 'MooseNexus',
	#tag : 'Project'
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
        configurations.findAll { it.canBeResolved }.each { configuration ->
            println "=${configuration.name}"
            configuration.resolvedConfiguration.resolvedArtifacts.each { artifact ->
                def group = artifact.moduleVersion.id.group
                def name = artifact.name
                def type = artifact.extension ?: "jar"
                def version = artifact.moduleVersion.id.version
                println "${group}:${name}:${type}:${version}"
            }
        }
    }
}'
	"only compile dependencies (named 'compileClasspath' in gradle)
	'tasks.register(""listResolvedDependencies"") {
    doLast {
        configurations.compileClasspath.resolvedConfiguration.resolvedArtifacts.each { artifact ->
            def group = artifact.moduleVersion.id.group
            def name = artifact.name
            def type = artifact.extension ?: ""jar""
            def version = artifact.moduleVersion.id.version
            println ""${group}:${name}:${type}:${version}""
        }
    }
}'"
]

{ #category : 'constants' }
NexusGradleProjectImporter class >> kotlinCodeForDependencies [
	"Code to insert in a build.gradle.kts file to obtain flat list of dependencies."

	^ 'tasks.register("' , self taskName , '") {
    doLast {
        configurations.filter { it.isCanBeResolved }.forEach { configuration ->
            println("=${configuration.name}")
            configuration.resolvedConfiguration.resolvedArtifacts.forEach { artifact ->
                val group = artifact.moduleVersion.id.group
                val name = artifact.name
                val type = artifact.extension ?: "jar"
                val version = artifact.moduleVersion.id.version
                println("$group:$name:$type:$version")
            }
        }
    }
}'
]

{ #category : 'constants' }
NexusGradleProjectImporter class >> taskName [

	^ 'mooseNexusListResolvedDependenciesByScope'
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

{ #category : 'instance creation' }
NexusGradleProjectImporter >> newProject [

	^ NexusGradleProject new
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
