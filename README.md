# theia-java
A custom Docker image containing the theia-ide for Java / Javascript development.
If you don't know what [Eclipse Theia](https://theia-ide.org/) is, here is their official description: **"An Open, Flexible and Extensible Cloud & Desktop IDE Platform"**.
Think vscode, but running on your browser instead.

---
## Motivation
There used to be an "official" theia docker image for Java developers, but this is not being developed anymore.
We were left with some options like php, dart, python or event the [full](https://github.com/theia-ide/theia-apps) docker image that has Java support, but it is huge.
Therefore, I decided to revamp this project to update it, improve security and further reduce its size.

---
## Features
* Multi arch: x64 or arm64
* Based on Alpine 3.14 / node 12.22.6 / yarn 1.22.5
* Includes OpenJDK 11, Maven 3.6.3 and Gradle 6.8.1
* Rellative small footprint: ~ 800 MB
* Runs as the "theia" user (UID=1000, GID=1000)
* No root access, no sudo
* Runs on port 3030, so container ports 3000 and 8080 are free

Pre-installed extensions (using [Open Vsx Registry](https://open-vsx.org/)):
1) [Language Support for Java(TM) by Red Hat](https://open-vsx.org/extension/redhat/java)
2) [Maven for Java](https://open-vsx.org/extension/vscjava/vscode-maven)
3) [Project Manager for Java](https://open-vsx.org/extension/vscjava/vscode-java-dependency)
4) [Debugger for Java](https://open-vsx.org/extension/vscjava/vscode-java-debug)
5) [Test Runner for Java](https://open-vsx.org/extension/vscjava/vscode-java-test)
6) [Gradle Tasks](https://open-vsx.org/extension/richardwillis/vscode-gradle)
7) [Spring Boot Tools](https://open-vsx.org/extension/Pivotal/vscode-spring-boot)
---
## Usage
```
$ docker run -d --name theia-java -p 3030:3030 -p 8080:8080 raonigabriel/theia-java
```
Notice that on this example, we're mapping port 3030, to access the theia-app from the host.
We are also mapping port 8080 to access the app being developed (say, a SpringBoot app) from the host.
Then open your browser: http://localhost:3030

---
## Remarks
The theia app running inside the container is **NOT** password protected and uses HTTP (no encryption).
If you want to add security, please use a reverse-proxy like nginx or Caddy and enable some kind of authentication and SSL.
In case you decide to do so, keep in mind that you will also need to forward the websocket theia uses.

---
## Volumes
* /home/theia/project
* /home/theia/.m2
* /home/theia/.graddle


You could bind mount those, maybe to use the host maven jar cache, or to use a custom settings.xml.

Just pay attention to the files ownerships: theia runs as **UID 1000** inside the container. 

---
## Customization (create your own image / inheritance)

Lets say you want to add a tool (docker cli for an example):
First, create a **Dockerfile** like this:
```
FROM raonigabriel/theia-java
# Change the user to root to install packages with apk
USER root
RUN apk add --no-cache docker-cli
# Go back to the theia user
USER theia
```
Build your custom image:
```
$ docker build . -t my-custom-theia
```

Then run it:
```
$ docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p 3030:3030 -p 8080:8080 my-custom-theia
```

Notice that for this specific scenario, the docker cli inside the container will need access to the Unix domain socket of the docker host, as we're would be running **"docker-in-docker"**, aka **dind**.
Hence, we bind mount it as:  **-v /var/run/docker.sock:/var/run/docker.sock**
Keep in mind that this is equivalent off giving root privileges on your host to the container.

---
## Licenses

[Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0)

---
## Disclaimer
* I am not affiliated in any way with Eclipse foundation.
* This image comes with no warranty. Use it at your own risk.
* I don't like comunists, socialists, left-wing ideology. Don't use my stuff, communist scam.
* Fuck off snowflakes, fuck-off code-covenant, I will call my branches the old way.
* Long live **master**, fuck-off renaming.
