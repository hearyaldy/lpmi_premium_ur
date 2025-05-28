plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.haweeinc.lpmi_premium"
    compileSdk = 35  // Use stable Android 14 SDK
    
    // Enhanced resolution strategy
    configurations.all {
        resolutionStrategy {
            // Force Kotlin 1.9.22 for all Kotlin libraries
            force("org.jetbrains.kotlin:kotlin-stdlib:2.0.0")
            force("org.jetbrains.kotlin:kotlin-stdlib-jdk7:2.0.0")
            force("org.jetbrains.kotlin:kotlin-stdlib-jdk8:2.0.0")
            force("org.jetbrains.kotlin:kotlin-reflect:2.0.0")
            
            // Force a compatible version of androidx.core
            force("androidx.core:core:1.12.0")
            force("androidx.core:core-ktx:1.12.0")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    kotlin {
        jvmToolchain(17)
    }

    defaultConfig {
        applicationId = "com.haweeinc.lpmi_premium"
        minSdk = 23
        targetSdk = 35  // Match compileSdk
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    // Use specific versions instead of BOM to ensure compatibility
    implementation("com.google.firebase:firebase-auth:22.3.0") {
        exclude(group = "org.jetbrains.kotlin")  // Corrected Kotlin DSL syntax
    }
    implementation("com.google.firebase:firebase-firestore:24.9.1") {
        exclude(group = "org.jetbrains.kotlin")  // Corrected Kotlin DSL syntax
    }
    implementation("com.google.firebase:firebase-storage:20.3.0") {
        exclude(group = "org.jetbrains.kotlin")  // Corrected Kotlin DSL syntax
    }
    
    // Explicitly add Kotlin dependencies
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.22")
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.22")
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.9.22")
    
    implementation("androidx.multidex:multidex:2.0.1")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = ".."
}