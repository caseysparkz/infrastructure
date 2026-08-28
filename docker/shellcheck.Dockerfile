# INTERMEDIATE =================================================================
FROM 770088062852.dkr.ecr.us-west-2.amazonaws.com/debian13:0.0.1 AS intermediate

# hadolint ignore=DL3002
USER root

# hadolint ignore=DL3009
RUN true                                                                    \
    && apt-get update                                                       \
    && apt-get install --assume-yes --no-install-recommends                 \
        shellcheck=0.10.0-1

# FINAL ========================================================================
LABEL contact="docker@caseysparkz.com"
LABEL maintainer="docker@caseysparkz.com"
LABEL parent_image="scratch"

FROM scratch

COPY --from=intermediate    /mnt                                        /
COPY --from=intermediate    /usr/bin/shellcheck                         /usr/bin/
COPY --from=intermediate    /usr/lib/x86_64-linux-gnu/libffi.so.8*      /usr/lib/x86_64-linux-gnu/


WORKDIR /mnt

ENTRYPOINT ["/usr/bin/shellcheck"]
