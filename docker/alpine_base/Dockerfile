FROM alpine:3.18

LABEL maintainer="ecr_admin@caseyspar.kz"

RUN apk update                                                          \
    && apk upgrade                                                      \
    && apk add                                                          \
        musl                                                            \
        musl-locales                                                    \
        musl-locales-lang                                               \
        sudo                                                            \
        tzdata

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
