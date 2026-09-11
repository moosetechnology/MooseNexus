#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 DESTINATION MAVEN_VERSION GRADLE_VERSION" >&2
  exit 64
fi

destination=$1
maven_version=$2
gradle_version=$3
maven_home="$destination/apache-maven-$maven_version"
gradle_home="$destination/gradle-$gradle_version"

mkdir -p "$destination"

if [ ! -x "$maven_home/bin/mvn" ]; then
  maven_archive="$destination/apache-maven-$maven_version-bin.tar.gz"
  curl --fail --location --retry 3 --silent --show-error \
    --output "$maven_archive" \
    "https://archive.apache.org/dist/maven/maven-3/$maven_version/binaries/apache-maven-$maven_version-bin.tar.gz"
  tar --extract --gzip --file "$maven_archive" --directory "$destination"
fi

if [ ! -x "$gradle_home/bin/gradle" ]; then
  gradle_archive="$destination/gradle-$gradle_version-bin.zip"
  curl --fail --location --retry 3 --silent --show-error \
    --output "$gradle_archive" \
    "https://services.gradle.org/distributions/gradle-$gradle_version-bin.zip"
  unzip -q "$gradle_archive" -d "$destination"
fi

printf '%s\n%s\n' "$maven_home/bin" "$gradle_home/bin"
