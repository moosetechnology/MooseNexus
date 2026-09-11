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
				baseline: 'FamixTypeScript'
				with: [ spec repository: 'github://fuhrmanator/FamixTypeScript:de43767b802588b14212fef65413a286bf24ba71/src' ].

			spec
				package: 'MooseNexus' with: [ spec requires: #( 'XMLParser' ) ];
				package: 'MooseNexus-Java' with: [ spec requires: #( 'MooseNexus' ) ];
				package: 'MooseNexus-TypeScript' with: [ spec requires: #( 'MooseNexus' 'FamixTypeScript' ) ];
				package: 'MooseNexus-UI' with: [ spec requires: #( 'MooseNexus' ) ];
				package: 'MooseNexus-TestResources' with: [ spec requires: #( 'MooseNexus' ) ];
				package: 'MooseNexus-Tests' with: [ spec requires: #( 'MooseNexus-TestResources' ) ];
				package: 'MooseNexus-Java-Tests' with: [ spec requires: #( 'MooseNexus-TestResources' ) ];
				package: 'MooseNexus-TypeScript-Tests' with: [ spec requires: #( 'MooseNexus-TypeScript' 'MooseNexus-TestResources' ) ];
				package: 'MooseNexus-IntegrationTests' with: [ spec requires: #( 'MooseNexus-TestResources' ) ];
				package: 'MooseNexus-Java-IntegrationTests' with: [ spec requires: #( 'MooseNexus-TestResources' ) ];
				package: 'MooseNexus-TypeScript-IntegrationTests'
				with: [ spec requires: #( 'MooseNexus-TypeScript' 'MooseNexus-TestResources' ) ].

			spec
				group: 'Core' with: #( 'MooseNexus' );
				group: 'Java' with: #( 'MooseNexus-Java' );
				group: 'TypeScript' with: #( 'MooseNexus-TypeScript' );
				group: 'UI' with: #( 'MooseNexus-UI' );
				group: 'UnitTests' with: #( 'MooseNexus-Tests' );
				group: 'JavaUnitTests' with: #( 'MooseNexus-Java-Tests' );
				group: 'TypeScriptUnitTests' with: #( 'MooseNexus-TypeScript-Tests' );
				group: 'IntegrationTests' with: #( 'MooseNexus-IntegrationTests' );
				group: 'JavaIntegrationTests' with: #( 'MooseNexus-Java-IntegrationTests' );
				group: 'TypeScriptIntegrationTests' with: #( 'MooseNexus-TypeScript-IntegrationTests' );
				group: 'Tests'
				with:
					#( 'UnitTests' 'JavaUnitTests' 'TypeScriptUnitTests' 'IntegrationTests' 'JavaIntegrationTests' 'TypeScriptIntegrationTests' );
				group: 'all' with: #( 'Core' 'Java' 'TypeScript' 'UI' 'Tests' );
				group: 'default' with: #( 'Core' 'Java' 'UnitTests' 'JavaUnitTests' ) ]
]
