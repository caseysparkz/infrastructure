FROM 770088062852.dkr.ecr.us-west-2.amazonaws.com/alpine_base:3.18.0

USER root

ENV PYTHONUNBUFFERED=1

RUN apk update                                                          \
    && apk upgrade                                                      \
    && apk add --update --no-cache                                      \
        python3                                                         \
    && ln -sf python3 /usr/bin/python                                   \
    && python -m ensurepip                                              \
    && ln -sf pip3 /usr/bin/pip

USER app

RUN pip install --user --no-cache-dir                                   \
    'boto>=2.49,<3.0'                                                   \
    'boto3>=1.28,<2.0'                                                  \
    'jinja2>=3.1,<4.0'                                                  \
    'python-dateutil>=2.8,<3.0'                                         \
    'requests>=2.31,<3.0'

ENTRYPOINT ["/usr/bin/python3"]
