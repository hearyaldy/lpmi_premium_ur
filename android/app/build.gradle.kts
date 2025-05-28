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
            force("org.jetbrains.kotlin:kotlin-stdlib:1.9.22")
            force("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.22")
            force("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.9.22")
            force("org.jetbrains.kotlin:kotlin-reflect:1.9.22")
            
            // Force a compatible version of androidx.core
            force("androidx.core:core:1.13.1")
            force("androidx.core:core-ktx:1.13.1")
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
        exclude(group = "org.jetbrains.kotlin")
    }
    implementation("com.google.firebase:firebase-firestore:24.9.1") {
        exclude(group = "org.jetbrains.kotlin")
    }
    implementation("com.google.firebase:firebase-storage:20.3.0") {
        exclude(group = "org.jetbrains.kotlin")
    }
    
    // Fix androidx.core compatibility issue
    implementation("androidx.core:core:1.13.1")
    implementation("androidx.core:core-ktx:1.13.1")
    
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

// Fix for Flutter APK location issue - Kotlin DSL version
tasks.configureEach {
    if (name == "assembleDebug") {
        finalizedBy("copyDebugApkToFlutterExpectedLocation")
    }
    if (name == "assembleRelease") {
        finalizedBy("copyReleaseApkToFlutterExpectedLocation")
    }
}

tasks.register("copyDebugApkToFlutterExpectedLocation") {
    doLast {
        val appBuildDir = layout.buildDirectory.get().asFile
        val projectRootDir = project.rootDir.parentFile
        val sourceDir = File(appBuildDir, "outputs/apk/debug")
        val targetDir = File(projectRootDir, "build/app/outputs/flutter-apk")
        
        if (sourceDir.exists()) {
            targetDir.mkdirs()
            
            val apkFiles = sourceDir.listFiles()?.filter { it.name.endsWith(".apk") } ?: emptyList()
            if (apkFiles.isNotEmpty()) {
                val sourceApk = apkFiles[0]
                val targetApk = File(targetDir, "app-debug.apk")
                
                sourceApk.copyTo(targetApk, overwrite = true)
                println("Copied APK from ${sourceApk.path} to ${targetApk.path}")
            }
        }
    }
}

tasks.register("copyReleaseApkToFlutterExpectedLocation") {
    doLast {
        val appBuildDir = layout.buildDirectory.get().asFile
        val projectRootDir = project.rootDir.parentFile
        val sourceDir = File(appBuildDir, "outputs/apk/release")
        val targetDir = File(projectRootDir, "build/app/outputs/flutter-apk")
        
        if (sourceDir.exists()) {
            targetDir.mkdirs()
            
            val apkFiles = sourceDir.listFiles()?.filter { it.name.endsWith(".apk") } ?: emptyList()
            if (apkFiles.isNotEmpty()) {
                val sourceApk = apkFiles[0]
                val targetApk = File(targetDir, "app-release.apk")
                
                sourceApk.copyTo(targetApk, overwrite = true)
                println("Copied APK from ${sourceApk.path} to ${targetApk.path}")
            }
        }
    }
}