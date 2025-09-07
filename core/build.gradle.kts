plugins {
    kotlin("multiplatform")
    kotlin("plugin.serialization")
}

kotlin {
    android()
    iosArm64()
    iosX64()
    iosSimulatorArm64()
    js(IR) { browser() }

    sourceSets {
        val commonMain by getting {
            dependencies {
                implementation(kotlin("stdlib"))
                implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.3")
                implementation("org.jetbrains.kotlinx:kotlinx-datetime:0.6.0")
            }
        }
        val commonTest by getting { 
            dependencies { 
                implementation(kotlin("test")) 
            } 
        }
    }
}
