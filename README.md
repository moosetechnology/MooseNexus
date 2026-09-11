[![Moose version](https://img.shields.io/badge/Moose-11-%23aac9ff.svg)](https://github.com/moosetechnology/Moose)
[![Moose version](https://img.shields.io/badge/Moose-12-%23aac9ff.svg)](https://github.com/moosetechnology/Moose)
![Build Info](https://github.com/moosetechnology/MooseNexus/workflows/Tests/badge.svg)
[![Coverage Status](https://coveralls.io/repos/github/moosetechnology/MooseNexus/badge.svg?branch=main)](https://coveralls.io/github/moosetechnology/MooseNexus?branch=main)

# MooseNexus

MooseNexus builds, stores, and shares Moose models of software projects. It records model provenance and dependency metadata independently from a project’s build system.

## Key Features

- Imports Java projects managed by Maven or Gradle, as well as explicitly configured unmanaged projects.
- Produces portable model artifacts with versioned metadata and dependency-resolution records.
- Stores artifacts locally and can publish or install them through OCI registries.

## Documentation

- [General](docs/general.md): concepts, architecture, and glossary.
- [User Guide](docs/user-guide.md): building, storing, and sharing models.
- [Installation Guide](docs/installation-guide.md): loading MooseNexus and installing only the tools required by a chosen importer.

## Support

Java support is part of the default MooseNexus distribution. TypeScript support is experimental and deferred from the v1 support commitment.
