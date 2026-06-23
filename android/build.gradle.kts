allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    // Enforce Java 17 compatibility for all JavaCompile tasks
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }

    // Enforce Kotlin JVM Target 17 compatibility for all subprojects via reflection
    tasks.configureEach {
        if (this.javaClass.name.contains("KotlinCompile")) {
            try {
                val compilerOptions = this.javaClass.getMethod("getCompilerOptions").invoke(this)
                val jvmTarget = compilerOptions.javaClass.getMethod("getJvmTarget").invoke(compilerOptions)
                val jvmTargetClass = Class.forName("org.jetbrains.kotlin.gradle.dsl.JvmTarget")
                val jvm17 = jvmTargetClass.getField("JVM_17").get(null)
                jvmTarget.javaClass.getMethod("set", Object::class.java).invoke(jvmTarget, jvm17)
                logger.lifecycle("Dynamically set Kotlin JVM target to 17 for task: $name in subproject :${project.name}")
            } catch (e: Exception) {
                try {
                    this.javaClass.getMethod("setJvmTarget", String::class.java).invoke(this, "17")
                    logger.lifecycle("Dynamically set Kotlin JVM target (legacy) to 17 for task: $name in subproject :${project.name}")
                } catch (ex: Exception) {
                    // Ignore
                }
            }
        }
    }

    val configureNamespace = {
        if (plugins.hasPlugin("com.android.application") || plugins.hasPlugin("com.android.library")) {
            val android = extensions.findByName("android")
            if (android != null) {
                // Dynamically configure namespace
                try {
                    val getNamespace = android.javaClass.getMethod("getNamespace")
                    val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                    val currentNamespace = getNamespace.invoke(android) as? String
                    if (currentNamespace.isNullOrEmpty()) {
                        val manifestFile = file("src/main/AndroidManifest.xml")
                        if (manifestFile.exists()) {
                            val manifestXml = manifestFile.readText()
                            val packageMatcher = java.util.regex.Pattern.compile("package=\"([^\"]+)\"").matcher(manifestXml)
                            if (packageMatcher.find()) {
                                val pkg = packageMatcher.group(1)
                                setNamespace.invoke(android, pkg)
                                logger.lifecycle("Dynamically set namespace for subproject :${project.name} to $pkg")
                            }
                        }
                    }
                } catch (e: Exception) {
                    // Ignore if methods do not exist
                }

                // Dynamically configure Java compileOptions compatibility to Java 17
                try {
                    val compileOptions = android.javaClass.getMethod("getCompileOptions").invoke(android)
                    val setSourceCompatibility = compileOptions.javaClass.methods.firstOrNull { it.name == "setSourceCompatibility" }
                    val setTargetCompatibility = compileOptions.javaClass.methods.firstOrNull { it.name == "setTargetCompatibility" }
                    setSourceCompatibility?.invoke(compileOptions, "17")
                    setTargetCompatibility?.invoke(compileOptions, "17")
                    logger.lifecycle("Dynamically set Android compileOptions to Java 17 for subproject :${project.name}")
                } catch (e: Exception) {
                    // Ignore if methods do not exist
                }
            }
        }
    }

    if (state.executed) {
        configureNamespace()
    } else {
        afterEvaluate {
            configureNamespace()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
