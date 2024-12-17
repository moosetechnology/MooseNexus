Class {
	#name : 'BaselineOfMooseNexus',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfMooseNexus',
	#package : 'BaselineOfMooseNexus'
}

{ #category : 'baselines' }
BaselineOfMooseNexus >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec
			package: 'MooseNexus'
			with: [ spec requires: #( 'MooseNexus-UI' ) ];
			package: 'MooseNexus-UI';
			package: 'MooseNexus-Tests'
			with: [ spec requires: #( 'MooseNexus' ) ].

		spec
			group: 'core' with: #( 'MooseNexus' );
			group: 'tests' with: #( 'MooseNexus-Tests' );
			group: 'default' with: #( core tests ) ]
]
