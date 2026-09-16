"
I am the versioned, JSON-serializable result of one MooseNexus operation executed without an interactive UI.

I record whether the operation succeeded, its operation and phase, a stable result code, a human-readable message, and caller-provided context. I deliberately capture an Error only at the headless boundary so consumers such as MooseNexus-CLI can report failures without parsing Pharo stack traces.
"
Class {
	#name : 'MooseNexusHeadlessResult',
	#superclass : 'Object',
	#instVars : [
		'operation',
		'phase',
		'status',
		'code',
		'message',
		'context'
	],
	#category : 'MooseNexus-System',
	#package : 'MooseNexus',
	#tag : 'System'
}

{ #category : 'evaluating' }
MooseNexusHeadlessResult class >> execute: operationName phase: phaseName context: aDictionary do: operationBlock [

	^ [
		  operationBlock value.
		  self successFor: operationName phase: phaseName context: aDictionary ]
		  on: Error
		  do: [ :error |
				  self
					  failureFor: operationName
					  phase: phaseName
					  context: aDictionary
					  error: error ]
]

{ #category : 'instance creation' }
MooseNexusHeadlessResult class >> failureFor: operationName phase: phaseName context: aDictionary error: anError [

	| result |
	result := self new.
	result initializeOperation: operationName phase: phaseName context: aDictionary.
	result initializeFailure: anError.
	^ result
]

{ #category : 'accessing' }
MooseNexusHeadlessResult class >> schemaVersion [

	^ '1'
]

{ #category : 'instance creation' }
MooseNexusHeadlessResult class >> successFor: operationName phase: phaseName context: aDictionary [

	| result |
	result := self new.
	result initializeOperation: operationName phase: phaseName context: aDictionary.
	result initializeSuccess.
	^ result
]

{ #category : 'converting' }
MooseNexusHeadlessResult >> asDictionary [

	^ Dictionary new
		  add: 'schemaVersion' -> self class schemaVersion;
		  add: 'operation' -> operation;
		  add: 'phase' -> phase;
		  add: 'status' -> status;
		  add: 'code' -> code;
		  add: 'message' -> message;
		  add: 'context' -> context;
		  yourself
]

{ #category : 'accessing' }
MooseNexusHeadlessResult >> code [

	^ code
]

{ #category : 'accessing' }
MooseNexusHeadlessResult >> context [

	^ context
]

{ #category : 'initialization' }
MooseNexusHeadlessResult >> initializeFailure: anError [

	status := 'failure'.
	code := 'operation-failed'.
	message := anError messageText.
	context at: 'errorClass' put: anError class name
]

{ #category : 'initialization' }
MooseNexusHeadlessResult >> initializeOperation: operationName phase: phaseName context: aDictionary [

	operation := operationName.
	phase := phaseName.
	context := aDictionary copy
]

{ #category : 'initialization' }
MooseNexusHeadlessResult >> initializeSuccess [

	status := 'success'.
	code := 'ok'.
	message := nil
]

{ #category : 'testing' }
MooseNexusHeadlessResult >> isSuccess [

	^ status = 'success'
]

{ #category : 'accessing' }
MooseNexusHeadlessResult >> message [

	^ message
]

{ #category : 'accessing' }
MooseNexusHeadlessResult >> operation [

	^ operation
]

{ #category : 'accessing' }
MooseNexusHeadlessResult >> phase [

	^ phase
]

{ #category : 'accessing' }
MooseNexusHeadlessResult >> status [

	^ status
]

{ #category : 'writing' }
MooseNexusHeadlessResult >> writeTo: resultFile [

	resultFile parent ensureCreateDirectory.
	resultFile writeStreamDo: [ :stream | STON put: self asDictionary asJsonOnStream: stream ]
]
