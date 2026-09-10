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
						repository: 'github://pharo-contributions/XML-XMLParser:v3.6.x/src' ].

			spec
				package: 'MooseNexus' with: [ spec requires: #( 'XMLParser' ) ];
				package: 'MooseNexus-UI' with: [ spec requires: #( 'MooseNexus' ) ];
				package: 'MooseNexus-TestResources' with: [ spec requires: #( 'MooseNexus' ) ];
				package: 'MooseNexus-Tests' with: [ spec requires: #( 'MooseNexus-TestResources' ) ];
				package: 'MooseNexus-IntegrationTests' with: [ spec requires: #( 'MooseNexus-TestResources' ) ].

			spec
				group: 'Core' with: #( 'MooseNexus' );
				group: 'UI' with: #( 'MooseNexus-UI' );
				group: 'UnitTests' with: #( 'MooseNexus-Tests' );
				group: 'IntegrationTests' with: #( 'MooseNexus-IntegrationTests' );
				group: 'Tests' with: #( 'UnitTests' 'IntegrationTests' );
				group: 'all' with: #( 'Core' 'UI' 'Tests' );
				group: 'default' with: #( 'Core' 'UnitTests' ) ]
]
