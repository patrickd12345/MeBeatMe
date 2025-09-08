pluginManagement {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}

rootProject.name = "MeBeatMe"
include(":core", ":platform:wearos", ":platform:watchos", ":web", ":server")
