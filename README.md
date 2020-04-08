# theia-java
A custom Docker image containing the theia-ide for Java development


## Features
* Based on https://github.com/theia-ide/theia-apps/tree/master/theia-java-docker
* The Java used is OpenJDK version instead of IBM one.
* Java, Maven and Gradle are copied over from another Docker images instead of using the distro version.
* Project dir is "/home/workspaces" instead of "/home/project"
* Small footprint: about 1.62 GB instead of 2.2GB

## Usage
```
$ docker volume create theia_workspaces
$ docker run -d --name theia-java --restart=unless-stopped --init -p 80:3000 -v theia_workspaces:/home/workspaces raonigabriel/theia-java
```
