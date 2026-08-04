Class {
	#name : 'MooseNexusModelSelectionPresenter',
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
MooseNexusModelSelectionPresenter class >> title [

	^ 'Nexus Model Importer'
]

{ #category : 'layout' }
MooseNexusModelSelectionPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: 'No models to import';
		  yourself
]

{ #category : 'initialization' }
MooseNexusModelSelectionPresenter >> initializeLabels [

	commentLabel := self newLabel.
	descriptionLabel := self newLabel.
	timestampLabel := self newLabel.
	famixVersionLabel := self newLabel.
	fileSizeLabel := self newLabel
]

{ #category : 'initialization' }
MooseNexusModelSelectionPresenter >> initializePresenters [

	modelsList := self newList
		              items: nexusProject models;
		              display: [ :artifact | artifact description ];
		              whenSelectedDo: [ :artifact | self updateForSelectedModel ].

	importButton := self newButton
		                label: 'Import';
		                disable;
		                action: [ nexusProject importModel: modelsList selectedItem ].

	self initializeLabels.

	"trigger the layout if at least one item"
	modelsList items ifNotEmpty: [ modelsList selectFirst ]
]

{ #category : 'initialization' }
MooseNexusModelSelectionPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter initialExtent: 16 @ 9 * 50
]

{ #category : 'accessing - model' }
MooseNexusModelSelectionPresenter >> setModelBeforeInitialization: aMooseNexusProject [

	nexusProject := aMooseNexusProject
]

{ #category : 'updating' }
MooseNexusModelSelectionPresenter >> updateForSelectedModel [

	importButton enable.
	self updateLayout.
	self updateLabels
]

{ #category : 'updating' }
MooseNexusModelSelectionPresenter >> updateLabels [

	commentLabel label: 'Comment: ' , modelsList selectedItem comment.
	timestampLabel label: 'Timestamp: ' , modelsList selectedItem timestamp.
	famixVersionLabel label: 'Famix version: ' , modelsList selectedItem famixVersion.
	fileSizeLabel label:
		'File size: ' , (FileLocator home / nexusProject directory / modelsList selectedItem path) size humanReadableByteSizeString
]

{ #category : 'updating' }
MooseNexusModelSelectionPresenter >> updateLayout [

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
