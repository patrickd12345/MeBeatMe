plugins {
    kotlin("multiplatform")
    kotlin("plugin.serialization")
    id("com.android.library")
}

kotlin {
    jvm()
    
    androidTarget {
        compilations.all {
            kotlinOptions {
                jvmTarget = "17"
            }
        }
    }
    
    jvm()
    
    listOf(
        iosX64(),
        iosArm64(),
        iosSimulatorArm64()
    ).forEach { target ->
        target.binaries.framework {
            baseName = "Shared"
            isStatic = true
        }
    }
    
    // Add watchOS targets (modern architectures only)
    listOf(
        watchosArm64(),
        watchosSimulatorArm64()
    ).forEach { target ->
        target.binaries.framework {
            baseName = "Shared"
            isStatic = true
        }
    }

    sourceSets {
        val commonMain by getting {
            dependencies {
                implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.0")
                implementation("org.jetbrains.kotlinx:kotlinx-datetime:0.4.1")
                implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
            }
        }
        val commonTest by getting {
            dependencies {
                implementation(kotlin("test"))
                implementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.3")
            }
        }
        val androidMain by getting
        val androidUnitTest by getting
        val iosX64Main by getting
        val iosArm64Main by getting
        val iosSimulatorArm64Main by getting
        val iosMain by creating {
            dependsOn(commonMain)
            iosX64Main.dependsOn(this)
            iosArm64Main.dependsOn(this)
            iosSimulatorArm64Main.dependsOn(this)
        }
        val iosTest by creating {
            dependsOn(commonTest)
        }
        
        // Add watchOS source sets (modern architectures only)
        val watchosArm64Main by getting
        val watchosSimulatorArm64Main by getting
        val watchosMain by creating {
            dependsOn(commonMain)
            watchosArm64Main.dependsOn(this)
            watchosSimulatorArm64Main.dependsOn(this)
        }
        val watchosTest by creating {
            dependsOn(commonTest)
        }
    }
}

android {
    namespace = "com.mebeatme.shared"
    compileSdk = 34
    defaultConfig {
        minSdk = 24
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

// Task to build XCFramework for iOS/watchOS
tasks.register("assembleXCFramework") {
    group = "build"
    description = "Build XCFramework for iOS/watchOS"
    dependsOn(
        "linkDebugFrameworkIosArm64", 
        "linkDebugFrameworkIosSimulatorArm64",
        "linkDebugFrameworkWatchosArm64",
        "linkDebugFrameworkWatchosSimulatorArm64"
    )
    
    doLast {
        val xcframeworkDir = file("build/XCFrameworks/debug")
        xcframeworkDir.mkdirs()
        
        val xcframeworkPath = file("build/XCFrameworks/debug/Shared.xcframework")
        
        // Remove existing XCFramework if it exists
        if (xcframeworkPath.exists()) {
            xcframeworkPath.deleteRecursively()
        }
        
        // Create XCFramework using xcodebuild with iOS and watchOS frameworks
        // Note: Using only modern architectures to avoid conflicts
        exec {
            commandLine(
                "xcodebuild", "-create-xcframework",
                "-framework", "build/bin/iosArm64/debugFramework/shared.framework",
                "-framework", "build/bin/iosSimulatorArm64/debugFramework/shared.framework",
                "-framework", "build/bin/watchosArm64/debugFramework/shared.framework",
                "-framework", "build/bin/watchosSimulatorArm64/debugFramework/shared.framework",
                "-output", xcframeworkPath.absolutePath
            )
        }
        
        println("XCFramework built successfully at: ${xcframeworkPath.absolutePath}")
    }
}
