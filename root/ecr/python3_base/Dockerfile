FROM 770088062852.dkr.ecr.us-west-2.amazonaws.com/alpine_base:3.17.1

USER root

RUN apk update                                                              \
    && apk upgrade                                                          \
    && apk add --update --no-cache                                          \
        python3                                                             \
        py-pip

RUN pip install --upgrade \
    wheel

USER app

RUN pip install --user --no-cache-dir                                       \
    boto                                                                    \
    boto3                                                                   \
    jinja2                                                                  \
    python-dateutil                                                         \
    pyyaml                                                                  \
    requests

ENTRYPOINT ["/usr/bin/python3"]
