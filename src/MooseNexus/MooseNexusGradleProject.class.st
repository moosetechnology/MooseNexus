"
I represent a project managed with Gradle.

The Gradle importer records Gradle-resolved, pathless dependency references from Groovy or Kotlin build files. When extraction needs a dependency classpath, I use a temporary Gradle init script to stage the selected artifacts. Gradle repository configuration stays in the build environment; it is not stored in project metadata.
"
Class {
	#name : 'MooseNexusGradleProject',
	#superclass : 'MooseNexusManagedProject',
	#category : 'MooseNexus-Project',
	#package : 'MooseNexus',
	#tag : 'Project'
}

{ #category : 'private' }
MooseNexusGradleProject >> gradleCommand [

	OSPlatform current isWindows
		ifTrue: [ self repositoryDirectory / 'gradlew.bat' ifExists: [ ^ 'gradlew.bat' ] ]
		ifFalse: [ self repositoryDirectory / 'gradlew' ifExists: [ ^ './gradlew' ] ].
	^ 'gradle'
]

{ #category : 'private' }
MooseNexusGradleProject >> gradleMaterializationInitScript [

	^ 'allprojects { tasks.register("mooseNexusMaterializeDependency") { doLast { def artifact = dependencies.create(project.findProperty("mooseNexusArtifact")); def file = configurations.detachedConfiguration(artifact).singleFile; copy { from file; into project.findProperty("mooseNexusOutputDirectory"); rename { project.findProperty("mooseNexusOutputFileName") } } } } }'
]

{ #category : 'testing' }
MooseNexusGradleProject >> isGradleProject [

	^ true
]

{ #category : 'private' }
MooseNexusGradleProject >> materializeGradleDependency: dependency into: dependenciesDirectory [

	| initScript command output markerStart exitStatus target result |
	initScript := FileLocator temp / ('moosenexus-gradle-materialize-' , UUID new asString , '.gradle').
	result := [
		          target := dependenciesDirectory / dependency materializationFileName.
		          initScript writeStreamDo: [ :stream | stream nextPutAll: self gradleMaterializationInitScript ].
		          command := String streamContents: [ :stream |
				                     stream << 'cd "' << self repositoryDirectory pathString << '" && ' << self gradleCommand
				                     << ' --no-daemon --init-script "' << initScript pathString << '" mooseNexusMaterializeDependency '
				                     << '-PmooseNexusArtifact="' << dependency group << ':' << dependency name << ':' << dependency version
				                     << '@' << dependency type << '" ' << '-PmooseNexusOutputDirectory="' << dependenciesDirectory pathString
				                     << '" -PmooseNexusOutputFileName="' << target basename
				                     << '"; printf "__MOOSE_NEXUS_COMMAND_EXIT_STATUS__:%s" "$?"' ].
		          output := LibC resultOfCommand: command.
		          markerStart := output indexOfSubCollection: '__MOOSE_NEXUS_COMMAND_EXIT_STATUS__:' startingAt: 1.
		          markerStart isZero ifTrue: [ Error signal: 'Gradle did not report an artifact materialization status' ].
		          exitStatus := (output copyFrom: markerStart + '__MOOSE_NEXUS_COMMAND_EXIT_STATUS__:' size to: output size) asInteger.
		          exitStatus isZero ifFalse: [ Error signal: 'Gradle artifact materialization failed:' , String cr , output ].
		          target exists ifFalse: [ Error signal: 'Gradle did not materialize the requested artifact: ' , target pathString ].
		          MooseNexusDependencyMaterializationResult
			          dependency: dependency
			          path: (target relativeTo: self repositoryDirectory) pathString
			          source: 'gradle' ] ensure: [ initScript deleteIfAbsent: [ ] ].
	^ result
]

{ #category : 'building' }
MooseNexusGradleProject >> materializeRemoteDependency: dependency into: dependenciesDirectory [

	^ self materializeGradleDependency: dependency into: dependenciesDirectory
]
