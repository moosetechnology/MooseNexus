Class {
	#name : 'MooseNexusDependencyDescriptorTest',
	#superclass : 'TestCase',
	#category : 'MooseNexus-Tests-Dependency',
	#package : 'MooseNexus-Tests',
	#tag : 'Dependency'
}

{ #category : 'tests' }
MooseNexusDependencyDescriptorTest >> testDescriptorIsValueObject [

	| descriptor sameDescriptor otherDescriptor |
	descriptor := MooseNexusDependencyDescriptor
		              group: 'org.example'
		              name: 'lib'
		              version: '1.0.0'
		              type: 'jar'
		              scope: 'compile'
		              path: '.m2/repository/org/example/lib/1.0.0/lib-1.0.0.jar'.
	sameDescriptor := MooseNexusDependencyDescriptor
		                  group: 'org.example'
		                  name: 'lib'
		                  version: '1.0.0'
		                  type: 'jar'
		                  scope: 'compile'
		                  path: '.m2/repository/org/example/lib/1.0.0/lib-1.0.0.jar'.
	otherDescriptor := MooseNexusDependencyDescriptor
		                   group: 'org.example'
		                   name: 'lib'
		                   version: '2.0.0'
		                   type: 'jar'
		                   scope: 'compile'
		                   path: '.m2/repository/org/example/lib/2.0.0/lib-2.0.0.jar'.

	self assert: descriptor equals: sameDescriptor.
	self deny: descriptor equals: otherDescriptor.
	self assert: descriptor printString equals: 'org.example:lib:1.0.0'
]

{ #category : 'tests' }
MooseNexusDependencyDescriptorTest >> testDictionaryRoundTrip [

	| dictionary descriptor |
	dictionary := Dictionary
		              with: #group -> 'org.example'
		              with: #name -> 'lib'
		              with: #version -> '1.0.0'
		              with: #type -> 'jar'
		              with: #scope -> 'compile'
		              with: #path -> '.m2/repository/org/example/lib/1.0.0/lib-1.0.0.jar'.
	descriptor := MooseNexusDependencyDescriptor fromDictionary: dictionary.

	self assert: descriptor asDictionary equals: dictionary
]

{ #category : 'tests' }
MooseNexusDependencyDescriptorTest >> testWithGroupAnswersCopy [

	| descriptor groupedDescriptor |
	descriptor := MooseNexusDependencyDescriptor
		              group: nil
		              name: 'lib'
		              version: '1.0.0'
		              type: 'jar'
		              scope: 'compile'
		              path: 'repository/lib-1.0.0.jar'.
	groupedDescriptor := descriptor withGroup: 'org.example'.

	self assert: descriptor group equals: nil.
	self assert: groupedDescriptor group equals: 'org.example'.
	self assert: groupedDescriptor name equals: descriptor name
]
