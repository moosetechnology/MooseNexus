"
I provide MooseNexus's release version.

The value is deliberately stored in the loaded package rather than inferred from Git, so model artifacts remain self-describing when built offline or from an installed image. Update it when preparing a MooseNexus release.
"
Class {
	#name : 'MooseNexusVersion',
	#superclass : 'Object',
	#category : 'MooseNexus-System',
	#package : 'MooseNexus',
	#tag : 'System'
}

{ #category : 'accessing' }
MooseNexusVersion class >> current [

	^ '0.6.0'
]
