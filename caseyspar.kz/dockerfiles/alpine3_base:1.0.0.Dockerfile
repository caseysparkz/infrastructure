FROM docker.io/alpine:3.18

RUN apk update                                                              \
    && apk add --no-cache                                                   \
        musl==1.2.4-r2                                                      \
        musl-locales==0.1.0-r1                                              \
        musl-locales-lang==0.1.0-r1                                         \
        sudo==1.9.13_p3-r2                                                  \
        tzdata==2024a-r0                                                    \
    && rm /var/cache/apk/*                                                  \
    && cp /usr/share/zoneinfo/UTC /etc/localtime                            \
    && echo "UTC" > /etc/timezone                                           \
    && echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel                   \
    && adduser                                                              \
        --home /app                                                         \
        --system                                                            \
        --disabled-password                                                 \
        --uid 780                                                           \
        app

USER app

ENV HOME="/app"
ENV PATH="${PATH}:${HOME}/.local/bin"

WORKDIR /app
