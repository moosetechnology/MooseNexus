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
harbor.example.com/moose/moosenexus/com.example/demo/demo-model:1.0.0-main
```

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

publisher
	publishManifest: manifest
	of: result project
	in: FileLocator temp / 'moosenexus-oci-bundle'.
```

The publisher builds the local bundle files, assigns the OCI reference, and delegates the push to ORAS.

MooseNexus passes `--disable-path-validation` to `oras push`. ORAS rejects absolute file paths by default because pushing absolute paths can accidentally expose local filesystem structure or unintended files. MooseNexus intentionally builds the bundle in a known local directory, often under the system temporary directory, so the model payload and source archive are passed to ORAS as absolute paths.

## Pulling

`MooseNexusOrasTransport` can pull an OCI reference into a directory:

```st
transport := MooseNexusOrasTransport new.
transport
	pull: 'harbor.example.com/moose/moosenexus/com.example/demo/demo-model:1.0.0-main'
	into: FileLocator temp / 'moosenexus-pulled-artifact'.
```

This currently downloads the OCI artifact files. It does not yet restore the artifact into a MooseNexus repository, validate checksums, or resolve dependencies from a local cache.

## Current Boundary

The current implementation deliberately keeps OCI support client-side:

- ORAS handles registry transport;
- MooseNexus defines the bundle contents;
- Harbor is used as an OCI registry, not through Harbor-specific APIs;
- publishing is explicit and never happens automatically after a build.

Repository-chain behavior such as local-first fetch, remote selection, cache refresh, and restoring pulled bundles into a local MooseNexus repository still belongs to future repository backend work.
