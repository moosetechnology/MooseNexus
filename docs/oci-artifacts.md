# OCI Artifacts

MooseNexus can package a recorded model artifact as an OCI artifact bundle and publish it through ORAS.

This is intended for repositories such as Harbor that support OCI artifacts. MooseNexus keeps the artifact shape independent from Harbor-specific APIs: Harbor stores the artifact, while MooseNexus defines the bundle contents and reference layout.

## Bundle Contents

An OCI bundle contains:

- the exported model payload;
- the original source project archived as `sources.zip`;
- the MooseNexus model artifact manifest as `moosenexus-artifact-manifest.json`.

Sources are part of the bundle because they are required to inspect, reproduce, or rebuild a model artifact. The model payload is currently an exported model file. Future bundle variants can use the same publication path for other payloads, such as a Pharo image containing an imported model.

## References

`MooseNexusOciReferenceMapper` maps model artifact coordinates to a Harbor-compatible OCI reference.

For example, these coordinates:

```text
project group:   com.example
project name:    demo
project version: 1.0.0
model name:      demo-model
classifier:      main
```

published to registry `harbor.example.com` and Harbor project `moose` produce:

```text
harbor.example.com/moose/moosenexus/com.example/demo:1.0.0
```

The OCI repository reference is based on the MooseNexus project coordinates: group, name, and version. The model name is stored as MooseNexus metadata and as an OCI annotation, but it is not part of the Harbor path.

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
	registry: 'harbor.example.com'
	harborProject: 'moose'.
transport := MooseNexusOrasTransport new.
publisher := MooseNexusOciArtifactPublisher
	referenceMapper: mapper
	transport: transport.

publisher publishManifest: manifest of: result project.
```

The publisher builds the local bundle files, assigns the OCI reference, and delegates the push to ORAS.

`publishManifest:of:` stages the bundle in a generated temporary directory whose name includes a UUID. Use `publishManifest:of:in:` only when you want to inspect or control the staging directory explicitly.

MooseNexus passes `--disable-path-validation` to `oras push`. ORAS rejects absolute file paths by default because pushing absolute paths can accidentally expose local filesystem structure or unintended files. MooseNexus intentionally builds the bundle in a known generated temporary directory, so the model payload and source archive are passed to ORAS as absolute paths.

## Pulling

`MooseNexusOrasTransport` can pull an OCI reference into a generated temporary directory:

```st
transport := MooseNexusOrasTransport new.
pulledDirectory := transport pull: 'harbor.example.com/moose/moosenexus/com.example/demo:1.0.0'.
```

The pull reference must include a tag or digest. For MooseNexus artifacts, the tag is the project version.

Use `pull:into:` only when you want to inspect or control the pull directory explicitly.

This currently downloads the OCI artifact files. It does not yet restore the artifact into a MooseNexus repository, validate checksums, or resolve dependencies from a local cache.

## Current Boundary

The current implementation deliberately keeps OCI support client-side:

- ORAS handles registry transport;
- MooseNexus defines the bundle contents;
- Harbor is used as an OCI registry, not through Harbor-specific APIs;
- publishing is explicit and never happens automatically after a build.

Repository-chain behavior such as local-first fetch, remote selection, cache refresh, and restoring pulled bundles into a local MooseNexus repository still belongs to future repository backend work.
