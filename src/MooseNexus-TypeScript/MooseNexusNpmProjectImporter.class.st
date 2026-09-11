"
I import npm project metadata from package.json and package-lock.json.

I read locked npm package references directly without invoking npm, contacting a registry, or downloading packages. Recording an npm project requires explicit MooseNexus project coordinates.
"
Class {
	#name : 'MooseNexusNpmProjectImporter',
	#superclass : 'MooseNexusProjectImporter',
	#instVars : [
		'dependencyResolutionResult'
	],
	#category : 'MooseNexus-TypeScript-Importer',
	#package : 'MooseNexus-TypeScript',
	#tag : 'Importer'
}

{ #category : 'capabilities' }
MooseNexusNpmProjectImporter class >> buildToolName [

	^ 'npm'
]

{ #category : 'testing' }
MooseNexusNpmProjectImporter class >> canHandle: directory [

	^ (directory asFileReference / 'package.json') exists
]

{ #category : 'capabilities' }
MooseNexusNpmProjectImporter class >> supportedLanguages [

	^ #( typescript )
]

{ #category : 'parsing' }
MooseNexusNpmProjectImporter >> dependenciesFrom: packageLock [

	| packageEntries dependencies |
	self lockfileVersionFrom: packageLock.
	packageEntries := packageLock at: 'packages' ifAbsent: [ Error signal: 'npm package-lock.json has no packages section' ].
	dependencies := OrderedCollection new.
	(packageEntries associations sorted: [ :left :right | left key <= right key ]) do: [ :association |
			(self isExternalPackageAt: association key metadata: association value) ifTrue: [
				dependencies add: (self dependencyAt: association key metadata: association value) ] ].
	^ dependencies asArray
]

{ #category : 'parsing' }
MooseNexusNpmProjectImporter >> dependencyAt: packagePath metadata: metadata [

	^ MooseNexusNpmDependencyDescriptor
		  packageName: (self packageNameForPackagePath: packagePath)
		  version: (metadata at: 'version')
		  scopes: (self scopesFor: metadata)
		  resolvedUrl: (metadata at: 'resolved' ifAbsent: [ nil ])
		  integrity: (metadata at: 'integrity' ifAbsent: [ nil ])
]

{ #category : 'querying' }
MooseNexusNpmProjectImporter >> dependencyResolutionResult [

	^ dependencyResolutionResult ifNil: [ MooseNexusDependencyResolutionResult forProject: project ]
]

{ #category : 'importing' }
MooseNexusNpmProjectImporter >> import [

	Error signal: 'npm project imports require explicit MooseNexus coordinates'
]

{ #category : 'importing' }
MooseNexusNpmProjectImporter >> importWithCoordinates: aMooseNexusCoordinates [

	| packageLock dependencies |
	aMooseNexusCoordinates ifNil: [ Error signal: 'npm project imports require explicit MooseNexus coordinates' ].
	project ifNil: [ project := self newProject ].
	packageLock := self packageLock.
	project initializeCoordinates: aMooseNexusCoordinates.
	project packageLockVersion: (self lockfileVersionFrom: packageLock).
	dependencies := self dependenciesFrom: packageLock.
	project dependencies: dependencies.
	dependencyResolutionResult := MooseNexusDependencyResolutionResult
		                              project: project
		                              dependencies: dependencies
		                              warnings: #(  )
		                              decisions: #(  ).
	^ project
]

{ #category : 'testing' }
MooseNexusNpmProjectImporter >> isExternalPackageAt: packagePath metadata: metadata [

	| version resolved |
	packagePath isEmpty ifTrue: [ ^ false ].
	(metadata at: 'link' ifAbsent: [ false ]) ifTrue: [ ^ false ].
	version := metadata at: 'version' ifAbsent: [ ^ false ].
	(version beginsWith: 'file:') ifTrue: [ ^ false ].
	(version beginsWith: 'workspace:') ifTrue: [ ^ false ].
	resolved := metadata at: 'resolved' ifAbsent: [ '' ].
	^ (resolved beginsWith: 'file:') not
]

{ #category : 'parsing' }
MooseNexusNpmProjectImporter >> lockfileVersionFrom: packageLock [

	| version |
	version := packageLock at: 'lockfileVersion' ifAbsent: [ Error signal: 'npm package-lock.json has no lockfileVersion' ].
	(#( 2 3 ) includes: version) ifFalse: [ Error signal: 'Unsupported npm package-lock.json version: ' , version asString ].
	^ version
]

{ #category : 'instance creation' }
MooseNexusNpmProjectImporter >> newProject [

	^ MooseNexusNpmProject new
]

{ #category : 'reading' }
MooseNexusNpmProjectImporter >> packageLock [

	| file |
	file := directory / 'package-lock.json'.
	file exists ifFalse: [ Error signal: 'npm import requires a committed package-lock.json' ].
	^ file readStreamDo: [ :stream | STON fromStream: stream ]
]

{ #category : 'parsing' }
MooseNexusNpmProjectImporter >> packageNameForPackagePath: packagePath [

	| segments nodeModulesIndex packageName |
	segments := packagePath substrings: '/'.
	nodeModulesIndex := 0.
	segments withIndexDo: [ :segment :index | segment = 'node_modules' ifTrue: [ nodeModulesIndex := index ] ].
	nodeModulesIndex isZero ifTrue: [ Error signal: 'Cannot determine npm package name from lockfile path: ' , packagePath ].
	packageName := segments at: nodeModulesIndex + 1.
	(packageName beginsWith: '@') ifTrue: [ packageName := packageName , '/' , (segments at: nodeModulesIndex + 2) ].
	^ packageName
]

{ #category : 'parsing' }
MooseNexusNpmProjectImporter >> scopesFor: metadata [

	| scopes |
	scopes := OrderedCollection new.
	(metadata at: 'dev' ifAbsent: [ false ]) ifTrue: [ scopes add: 'dev' ].
	(metadata at: 'optional' ifAbsent: [ false ]) ifTrue: [ scopes add: 'optional' ].
	(metadata at: 'peer' ifAbsent: [ false ]) ifTrue: [ scopes add: 'peer' ].
	scopes ifEmpty: [ scopes add: 'runtime' ].
	^ scopes asArray
]
