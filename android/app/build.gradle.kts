plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.shelfsense.app"
    // Pinned: the Flutter default (37) only exists in the SDK as the minor-versioned
    // "android-37.0" package, which AGP cannot resolve from the plain "android-37" hash.
    // 36 = Android 16, which is what the target iQOO 15 runs.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.shelfsense.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
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


// tflite_flutter 0.12.1 pins LiteRT 1.4.0, which fails on A's model
// ("Input tensor 207 lacks data"). 1.4.2 is the newest runtime that still
// ships the classic C API (libtensorflowlite_jni.so) the Dart FFI binds;
// 2.x replaces it with libLiteRt.so and a different API.
configurations.all {
    resolutionStrategy.force(
        "com.google.ai.edge.litert:litert:1.4.2",
        "com.google.ai.edge.litert:litert-gpu:1.4.2",
    )
}
