"
I test npm lockfile dependency metadata without invoking npm or a registry.
"
Class {
	#name : 'MooseNexusNpmProjectImporterTest',
	#superclass : 'TestCase',
	#category : 'MooseNexus-TypeScript-Tests-Importer',
	#package : 'MooseNexus-TypeScript-Tests',
	#tag : 'Importer'
}

{ #category : 'helpers' }
MooseNexusNpmProjectImporterTest >> packageLockWithPackages: packages [

	^ Dictionary new
		  add: 'lockfileVersion' -> 3;
		  add: 'packages' -> packages;
		  yourself
]

{ #category : 'helpers' }
MooseNexusNpmProjectImporterTest >> packageMetadataVersion: version resolvedUrl: resolvedUrl integrity: integrity [

	^ Dictionary new
		  add: 'version' -> version;
		  add: 'resolved' -> resolvedUrl;
		  add: 'integrity' -> integrity;
		  yourself
]

{ #category : 'tests' }
MooseNexusNpmProjectImporterTest >> testExcludesLinkedAndFileDependencies [

	| importer packages dependencies |
	packages := Dictionary new.
	packages at: 'node_modules/linked' put: (Dictionary new
			 add: 'version' -> '1.0.0';
			 add: 'link' -> true;
			 yourself).
	packages at: 'node_modules/file-based' put: (Dictionary new
			 add: 'version' -> 'file:../file-based';
			 add: 'resolved' -> 'file:../file-based';
			 yourself).
	importer := MooseNexusNpmProjectImporter new.

	dependencies := importer dependenciesFrom: (self packageLockWithPackages: packages).

	self assert: dependencies isEmpty
]

{ #category : 'tests' }
MooseNexusNpmProjectImporterTest >> testNpmProjectIsManagedWithoutMultiModuleMetadata [

	| project properties |
	project := MooseNexusNpmProject new.
	project initializeCoordinates: (MooseNexusCoordinates group: 'org.example' name: 'npm-project' version: '1.0.0').
	project language: 'typescript'.
	properties := project properties.

	self assert: project isManagedProject.
	self deny: (properties includesKey: #projects).
	self assert: (properties at: #language) equals: 'typescript'
]

{ #category : 'tests' }
MooseNexusNpmProjectImporterTest >> testNpmReferenceRoundTripsThroughGenericDependencyReader [

	| descriptor reloaded |
	descriptor := MooseNexusNpmDependencyDescriptor
		              packageName: '@scope/library'
		              version: '2.0.0'
		              scopes: #( 'runtime' )
		              resolvedUrl: 'https://registry.example.test/library-2.0.0.tgz'
		              integrity: 'sha512-library'.

	reloaded := MooseNexusDependencyDescriptor fromDictionary: descriptor asDictionary.

	self assert: reloaded equals: descriptor.
	self assert: reloaded class equals: MooseNexusNpmDependencyDescriptor
]

{ #category : 'tests' }
MooseNexusNpmProjectImporterTest >> testParsesPortableScopedAndUnscopedNpmReferences [

	| importer packages dependencies lodash scoped |
	packages := Dictionary new.
	packages at: '' put: (Dictionary new
			 add: 'name' -> 'demo';
			 yourself).
	packages at: 'node_modules/lodash' put: (self
			 packageMetadataVersion: '4.17.21'
			 resolvedUrl: 'https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz'
			 integrity: 'sha512-lodash').
	packages at: 'node_modules/@scope/library' put: (self
			 packageMetadataVersion: '2.0.0'
			 resolvedUrl: 'https://registry.example.test/@scope/library/-/library-2.0.0.tgz'
			 integrity: 'sha512-scoped').
	importer := MooseNexusNpmProjectImporter new.

	dependencies := importer dependenciesFrom: (self packageLockWithPackages: packages).
	lodash := dependencies detect: [ :dependency | dependency name = 'lodash' ].
	scoped := dependencies detect: [ :dependency | dependency name = '@scope/library' ].

	self assert: dependencies size equals: 2.
	self assert: lodash class equals: MooseNexusNpmDependencyDescriptor.
	self assert: lodash group equals: 'npm'.
	self assert: lodash version equals: '4.17.21'.
	self assert: lodash resolvedUrl equals: 'https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz'.
	self assert: scoped integrity equals: 'sha512-scoped'.
	self assert: (lodash asDictionary at: 'ecosystem') equals: 'npm'.
	self deny: lodash isLocal.
	self deny: lodash supportsClasspathMaterialization
]

{ #category : 'tests' }
MooseNexusNpmProjectImporterTest >> testPreservesDependencyRolesAndSkipsNpmMaterialization [

	| importer metadata dependency policy |
	metadata := self
		            packageMetadataVersion: '1.0.0'
		            resolvedUrl: 'https://registry.example.test/library-1.0.0.tgz'
		            integrity: 'sha512-library'.
	metadata at: 'dev' put: true.
	metadata at: 'optional' put: true.
	importer := MooseNexusNpmProjectImporter new.
	dependency := importer dependencyAt: 'node_modules/library' metadata: metadata.
	policy := MooseNexusDependencyClasspathSelectionPolicy all.

	self assertCollection: dependency scopes hasSameElements: #( 'dev' 'optional' ).
	self deny: (policy includesDependency: dependency)
]

{ #category : 'tests' }
MooseNexusNpmProjectImporterTest >> testRejectsUnsupportedLockfileVersion [

	| importer |
	importer := MooseNexusNpmProjectImporter new.

	self
		should: [
				importer dependenciesFrom: (Dictionary new
						 add: 'lockfileVersion' -> 1;
						 add: 'packages' -> Dictionary new;
						 yourself) ]
		raise: Error
]
