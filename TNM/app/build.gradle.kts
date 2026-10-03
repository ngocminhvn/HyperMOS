val playCloudProjectNumber = System.getenv("PLAY_CLOUD_PROJECT_NUMBER")
    ?.takeIf { it.matches(Regex("\\d+")) }
    ?: "0"
val playIntegrityBackendUrl = System.getenv("PLAY_INTEGRITY_BACKEND_URL").orEmpty()
val escapedPlayIntegrityBackendUrl = playIntegrityBackendUrl
    .replace("\\", "\\\\")
    .replace("\"", "\\\"")

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.plugin.compose")
}

android {
    namespace = "com.android.trinhngocminh"
    compileSdk = 37

    defaultConfig {
        applicationId = "com.android.trinhngocminh"
        minSdk = 24
        targetSdk = 36
        versionCode = 1
        versionName = "0.2-test"
        buildConfigField("long", "PLAY_CLOUD_PROJECT_NUMBER", "${playCloudProjectNumber}L")
        buildConfigField("String", "PLAY_INTEGRITY_BACKEND_URL", "\"$escapedPlayIntegrityBackendUrl\"")
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    packaging {
        resources.excludes += "/META-INF/{AL2.0,LGPL2.1}"
    }
}

dependencies {
    implementation("androidx.activity:activity-compose:1.13.0")
    implementation("top.yukonga.miuix.kmp:miuix-ui-android:0.9.4")
    implementation("top.yukonga.miuix.kmp:miuix-preference-android:0.9.4")
    implementation("top.yukonga.miuix.kmp:miuix-icons-android:0.9.4")
    implementation("com.google.android.play:integrity:1.6.0")
}
