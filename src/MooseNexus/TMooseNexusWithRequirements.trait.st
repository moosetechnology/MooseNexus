"
I provide the shared protocol for objects that declare preflight requirements before they can do their work.

Users provide #requirements as a collection of MooseNexusRequirement instances. I validate each requirement through its own validation protocol, so command-line requirements and image requirements can decide how they should be checked without callers branching on their concrete type.
"
Trait {
	#name : 'TMooseNexusWithRequirements',
	#category : 'MooseNexus-Requirement',
	#package : 'MooseNexus',
	#tag : 'Requirement'
}

{ #category : 'capabilities' }
TMooseNexusWithRequirements >> requirements [

	^ #(  )
]

{ #category : 'validating' }
TMooseNexusWithRequirements >> validateRequirements [

	^ self validateRequirements: (self requirements collect: [ :requirement | requirement validate ])
]

{ #category : 'validating' }
TMooseNexusWithRequirements >> validateRequirements: validationResults [

	validationResults detect: [ :result | result isAvailable not ] ifFound: [ :result | Error signal: result errorMessage ].
	^ validationResults
]
