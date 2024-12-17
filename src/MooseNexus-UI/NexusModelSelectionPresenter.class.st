Class {
	#name : 'NexusModelSelectionPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'modelsList',
		'importButton',
		'nexusProject',
		'commentLabel',
		'descriptionLabel',
		'timestampLabel',
		'famixVersionLabel',
		'fileSizeLabel'
	],
	#category : 'MooseNexus-UI',
	#package : 'MooseNexus-UI'
}

{ #category : 'specs' }
NexusModelSelectionPresenter class >> title [

	^ 'Nexus Model Importer'
]

{ #category : 'layout' }
NexusModelSelectionPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: 'No models to import';
		  yourself
]

{ #category : 'initialization' }
NexusModelSelectionPresenter >> initializeLabels [

	commentLabel := self newLabel.
	descriptionLabel := self newLabel.
	timestampLabel := self newLabel.
	famixVersionLabel := self newLabel.
	fileSizeLabel := self newLabel
]

{ #category : 'initialization' }
NexusModelSelectionPresenter >> initializePresenters [

	modelsList := self newList
		              items: nexusProject models;
		              display: [ :dict | dict at: 'description' ];
		              whenSelectedDo: [ :dict | self updateForSelectedModel ].

	importButton := self newButton
		                label: 'Import';
		                disable;
		                action: [
			                nexusProject importModel: modelsList selectedItem ].

	self initializeLabels.

	"trigger the layout if at least one item"
	modelsList items ifNotEmpty: [ modelsList selectFirst ]
]

{ #category : 'initialization' }
NexusModelSelectionPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter initialExtent: 16 @ 9 * 50
]

{ #category : 'accessing - model' }
NexusModelSelectionPresenter >> setModelBeforeInitialization: aNexusProject [

	nexusProject := aNexusProject
]

{ #category : 'updating' }
NexusModelSelectionPresenter >> updateForSelectedModel [

	importButton enable.
	self updateLayout.
	self updateLabels
]

{ #category : 'updating' }
NexusModelSelectionPresenter >> updateLabels [

	commentLabel label:
		'Comment: ' , (modelsList selectedItem at: 'comment').
	timestampLabel label:
		'Timestamp: ' , (modelsList selectedItem at: 'timestamp').
	famixVersionLabel label:
		'Famix version: ' , (modelsList selectedItem at: 'famixVersion').
	fileSizeLabel label:
		'File size: ' , (nexusProject directory asFileReference / 'models'
		 / (modelsList selectedItem at: 'name')) size
			humanReadableByteSizeString
]

{ #category : 'updating' }
NexusModelSelectionPresenter >> updateLayout [

	self layout: (SpPanedLayout newLeftToRight
			 add: modelsList;
			 positionOfSlider: 0.4;
			 add: (SpBoxLayout newTopToBottom
					  add: commentLabel;
					  add: timestampLabel;
					  add: famixVersionLabel;
					  add: fileSizeLabel;
					  add: importButton;
					  yourself);
			 yourself)
]
