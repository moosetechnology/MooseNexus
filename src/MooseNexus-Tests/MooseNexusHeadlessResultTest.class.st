"
I test the stable JSON contract written by MooseNexusHeadlessResult.
"
Class {
	#name : 'MooseNexusHeadlessResultTest',
	#superclass : 'TestCase',
	#category : 'MooseNexus-Tests-System',
	#package : 'MooseNexus-Tests',
	#tag : 'System'
}

{ #category : 'tests' }
MooseNexusHeadlessResultTest >> testFailureWritesAStableErrorEnvelope [

	| resultFile result dictionary |
	resultFile := FileLocator temp / ('moosenexus-headless-result-' , UUID new asString , '.json').
	[
		result := MooseNexusHeadlessResult
			          execute: 'build-model'
			          phase: 'execute-spec'
			          context: (Dictionary new
					           add: 'project' -> 'com.example:demo:1.0.0';
					           yourself)
			          do: [ Error signal: 'Model extraction failed' ].
		result writeTo: resultFile.
		dictionary := resultFile readStreamDo: [ :stream | STON fromStream: stream ].

		self deny: result isSuccess.
		self assert: (dictionary at: 'schemaVersion') equals: '1'.
		self assert: (dictionary at: 'operation') equals: 'build-model'.
		self assert: (dictionary at: 'phase') equals: 'execute-spec'.
		self assert: (dictionary at: 'status') equals: 'failure'.
		self assert: (dictionary at: 'code') equals: 'operation-failed'.
		self assert: (dictionary at: 'message') equals: 'Model extraction failed'.
		self assert: ((dictionary at: 'context') at: 'project') equals: 'com.example:demo:1.0.0'.
		self assert: ((dictionary at: 'context') at: 'errorClass') equals: 'Error' ] ensure: [
		resultFile exists ifTrue: [ resultFile delete ] ]
]

{ #category : 'tests' }
MooseNexusHeadlessResultTest >> testSuccessWritesAStableResultEnvelope [

	| resultFile result dictionary |
	resultFile := FileLocator temp / ('moosenexus-headless-result-' , UUID new asString , '.json').
	[
		result := MooseNexusHeadlessResult
			          execute: 'build-model'
			          phase: 'execute-spec'
			          context: (Dictionary new
					           add: 'project' -> 'com.example:demo:1.0.0';
					           yourself)
			          do: [ ].
		result writeTo: resultFile.
		dictionary := resultFile readStreamDo: [ :stream | STON fromStream: stream ].

		self assert: result isSuccess.
		self assert: (dictionary at: 'schemaVersion') equals: '1'.
		self assert: (dictionary at: 'operation') equals: 'build-model'.
		self assert: (dictionary at: 'phase') equals: 'execute-spec'.
		self assert: (dictionary at: 'status') equals: 'success'.
		self assert: (dictionary at: 'code') equals: 'ok'.
		self assert: (dictionary at: 'message') isNil.
		self assert: ((dictionary at: 'context') at: 'project') equals: 'com.example:demo:1.0.0' ] ensure: [
		resultFile exists ifTrue: [ resultFile delete ] ]
]
