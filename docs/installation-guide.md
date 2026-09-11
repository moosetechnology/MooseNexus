# Installation Guide

## Load MooseNexus

Load the Java distribution, which includes the core and Java importers:

```st
Metacello new
	githubUser: 'moosetechnology' project: 'MooseNexus' commitish: 'v1.x.x' path: 'src';
	baseline: 'MooseNexus';
	load: 'Java'.
```

`v1.x.x` is the floating tag for the newest compatible v1 release. Use an exact version tag when reproducibility matters.

To depend on MooseNexus from another baseline:

```st
spec
	baseline: 'MooseNexus'
	with: [ spec repository: 'github://moosetechnology/MooseNexus:v1.x.x/src' ].
```

## Importer Requirements

Install only the requirements for the importer and extractor you choose:

- Unmanaged Java projects do not require Maven or Gradle. They require a Java model extractor, such as [VerveineJ](https://github.com/moosetechnology/VerveineJ/) or [VerveineJ-Docker](https://github.com/Evref-BL/VerveineJ-Docker).
- Maven-managed projects require Maven and a Java model extractor.
- Gradle-managed projects require Gradle and a Java model extractor.

The Maven importer supports Maven 3.6.3 and later Maven 3 releases, and rejects Maven 4. Gradle has no importer-side version guard; managed-import integration tests continuously check these boundary configurations:

| Toolchain | Java | Maven | Gradle |
| --- | --- | --- | --- |
| Oldest supported | 8 | 3.6.3 | 6.9.4 |
| Current stable | 17 | 3.9.16 | 9.7.1 |

## Experimental TypeScript Support

`MooseNexus-TypeScript` is optional, requires Moose 13, and is excluded from the v1 support commitment. Its stable extraction workflow awaits an upstream ts2famix release. MooseNexus does not publish or support a MooseNexus-owned ts2famix image.

It can be loaded explicitly for evaluation:

```st
Metacello new
	githubUser: 'moosetechnology' project: 'MooseNexus' commitish: 'v1.x.x' path: 'src';
	baseline: 'MooseNexus';
	load: 'TypeScript'.
```
