plugins { 
    kotlin("jvm")
    application 
    kotlin("plugin.serialization")
}
application { 
    mainClass.set("com.mebeatme.server.MainKt") 
}
dependencies {
    implementation("io.ktor:ktor-server-netty:3.0.0")
    implementation("io.ktor:ktor-server-content-negotiation:3.0.0")
    implementation("io.ktor:ktor-serialization-kotlinx-json:3.0.0")
    implementation("io.ktor:ktor-server-cors:3.0.0")
    implementation("io.ktor:ktor-server-auth:3.0.0")
    implementation("io.ktor:ktor-server-auth-jwt:3.0.0")
    implementation("io.ktor:ktor-server-call-logging:3.0.0")
    implementation("io.ktor:ktor-server-status-pages:3.0.0")
    implementation("ch.qos.logback:logback-classic:1.4.14")
    
    // Add shared module dependency
    implementation(project(":shared"))
    
    testImplementation("io.ktor:ktor-server-test-host:3.0.0")
    testImplementation("org.jetbrains.kotlin:kotlin-test-junit:1.9.20")
}
