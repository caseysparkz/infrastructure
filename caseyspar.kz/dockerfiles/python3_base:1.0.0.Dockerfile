FROM 770088062852.dkr.ecr.us-west-2.amazonaws.com/alpine3_base:1.0.0

USER root

ENV PYTHONUNBUFFERED=1

RUN apk update                                                              \
    && apk add --no-cache                                                   \
        py3-pip==23.1.2-r0                                                  \
        python3==3.11.8-r0                                                  \
    && rm /var/cache/apk/*

USER app

RUN pip3 install --user --no-cache-dir                                      \
    'boto3>=1.28,<2.0'                                                      \
    'boto>=2.49,<3.0'                                                       \
    'jinja2>=3.1,<4.0'                                                      \
    'python-dateutil>=2.8,<3.0'                                             \
    'requests>=2.31,<3.0'

ENTRYPOINT ["/usr/bin/python3"]
