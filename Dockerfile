FROM maven:3-jdk-8-slim as maven-base
FROM gradle:jre as gradle-base

FROM node:10-slim

# Metadata
LABEL org.label-schema.schema-version = "1.0" \
      org.label-schema.name="theia-java" \
      org.label-schema.description="A Docker image containing the theia-ide for Java development" \
      org.label-schema.vcs-url="https://github.com/raonigabriel/theia-java" \
      org.label-schema.version="1.0.0"

COPY --from=maven-base /usr/local/openjdk-8 /usr/local/openjdk-8
COPY --from=maven-base /usr/share/maven /usr/share/maven
COPY --from=gradle-base /opt/gradle /opt/gradle

ENV DEBIAN_FRONTEND=noninteractive \
    JAVA_HOME=/usr/local/openjdk-8 \
    MAVEN_HOME=/usr/share/maven \
    GRADLE_HOME=/opt/gradle \
    PATH=/usr/local/openjdk-8/bin:$PATH

RUN ln -s "${MAVEN_HOME}/bin/mvn" /usr/bin/mvn && \
    ln -s "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle && \
    apt-get update && \
    apt-get install -y python python-pip build-essential gnupg git nano curl apt-transport-https unzip wget && \
    rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos '' theia
RUN chmod g+rw /home && \
    mkdir -p /home/workspaces && \
    chown -R theia:theia /home/theia && \
    chown -R theia:theia /home/workspaces;
WORKDIR /home/theia
USER theia

ADD next.package.json ./package.json
RUN yarn --cache-folder ./ycache && rm -rf ./ycache && \
    NODE_OPTIONS="--max_old_space_size=4096" yarn theia build ; \
    yarn theia download:plugins
EXPOSE 3000

ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/home/theia/plugins
ENTRYPOINT [ "yarn", "theia", "start", "/home/workspaces", "--hostname=0.0.0.0" ]
