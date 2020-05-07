FROM python:3.7-slim-buster

ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux
ENV PYTHONUNBUFFERED 1

# Airflow
ARG AIRFLOW_VERSION=1.10.7
ARG PYTHON_DEPS="bs4==0.0.1 cryptography==2.6.1 lxml==4.2.4 Pillow==5.4.1 flask-bcrypt==0.7.1 kubernetes==11.0.0"

# Disable noisy "Handling signal" log messages:
# ENV GUNICORN_CMD_ARGS --log-level WARNING

RUN set -ex \
    && buildDeps=' \
        freetds-dev \
        libkrb5-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        libpq-dev \
        git \
    ' \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
        freetds-bin \
        build-essential \
        default-libmysqlclient-dev \
        apt-utils \
        curl \
        rsync \
        netcat \
    && pip install -U pip setuptools wheel \
    && pip install pytz \
    && pip install pyOpenSSL \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && if [ -n "${PYTHON_DEPS}" ]; then pip install ${PYTHON_DEPS}; fi \
    && pip install apache-airflow[celery,kubernetes]==${AIRFLOW_VERSION} \
    && apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

RUN pip install werkzeug==0.16.1