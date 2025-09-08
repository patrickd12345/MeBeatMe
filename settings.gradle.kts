pluginManagement {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}

rootProject.name = "MeBeatMe"
include(":core", ":shared", ":platform:wearos", ":platform:watchos", ":web", ":server", ":androidApp", ":wearApp")
