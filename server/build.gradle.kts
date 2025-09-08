plugins { 
    kotlin("jvm")
    application 
    kotlin("plugin.serialization")
}

application { 
    mainClass.set("com.mebeatme.server.MainKt") 
}

dependencies {
    implementation(project(":shared"))
    implementation("io.ktor:ktor-server-netty:3.0.0")
    implementation("io.ktor:ktor-server-content-negotiation:3.0.0")
    implementation("io.ktor:ktor-serialization-kotlinx-json:3.0.0")
    implementation("io.ktor:ktor-server-cors:3.0.0")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.0")
}
