Class {
	#name : 'NexusMavenProjectParameterizedTest',
	#superclass : 'ParametrizedTestCase',
	#instVars : [
		'mavenOutput',
		'group',
		'name',
		'version',
		'language',
		'subDirectories',
		'dependencies',
		'project',
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
[INFO] --- dependency:0.0.0:list (default-cli) @ test1 ---
[INFO] 
[INFO] The following files have been resolved:
[INFO]    none
[INFO] 
[INFO]'.

	projects := Dictionary with:
		            group -> (Dictionary with: projectName -> (Dictionary
				              with: #version -> version
				              with: #dependencies -> Dictionary new)).

	^ {
		  (#mavenOutput -> mavenOutput).
		  (#group -> group).
		  (#name -> projectName).
		  (#version -> version).
		  (#language -> language).
		  (#dependencies -> {  }).
		  (#subDirectories -> { ('src/main/' , language) }).
		  (#projects -> projects) }
]

{ #category : 'building suites' }
NexusMavenProjectParameterizedTest class >> case2 [
	"A simple case with one managed project and few dependencies"

	| group projectName version language mavenOutput projects dependencies projectDependencies |
	group := 'org.moose'.
	projectName := 'test2'.
	version := '2.0.1'.
	language := 'java'.

	"result of the `mvn dependency:list` command"
	mavenOutput := '
[INFO] ---------------------< org.moose:test2 >----------------------
[INFO] Building ''Nother Moose Nexus Test2 2.0.1                           [1/1]
[INFO]   from pom.xml
[INFO] -------------------------------[ compile ]-------------------------------
[INFO] 
[INFO] --- dependency:0.0.0:list (default-cli) @ test2 ---
[INFO] 
[INFO] The following files have been resolved:
[INFO]    org.moose:fame:jar:1.1:compile
[INFO]    org.moose:famix:jar:2.0:runtime
[INFO]    com.example:logger:jar:3.14.0:provided
[INFO] 
[INFO]'.

	"expected list of flattened dependencies"
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
					 with: #directory
						 ->
							 (self mavenHome , 'org/moose/fame/1.1/fame-1.1.jar')
								 asFileReference absolutePath pathString).
				(Dictionary
					 with: #name -> 'famix'
					 with: #version -> '2.0'
					 with: #type -> 'jar'
					 with: #scope -> 'runtime'
					 with: #directory
						 ->
							 (self mavenHome , 'org/moose/famix/2.0/famix-2.0.jar')
								 asFileReference absolutePath pathString) };
		at: 'com.example' put: { (Dictionary
				 with: #name -> 'logger'
				 with: #version -> '3.14.0'
				 with: #type -> 'jar'
				 with: #scope -> 'provided'
				 with: #directory
					 ->
						 (self mavenHome , 'com/example/logger/3.14.0/logger-3.14.0.jar')
							 asFileReference absolutePath pathString) }.

	^ {
		  (#mavenOutput -> mavenOutput).
		  (#group -> group).
		  (#name -> projectName).
		  (#version -> version).
		  (#language -> language).
		  (#dependencies -> dependencies).
		  (#subDirectories -> { ('src/main/' , language) }).
		  (#projects -> projects) }
]

{ #category : 'accessing' }
NexusMavenProjectParameterizedTest class >> mavenHome [
	"Where the mock Maven repository is located."

	^ 'pharo-local/nexus/tests/maven/repository/'
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
NexusMavenProjectParameterizedTest >> mavenOutput: aString [

	mavenOutput := aString
]

{ #category : 'accessing' }
NexusMavenProjectParameterizedTest >> name: aString [

	name := aString
]

{ #category : 'tests' }
NexusMavenProjectParameterizedTest >> projects: aCollection [

	projects := aCollection
]

{ #category : 'running' }
NexusMavenProjectParameterizedTest >> setUp [

	| root home |
	super setUp.
	root := 'pharo-local/nexus/tests' asFileReference.

	"initialize mock Maven repository"
	home := (root / 'maven/repository') ensureCreateDirectory.
	dependencies do: [ :dependency |
		| depName depVersion |
		depName := dependency at: #name.
		depVersion := dependency at: #version.
		dependency
			at: #directory
			put:
				(home / ((dependency at: #group) copyReplaceAll: '.' with: '/')
				 / depName / depVersion / (String streamContents: [ :s |
					  s << depName << '-' << depVersion << '.'
					  << (dependency at: #type) ])) ensureCreateFile absolutePath
					pathString ].

	"initialize project"
	subDirectories do: [ :path |
		(root / name / path) ensureCreateDirectory ].
	project := NexusMavenProject new.
	project home: root / 'maven'.
	project directory: root / name.
	project parse: mavenOutput
]

{ #category : 'accessing' }
NexusMavenProjectParameterizedTest >> subDirectories: aCollection [

	subDirectories := aCollection
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
