FROM docker.io/ubuntu:24.04

ENV TZ="UTC"
ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"
ENV DEBIAN_FRONTEND="noninteractive"
ENV APP_HOME="/app"

RUN apt-get update                                                          \
    && apt-get install -y --no-install-recommends                           \
        apt-transport-https=2.7.14build2                                    \
        ca-certificates=20240203                                            \
        curl=8.5.0-2ubuntu10.1                                              \
        git=1:2.43.0-1ubuntu7.1                                             \
        iputils-ping=3:20240117-1build1                                     \
        locales=2.39-0ubuntu8.2                                             \
        locales-all=2.39-0ubuntu8.2                                         \
        lsb-release=12.0-2                                                  \
        tzdata=2024a-3ubuntu1.1                                             \
        unzip=6.0-28ubuntu4                                                 \
        vim=2:9.1.0016-1ubuntu7.1                                           \
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
