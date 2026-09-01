# OCI Artifacts

MooseNexus can package a recorded model artifact as an OCI artifact bundle and publish it through ORAS.

This is intended for repositories that support OCI artifacts, such as Harbor, Sonatype Nexus, Artifactory, or plain OCI registries. MooseNexus keeps the artifact shape independent from backend-specific APIs: the registry stores the artifact, while MooseNexus defines the bundle contents and reference layout.

## Bundle Contents

An OCI bundle contains:

- the exported model payload;
- the original source project archived as `sources.zip`;
- the recorded MooseNexus project properties as `moosenexus-project-properties.json`;
- the MooseNexus model artifact manifest as `moosenexus-artifact-manifest.json`.

Sources are part of the bundle because they are required to inspect, reproduce, or rebuild a model artifact. The model payload is currently an exported model file. Future bundle variants can use the same publication path for other payloads, such as a Pharo image containing an imported model.

## References

`MooseNexusOciReferenceMapper` maps model artifact coordinates to an OCI reference under a registry namespace.

For example, these coordinates:

```text
project group:   com.example
project name:    demo
project version: 1.0.0
model name:      demo-model
classifier:      main
```

published to registry `registry.example.com` and namespace `moose` produce:

```text
registry.example.com/moose/moosenexus/com.example/demo:1.0.0
```

The OCI repository reference is based on the MooseNexus project coordinates: group, name, and version. The model name is stored as MooseNexus metadata and as an OCI annotation, but it is not part of the OCI repository path.

The registry must be logged in before publishing. With ORAS, that is usually done outside MooseNexus:

```sh
oras login harbor.example.com
```

## Publishing

Build and record a model artifact first:

```st
| coordinates spec result manifest mapper transport publisher |

coordinates := MooseNexusCoordinates
	group: 'com.example'
	name: 'demo'
	version: '1.0.0'.

spec := MooseNexusBuildSpec
	coordinates: coordinates
	sourceDirectory: '/path/to/source/project' asFileReference.
spec modelName: 'demo-model'.

result := spec execute.

manifest := result project modelManifests
	detect: [ :each | each modelArtifact = result modelArtifact ].

mapper := MooseNexusOciReferenceMapper
	registry: 'registry.example.com'
	namespace: 'moose'.
transport := MooseNexusOrasTransport new.
publisher := MooseNexusOciArtifactPublisher
	referenceMapper: mapper
	transport: transport.

publisher publishManifest: manifest of: result project.
```

The publisher builds the local bundle files, assigns the OCI reference, and delegates the push to ORAS.

`publishManifest:of:` stages the bundle in a generated temporary directory whose name includes a UUID. Use `publishManifest:of:in:` only when you want to inspect or control the staging directory explicitly.

MooseNexus runs `oras push` from the generated bundle directory and passes bundle-local file names to ORAS. The artifact therefore records portable layer paths such as `model.json`, `sources.zip`, and `moosenexus-project-properties.json`; pulling the artifact restores those files inside the generated pull directory.

## Pulling

Use `MooseNexusOciArtifactPuller` to pull an OCI artifact and install it into a local MooseNexus repository:

```st
| mapper transport repository puller project |

mapper := MooseNexusOciReferenceMapper
	registry: 'registry.example.com'
	namespace: 'moose'.
transport := MooseNexusOrasTransport new.
repository := MooseNexusRepository default.
puller := MooseNexusOciArtifactPuller
	referenceMapper: mapper
	transport: transport
	repository: repository.

project := puller pull: 'registry.example.com/moose/moosenexus/com.example/demo:1.0.0'.
```

The pull reference must include a tag or digest. For MooseNexus artifacts, the tag is the project version.

Pulling is local-first when the reference encodes MooseNexus coordinates. If the project already exists in the local repository, the puller returns the local project without contacting the remote registry.

Use `force: true` to fetch and reinstall from the remote registry even when a local project already exists:

```st
project := puller
	pull: 'registry.example.com/moose/moosenexus/com.example/demo:1.0.0'
	force: true.
```

`MooseNexusOrasTransport >> pull:` remains available when you only want to download the OCI artifact files into a generated temporary directory. Use `pull:into:` when you want to inspect or control that directory explicitly.

Artifacts published before MooseNexus switched to bundle-local OCI layer paths should be republished. Those older artifacts recorded absolute staging paths and cannot be restored portably by the installer.

## Current Boundary

The current implementation deliberately keeps OCI support client-side:

- ORAS handles registry transport;
- MooseNexus defines the bundle contents;
- registry products such as Harbor are used as OCI registries, not through backend-specific APIs;
- publishing is explicit and never happens automatically after a build;
- pulling installs the artifact into a local MooseNexus repository and is local-first when the OCI reference encodes MooseNexus coordinates.

Richer repository-chain behavior such as remote selection policy and cache refresh still belongs to future repository backend work.
