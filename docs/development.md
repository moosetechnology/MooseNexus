# Development

## Release

Create a release PR that updates `MooseNexusVersion class >> current` to the next plain SemVer version. Run the relevant tests, wait for the Tests workflow, then merge the PR. Do not create a GitHub release or tag manually.

After Tests succeeds on `main`, the Release workflow creates the exact `v<version>` GitHub release and updates the `v<major>.x.x` and `v<major>.<minor>.x` floating tags.

Use the manual Release workflow only to recover a failed automatic release. Run it from `main` after Tests has succeeded for the intended commit. If the release exists but its floating tags were not updated, run Update Floating Release Tags with the exact release tag. Do not force-push release or floating tags manually.
