"
I detect TypeScript source evidence.

A tsconfig.json file is direct TypeScript evidence. In its absence I look for TypeScript source files while excluding dependency and common generated-output directories.
"
Class {
	#name : 'MooseNexusTypeScriptLanguageDetector',
	#superclass : 'MooseNexusLanguageDetector',
	#category : 'MooseNexus-TypeScript-Project',
	#package : 'MooseNexus-TypeScript',
	#tag : 'Project'
}

{ #category : 'detecting' }
MooseNexusTypeScriptLanguageDetector class >> evidenceIn: aDirectory [

	| evidence |
	evidence := OrderedCollection new.
	aDirectory / 'tsconfig.json' ifExists: [ :config | evidence add: (config relativeTo: aDirectory) pathString ].
	(self sourceFilesIn: aDirectory) do: [ :sourceFile | evidence add: (sourceFile relativeTo: aDirectory) pathString ].
	^ evidence asArray
]

{ #category : 'constants' }
MooseNexusTypeScriptLanguageDetector class >> ignoredDirectoryNames [

	^ #( 'node_modules' 'dist' 'build' 'out' )
]

{ #category : 'testing' }
MooseNexusTypeScriptLanguageDetector class >> isSourceFile: aFileReference [

	^ (self ignoredDirectoryNames noneSatisfy: [ :directoryName | aFileReference pathSegments includes: directoryName ]) and: [
		  (#( 'ts' 'tsx' ) includes: aFileReference extension) and: [ (aFileReference basename endsWith: '.d.ts') not ] ]
]

{ #category : 'capabilities' }
MooseNexusTypeScriptLanguageDetector class >> language [

	^ 'typescript'
]

{ #category : 'detecting' }
MooseNexusTypeScriptLanguageDetector class >> sourceFilesIn: aDirectory [

	^ aDirectory allFiles select: [ :file | self isSourceFile: file ]
]
