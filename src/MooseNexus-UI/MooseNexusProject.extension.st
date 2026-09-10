Extension { #name : 'MooseNexusProject' }

{ #category : '*MooseNexus-UI' }
MooseNexusProject >> importModel [
	"There can be multiple models with different settings for the same project."

	self models ifEmpty: [ self inform: 'No models to import' ] ifNotEmpty: [ :models |
			models size = 1 ifTrue: [ ^ self importModel: models first ].

			"Open a presenter to choose a model to import."
			(MooseNexusModelSelectionPresenter on: self) open ]
]
