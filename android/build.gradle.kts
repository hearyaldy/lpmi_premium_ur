buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.4")  // Stable version
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.0.0")
        classpath("com.google.gms:google-services:4.4.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Simplified build directory configuration
rootProject.buildDir = File(rootDir, "build")

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}