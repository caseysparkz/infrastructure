FROM docker.io/ubuntu:22.04

ENV APP_HOME="/app"
ENV DEBIAN_FRONTEND="noninteractive"
ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"
ENV TZ="UTC"

RUN apt-get update                                                          \
    && apt-get install -y --no-install-recommends                           \
        apt-transport-https=2.4.12                                          \
        ca-certificates=20230311ubuntu0.22.04.1                             \
        curl=7.81.0-1ubuntu1.16                                             \
        git=1:2.34.1-1ubuntu1.11                                            \
        iputils-ping=3:20211215-1                                           \
        locales=2.35-0ubuntu3.8                                             \
        locales-all=2.35-0ubuntu3.8                                         \
        lsb-release=11.1.0ubuntu4                                           \
        tzdata=2024a-0ubuntu0.22.04.1                                       \
        unzip=6.0-26ubuntu3.2                                               \
        vim=2:8.2.3995-1ubuntu2.17                                          \
    && rm -rf /var/cache/apt/*                                              \
    && mkdir -p /opt/bin                                                    \
    && mkdir -p /opt/local/bin                                              \
    && useradd                                                              \
        --system                                                            \
        --home-dir ${APP_HOME}                                              \
        --uid 780                                                           \
        --user-group                                                        \
        app

USER app

ENV PATH="${PATH}:${HOME}/.local/bin"

WORKDIR ${APP_HOME}

ENTRYPOINT ["/usr/bin/bash"]
