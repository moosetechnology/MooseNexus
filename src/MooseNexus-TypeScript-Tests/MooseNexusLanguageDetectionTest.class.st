"
I test source-language detection independently from build-system importers.
"
Class {
	#name : 'MooseNexusLanguageDetectionTest',
	#superclass : 'TestCase',
	#instVars : [
		'rootDirectory'
	],
	#category : 'MooseNexus-TypeScript-Tests-Project',
	#package : 'MooseNexus-TypeScript-Tests',
	#tag : 'Project'
}

{ #category : 'running' }
MooseNexusLanguageDetectionTest >> setUp [

	super setUp.
	rootDirectory := FileLocator temp / ('MooseNexus-language-detection-' , UUID new asString).
	rootDirectory ensureCreateDirectory
]

{ #category : 'running' }
MooseNexusLanguageDetectionTest >> tearDown [

	rootDirectory ensureDeleteAll.
	super tearDown
]

{ #category : 'tests' }
MooseNexusLanguageDetectionTest >> testDetectionRejectsMultipleLanguages [

	| result |
	self writeFile: 'src/main/java/Example.java' contents: 'class Example {}'.
	self writeFile: 'tsconfig.json' contents: '{}'.
	result := MooseNexusLanguageDetector detectIn: rootDirectory.
	self assert: result languages equals: #( 'java' 'typescript' ).
	self should: [ result language ] raise: Error
]

{ #category : 'tests' }
MooseNexusLanguageDetectionTest >> testJavaDetectionFindsNestedModuleSourceRoot [

	| result |
	self writeFile: 'module/src/main/java/Example.java' contents: 'class Example {}'.
	result := MooseNexusLanguageDetector detectIn: rootDirectory.
	self assert: result languages equals: #( 'java' ).
	self assert: result language equals: 'java'
]

{ #category : 'tests' }
MooseNexusLanguageDetectionTest >> testTypeScriptDetectionExcludesNodeModulesAndDeclarations [

	| result |
	self writeFile: 'node_modules/example/index.ts' contents: 'export const ignored = true'.
	self writeFile: 'src/types.d.ts' contents: 'declare const ignored: boolean'.
	result := MooseNexusLanguageDetector detectIn: rootDirectory.
	self assert: result isEmpty
]

{ #category : 'tests' }
MooseNexusLanguageDetectionTest >> testTypeScriptDetectionFindsTsxSourceWithoutTsconfig [

	| result |
	self writeFile: 'src/App.tsx' contents: 'export const App = () => null'.
	result := MooseNexusLanguageDetector detectIn: rootDirectory.
	self assert: result language equals: 'typescript'
]

{ #category : 'tests' }
MooseNexusLanguageDetectionTest >> testTypeScriptDetectionUsesTsconfig [

	| result |
	self writeFile: 'tsconfig.json' contents: '{}'.
	result := MooseNexusLanguageDetector detectIn: rootDirectory.
	self assert: result languages equals: #( 'typescript' ).
	self assert: (result evidenceForLanguage: 'typescript') equals: #( 'tsconfig.json' )
]

{ #category : 'testing' }
MooseNexusLanguageDetectionTest >> writeFile: aRelativePath contents: aString [

	| file |
	file := rootDirectory / aRelativePath.
	file parent ensureCreateDirectory.
	file writeStreamDo: [ :stream | stream nextPutAll: aString ].
	^ file
]
