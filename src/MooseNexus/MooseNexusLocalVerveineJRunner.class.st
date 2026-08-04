Class {
	#name : 'MooseNexusLocalVerveineJRunner',
	#superclass : 'MooseNexusVerveineJRunner',
	#instVars : [
		'directory'
	],
	#category : 'MooseNexus-ModelExtraction',
	#package : 'MooseNexus',
	#tag : 'ModelExtraction'
}

{ #category : 'accessing' }
MooseNexusLocalVerveineJRunner >> directory [

	^ directory
]

{ #category : 'accessing' }
MooseNexusLocalVerveineJRunner >> directory: aPath [

	directory := aPath asFileReference
]

{ #category : 'running' }
MooseNexusLocalVerveineJRunner >> run [

	| returnCode |
	returnCode := self runCommand: self writeCommand.
	returnCode == 0 ifFalse: [ Error signal: 'Failed to create the model, error code: ' , returnCode asString ].

	^ self outputPath
]

{ #category : 'printing' }
MooseNexusLocalVerveineJRunner >> shellQuoted: aString [

	^ '"' , (aString copyReplaceAll: '"' with: '\"') , '"'
]

{ #category : 'capabilities' }
MooseNexusLocalVerveineJRunner >> toolRequirements [

	| wrapperCommand |
	wrapperCommand := (self shellQuoted: (self verveineJDirectory / 'gradlew') pathString) , ' --version'.
	^ super toolRequirements , {
		  (MooseNexusToolRequirement
			   name: 'Java'
			   availabilityCommand: 'java -version'
			   versionCommand: 'java -version'
			   expectedVersionDescription: 'Java runtime compatible with VerveineJ').
		  (MooseNexusToolRequirement
			   name: 'VerveineJ Gradle wrapper'
			   availabilityCommand: wrapperCommand
			   versionCommand: wrapperCommand
			   expectedVersionDescription: 'VerveineJ checkout Gradle wrapper capable of running app:run') }
]

{ #category : 'accessing' }
MooseNexusLocalVerveineJRunner >> verveineJDirectory [

	^ directory ifNil: [ Error signal: 'VerveineJ directory is required' ]
]

{ #category : 'writing' }
MooseNexusLocalVerveineJRunner >> writeCommand [

	| dependencyDirectory sourceDirectory outputFile |
	dependencyDirectory := target asFileReference / 'dependencies'.
	sourceDirectory := target asFileReference / 'sources'.
	outputFile := sourceDirectory / (self class outputFilename , '.' , self format).

	^ String streamContents: [ :s |
			  s << (self shellQuoted: (self verveineJDirectory / 'gradlew') pathString).
			  s << ' -p ' << (self shellQuoted: self verveineJDirectory pathString).
			  s << ' app:run --args='.
			  s << (self shellQuoted: (String streamContents: [ :args |
						    self printOptionsOn: args outputFile: outputFile pathString.
						    args << ' -autocp ' << dependencyDirectory pathString.
						    args << ' ' << sourceDirectory pathString ])) ]
]
