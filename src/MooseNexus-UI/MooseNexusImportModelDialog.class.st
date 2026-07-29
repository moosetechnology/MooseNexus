Class {
	#name : 'MooseNexusImportModelDialog',
	#superclass : 'MiImportModelDialog',
	#instVars : [
		'foldersList',
		'dependencyCheckbox',
		'deleteButton',
		'importerPathField',
		'importerDropList',
		'addFolderPresenter'
	],
	#category : 'MooseNexus-UI',
	#package : 'MooseNexus-UI'
}

{ #category : 'specs' }
MooseNexusImportModelDialog class >> title [

	^ 'Nexus Java Model Importer'
]

{ #category : 'accessing' }
MooseNexusImportModelDialog class >> windowExtent [

	^ 16 @ 9 * 50
]

{ #category : 'layout' }
MooseNexusImportModelDialog >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: (SpBoxLayout newLeftToRight
				   add: ('Folders to parse' asPresenter addStyle: 'title2');
				   addLast: dependencyCheckbox;
				   addLast: deleteButton;
				   yourself)
		  expand: false;
		  add: foldersList withConstraints: [ :c | c padding: 10 ];
		  add: ('Java importer:' asPresenter addStyle: 'title2') expand: false;
		  add: (SpGridLayout new
				   add: importerDropList at: 1 @ 1;
				   add: importerPathField at: 2 @ 1 span: 2 @ 1;
				   yourself)
		  expand: false;
		  yourself
]

{ #category : 'initialization' }
MooseNexusImportModelDialog >> initializeAddFolderPresenter [

	| addFolder addSubFolders |
	addFolderPresenter := self instantiate: SpPresenter.

	addFolder := addFolderPresenter newButton
		             label: 'Add folder';
		             iconName: #add;
		             action: [ self openFolderSelection ].
	addSubFolders := addFolderPresenter newButton
		                 label: 'Add subfolders';
		                 iconName: #add;
		                 help: 'Add the direct subfolders of the chosen folder';
		                 action: [ self openSubFoldersSelection ].

	addFolderPresenter layout: (SpBoxLayout newLeftToRight
			 add: addFolder;
			 add: addSubFolders;
			 yourself)
]

{ #category : 'initialization' }
MooseNexusImportModelDialog >> initializePresenters [

	self initializeAddFolderPresenter.

	foldersList := self newComponentList addPresenter: addFolderPresenter.

	dependencyCheckbox := self newCheckBox
		                      labelOnLeft;
		                      label: 'Include dependencies';
		                      help: 'Toggle all'.
	deleteButton := self newButton
		                iconName: #remove;
		                help: 'Remove all'.

	importerDropList := self newDropList.
	importerPathField := self newTextInput
		                     placeholder: 'Path/to/importer';
		                     centered
]

{ #category : 'initialization' }
MooseNexusImportModelDialog >> openFolderSelection [

	self shouldBeImplemented
]

{ #category : 'initialization' }
MooseNexusImportModelDialog >> openSubFoldersSelection [

	self shouldBeImplemented
]

{ #category : 'accessing' }
MooseNexusImportModelDialog >> selectedFolders [

	^ foldersList items
]
