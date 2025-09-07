plugins { 
    kotlin("jvm")
    application 
}
application { 
    mainClass.set("com.mebeatme.server.MainKt") 
}
dependencies {
    implementation("io.ktor:ktor-server-netty:3.0.0")
    implementation("io.ktor:ktor-server-content-negotiation:3.0.0")
    implementation("io.ktor:ktor-serialization-kotlinx-json:3.0.0")
}
