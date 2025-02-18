FROM ubuntu:22.04

# system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gpp \
        pandoc \
        patch \
        python3 \
        python-is-python3 \
        python3-pip \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# python dependencies
COPY ./requirements.txt /
RUN pip3 install --no-cache-dir -r /requirements.txt

WORKDIR /work
