FROM 770088062852.dkr.ecr.us-west-2.amazonaws.com/ubuntu22_base:1.0.0

USER root

ENV PYTHONUNBUFFERED=1

RUN apt-get update                                                          \
    && apt-get install -y --no-install-recommends                           \
        python3-pip=22.0.2+dfsg-1ubuntu0.4                                  \
    && rm -rf /var/cache/apt/*

USER app

RUN pip3 install --user --no-cache-dir                                      \
    'boto3>=1.28,<2.0'                                                      \
    'boto>=2.49,<3.0'                                                       \
    'jinja2>=3.1,<4.0'                                                      \
    'python-dateutil>=2.8,<3.0'                                             \
    'requests>=2.31,<3.0'

ENTRYPOINT ["/usr/bin/python3"]
