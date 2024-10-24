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
		spec package: 'MooseNexus'.
		spec
			group: 'core' with: #( 'MooseNexus' );
			group: 'tests' with: #(  );
			group: 'default' with: #( core tests ) ]
]
