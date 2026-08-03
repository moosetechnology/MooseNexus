Class {
	#name : 'MooseNexusLocalVerveineJRunnerTest',
	#superclass : 'TestCase',
	#instVars : [
		'rootDirectory',
		'runner'
	],
	#category : 'MooseNexus-Tests-ModelExtraction',
	#package : 'MooseNexus-Tests',
	#tag : 'ModelExtraction'
}

{ #category : 'running' }
MooseNexusLocalVerveineJRunnerTest >> setUp [

	super setUp.
	rootDirectory := FileLocator temp / ('MooseNexus-' , UUID new asString).
	runner := MooseNexusTestLocalVerveineJRunner new.
	runner
		directory: rootDirectory / 'VerveineJ';
		target: (rootDirectory / 'project') pathString
]

{ #category : 'running' }
MooseNexusLocalVerveineJRunnerTest >> tearDown [

	rootDirectory ifNotNil: [ rootDirectory ifExists: [ rootDirectory deleteAll ] ].
	super tearDown
]

{ #category : 'tests' }
MooseNexusLocalVerveineJRunnerTest >> testRunAnswersRelativeOutputPath [

	self assert: runner run equals: 'sources/mooseNexusModel.json'.
	self assert: runner executedCommand equals: runner writeCommand
]

{ #category : 'tests' }
MooseNexusLocalVerveineJRunnerTest >> testRunFailsWhenCommandFails [

	runner returnCode: 1.

	self should: [ runner run ] raise: Error
]

{ #category : 'tests' }
MooseNexusLocalVerveineJRunnerTest >> testWriteCommandIncludesVerveineJOptions [

	runner
		allLocals: true;
		anchor: #assoc;
		javaVersion: '17';
		summary: true;
		excludePaths: #( '**/target/**' ).

	self assert:
		(runner writeCommand includesSubstring: '-format json -alllocals -anchor assoc -17 -summary -excludepath **/target/** -autocp')
]

{ #category : 'tests' }
MooseNexusLocalVerveineJRunnerTest >> testWriteCommandRunsVerveineJWithMooseNexusLayout [

	| verveineJDirectory projectDirectory outputFile expectedArguments expectedCommand |
	verveineJDirectory := rootDirectory / 'VerveineJ'.
	projectDirectory := rootDirectory / 'project'.
	outputFile := projectDirectory / 'sources' / 'mooseNexusModel.json'.
	expectedArguments := String streamContents: [ :s |
			                     s << '-o ' << outputFile pathString << ' -format json'.
			                     s << ' -autocp ' << (projectDirectory / 'dependencies') pathString.
			                     s << ' ' << (projectDirectory / 'sources') pathString ].
	expectedCommand := String streamContents: [ :s |
			                   s << (runner shellQuoted: (verveineJDirectory / 'gradlew') pathString).
			                   s << ' -p ' << (runner shellQuoted: verveineJDirectory pathString).
			                   s << ' app:run --args=' << (runner shellQuoted: expectedArguments) ].

	self assert: runner writeCommand equals: expectedCommand
]
