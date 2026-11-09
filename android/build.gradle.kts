import java.util.Properties
import java.io.FileInputStream

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}

allprojects {
    val downloadsToken = localProperties.getProperty("MAPBOX_DOWNLOADS_TOKEN", "")
    if (downloadsToken.isNotEmpty()) {
        extra.set("MAPBOX_DOWNLOADS_TOKEN", downloadsToken)
    }
    val accessToken = localProperties.getProperty("MAPBOX_ACCESS_TOKEN", "")
    if (accessToken.isNotEmpty()) {
        extra.set("MAPBOX_ACCESS_TOKEN", accessToken)
    }
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://api.mapbox.com/downloads/v2/releases/maven")
            authentication {
                create<HttpHeaderAuthentication>("basic")
            }
            credentials(HttpHeaderCredentials::class) {
                name = "Authorization"
                value = "Bearer ${localProperties.getProperty("MAPBOX_DOWNLOADS_TOKEN", "")}"
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
