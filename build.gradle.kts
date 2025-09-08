plugins {
    kotlin("multiplatform") version "2.0.0" apply false
    kotlin("plugin.serialization") version "2.0.0" apply false
    kotlin("js") version "2.0.0" apply false
    kotlin("jvm") version "2.0.0" apply false
    id("com.android.library") version "8.2.0" apply false
}

allprojects {
    repositories { 
        google()
        mavenCentral()
        maven("https://maven.pkg.jetbrains.space/public/p/compose/dev")
    }
}
