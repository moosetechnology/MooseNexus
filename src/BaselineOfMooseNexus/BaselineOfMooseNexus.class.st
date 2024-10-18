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
		spec package: 'Moose-Nexus'.
		spec
			group: 'core' with: #( 'Moose-Nexus' );
			group: 'tests' with: #(  );
			group: 'default' with: #( core tests ) ]
]
