ARG NODE_VERSION
FROM node:${NODE_VERSION}

RUN apk add --no-cache make pkgconfig gcc g++ python3 libx11-dev libxkbfile-dev libsecret-dev

WORKDIR /home/theia
ADD latest.package.json ./package.json

RUN yarn --pure-lockfile && \
    NODE_OPTIONS="--max_old_space_size=4096" yarn theia build && \
    yarn theia download:plugins && \
    yarn --production && \
    yarn autoclean --init && \
    echo *.ts >> .yarnclean && \
    echo *.ts.map >> .yarnclean && \
    echo *.spec.* >> .yarnclean && \
    yarn autoclean --force && \
    yarn cache clean

FROM node:${NODE_VERSION}

# Env variables
ENV HOME=/home/theia \
    SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/home/theia/plugins \
    USE_LOCAL_GIT=true \
    TINI_KILL_PROCESS_GROUP=1 \
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk \
    MAVEN_HOME=/usr/share/java/maven-3 \
    GRADLE_HOME=/usr/share/java/gradle

# Whenever possible, install tools using the distro package manager
RUN apk add --no-cache git openssh bash libsecret \
    tini jq curl socat openjdk11-jdk openjdk11-jmods gradle maven

# Add user
RUN addgroup theia && \
    adduser -G theia -s /bin/sh -D theia && \
    chmod g+rw /home && \
# Setup folders
    mkdir -p /home/theia/workspace && \
    mkdir -p /home/theia/.m2 && \
    mkdir -p /home/theia/.theia && \
    mkdir -p /home/theia/.gradle && \    
    chown -R theia:theia /home/theia && \
# Configure a nice terminal
    echo "export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" >> /home/theia/.bashrc && \
# Fake poweroff (stops the container from the inside by sending SIGHUP to PID 1)
    echo "alias poweroff='kill -1 1'" >> /home/theia/.bashrc && \
# Setup Path
    echo "export PATH='$MAVEN_HOME/bin:$GRADLE_HOME/bin:$PATH'" >> /home/theia/.bashrc && \
# Setup an initial workspace
    echo '{"recentRoots":["file:///home/theia/workspace"]}' > /home/theia/.theia/recentworkspace.json && \
# Setup settings (file icons theme)
    echo '{"workbench.iconTheme": "vs-seti"}' > /home/theia/.theia/settings.json

# Copy files from previous stage 
COPY --from=0 --chown=theia:theia /home/theia /home/theia

# Use tini 
ENTRYPOINT ["/sbin/tini", "--"]

# Running environment
EXPOSE 3030
WORKDIR /home/theia
USER theia
CMD [ "node", "/home/theia/src-gen/backend/main.js", "--hostname=0.0.0.0", "--port=3030" ]
