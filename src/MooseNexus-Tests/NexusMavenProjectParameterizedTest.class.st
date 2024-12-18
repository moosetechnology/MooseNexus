Class {
	#name : 'NexusMavenProjectParameterizedTest',
	#superclass : 'ParametrizedTestCase',
	#instVars : [
		'project',
		'group',
		'name',
		'version',
		'language',
		'dependencies',
		'projects'
	],
	#category : 'MooseNexus-Tests',
	#package : 'MooseNexus-Tests'
}

{ #category : 'building suites' }
NexusMavenProjectParameterizedTest class >> case1 [
	"A simple case with one managed project and no dependencies"

	| group projectName version language mavenOutput projects |
	group := 'org.moose'.
	projectName := 'test1'.
	version := '1.0.0'.
	language := 'java'.

	mavenOutput := '
[INFO] ---------------------< org.moose:test1 >----------------------
[INFO] Building Maven Moose Nexus Test1 1.0.0                              [1/1]
[INFO]   from pom.xml
[INFO] -------------------------------[ compile ]-------------------------------
[INFO] 
[INFO] --- dependency:0.0.0:resolve (default-cli) @ test1 ---
[INFO] 
[INFO] The following files have been resolved:
[INFO]    none
[INFO] 
[INFO]'.

	projects := Dictionary with:
		            group -> (Dictionary with: projectName -> (Dictionary
				              with: #version -> version
				              with: #dependencies -> Dictionary new)).

	^ self
		  initializeCase: {
				  (#group -> group).
				  (#name -> projectName).
				  (#version -> version).
				  (#language -> language).
				  (#dependencies -> {  }).
				  (#projects -> projects) } asDictionary
		  withMavenOutput: mavenOutput
		  andDirectories: { ('src/main/' , language) }
]

{ #category : 'building suites' }
NexusMavenProjectParameterizedTest class >> case2 [
	"A simple case with one managed project and few dependencies"

	| group projectName version language mavenOutput projects dependencies projectDependencies |
	group := 'org.moose'.
	projectName := 'test2'.
	version := '2.0.1'.
	language := 'java'.

	"result of the `mvn dependency:resolve` command"
	mavenOutput := '
[INFO] ---------------------< org.moose:test2 >----------------------
[INFO] Building ''Nother Moose Nexus Test2 2.0.1                           [1/1]
[INFO]   from pom.xml
[INFO] -------------------------------[ compile ]-------------------------------
[INFO] 
[INFO] --- dependency:0.0.0:resolve (default-cli) @ test2 ---
[INFO] 
[INFO] The following files have been resolved:
[INFO]    org.moose:fame:jar:1.1:compile
[INFO]    org.moose:famix:jar:2.0:runtime
[INFO]    com.example:logger:jar:3.14.0:provided
[INFO] 
[INFO]'.

	"expected list of flat dependencies"
	dependencies := {
		                (Dictionary
			                 with: #group -> group
			                 with: #name -> 'fame'
			                 with: #version -> '1.1'
			                 with: #type -> 'jar'
			                 with: #scope -> 'compile').
		                (Dictionary
			                 with: #group -> group
			                 with: #name -> 'famix'
			                 with: #version -> '2.0'
			                 with: #type -> 'jar'
			                 with: #scope -> 'runtime').
		                (Dictionary
			                 with: #group -> 'com.example'
			                 with: #name -> 'logger'
			                 with: #version -> '3.14.0'
			                 with: #type -> 'jar'
			                 with: #scope -> 'provided') }.

	"expected projects to parse"
	(projects := Dictionary new)
		at: group
		put: (Dictionary with: projectName -> (Dictionary
					  with: #version -> version
					  with: #dependencies -> (projectDependencies := Dictionary new))).
	projectDependencies
		at: 'org.moose' put: {
				(Dictionary
					 with: #name -> 'fame'
					 with: #version -> '1.1'
					 with: #type -> 'jar'
					 with: #scope -> 'compile'
					 with: #path -> 'mavenRepository').
				(Dictionary
					 with: #name -> 'famix'
					 with: #version -> '2.0'
					 with: #type -> 'jar'
					 with: #scope -> 'runtime'
					 with: #path -> 'mavenRepository') };
		at: 'com.example' put: { (Dictionary
				 with: #name -> 'logger'
				 with: #version -> '3.14.0'
				 with: #type -> 'jar'
				 with: #scope -> 'provided'
				 with: #path -> 'mavenRepository') }.

	^ self
		  initializeCase: {
				  (#group -> group).
				  (#name -> projectName).
				  (#version -> version).
				  (#language -> language).
				  (#dependencies -> dependencies).
				  (#projects -> projects) } asDictionary
		  withMavenOutput: mavenOutput
		  andDirectories: { ('src/main/' , language) }
]

{ #category : 'initialization' }
NexusMavenProjectParameterizedTest class >> initializeCase: aCase withMavenOutput: mavenOutput andDirectories: directories [
	"Some case data is computed here instead of being hard-coded, such as paths."

	| projectName dependencies projects root repositoryPath project |
	projectName := aCase at: #name.
	dependencies := aCase at: #dependencies.
	projects := aCase at: #projects.

	root := 'pharo-local/nexus/tests' asFileReference.

	"initialize mock Maven repository"
	repositoryPath := (root / 'mavenRepository') ensureCreateDirectory
		                  absolutePath pathString.
	dependencies do: [ :dependency |
		| depName depVersion depPath |
		depName := dependency at: #name.
		depVersion := dependency at: #version.
		depPath := String streamContents: [ :s |
			           s << repositoryPath << '/'
			           <<
			           ((dependency at: #group) copyReplaceAll: '.' with: '/')
			           << '/' << depName << '/' << depVersion << '/' << depName
			           << '-' << depVersion << '.' << (dependency at: #type) ].
		"create mock artifact and set the expected path of the artifact"
		depPath := (depPath asFileReference ensureCreateFile relativeTo:
			            FileLocator home) pathString.
		dependency at: #path put: depPath ].

	"compute paths of dependencies of subprojects"
	projects do: [ :projectGroup |
		projectGroup do: [ :subProject |
			(subProject at: #dependencies) keysAndValuesDo: [
				:groupName
				:dependencyGroup |
				dependencyGroup do: [ :dependency | "'dependency at: #path' is the repository name only, compute the rest of the path"
					| depName depVersion filename path |
					depName := dependency at: #name.
					depVersion := dependency at: #version.
					filename := String streamContents: [ :s |
						            s << depName << '-' << depVersion << '.jar' ].
					path := ((root / (dependency at: #path)
					          / (groupName copyReplaceAll: '.' with: '/') / depName
					          / depVersion / filename) absolutePath relativeTo:
						         FileLocator home) pathString.
					dependency at: #path put: path ] ] ] ].

	"create the project subdirectories, mostly used to determine the language"
	directories do: [ :path |
		(root / projectName / path) ensureCreateDirectory ].

	"initialize the NexusProject"
	project := aCase at: #project put: NexusMavenProject new.
	project localRepositories: { (NexusMavenRepository new directory:
			 (root / 'mavenRepository') pathString) }.
	project directory: root / projectName.
	project parse: mavenOutput.

	^ aCase associations
]

{ #category : 'building suites' }
NexusMavenProjectParameterizedTest class >> testParameters [

	^ ParametrizedTestMatrix new
		  addCase: self case1;
		  addCase: self case2;
		  yourself
]

{ #category : 'accessing' }
NexusMavenProjectParameterizedTest >> dependencies: aCollection [

	dependencies := aCollection
]

{ #category : 'accessing' }
NexusMavenProjectParameterizedTest >> group: aString [

	group := aString
]

{ #category : 'accessing' }
NexusMavenProjectParameterizedTest >> language: aString [

	language := aString
]

{ #category : 'accessing' }
NexusMavenProjectParameterizedTest >> name: aString [

	name := aString
]

{ #category : 'accessing' }
NexusMavenProjectParameterizedTest >> project: aNexusMavenProject [

	project := aNexusMavenProject
]

{ #category : 'tests' }
NexusMavenProjectParameterizedTest >> projects: aCollection [

	projects := aCollection
]

{ #category : 'tests' }
NexusMavenProjectParameterizedTest >> testDetermineDependencies [

	self
		assertCollection: project determineDependencies
		hasSameElements: dependencies
]

{ #category : 'tests' }
NexusMavenProjectParameterizedTest >> testDetermineGroup [

	self assert: project determineGroup equals: group
]

{ #category : 'tests' }
NexusMavenProjectParameterizedTest >> testDetermineLanguage [

	self assert: project determineLanguage equals: language
]

{ #category : 'tests' }
NexusMavenProjectParameterizedTest >> testDetermineName [

	self assert: project determineName equals: name
]

{ #category : 'tests' }
NexusMavenProjectParameterizedTest >> testDetermineVersion [

	self assert: project determineVersion equals: version
]

{ #category : 'tests' }
NexusMavenProjectParameterizedTest >> testProjects [

	self assert: project projects equals: projects
]

{ #category : 'accessing' }
NexusMavenProjectParameterizedTest >> version: aString [

	version := aString
]
