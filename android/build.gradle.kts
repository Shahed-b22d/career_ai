allprojects {
    repositories {
        google()
        mavenCentral()
    }

    repositories.all {
        if (this is MavenArtifactRepository) {
            val originalUrl = url.toString()
            if (originalUrl.contains("storage.googleapis.com")) {
                url = uri(originalUrl.replace("storage.googleapis.com", "storage.flutter-io.cn"))
            }
        }
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
