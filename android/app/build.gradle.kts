import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing comes from android/key.properties (git-ignored). CI writes it
// from secrets; the release workflow sets REQUIRE_RELEASE_SIGNING so that a
// missing keystore fails the build instead of silently using debug keys.
val keystoreFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystoreFile.exists()
val keystoreProperties = Properties().apply {
    if (hasReleaseKeystore) keystoreFile.inputStream().use { load(it) }
}

if (!hasReleaseKeystore) {
    if (System.getenv("REQUIRE_RELEASE_SIGNING") == "true") {
        throw GradleException(
            "android/key.properties is required when REQUIRE_RELEASE_SIGNING=true."
        )
    }
    logger.warn(
        "android/key.properties not found: release builds use the debug key."
    )
}

android {
    namespace = "com.darcode.solenn"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.darcode.solenn"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (hasReleaseKeystore) {
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        debug {
            // Lets a debug build install next to a release build.
            applicationIdSuffix = ".debug"
        }
        release {
            signingConfig = signingConfigs.getByName(
                if (hasReleaseKeystore) "release" else "debug"
            )
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
