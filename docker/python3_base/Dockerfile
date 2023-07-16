FROM ecr.caseyspar.kz/alpine_base:3.18.0

USER root

RUN apk update                                                          \
    && apk upgrade                                                      \
    && apk add --update --no-cache                                      \
        python3                                                         \
        py-pip

RUN pip install --upgrade                                               \
    wheel

USER app

RUN pip install --user --no-cache-dir                                   \
    boto                                                                \
    boto3                                                               \
    jinja2                                                              \
    python-dateutil                                                     \
    pyyaml                                                              \
    requests

ENTRYPOINT ["/usr/bin/python3"]
