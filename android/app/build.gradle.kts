import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    val appKeyProperties = file("key.properties")
    if (appKeyProperties.exists()) {
        keystoreProperties.load(FileInputStream(appKeyProperties))
    }
}

android {
    namespace = "com.velaplayer.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    signingConfigs {
        create("release") {
            val keyAliasProp = keystoreProperties.getProperty("keyAlias")
            val keyPassProp = keystoreProperties.getProperty("keyPassword")
            val storePassProp = keystoreProperties.getProperty("storePassword")
            val storeFileProp = keystoreProperties.getProperty("storeFile")

            if (keyAliasProp != null && storeFileProp != null) {
                keyAlias = keyAliasProp
                keyPassword = keyPassProp
                storePassword = storePassProp
                val candidate1 = file(storeFileProp)
                val candidate2 = file("../$storeFileProp")
                val candidate3 = rootProject.file(storeFileProp)
                storeFile = when {
                    candidate1.exists() -> candidate1
                    candidate2.exists() -> candidate2
                    else -> candidate3
                }
            }
        }
    }

    defaultConfig {
        applicationId = "com.velaplayer.app"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            val hasReleaseKey = signingConfigs.getByName("release").storeFile?.exists() == true
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Official AndroidX Media3 1.11.0 (Released August 2026)
    implementation("androidx.media3:media3-exoplayer:1.11.0")
    implementation("androidx.media3:media3-session:1.11.0")
    implementation("androidx.media3:media3-ui:1.11.0")
}
