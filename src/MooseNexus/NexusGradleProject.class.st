"
I represent a project managed with Gradle.

The `gradle` command or an existing `gradlew` executable is used to get the projects and dependencies declared in a build file.
Build files can be written in Groovy and named `build.gradle`, or written in Kotlin and named `build.gradle.kts`.

### Specification
Dependency descriptors are strings structured as `group:artifact:type:version:scope:path`.
The type can be custom, or more commonly jar, war, ear, zip, tar, or pom.
The scope can be custom, or one of the following:
- `compile` (deprecated): Compile time dependencies. Superseded by implementation.
- `implementation` extends `compile`: Implementation only dependencies.
- `compileOnly`: Compile time only dependencies, not used at runtime.
- `compileClasspath` extends `compile`, `compileOnly`, `implementation`: Compile classpath, used when compiling source. Used by the task compileJava.
- `annotationProcessor`: Annotation processors used during compilation.
- `runtime` (deprecated) extends `compile`: Runtime dependencies. Superseded by runtimeOnly.
- `runtimeOnly`: Runtime only dependencies.
- `runtimeClasspath` extends `runtimeOnly`, `runtime`, `implementation`: Runtime classpath contains elements of the implementation, as well as runtime-only elements.
- `testCompile` (deprecated) extends `compile`: Additional dependencies for compiling tests. Superseded by testImplementation.
- `testImplementation` extends `testCompile`, `implementation`: Implementation only dependencies for tests.
- `testCompileOnly`: Additional dependencies only for compiling tests, not used at runtime.
- `testCompileClasspath` extends `testCompile`, `testCompileOnly`, `testImplementation`: Test compile classpath, used when compiling test sources. Used by the task compileTestJava.
- `testRuntime` (deprecated) extends `runtime`, `testCompile`: Additional dependencies for running tests only. Superseded by testRuntimeOnly.
- `testRuntimeOnly` extends `runtimeOnly`: Runtime-only dependencies for running tests.
- `testRuntimeClasspath` extends `testRuntimeOnly`, `testRuntime`, `testImplementation`: Runtime classpath for running tests. Used by the task test.
- `archives`: Artifacts (e.g., jars) produced by this project. Used by the task uploadArchives.
- `default` extends `runtime`: The default configuration used by a project dependency on this project. Contains the artifacts and dependencies required by this project at runtime.

"
Class {
	#name : 'NexusGradleProject',
	#superclass : 'NexusManagedProject',
	#category : 'MooseNexus-Project',
	#package : 'MooseNexus',
	#tag : 'Project'
}

{ #category : 'testing' }
NexusGradleProject >> isGradleProject [

	^ true
]
