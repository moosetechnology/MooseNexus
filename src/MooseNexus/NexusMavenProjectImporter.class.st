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
		ifTrue: [
		directory asFileReference / 'mvnw.cmd' ifExists: [ ^ 'mvnw.cmd' ] ]
		ifFalse: [ "assume *nix"
			directory asFileReference / 'mvnw' ifExists: [ ^ './mvnw' ] ].
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
	newLines := String with: Character cr with: Character lf.
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
		project projects at: projectGroup at: projectName put: descriptor.

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

{ #category : 'reading' }
NexusMavenProjectImporter >> read [
	"Runs the `mvn` command using the `dependency:resolve` plugin.
	Requires Maven to be installed."

	^ LibC resultOfCommand:
		  'cd "' , directory , '" && ' , self findMavenCommand
		  , ' --batch-mode dependency:resolve'
]
