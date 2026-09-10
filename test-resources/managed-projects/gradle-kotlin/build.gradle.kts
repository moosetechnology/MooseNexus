plugins {
    `java`
}

group = "org.moosenexus.fixture"
version = "1.0.0"

repositories {
    maven {
        url = uri("../repository")
    }
}

dependencies {
    implementation("org.moosenexus.fixture:materialized-dependency:1.0.0")
}
