# Build Spec

`MooseNexusBuildSpec` is the main client-side entry point for recording a source project, resolving its dependencies, running a model extractor, and storing the produced model artifact.

Use a build spec when you want a repeatable model build rather than a one-off repository import.

## Concepts

A build spec combines:

- project coordinates and source directory, through `MooseNexusProjectSpec`;
- project import strategy, either autodetected or explicitly configured;
- dependency-resolution options;
- model extraction options;
- the repository where the project and model artifact are recorded.

The build lifecycle is:

1. validate the source project spec;
2. select and configure a project importer;
3. import project metadata and dependencies;
4. record the MooseNexus project in the repository;
5. resolve dependencies;
6. run the model extractor;
7. record the model artifact and its manifest.

## Managed Source Projects

Managed source projects are projects whose metadata and dependency declarations are read from a supported build tool. Maven and Gradle are currently supported.

When no importer is configured explicitly, the build spec asks `MooseNexusProjectImporter` to select an importer from the source directory.

```st
| coordinates sourceDirectory repository spec result |

coordinates := MooseNexusCoordinates
	group: 'com.example'
	name: 'demo'
	version: '1.0.0'.
sourceDirectory := '/path/to/source/project' asFileReference.
repository := MooseNexusRepository default.

spec := MooseNexusBuildSpec
	coordinates: coordinates
	sourceDirectory: sourceDirectory.

spec
	modelName: 'demo-model';
	modelComment: 'Generated from the managed source project';
	withDependencies: false.

result := spec executeIn: repository.
```

This keeps Maven/Gradle detection as a convenience:

- a Maven project is selected when the Maven importer can handle the directory;
- a Gradle project is selected when the Gradle importer can handle the directory;
- an error is raised when no supported importer can handle the directory.

## Unmanaged Source Projects

Unmanaged source projects are projects whose MooseNexus metadata is supplied explicitly. They may still contain Maven or Gradle files, but MooseNexus will not inspect those files when an unmanaged importer is configured explicitly.

Use `MooseNexusUnmanagedProjectImporter` when the source project should be treated as unmanaged.

```st
| coordinates sourceDirectory repository importer spec result |

coordinates := MooseNexusCoordinates
	group: 'com.example'
	name: 'demo'
	version: '1.0.0'.
sourceDirectory := '/path/to/source/project' asFileReference.
repository := MooseNexusRepository default.

importer := MooseNexusUnmanagedProjectImporter new
	language: 'java';
	dependencies: #( ).

spec := MooseNexusBuildSpec
	coordinates: coordinates
	sourceDirectory: sourceDirectory.

spec
	projectImporter: importer;
	modelName: 'demo-model';
	withDependencies: false.

result := spec executeIn: repository.
```

`projectImporter:` is an explicit override. If it is set, directory autodetection is not used.

## Unmanaged Dependencies

An unmanaged importer can receive dependency descriptors directly. For now, those descriptors become the project's resolved dependencies.

```st
| dependency importer |

dependency := MooseNexusDependencyDescriptor
	coordinates: (MooseNexusCoordinates
		group: 'org.example'
		name: 'library'
		version: '2.0.0')
	type: 'jar'
	scopes: #( 'compile' )
	path: 'repository/org.example/library/2.0.0/artifacts/library-2.0.0.jar'.

importer := MooseNexusUnmanagedProjectImporter new
	language: 'java';
	dependencies: { dependency }.
```

`withDependencies:` controls whether dependency sources or artifacts are copied into the model extraction workspace. If dependency paths do not point to existing local files, keep `withDependencies: false`.

## Model Extraction

If no extractor is configured, MooseNexus selects one from the project language when the build executes.

Use `extractor:` when the caller wants a specific extractor implementation:

```st
spec extractor: MooseNexusLocalVerveineJRunner new.
```

The extractor must validate its requirements and produce a model file under the recorded project's repository directory.

## Execution

Execute in the default repository:

```st
result := spec execute.
```

Execute in a specific repository:

```st
repository := MooseNexusRepository new directory: '/path/to/nexus-repository' asFileReference.
result := spec executeIn: repository.
```

For lower-level orchestration, create a plan explicitly:

```st
plan := spec planIn: repository.
project := plan configureProjectMetadata.
plan recordProject: project.
dependencyResolution := plan resolveDependencies.
modelBuildResult := plan executeExtraction.
```

Most clients should prefer `execute` or `executeIn:`.

## Coordinate Policy

Build spec coordinates are the MooseNexus project coordinates recorded in the repository.

For unmanaged source projects, these coordinates are the only source of project identity.

For managed source projects, Maven or Gradle may also declare coordinates. The current build-spec flow records the explicit MooseNexus coordinates supplied by the build spec. Future schema work may preserve managed build-tool coordinates separately as source metadata.
