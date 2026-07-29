Class {
	#name : 'MooseNexusDependencySelectionPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'resolverConfig',
		'applyButton',
		'conflictList',
		'conflicts',
		'lockResolver'
	],
	#category : 'MooseNexus-UI',
	#package : 'MooseNexus-UI'
}

{ #category : 'specs' }
MooseNexusDependencySelectionPresenter class >> title [

	^ 'Nexus Dependency Conflict Selector'
]

{ #category : 'actions' }
MooseNexusDependencySelectionPresenter >> applyResolver: resolver [

	| choices |
	lockResolver fallbackResolver: resolver.
	choices := lockResolver resolveConflicts: conflicts.
	conflictList items do: [ :conflictPresenter |
		conflictPresenter updateWithResolverChoice: (choices at: conflictPresenter conflictId) ]
]

{ #category : 'layout' }
MooseNexusDependencySelectionPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 5;
		  add: resolverConfig expand: false;
		  add: conflictList;
		  add: applyButton expand: false;
		  yourself
]

{ #category : 'initialization' }
MooseNexusDependencySelectionPresenter >> initialize [
	"There is an implicit version locking resolver that handles locking versions that have been chosen manually."

	super initialize.
	lockResolver := MooseNexusVersionLockingDependencyConflictResolver new
]

{ #category : 'initialization' }
MooseNexusDependencySelectionPresenter >> initializePresenters [

	resolverConfig := self newDropList
		                  items: (MooseNexusDependencyConflictResolver allSubclasses
				                   reject: [ :class | class isAbstract or: [ class == MooseNexusVersionLockingDependencyConflictResolver ] ]
				                   thenCollect: #new);
		                  display: [ :item | item displayName ];
		                  whenSelectedItemChangedDo: [ :item | self applyResolver: item ].

	conflictList := self newComponentList items: (conflicts associations collect: [ :conflict |
				                 (self instantiate: (MooseNexusDependencyConflictPresenter on: conflict)) whenLockedVersionChangedDo: [
						                 :version
						                 :isLocked |
						                 isLocked
							                 ifTrue: [ lockResolver addLock: conflict key -> version ]
							                 ifFalse: [ lockResolver removeLock: conflict key ] ] ]).

	applyButton := self newButton
		               label: 'Apply';
		               action: [ ]
]

{ #category : 'initialization' }
MooseNexusDependencySelectionPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter initialExtent: 16 @ 9 * 50
]

{ #category : 'accessing - model' }
MooseNexusDependencySelectionPresenter >> setModelBeforeInitialization: aDictionary [

	conflicts := aDictionary
]
