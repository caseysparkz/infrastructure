FROM alpine:3.18

LABEL maintainer="ecr_admin@caseyspar.kz"

RUN apk update                                                          \
    && apk upgrade                                                      \
    && apk add --no-cache                                               \
        musl=1.2.4-r0                                                   \
        musl-locales=0.1.0-r1                                           \
        musl-locales-lang=0.1.0-r1                                      \
        sudo=1.9.13_p3-r2                                               \
        tzdata=2023c-r1

RUN cp /usr/share/zoneinfo/UTC /etc/localtime                           \
    && echo "UTC" > /etc/timezone

RUN echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel

RUN adduser app                                                         \
        -h /app                                                         \
        -D                                                              \
        -u 780                                                          \
    && adduser app wheel

USER app

WORKDIR /app
