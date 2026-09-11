"
I detect Java source layout evidence.

I recognize Maven and Gradle style source roots named src/main/java, including roots below project modules.
"
Class {
	#name : 'MooseNexusJavaLanguageDetector',
	#superclass : 'MooseNexusLanguageDetector',
	#category : 'MooseNexus-Java-Project',
	#package : 'MooseNexus-Java',
	#tag : 'Project'
}

{ #category : 'detecting' }
MooseNexusJavaLanguageDetector class >> addSourceRootBelow: aDirectory to: sourceRoots [

	aDirectory / 'src' / 'main' / 'java' ifExists: [ :sourceRoot | sourceRoots add: sourceRoot ]
]

{ #category : 'detecting' }
MooseNexusJavaLanguageDetector class >> evidenceIn: aDirectory [

	^ (self sourceRootsIn: aDirectory) collect: [ :sourceRoot | (sourceRoot relativeTo: aDirectory) pathString ]
]

{ #category : 'capabilities' }
MooseNexusJavaLanguageDetector class >> language [

	^ 'java'
]

{ #category : 'detecting' }
MooseNexusJavaLanguageDetector class >> sourceRootsIn: aDirectory [

	| roots |
	roots := OrderedCollection new.
	self addSourceRootBelow: aDirectory to: roots.
	aDirectory allDirectories do: [ :directory | self addSourceRootBelow: directory to: roots ].
	^ roots asSet asArray sorted
]
