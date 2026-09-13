ARG HERMES_VERSION=latest
FROM nousresearch/hermes-agent:${HERMES_VERSION}

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends httpie \
    && rm -rf /var/lib/apt/lists/*

USER hermes
