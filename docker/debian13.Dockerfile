# Author:       Casey Sparks
# Date:         August 27, 2026
# Description:  Debian 13 image
FROM docker.io/library/debian:13-slim

LABEL contact="docker@caseysparkz.com"
LABEL maintainer="docker@caseysparkz.com"
LABEL parent_image="docker.io/library/debian:13"

ENV DEBCONF_NOWARNINGS yes
ENV DEBIAN_FRONTEND noninteractive
ENV TZ UTC

RUN true                                                                    \
  && echo "${TZ}" > /etc/timezone                                           \
  && apt-get update                                                         \
  && apt-get install --assume-yes --no-install-recommends                   \
    locales=2.41-12+deb13u3                                                 \
  && localedef                                                              \
    -i en_US                                                                \
    -c                                                                      \
    -f UTF-8                                                                \
    -A /usr/share/locale/locale.alias                                       \
    en_US.UTF-8                                                             \
  && rm                                                                     \
    --recursive                                                             \
    --force                                                                 \
    /var/lib/apt/lists/*                                                    \
  && useradd                                                                \
    --home-dir "/home/app"                                                  \
    --create-home                                                           \
    --shell /usr/bin/bash                                                   \
    --system                                                                \
    app

WORKDIR /home/app

USER app
