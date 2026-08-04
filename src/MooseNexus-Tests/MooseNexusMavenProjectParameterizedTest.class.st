Class {
	#name : 'MooseNexusMavenProjectParameterizedTest',
	#superclass : 'ParametrizedTestCase',
	#instVars : [
		'project',
		'importer',
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
MooseNexusMavenProjectParameterizedTest class >> case1 [
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

	projects := Dictionary with: group -> (Dictionary with:
			             projectName
			             ->
			             (MooseNexusManagedProjectDescriptor version: version path: nil dependencyGraph: MooseNexusDependencyGraph empty)).

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
MooseNexusMavenProjectParameterizedTest class >> case2 [
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
[INFO]    org.moose:fame:jar:1.1:runtime
[INFO]    org.moose:famix:jar:2.0:runtime
[INFO]    com.example:logger:jar:3.14.0:provided
[INFO] 
[INFO]'.

	"expected list of resolved dependencies"
	dependencies := {
		                (self
			                 dependencyGroup: group
			                 name: 'fame'
			                 version: '1.1'
			                 type: 'jar'
			                 scopes: #( 'compile' 'runtime' )
			                 path: nil).
		                (self
			                 dependencyGroup: group
			                 name: 'famix'
			                 version: '2.0'
			                 type: 'jar'
			                 scopes: #( 'runtime' )
			                 path: nil).
		                (self
			                 dependencyGroup: 'com.example'
			                 name: 'logger'
			                 version: '3.14.0'
			                 type: 'jar'
			                 scopes: #( 'provided' )
			                 path: nil) }.

	"expected projects to parse"
	projectDependencies := {
		                       (self
			                        dependencyGroup: group
			                        name: 'fame'
			                        version: '1.1'
			                        type: 'jar'
			                        scopes: #( 'compile' 'runtime' )
			                        path: 'mavenRepository').
		                       (self
			                        dependencyGroup: group
			                        name: 'famix'
			                        version: '2.0'
			                        type: 'jar'
			                        scopes: #( 'runtime' )
			                        path: 'mavenRepository').
		                       (self
			                        dependencyGroup: 'com.example'
			                        name: 'logger'
			                        version: '3.14.0'
			                        type: 'jar'
			                        scopes: #( 'provided' )
			                        path: 'mavenRepository') }.
	projects := Dictionary with: group -> (Dictionary with: projectName -> (MooseNexusManagedProjectDescriptor
				              version: version
				              path: nil
				              dependencyGraph: (MooseNexusDependencyGraph dependencies: projectDependencies))).

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

{ #category : 'private' }
MooseNexusMavenProjectParameterizedTest class >> dependency: dependency withPath: path [

	^ MooseNexusDependencyDescriptor
		  coordinates: dependency coordinates
		  type: dependency type
		  scopes: dependency scopes
		  path: path
]

{ #category : 'private' }
MooseNexusMavenProjectParameterizedTest class >> dependencyGroup: group name: dependencyName version: dependencyVersion type: type scopes: scopes path: path [

	^ MooseNexusDependencyDescriptor
		  coordinates: (MooseNexusCoordinates group: group name: dependencyName version: dependencyVersion)
		  type: type
		  scopes: scopes
		  path: path
]

{ #category : 'initialization' }
MooseNexusMavenProjectParameterizedTest class >> initializeCase: aCase withMavenOutput: mavenOutput andDirectories: directories [
	"Some case data is computed here instead of being hard-coded, such as paths."

	| projectName dependencies projects root repositoryPath importer project projectDirectory dependencyResolutionResult |
	projectName := aCase at: #name.
	dependencies := aCase at: #dependencies.
	projects := aCase at: #projects.

	root := 'pharo-local/nexus/tests' asFileReference.
	projectDirectory := (root / projectName) pathString.

	"initialize mock Maven repository"
	repositoryPath := (root / 'mavenRepository') ensureCreateDirectory absolutePath pathString.
	dependencies := dependencies collect: [ :dependency |
			                | depName depVersion depPath |
			                depName := dependency name.
			                depVersion := dependency version.
			                depPath := String streamContents: [ :s |
					                           s << repositoryPath << '/' << (dependency group copyReplaceAll: '.' with: '/') << '/' << depName
					                           << '/' << depVersion << '/' << depName << '-' << depVersion << '.' << dependency type ].
			                "create mock artifact and set the expected path of the artifact"
			                depPath := (depPath asFileReference ensureCreateFile relativeTo: FileLocator home) pathString.
			                self dependency: dependency withPath: depPath ].
	aCase at: #dependencies put: dependencies.

	"compute paths of projects and dependencies"
	projects do: [ :projectGroup |
			projectGroup keysAndValuesDo: [ :subProjectName :subProject |
					| projectDependencies |
					projectDependencies := subProject dependencyGraph dependencies collect: [ :dependency |
							                       | filename path |
							                       filename := String streamContents: [ :s |
								                                   s << dependency name << '-' << dependency version << '.jar' ].
							                       path := ((root / dependency path / (dependency group copyReplaceAll: '.' with: '/')
							                                 / dependency name / dependency version / filename) absolutePath relativeTo:
								                                FileLocator home) pathString.
							                       self dependency: dependency withPath: path ].
					projectGroup at: subProjectName put: (MooseNexusManagedProjectDescriptor
							 version: subProject version
							 path: '.'
							 dependencyGraph:
							 (MooseNexusDependencyGraph dependencies:
								  (MooseNexusManagedProjectImporter new sortedDependencyDescriptors: projectDependencies))) ] ].

	"create the project subdirectories, mostly used to determine the language"
	directories do: [ :path | (root / projectName / 'sources/project' / path) ensureCreateDirectory ].

	"initialize the MooseNexusProject and its importer"
	project := aCase at: #project put: MooseNexusMavenProject new.

	importer := aCase at: #importer put: MooseNexusMavenProjectImporter new.
	importer project: project.
	importer directory: projectDirectory.
	importer localRepositories: { (MooseNexusMavenRepository new directory: (root / 'mavenRepository') pathString) }.

	importer parse: mavenOutput.
	project initializeCoordinates: importer determineCoordinates.
	project directory: projectDirectory.
	dependencyResolutionResult := importer resolveDependencies.
	project dependencies: dependencyResolutionResult dependencies.

	^ aCase associations
]

{ #category : 'building suites' }
MooseNexusMavenProjectParameterizedTest class >> testParameters [

	^ ParametrizedTestMatrix new
		  addCase: self case1;
		  addCase: self case2;
		  yourself
]

{ #category : 'accessing' }
MooseNexusMavenProjectParameterizedTest >> dependencies: aCollection [

	dependencies := aCollection
]

{ #category : 'accessing' }
MooseNexusMavenProjectParameterizedTest >> group: aString [

	group := aString
]

{ #category : 'accessing' }
MooseNexusMavenProjectParameterizedTest >> importer: aMooseNexusMavenProjectImporter [

	importer := aMooseNexusMavenProjectImporter
]

{ #category : 'accessing' }
MooseNexusMavenProjectParameterizedTest >> language: aString [

	language := aString
]

{ #category : 'accessing' }
MooseNexusMavenProjectParameterizedTest >> name: aString [

	name := aString
]

{ #category : 'accessing' }
MooseNexusMavenProjectParameterizedTest >> project: aMooseNexusMavenProject [

	project := aMooseNexusMavenProject
]

{ #category : 'tests' }
MooseNexusMavenProjectParameterizedTest >> projects: aCollection [

	projects := aCollection
]

{ #category : 'tests' }
MooseNexusMavenProjectParameterizedTest >> testDetermineGroup [

	self assert: importer determineGroup equals: group
]

{ #category : 'tests' }
MooseNexusMavenProjectParameterizedTest >> testDetermineLanguage [

	self assert: project determineLanguage equals: language
]

{ #category : 'tests' }
MooseNexusMavenProjectParameterizedTest >> testDetermineName [

	self assert: importer determineName equals: name
]

{ #category : 'tests' }
MooseNexusMavenProjectParameterizedTest >> testDetermineVersion [

	self assert: importer determineVersion equals: version
]

{ #category : 'tests' }
MooseNexusMavenProjectParameterizedTest >> testFlattenDependencies [

	self assertCollection: project dependencies hasSameElements: dependencies
]

{ #category : 'tests' }
MooseNexusMavenProjectParameterizedTest >> testProjects [

	self assert: project projects equals: projects
]

{ #category : 'accessing' }
MooseNexusMavenProjectParameterizedTest >> version: aString [

	version := aString
]
