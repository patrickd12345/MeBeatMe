plugins { kotlin("js") }
kotlin {
    js(IR) {
        binaries.executable()
        browser { 
            commonWebpackConfig { 
                cssSupport { enabled.set(true) } 
            } 
        }
    }
}
dependencies { implementation(project(":core")) }
