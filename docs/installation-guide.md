# Installation Guide

## Baseline Groups

A Metacello baseline group is a named set of packages. Choose a group to load only the runtime support or test packages needed for a use case; package dependencies are loaded automatically. Calling `load` without a group selects the `default` group, which is intended for core/Java development rather than a minimal consumer installation.

### Runtime Groups

| Group | Purpose |
| --- | --- |
| `Core` | Core repository, project, dependency, and model-artifact support. |
| `Java` | Java importers and runners; it also loads `Core`. |
| `UI` | Optional MooseNexus user-interface package; it also loads `Core`. |
| `TypeScript` | Experimental npm and TypeScript support; it also loads `Core` and FamixTypeScript. |

### Test Groups

| Group | Purpose |
| --- | --- |
| `UnitTests` | Core unit tests. |
| `JavaUnitTests` | Java unit tests; use with `Java`. |
| `TypeScriptUnitTests` | Experimental TypeScript unit tests; use with `TypeScript`. |
| `IntegrationTests` | Core integration tests. |
| `JavaIntegrationTests` | Java integration tests. |
| `TypeScriptIntegrationTests` | Experimental TypeScript integration tests. |
| `Tests` | All unit and integration test groups, including TypeScript; use `all` for a complete test setup. |

### Aggregate Groups

| Group | Purpose |
| --- | --- |
| `all` | All runtime and test groups, including UI and TypeScript. |
| `default` | `Core`, `Java`, and their unit-test groups. |

Use `Java` for the normal Java consumer installation. It is explicit because it avoids loading development tests and the optional TypeScript dependency.

## Consumer Installation

Load Java support when importing or building Java projects:

```st
Metacello new
	githubUser: 'moosetechnology' project: 'MooseNexus' commitish: 'v1.x.x' path: 'src';
	baseline: 'MooseNexus';
	load: 'Java'.
```

`v1.x.x` is the floating tag for the newest compatible v1 release. Use an exact version tag when reproducibility matters.

Load only `Core` when Java support is not needed:

```st
Metacello new
	githubUser: 'moosetechnology' project: 'MooseNexus' commitish: 'v1.x.x' path: 'src';
	baseline: 'MooseNexus';
	load: 'Core'.
```

To depend on MooseNexus from another baseline:

```st
spec
	baseline: 'MooseNexus'
	with: [ spec repository: 'github://moosetechnology/MooseNexus:v1.x.x/src' ].
```

## Development Installation

For normal core/Java development, load the explicit `default` group. It includes the core and Java packages together with their unit tests:

```st
Metacello new
	githubUser: 'moosetechnology' project: 'MooseNexus' commitish: 'v1.x.x' path: 'src';
	baseline: 'MooseNexus';
	load: 'default'.
```

Load `IntegrationTests` and `JavaIntegrationTests` explicitly when working on integration behavior. These tests use checked-in fixtures and require an attached Iceberg repository. Load `all` only when also developing UI or experimental TypeScript support.

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
