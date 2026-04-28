allprojects {
    repositories {
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/central") }
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }
        // google()
        // mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Workaround for older Flutter plugins lacking a namespace in AGP 8.0+
    afterEvaluate {
        val pluginBuildFile = file("build.gradle")
        if (pluginBuildFile.exists()) {
            val content = pluginBuildFile.readText()
            if (!content.contains("namespace")) {
                var pluginNamespace = "com.example.placeholder"
                val manifestFile = file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    val manifestContent = manifestFile.readText()
                    val packageMatcher = Regex("package=\"([^\"]+)\"").find(manifestContent)
                    if (packageMatcher != null) {
                        pluginNamespace = packageMatcher.groupValues[1]
                    }
                }
                
                extensions.configure<com.android.build.gradle.BaseExtension> {
                    namespace = pluginNamespace
                }
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
