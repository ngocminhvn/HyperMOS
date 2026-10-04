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
        versionCode = 5
        versionName = "0.9-material3"
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
}
