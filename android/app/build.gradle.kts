plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.my_flutter_app"
    compileSdk = 35                                // ✅ Android SDK 35 recommandé
    ndkVersion = "27.0.12077973"                   // ✅ Plugins demandent NDK 27.x

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.my_flutter_app"
        minSdk = flutter.minSdkVersion
        targetSdk = 35                              // ✅ Cible compatible avec les plugins
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
