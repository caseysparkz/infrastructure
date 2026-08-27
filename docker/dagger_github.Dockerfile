FROM 770088062852.dkr.ecr.us-west-2.amazonaws.com/debian13:0.0.1

LABEL contact="docker@caseysparkz.com"
LABEL maintainer="docker@caseysparkz.com"
LABEL parent_image="docker.io/library/debian:13-slim"

ARG GH_URL="https://github.com/cli/cli/releases/download"
ARG GH_VERSION="2.98.0"

USER root

# Install dependencies
RUN true                                                                    \
    && apt-get update                                                       \
    && apt-get install --assume-yes --no-install-recommends                 \
        ca-certificates=20250419                                            \
        git=1:2.47.3-0+deb13u1                                              \
        wget=1.25.0-2                                                       \
    && wget --quiet                                                         \
        "${GH_URL}/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.deb"         \
        -O /tmp/gh.deb                                                      \
    && dpkg -i /tmp/gh.deb                                                  \
    && rm --recursive --force                                               \
        /tmp/gh.deb                                                         \
        /var/lib/apt/lists/*                                                \
    && chown app:app /mnt

USER app

WORKDIR /mnt
