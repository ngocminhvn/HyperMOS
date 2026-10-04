val driveApiKey = System.getenv("GOOGLE_DRIVE_API_KEY")?.takeIf { it.isNotBlank() } ?: "AIzaSyDf57lzGqJ5jzi9bGTD7PqgNpMVadEvBnw"
val escapedDriveApiKey = driveApiKey
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
        minSdk = 33
        targetSdk = 36
        versionCode = 6
        versionName = "1.0-duck"
        buildConfigField("String", "DRIVE_API_KEY", "\"$escapedDriveApiKey\"")
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
        jniLibs.useLegacyPackaging = true
    }
}

dependencies {
    implementation("androidx.activity:activity-compose:1.13.0")
    implementation("androidx.compose.material3:material3:1.4.0")
    implementation("androidx.compose.material:material-icons-extended:1.7.8")
    implementation(files("libs/duckdetector-sdk.aar"))
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.11.0")
    implementation("androidx.datastore:datastore-preferences:1.2.1")
    implementation("androidx.annotation:annotation:1.11.0")
    implementation("org.lsposed.hiddenapibypass:hiddenapibypass:6.1")
    implementation("org.bouncycastle:bcprov-jdk18on:1.86")
    implementation("com.github.Tencent.soter:soter-core:2.0.7")
}
