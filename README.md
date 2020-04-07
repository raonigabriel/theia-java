# theia-java
A custom Docker image containing the theia-ide for Java development


## Usage
```
$ docker volume create theia_workspaces
$ docker run -d --name theia-java --restart=unless-stopped --init -p 80:3000 -v theia_workspaces:/home/workspaces raonigabriel/theia-java
```
