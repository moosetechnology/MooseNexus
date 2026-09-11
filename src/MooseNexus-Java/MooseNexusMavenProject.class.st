"
I represent a project managed with Maven.

The Maven importer records Maven-resolved, pathless dependency references. When extraction needs a dependency classpath, I use Maven's dependency plugin to stage the selected artifacts temporarily. Maven settings, mirrors, and repository configuration stay in the build environment; they are not stored in project metadata.
"
Class {
	#name : 'MooseNexusMavenProject',
	#superclass : 'MooseNexusManagedProject',
	#category : 'MooseNexus-Java-Project',
	#package : 'MooseNexus-Java',
	#tag : 'Project'
}

{ #category : 'testing' }
MooseNexusMavenProject >> isMavenProject [

	^ true
]

{ #category : 'private' }
MooseNexusMavenProject >> materializeMavenDependency: dependency into: dependenciesDirectory [

	| command output markerStart exitStatus target copiedArtifact |
	target := dependenciesDirectory / dependency materializationFileName.
	command := String streamContents: [ :stream |
			           stream << 'cd "' << self repositoryDirectory pathString << '" && ' << self mavenCommand << ' --batch-mode '
			           << 'org.apache.maven.plugins:maven-dependency-plugin:3.8.1:copy ' << '-Dartifact=' << dependency group << ':'
			           << dependency name << ':' << dependency version << ':' << dependency type << ' ' << '-DoutputDirectory="'
			           << dependenciesDirectory pathString << '"; printf "__MOOSE_NEXUS_COMMAND_EXIT_STATUS__:%s" "$?"' ].
	output := LibC resultOfCommand: command.
	markerStart := output indexOfSubCollection: '__MOOSE_NEXUS_COMMAND_EXIT_STATUS__:' startingAt: 1.
	markerStart isZero ifTrue: [ Error signal: 'Maven did not report an artifact materialization status' ].
	exitStatus := (output copyFrom: markerStart + '__MOOSE_NEXUS_COMMAND_EXIT_STATUS__:' size to: output size) asInteger.
	exitStatus isZero ifFalse: [ Error signal: 'Maven artifact materialization failed:' , String cr , output ].
	copiedArtifact := dependenciesDirectory / (dependency name , '-' , dependency version , '.' , dependency type).
	copiedArtifact exists ifFalse: [ Error signal: 'Maven did not materialize the requested artifact: ' , copiedArtifact pathString ].
	target ensureDelete.
	copiedArtifact moveTo: target.
	^ MooseNexusDependencyMaterializationResult
		  dependency: dependency
		  path: (target relativeTo: self repositoryDirectory) pathString
		  source: 'maven'
]

{ #category : 'building' }
MooseNexusMavenProject >> materializeRemoteDependency: dependency into: dependenciesDirectory [

	^ self materializeMavenDependency: dependency into: dependenciesDirectory
]

{ #category : 'private' }
MooseNexusMavenProject >> mavenCommand [

	OSPlatform current isWindows
		ifTrue: [ self repositoryDirectory / 'mvnw.cmd' ifExists: [ ^ 'mvnw.cmd' ] ]
		ifFalse: [ self repositoryDirectory / 'mvnw' ifExists: [ ^ './mvnw' ] ].
	^ 'mvn'
]
