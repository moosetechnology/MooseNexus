"
I represent a managed source project composed of multiple build-tool modules or subprojects.

I preserve the declared dependency graph for each contained project. Maven reactors and Gradle multi-project builds use this representation; a single-project managed source such as npm does not.
"
Class {
	#name : 'MooseNexusMultiModuleManagedProject',
	#superclass : 'MooseNexusManagedProject',
	#instVars : [
		'projects'
	],
	#category : 'MooseNexus-Project',
	#package : 'MooseNexus',
	#tag : 'Project'
}

{ #category : 'enumerating' }
MooseNexusMultiModuleManagedProject >> projectDependenciesDo: aBlock [
	"Iterate over dependency descriptors declared by managed modules."

	self projects do: [ :projectGroup |
			projectGroup do: [ :projectDescriptor |
				projectDescriptor dependencyGraph do: [ :descriptor | aBlock value: descriptor group value: descriptor ] ] ]
]

{ #category : 'properties' }
MooseNexusMultiModuleManagedProject >> projectDescriptorFromProperties: projectDescriptor [

	^ MooseNexusManagedProjectDescriptor fromDictionary: projectDescriptor
]

{ #category : 'accessing' }
MooseNexusMultiModuleManagedProject >> projects [
	"Return the descriptors of the modules or subprojects analyzed by the build tool."

	^ projects ifNil: [ projects := Dictionary new ]
]

{ #category : 'accessing' }
MooseNexusMultiModuleManagedProject >> projects: aDictionary [
	"This is handled by the internal importer API."

	projects := aDictionary
]

{ #category : 'properties' }
MooseNexusMultiModuleManagedProject >> projectsFromProperties: projectGroups [

	^ projectGroups collect: [ :projectGroup |
		  projectGroup collect: [ :projectDescriptor | self projectDescriptorFromProperties: projectDescriptor ] ]
]

{ #category : 'enumerating' }
MooseNexusMultiModuleManagedProject >> properties [

	^ super properties
		  add: #projects -> self serializedProjects;
		  yourself
]

{ #category : 'properties' }
MooseNexusMultiModuleManagedProject >> readProperties: properties [

	super readProperties: properties.
	properties at: #projects ifPresent: [ :data | self projects: (self projectsFromProperties: data) ]
]

{ #category : 'enumerating' }
MooseNexusMultiModuleManagedProject >> serializedProjectDescriptor: projectDescriptor [

	^ projectDescriptor asDictionary
]

{ #category : 'enumerating' }
MooseNexusMultiModuleManagedProject >> serializedProjects [

	^ self projects collect: [ :projectGroup |
		  projectGroup collect: [ :projectDescriptor | self serializedProjectDescriptor: projectDescriptor ] ]
]
