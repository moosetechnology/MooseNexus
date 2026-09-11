"
I test the generic managed-project and multi-module-managed-project contracts.
"
Class {
	#name : 'MooseNexusManagedProjectTest',
	#superclass : 'TestCase',
	#category : 'MooseNexus-Tests-Project',
	#package : 'MooseNexus-Tests',
	#tag : 'Project'
}

{ #category : 'tests' }
MooseNexusManagedProjectTest >> testMultiModuleManagedProjectPreservesModuleMetadata [

	| project properties |
	project := MooseNexusMultiModuleManagedProject new.
	project initializeCoordinates: (MooseNexusCoordinates group: 'org.example' name: 'root' version: '1.0.0').
	project language: 'java'.
	properties := project properties.

	self assert: project isManagedProject.
	self assert: project projects isEmpty.
	self assert: (properties at: #projects) isEmpty
]
