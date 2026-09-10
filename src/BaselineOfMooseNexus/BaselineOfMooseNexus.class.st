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
			spec baseline: 'XMLParser' with: [
					spec
						loads: #( 'Core' );
						repository: 'github://pharo-contributions/XML-XMLParser:v3.6.3/src' ].

			spec
				package: 'MooseNexus' with: [ spec requires: #( 'XMLParser' ) ];
				package: 'MooseNexus-UI' with: [ spec requires: #( 'MooseNexus' ) ];
				package: 'MooseNexus-Tests' with: [ spec requires: #( 'MooseNexus' ) ].

			spec
				group: 'Core' with: #( 'MooseNexus' );
				group: 'UI' with: #( 'MooseNexus-UI' );
				group: 'Tests' with: #( 'MooseNexus-Tests' );
				group: 'all' with: #( 'default' 'UI' );
				group: 'default' with: #( 'Core' 'Tests' ) ]
]
