"
I am responsible for importing a project that uses Gradle to manage dependencies.

Gradle has the `dependencies` option to print the full dependency tree, which contains redundancies and is difficult to parse. However, it also allows the definition of custom tasks, which are used to efficiently obtain the project description.

This freedom also means that the project definition does not follow a strict standard. In particular, the group, name, and version can be omitted or defined in different ways. To overcome this, users can write custom code to retrieve this data.
"
Class {
	#name : 'MooseNexusGradleProjectImporter',
	#superclass : 'MooseNexusManagedProjectImporter',
	#instVars : [
		'groupCode',
		'nameCode',
		'versionCode'
	],
	#category : 'MooseNexus-Java-Importer',
	#package : 'MooseNexus-Java',
	#tag : 'Importer'
}

{ #category : 'capabilities' }
MooseNexusGradleProjectImporter class >> buildToolName [

	^ 'gradle'
]

{ #category : 'testing' }
MooseNexusGradleProjectImporter class >> canHandle: directory [

	| directoryReference |
	directoryReference := directory asFileReference.
	directoryReference / 'build.gradle' ifExists: [ ^ true ].
	directoryReference / 'build.gradle.kts' ifExists: [ ^ true ].
	^ false
]

{ #category : 'capabilities' }
MooseNexusGradleProjectImporter class >> supportedLanguages [

	^ #( java )
]

{ #category : 'constants' }
MooseNexusGradleProjectImporter class >> taskName [

	^ 'mooseNexusListDependencies'
]

{ #category : 'enumerating' }
MooseNexusGradleProjectImporter >> findBuildFile [

	directory / 'build.gradle' ifExists: [ :file | ^ file ].
	directory / 'build.gradle.kts' ifExists: [ :file | ^ file ].
	Error signal: 'Cannot find gradle build file'
]

{ #category : 'enumerating' }
MooseNexusGradleProjectImporter >> findGradleCommand [
	"Return the name of the gradle executable, can be a wrapper or the global 'gradle' command."

	OSPlatform current isWindows
		ifTrue: [ directory / 'gradlew.bat' ifExists: [ ^ 'gradlew.bat' ] ]
		ifFalse: [ "assume *nix" directory / 'gradlew' ifExists: [ ^ './gradlew' ] ].
	"assume gradle is installed"
	^ 'gradle'
]

{ #category : 'constants' }
MooseNexusGradleProjectImporter >> groovyCodeForDependencies [
	"Code to append to build.gradle for a pathless list of resolved dependency coordinates."

	^ String streamContents: [ :s |
			  s << 'tasks.register("' << self class taskName
			  <<
			  '") { doLast { def rootDirPath = rootDir.canonicalPath; allprojects.findAll { it.projectDir.canonicalPath.startsWith(rootDirPath) }.each { project -> println("-${'
			  << self groupCode << '}:${' << self nameCode << '}:${' << self versionCode
			  <<
			  '}"); def projectDirPath = project.projectDir.canonicalPath; println(projectDirPath.equals(rootDirPath) ? "." : projectDirPath.substring(rootDirPath.length() + 1)); configurations.findAll { it.canBeResolved }.each { configuration -> def scope = configuration.name; configuration.resolvedConfiguration.resolvedArtifacts.each { artifact -> println("${artifact.moduleVersion.id.group}:${artifact.name}:${artifact.extension ?: "jar"}:${artifact.moduleVersion.id.version}:$scope") } } } } }' ]
]

{ #category : 'accessing' }
MooseNexusGradleProjectImporter >> groupCode [

	^ groupCode ifNil: [ groupCode := 'project.group' ]
]

{ #category : 'accessing' }
MooseNexusGradleProjectImporter >> groupCode: aString [
	"Define the code that returns the group string of a project."

	groupCode := aString
]

{ #category : 'initialization' }
MooseNexusGradleProjectImporter >> initialize [

	super initialize.
	localRepositories := {
		                     MooseNexusGradleRepository default.
		                     MooseNexusMavenRepository default }
]

{ #category : 'constants' }
MooseNexusGradleProjectImporter >> kotlinCodeForDependencies [
	"Code to append to build.gradle.kts for pathless resolved dependency coordinates."

	^ String streamContents: [ :s |
			  s << 'tasks.register("' << self class taskName << '") {'.
			  s crlf tab << 'doLast {'.
			  (s crlf tab: 2) << 'val rootDirPath = rootDir.canonicalPath'.
			  (s crlf tab: 2) << 'allprojects.filter { it.projectDir.canonicalPath.startsWith(rootDirPath) }.forEach { project ->'.
			  (s crlf tab: 3) << 'println("-${' << self groupCode << '}:${' << self nameCode << '}:${' << self versionCode << '}")'.
			  (s crlf tab: 3) << 'val projectDirPath = project.projectDir.canonicalPath'.
			  (s crlf tab: 3)
			  << 'println(if (projectDirPath.equals(rootDirPath)) "." else projectDirPath.substring(rootDirPath.length + 1))'.
			  (s crlf tab: 3) << 'project.configurations.filter { it.isCanBeResolved }.forEach { configuration ->'.
			  (s crlf tab: 4) << 'val scope = configuration.name'.
			  (s crlf tab: 4) << 'configuration.resolvedConfiguration.resolvedArtifacts.forEach { artifact ->'.
			  (s crlf tab: 5)
			  <<
			  'println("${artifact.moduleVersion.id.group}:${artifact.name}:${artifact.extension ?: "jar"}:${artifact.moduleVersion.id.version}:$scope")'.
			  (s crlf tab: 4) nextPut: $}.
			  (s crlf tab: 3) nextPut: $}.
			  (s crlf tab: 2) nextPut: $}.
			  s crlf tab nextPut: $}.
			  s crlf nextPut: $} ]
]

{ #category : 'accessing' }
MooseNexusGradleProjectImporter >> nameCode [

	^ nameCode ifNil: [ nameCode := 'project.name' ]
]

{ #category : 'accessing' }
MooseNexusGradleProjectImporter >> nameCode: aString [
	"Define the code that returns the name string of a project."

	nameCode := aString
]

{ #category : 'instance creation' }
MooseNexusGradleProjectImporter >> newProject [

	^ MooseNexusGradleProject new
]

{ #category : 'parsing' }
MooseNexusGradleProjectImporter >> parse: raw [
	"Parse pathless Gradle-resolved dependency coordinates."

	| lines line index |
	lines := raw lines.
	index := 2.
	[ (line := lines at: (index := index + 1)) isNotEmpty and: [ line first == $- ] ] whileFalse.
	[ (line := lines at: index) isNotEmpty ] whileTrue: [
			| projectData group name version path dependencies |
			projectData := $: split: line allButFirst.
			group := projectData first ifEmpty: [ 'unknown' ].
			name := projectData second.
			version := self validateProjectVersion: projectData third.
			path := lines at: (index := index + 1).
			dependencies := Dictionary new.
			[ (line := lines at: (index := index + 1)) isEmpty or: [ line first == $- ] ] whileFalse: [
					| parts dependency |
					parts := $: split: line.
					dependency := MooseNexusDependencyDescriptor
						              coordinates: (MooseNexusCoordinates group: parts first name: parts second version: (parts at: 4))
						              type: (parts at: 3)
						              scopes: { (parts at: 5) }.
					self addDependency: dependency to: dependencies group: dependency group ].
			project projects at: group at: name put: (MooseNexusManagedProjectDescriptor
					 version: version
					 path: path
					 dependencyGraph: (self dependencyGraphFrom: dependencies)
					 workspaceDependencies: #(  )) ]
]

{ #category : 'reading' }
MooseNexusGradleProjectImporter >> read [
	"Append a temporary dependency query task, run Gradle, and restore the build file even when Gradle fails."

	| buildFile gradleCmd originalSize command commandResult |
	buildFile := self findBuildFile.
	gradleCmd := self findGradleCommand.
	originalSize := buildFile size.
	command := String streamContents: [ :stream |
			           stream << 'cd "' << directory pathString << '" && ' << gradleCmd << ' ' << self class taskName << ' 2>&1; printf "'
			           << self commandExitStatusMarker << '%s" "$?"' ].

	^ [
		  buildFile writeStreamDo: [ :stream |
				  stream
					  setToEnd;
					  crlf;
					  nextPutAll: (buildFile extension = 'kts'
							   ifTrue: [ self kotlinCodeForDependencies ]
							   ifFalse: [ self groovyCodeForDependencies ]) ].

		  commandResult := LibC resultOfCommand: command.
		  self commandOutputFrom: commandResult forToolNamed: 'Gradle' ] ensure: [
		  (File named: buildFile fullName) writeStreamDo: [ :stream | stream truncate: originalSize ] ]
]

{ #category : 'capabilities' }
MooseNexusGradleProjectImporter >> requirements [

	| command |
	command := self findGradleCommand , ' --version'.
	^ { (MooseNexusToolRequirement
		   name: 'Gradle'
		   availabilityValidation: command
		   versionValidation: command
		   expectedVersionDescription: 'Gradle CLI compatible with injected MooseNexus dependency task') }
]

{ #category : 'validating' }
MooseNexusGradleProjectImporter >> validateProjectVersion: version [

	| validatedVersion |
	validatedVersion := super validateProjectVersion: version.
	validatedVersion = 'unspecified' ifTrue: [
		Error signal: 'Cannot infer MooseNexus project version from Gradle unspecified project version' ].
	^ validatedVersion
]

{ #category : 'accessing' }
MooseNexusGradleProjectImporter >> versionCode [

	^ versionCode ifNil: [ versionCode := 'project.version' ]
]

{ #category : 'accessing' }
MooseNexusGradleProjectImporter >> versionCode: aString [
	"Define the code that returns the version string of a project."

	versionCode := aString
]
