Class {
	#name : 'NexusDependencyConflictPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'#idLabel',
		'#lockButton',
		'#isLocked',
		'#versionRadioButtons',
		'#lockedVersion => ObservableSlot',
		'#descriptors',
		'#conflictId'
	],
	#category : 'MooseNexus-UI',
	#package : 'MooseNexus-UI'
}

{ #category : 'as yet unclassified' }
NexusDependencyConflictPresenter >> conflictId [

	^ conflictId
]

{ #category : 'layout' }
NexusDependencyConflictPresenter >> defaultLayout [

	| radioLayout |
	radioLayout := SpBoxLayout newLeftToRight. "left align would be nice but hAlignStart gives bad result"
	versionRadioButtons do: [ :choice | radioLayout add: choice ].
	^ SpBoxLayout newLeftToRight
		  vAlignCenter;
		  add: idLabel
		  expand: false
		  fill: false
		  padding: 5;
		  add: radioLayout;
		  add: lockButton width: 24
]

{ #category : 'initialization' }
NexusDependencyConflictPresenter >> initialize [

	super initialize.
	isLocked := false
]

{ #category : 'initialization' }
NexusDependencyConflictPresenter >> initializePresenters [

	idLabel := self newLabel label: conflictId.

	versionRadioButtons := descriptors collect: [ :descriptor |
		                       | version |
		                       version := descriptor at: #version.
		                       self newRadioButton
			                       label: version;
			                       whenActivatedDo: [
				                       self lock.
				                       lockedVersion := version ];
			                       yourself ].
	versionRadioButtons first associatedRadioButtons: versionRadioButtons.

	lockButton := self newButton
		              icon: (self iconNamed: #smallQuestion);
		              action: [ self toggleLock ];
		              yourself
]

{ #category : 'actions api' }
NexusDependencyConflictPresenter >> lock [

	isLocked ifTrue: [ ^ self ].
	isLocked := true.
	lockButton icon: (self iconNamed: #lock)
]

{ #category : 'accessing - model' }
NexusDependencyConflictPresenter >> setModelBeforeInitialization: anAssociation [

	conflictId := anAssociation key.
	descriptors := anAssociation value
]

{ #category : 'actions api' }
NexusDependencyConflictPresenter >> toggleLock [

	isLocked
		ifTrue: [ self unlock ]
		ifFalse: [ self lock ]
]

{ #category : 'actions api' }
NexusDependencyConflictPresenter >> unlock [

	isLocked ifFalse: [ ^ self ].
	isLocked := false.
	lockButton icon: (self iconNamed: #smallQuestion)
]

{ #category : 'accessing' }
NexusDependencyConflictPresenter >> versionRadioButtons [

	^ versionRadioButtons
]

{ #category : 'enumerating' }
NexusDependencyConflictPresenter >> whenLockedVersionChangedDo: aBlock [

	self
		property: #lockedVersion
		whenChangedDo: [ aBlock value: lockedVersion value: isLocked ]
]