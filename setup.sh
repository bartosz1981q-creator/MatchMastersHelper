#!/bin/bash
# Match Masters Helper - automatyczne tworzenie całego projektu
set -e

echo "=== Tworzenie struktury projektu ==="
mkdir -p .github/workflows
mkdir -p gradle/wrapper
mkdir -p app/src/main/java/com/matchmasters/helper/ui/theme
mkdir -p app/src/main/res/values

echo "=== Plik 1: build.gradle.kts (root) ==="
cat > build.gradle.kts << 'EOF'
plugins {
    id("com.android.application") version "8.5.2" apply false
    id("org.jetbrains.kotlin.android") version "2.0.20" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
    id("com.google.firebase.crashlytics") version "3.0.2" apply false
}
EOF

echo "=== Plik 2: settings.gradle.kts ==="
cat > settings.gradle.kts << 'EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "MatchMastersHelper"
include(":app")
EOF

echo "=== Plik 3: gradle.properties ==="
cat > gradle.properties << 'EOF'
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
kotlin.code.style=official
android.nonTransitiveRClass=true
EOF

echo "=== Plik 4: gradle/wrapper/gradle-wrapper.properties ==="
cat > gradle/wrapper/gradle-wrapper.properties << 'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.9-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

echo "=== Plik 5: .github/workflows/build.yml ==="
cat > .github/workflows/build.yml << 'EOF'
name: Build APK

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'

      - name: Set up Gradle
        uses: gradle/actions/setup-gradle@v4

      - name: Build debug APK
        run: gradle assembleDebug

      - name: Upload APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: match-masters-debug-apk
          path: app/build/outputs/apk/debug/*.apk
EOF

echo "=== Plik 6: app/build.gradle.kts ==="
cat > app/build.gradle.kts << 'EOF'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    id("kotlin-kapt")
}

android {
    namespace = "com.matchmasters.helper"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.matchmasters.helper"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    buildFeatures {
        compose = true
    }
    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.14"
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }
}

dependencies {
    implementation(platform("androidx.compose:compose-bom:2024.09.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.activity:activity-compose:1.9.2")
    implementation("androidx.navigation:navigation-compose:2.8.1")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.5")

    implementation(platform("com.google.firebase:firebase-bom:33.2.0"))
    implementation("com.google.firebase:firebase-auth-ktx")
    implementation("com.google.firebase:firebase-firestore-ktx")
    implementation("com.google.firebase:firebase-functions-ktx")
    implementation("com.google.firebase:firebase-messaging-ktx")
    implementation("com.google.firebase:firebase-crashlytics-ktx")

    implementation("com.android.billingclient:billing-ktx:7.1.1")
    implementation("com.google.android.gms:play-services-ads:23.2.0")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")
    implementation("io.coil-kt:coil-compose:2.7.0")
}
EOF

echo "=== Plik 7: app/src/main/AndroidManifest.xml ==="
cat > app/src/main/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.MatchMastersHelper">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:theme="@style/Theme.MatchMastersHelper">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

    </application>
</manifest>
EOF

echo "=== Plik 8: app/src/main/res/values/strings.xml ==="
cat > app/src/main/res/values/strings.xml << 'EOF'
<resources>
    <string name="app_name">Match Masters Helper</string>
</resources>
EOF

echo "=== Plik 9: app/src/main/res/values/themes.xml ==="
cat > app/src/main/res/values/themes.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.MatchMastersHelper" parent="android:Theme.Material.NoActionBar">
        <item name="android:statusBarColor">#0A0A12</item>
        <item name="android:navigationBarColor">#0A0A12</item>
        <item name="android:windowBackground">#0A0A12</item>
    </style>
</resources>
EOF

echo "=== Plik 10: app/src/main/java/com/matchmasters/helper/MainActivity.kt ==="
cat > app/src/main/java/com/matchmasters/helper/MainActivity.kt << 'EOF'
package com.matchmasters.helper

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.matchmasters.helper.ui.theme.MatchMastersTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MatchMastersTheme {
                HomeScreen()
            }
        }
    }
}

@Composable
fun HomeScreen() {
    val bgGradient = Brush.verticalGradient(
        listOf(Color(0xFF0A0A12), Color(0xFF1A0B2E))
    )

    Scaffold(
        containerColor = Color.Transparent,
        bottomBar = { BottomBar() }
    ) { padding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(bgGradient)
                .padding(padding),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "Match Masters\nHelper",
                color = Color.White,
                fontSize = 34.sp,
                letterSpacing = 2.sp
            )
        }
    }
}

@Composable
fun BottomBar() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Transparent)
    ) {}
}
EOF

echo "=== Plik 11: app/src/main/java/com/matchmasters/helper/ui/theme/Theme.kt ==="
cat > app/src/main/java/com/matchmasters/helper/ui/theme/Theme.kt << 'EOF'
package com.matchmasters.helper.ui.theme

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Shapes
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

val DeepBlack = Color(0xFF0A0A12)
val PanelDark = Color(0xFF14141F)
val NeonPurple = Color(0xFF9D4DFF)
val NeonGreen = Color(0xFF00E676)
val NeonPink = Color(0xFFFF2D78)
val TextMain = Color(0xFFEDEDF5)
val TextDim = Color(0xFF8A8AA3)
val DiamondGold = Color(0xFF4DD0E1)

val DiamondGradient = Brush.linearGradient(
    colors = listOf(Color(0xFF4DD0E1), Color(0xFFB2EBF2), Color(0xFF00E5FF))
)

private val AppColors = darkColorScheme(
    primary = NeonPurple,
    secondary = NeonGreen,
    tertiary = NeonPink,
    background = DeepBlack,
    surface = PanelDark,
    onPrimary = Color.White,
    onBackground = TextMain,
    onSurface = TextMain
)

private val AppShapes = Shapes(
    small = RoundedCornerShape(8.dp),
    medium = RoundedCornerShape(16.dp),
    large = RoundedCornerShape(24.dp)
)

@Composable
fun MatchMastersTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = AppColors,
        shapes = AppShapes,
        typography = MaterialTheme.typography,
        content = content
    )
}
EOF

echo ""
echo "=============================================="
echo "  GOTOWE! Wszystkie 11 plików utworzonych."
echo "  Teraz w terminalu wpisz:"
echo "=============================================="
echo ""
echo "  git add . && git commit -m \"init\" && git push"
echo ""
echo "  Potem w GitHub wejdź w Actions i poczekaj na build."
echo "=============================================="