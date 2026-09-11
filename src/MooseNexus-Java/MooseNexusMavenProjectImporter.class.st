"
I import a Maven project through Maven's structured build-tool output.

I obtain Maven's effective POM to discover active reactor projects and their order, then ask the dependency plugin for each module's resolved JSON tree. The tree preserves Maven's dependency mediation for that module. For the one-model flattened analysis classpath, cross-module conflicts use the configured resolver; the default First Found policy is supplied in effective-POM reactor order, so it is deterministic.

External artifacts are recorded as pathless references during import and are materialized lazily only when extraction needs a dependency classpath.

I support Maven 3.6.3 through Maven 3.x. The floor comes from the pinned Help and Dependency plugins; Maven 4 is rejected until it has a separately validated contract.
"
Class {
	#name : 'MooseNexusMavenProjectImporter',
	#superclass : 'MooseNexusManagedProjectImporter',
	#instVars : [
		'reactorProjectOrder'
	],
	#category : 'MooseNexus-Java-Importer',
	#package : 'MooseNexus-Java',
	#tag : 'Importer'
}

{ #category : 'capabilities' }
MooseNexusMavenProjectImporter class >> buildToolName [

	^ 'maven'
]

{ #category : 'testing' }
MooseNexusMavenProjectImporter class >> canHandle: directory [

	^ (directory asFileReference / 'pom.xml') exists
]

{ #category : 'capabilities' }
MooseNexusMavenProjectImporter class >> minimumMavenVersion [

	^ #( 3 6 3 )
]

{ #category : 'capabilities' }
MooseNexusMavenProjectImporter class >> supportedLanguages [

	^ #( java )
]

{ #category : 'capabilities' }
MooseNexusMavenProjectImporter class >> supportedMavenVersionDescription [

	^ 'Maven 3.6.3 through 3.x; Maven 4 is not yet supported'
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> addExternalDependenciesInTree: node to: dependencies [

	(self isWorkspaceTreeNode: node) ifFalse: [
			(self resolve: (self mavenDescriptorForTreeNode: node)) ifNotNil: [ :mapping |
				self addDependency: mapping value to: dependencies group: mapping key ] ].
	(self treeChildrenOf: node) do: [ :child | self addExternalDependenciesInTree: child to: dependencies ]
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> addExternalDependencyReferencesInTree: node to: dependencies [

	(self isWorkspaceTreeNode: node) ifFalse: [
		self addDependency: (self dependencyReferenceForTreeNode: node) to: dependencies group: (node at: 'groupId') ].
	(self treeChildrenOf: node) do: [ :child | self addExternalDependencyReferencesInTree: child to: dependencies ]
]

{ #category : 'parsing' }
MooseNexusMavenProjectImporter >> analyze [
	"Discover the active Maven reactor before resolving external dependency metadata."

	| effectivePomFile effectivePomXml |
	effectivePomFile := self temporaryOutputFileWithExtension: 'xml'.
	[
		self writeEffectivePomTo: effectivePomFile.
		effectivePomXml := effectivePomFile contents.
		self parseEffectivePom: effectivePomXml.
		self enrichExternalDependencies ] ensure: [ effectivePomFile deleteIfAbsent: [ ] ]
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> childNamed: name in: element [

	^ element nodes detect: [ :node | node isElement and: [ node name = name ] ] ifNone: [ nil ]
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> childrenNamed: name in: element [

	^ element nodes select: [ :node | node isElement and: [ node name = name ] ]
]

{ #category : 'querying' }
MooseNexusMavenProjectImporter >> dependencyDescriptorsForResolution [
	"Answer dependency descriptors in the Maven reactor order captured from the effective POM."

	reactorProjectOrder ifNil: [ ^ super dependencyDescriptorsForResolution ].
	^ Array streamContents: [ :stream |
			  reactorProjectOrder do: [ :projectKey |
					  | descriptor |
					  descriptor := (project projects at: projectKey first) at: projectKey second.
					  descriptor dependencyGraph do: [ :dependency | stream nextPut: dependency ] ] ]
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> dependencyReferenceForTreeNode: node [

	^ MooseNexusDependencyDescriptor
		  coordinates: (MooseNexusCoordinates group: (node at: 'groupId') name: (node at: 'artifactId') version: (node at: 'version'))
		  type: (node at: 'type')
		  scopes: { (node at: 'scope' ifAbsent: [ 'compile' ]) }
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> effectiveProjectElementsFrom: xmlString [

	| root |
	root := (XMLDOMParser parse: xmlString) document root.
	root name = 'project' ifTrue: [ ^ { root } ].
	^ root nodes select: [ :node | node isElement and: [ node name = 'project' ] ]
]

{ #category : 'parsing' }
MooseNexusMavenProjectImporter >> enrichExternalDependencies [

	project projects keysAndValuesDo: [ :group :projectsByName |
		projectsByName keysAndValuesDo: [ :name :descriptor | self enrichExternalDependenciesOf: descriptor group: group name: name ] ]
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> enrichExternalDependenciesOf: descriptor group: group name: name [

	| treeFile tree dependencies |
	treeFile := self temporaryOutputFileWithExtension: 'json'.
	[
		self writeDependencyTreeForGroup: group name: name to: treeFile.
		tree := STONJSON fromString: treeFile contents.
		dependencies := self resolvedExternalDependenciesInTree: tree.
		project projects at: group at: name put: (MooseNexusManagedProjectDescriptor
				 version: descriptor version
				 path: descriptor path
				 dependencyGraph: (self dependencyGraphFrom: dependencies)
				 workspaceDependencies: descriptor workspaceDependencies) ] ensure: [ treeFile deleteIfAbsent: [ ] ]
]

{ #category : 'enumerating' }
MooseNexusMavenProjectImporter >> findMavenCommand [
	"Return the name of the maven executable, can be a wrapper or the global 'mvn' command."

	OSPlatform current isWindows
		ifTrue: [ directory / 'mvnw.cmd' ifExists: [ ^ 'mvnw.cmd' ] ]
		ifFalse: [ "assume *nix" directory / 'mvnw' ifExists: [ ^ './mvnw' ] ].
	"assume maven is installed"
	^ 'mvn'
]

{ #category : 'initialization' }
MooseNexusMavenProjectImporter >> initialize [

	localRepositories := { MooseNexusMavenRepository default }
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> isSupportedMavenVersion: versionString [

	| components minimumVersion major minor patch |
	components := versionString findTokens: '.-'.
	components size < 3 ifTrue: [ ^ false ].
	minimumVersion := self class minimumMavenVersion.
	major := components first asInteger.
	major = minimumVersion first ifFalse: [ ^ false ].
	minor := components second asInteger.
	patch := components third asInteger.
	^ minor > minimumVersion second or: [ minor = minimumVersion second and: [ patch >= minimumVersion third ] ]
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> isWorkspaceDependencyElement: element [

	| group name version descriptor |
	group := self valueNamed: 'groupId' in: element.
	name := self valueNamed: 'artifactId' in: element.
	version := self valueNamed: 'version' in: element.
	descriptor := (project projects at: group ifAbsent: [ ^ false ]) at: name ifAbsent: [ ^ false ].
	^ descriptor version = version
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> isWorkspaceTreeNode: node [

	| group name version descriptor |
	group := node at: 'groupId'.
	name := node at: 'artifactId'.
	version := node at: 'version'.
	descriptor := (project projects at: group ifAbsent: [ ^ false ]) at: name ifAbsent: [ ^ false ].
	^ descriptor version = version
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> mavenDescriptorForTreeNode: node [

	^ String streamContents: [ :stream |
			  stream
				  nextPutAll: (node at: 'groupId');
				  nextPut: $:;
				  nextPutAll: (node at: 'artifactId');
				  nextPut: $:;
				  nextPutAll: (node at: 'type');
				  nextPut: $:;
				  nextPutAll: (node at: 'version');
				  nextPut: $:;
				  nextPutAll: (node at: 'scope' ifAbsent: [ 'compile' ]) ]
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> mavenVersionFrom: versionDetails [

	| prefix versionString |
	prefix := 'Apache Maven '.
	(versionDetails beginsWith: prefix) ifFalse: [ Error signal: 'Cannot determine Maven version from: ' , versionDetails ].
	versionString := (versionDetails allButFirst: prefix size) , ' ' copyUpTo: Character space.
	versionString ifEmpty: [ Error signal: 'Cannot determine Maven version from: ' , versionDetails ].
	^ versionString
]

{ #category : 'instance creation' }
MooseNexusMavenProjectImporter >> newProject [

	^ MooseNexusMavenProject new
]

{ #category : 'parsing' }
MooseNexusMavenProjectImporter >> parseEffectivePom: xmlString [

	| projectElements |
	projectElements := self effectiveProjectElementsFrom: xmlString.
	self reactorProjectOrder: (projectElements collect: [ :element |
				 {
					 (self valueNamed: 'groupId' in: element).
					 (self valueNamed: 'artifactId' in: element) } ]).
	projectElements do: [ :element | self registerEffectiveProject: element ].
	projectElements do: [ :element | self registerWorkspaceDependenciesOf: element ]
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> pathForProjectGroup: group name: name [

	| output path |
	output := self runMavenArguments: {
			          '-q'.
			          '-pl'.
			          (group , ':' , name).
			          'org.apache.maven.plugins:maven-help-plugin:3.5.1:evaluate'.
			          '-Dexpression=project.basedir'.
			          '-DforceStdout' }.
	path := output trimBoth asFileReference.
	(path = directory or: [ path isContainedBy: directory ]) ifFalse: [
		Error signal: 'Maven reactor project is outside the imported directory: ' , path pathString ].
	^ (path relativeTo: directory) pathString
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> reactorProjectOrder: projectKeys [
	"Set the Maven reactor order as group/artifact key pairs."

	reactorProjectOrder := projectKeys asArray
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> registerEffectiveProject: element [

	| group name version path |
	group := self valueNamed: 'groupId' in: element.
	name := self valueNamed: 'artifactId' in: element.
	version := self valueNamed: 'version' in: element.
	path := self pathForProjectGroup: group name: name.
	project projects at: group at: name put: (MooseNexusManagedProjectDescriptor
			 version: version
			 path: path
			 dependencyGraph: MooseNexusDependencyGraph empty
			 workspaceDependencies: #(  ))
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> registerWorkspaceDependenciesOf: element [

	| group name descriptor workspaceDependencies |
	group := self valueNamed: 'groupId' in: element.
	name := self valueNamed: 'artifactId' in: element.
	descriptor := project projects at: group at: name.
	workspaceDependencies := self workspaceDependenciesDeclaredIn: element.
	project projects at: group at: name put: (MooseNexusManagedProjectDescriptor
			 version: descriptor version
			 path: descriptor path
			 dependencyGraph: descriptor dependencyGraph
			 workspaceDependencies: workspaceDependencies)
]

{ #category : 'capabilities' }
MooseNexusMavenProjectImporter >> requirements [

	| command |
	command := self findMavenCommand , ' --version'.
	^ { (MooseNexusToolRequirement
		   name: 'Maven'
		   availabilityValidation: command
		   versionValidation: command
		   expectedVersionDescription: self class supportedMavenVersionDescription) }
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> resolvedExternalDependenciesInTree: tree [

	| dependencies |
	dependencies := Dictionary new.
	(self treeChildrenOf: tree) do: [ :node | self addExternalDependencyReferencesInTree: node to: dependencies ].
	^ dependencies
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> runMavenArguments: arguments [

	| command commandResult |
	command := String streamContents: [ :stream |
			           stream << 'cd "' << directory pathString << '" && ' << self findMavenCommand << ' --batch-mode'.
			           arguments do: [ :argument | stream space << argument ].
			           stream << '; printf "' << self commandExitStatusMarker << '%s" "$?"' ].
	commandResult := LibC resultOfCommand: command.
	^ self commandOutputFrom: commandResult forToolNamed: 'Maven'
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> temporaryOutputFileWithExtension: extension [

	^ FileLocator temp / ('moosenexus-maven-' , UUID new asString , '.' , extension)
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> treeChildrenOf: node [

	^ node at: 'children' ifAbsent: [ #(  ) ]
]

{ #category : 'validating' }
MooseNexusMavenProjectImporter >> validateMavenVersion: versionDetails [

	| versionString |
	versionString := self mavenVersionFrom: versionDetails.
	(self isSupportedMavenVersion: versionString) ifFalse: [
			Error signal:
				'Unsupported Maven version ' , versionString , '. MooseNexus requires ' , self class supportedMavenVersionDescription ].
	^ versionString
]

{ #category : 'validating' }
MooseNexusMavenProjectImporter >> validateRequirements [

	| validationResults mavenValidation |
	validationResults := super validateRequirements.
	mavenValidation := validationResults detect: [ :each | each requirementName = 'Maven' ].
	self validateMavenVersion: mavenValidation versionDetails.
	^ validationResults
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> valueNamed: name in: element [

	| child |
	child := self childNamed: name in: element.
	child ifNil: [ ^ nil ].
	^ child nodes ifEmpty: [ '' ] ifNotEmpty: [ child nodes first asString ]
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> workspaceDependenciesDeclaredIn: element [

	| dependenciesElement |
	dependenciesElement := self childNamed: 'dependencies' in: element.
	dependenciesElement ifNil: [ ^ #(  ) ].
	^ (self childrenNamed: 'dependency' in: dependenciesElement)
		  select: [ :dependencyElement | self isWorkspaceDependencyElement: dependencyElement ]
		  thenCollect: [ :dependencyElement | self workspaceDependencyFrom: dependencyElement ]
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> workspaceDependencyFrom: element [

	^ MooseNexusWorkspaceDependencyDescriptor
		  coordinates: (MooseNexusCoordinates
				   group: (self valueNamed: 'groupId' in: element)
				   name: (self valueNamed: 'artifactId' in: element)
				   version: (self valueNamed: 'version' in: element))
		  scopes: { ((self valueNamed: 'scope' in: element) ifNil: [ 'compile' ]) }
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> writeDependencyTreeForGroup: group name: name to: outputFile [

	self runMavenArguments: {
			'-pl'.
			(group , ':' , name).
			'-am'.
			'org.apache.maven.plugins:maven-dependency-plugin:3.8.1:tree'.
			'-DoutputType=json'.
			('-DoutputFile=' , outputFile pathString) }
]

{ #category : 'private' }
MooseNexusMavenProjectImporter >> writeEffectivePomTo: outputFile [

	self runMavenArguments: {
			'org.apache.maven.plugins:maven-help-plugin:3.5.1:effective-pom'.
			('-Doutput=' , outputFile pathString) }
]
