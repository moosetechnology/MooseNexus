Class {
	#name : 'MooseNexusDependencyConflictPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'#idLabel',
		'#lockButton',
		'#isLocked',
		'#versionRadioButtons',
		'#lockedVersion => ObservableSlot',
		'#descriptors',
		'#conflictId',
		'#freezeLock'
	],
	#category : 'MooseNexus-UI',
	#package : 'MooseNexus-UI'
}

{ #category : 'accessing' }
MooseNexusDependencyConflictPresenter >> conflictId [

	^ conflictId
]

{ #category : 'layout' }
MooseNexusDependencyConflictPresenter >> defaultLayout [

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

{ #category : 'accessing' }
MooseNexusDependencyConflictPresenter >> freezeLock: aBoolean [

	freezeLock := aBoolean
]

{ #category : 'initialization' }
MooseNexusDependencyConflictPresenter >> initialize [

	super initialize.
	isLocked := freezeLock := false
]

{ #category : 'initialization' }
MooseNexusDependencyConflictPresenter >> initializePresenters [

	idLabel := self newLabel label: conflictId.

	versionRadioButtons := descriptors collect: [ :descriptor |
			                       | version |
			                       version := descriptor version.
			                       self newRadioButton
				                       label: version;
				                       whenActivatedDo: [
						                       freezeLock ifFalse: [ self lock ].
						                       lockedVersion := version ];
				                       yourself ].
	versionRadioButtons first associatedRadioButtons: versionRadioButtons.

	lockButton := self newButton
		              icon: (self iconNamed: #smallQuestion);
		              action: [ self toggleLock ];
		              yourself
]

{ #category : 'actions' }
MooseNexusDependencyConflictPresenter >> lock [

	isLocked ifTrue: [ ^ self ].
	isLocked := true.
	lockButton icon: (self iconNamed: #lock)
]

{ #category : 'accessing - model' }
MooseNexusDependencyConflictPresenter >> setModelBeforeInitialization: anAssociation [

	conflictId := anAssociation key.
	descriptors := anAssociation value
]

{ #category : 'actions' }
MooseNexusDependencyConflictPresenter >> toggleLock [

	isLocked
		ifTrue: [ self unlock ]
		ifFalse: [ self lock ]
]

{ #category : 'actions' }
MooseNexusDependencyConflictPresenter >> unlock [

	isLocked ifFalse: [ ^ self ].
	isLocked := false.
	lockButton icon: (self iconNamed: #smallQuestion).
	lockedVersion := nil "triggers `MooseNexusDependencySelectionPresenter >> #whenLockedVersionChangedDo:`"
]

{ #category : 'actions' }
MooseNexusDependencyConflictPresenter >> updateWithResolverChoice: descriptor [

	self freezeLock: true.
	(self versionRadioButtons detect: [ :button | button label = descriptor version ]) state: true.
	self freezeLock: false
]

{ #category : 'accessing' }
MooseNexusDependencyConflictPresenter >> versionRadioButtons [

	^ versionRadioButtons
]

{ #category : 'actions' }
MooseNexusDependencyConflictPresenter >> whenLockedVersionChangedDo: aBlock [

	self property: #lockedVersion whenChangedDo: [ aBlock value: lockedVersion value: isLocked ]
]
