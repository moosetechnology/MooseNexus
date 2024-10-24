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
			package: 'MooseNexus';
			package: 'MooseNexus-Tests'
			with: [ spec requires: #( 'MooseNexus' ) ].

		spec
			group: 'core' with: #( 'MooseNexus' );
			group: 'tests' with: #( 'MooseNexus-Tests' );
			group: 'default' with: #( core tests ) ]
]
