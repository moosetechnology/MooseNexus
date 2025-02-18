Class {
	#name : 'NexusDependencySelectionPresenter',
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
NexusDependencySelectionPresenter class >> title [

	^ 'Nexus Dependency Conflict Selector'
]

{ #category : 'actions' }
NexusDependencySelectionPresenter >> applyResolver: resolver [

	| choices |
	lockResolver fallbackResolver: resolver.
	choices := lockResolver resolveConflicts: conflicts.
	conflictList items do: [ :conflictPresenter |
		conflictPresenter updateWithResolverChoice:
			(choices at: conflictPresenter conflictId) ]
]

{ #category : 'layout' }
NexusDependencySelectionPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 5;
		  add: resolverConfig expand: false;
		  add: conflictList;
		  add: applyButton expand: false;
		  yourself
]

{ #category : 'initialization' }
NexusDependencySelectionPresenter >> initialize [
	"There is an implicit version locking resolver that handles locking versions that have been chosen manually."

	super initialize.
	lockResolver := NexusVersionLockingDependencyConflictResolver new
]

{ #category : 'initialization' }
NexusDependencySelectionPresenter >> initializePresenters [

	resolverConfig := self newDropList
		                  items:
			                  (NexusDependencyConflictResolver allSubclasses
				                   reject: [ :class |
					                   class isAbstract or: [
							                   class
							                   ==
								                   NexusVersionLockingDependencyConflictResolver ] ]
				                   thenCollect: #new);
		                  display: [ :item | item displayName ];
		                  whenSelectedItemChangedDo: [ :item |
			                  self applyResolver: item ].

	conflictList := self newComponentList items:
		                (conflicts associations collect: [ :conflict |
			                 (self instantiate:
				                  (NexusDependencyConflictPresenter on: conflict))
				                 whenLockedVersionChangedDo: [ :version :isLocked |
					                 isLocked
						                 ifTrue: [
						                 lockResolver addLock: conflict key -> version ]
						                 ifFalse: [
						                 lockResolver removeLock: conflict key ] ] ]).

	applyButton := self newButton
		               label: 'Apply';
		               action: [  ]
]

{ #category : 'initialization' }
NexusDependencySelectionPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter initialExtent: 16 @ 9 * 50
]

{ #category : 'accessing - model' }
NexusDependencySelectionPresenter >> setModelBeforeInitialization: aDictionary [

	conflicts := aDictionary
]
