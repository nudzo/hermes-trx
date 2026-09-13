ARG HERMES_VERSION=latest
FROM nousresearch/hermes-agent:${HERMES_VERSION}

ARG TARGETARCH

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl httpie \
    && case "${TARGETARCH}" in \
        amd64) obscura_arch=x86_64 ;; \
        arm64) obscura_arch=aarch64 ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
    && curl --fail --location --retry 3 \
        "https://github.com/h4ckf0r0day/obscura/releases/latest/download/obscura-${obscura_arch}-linux-stealth.tar.gz" \
        -o /tmp/obscura.tar.gz \
    && tar -xzf /tmp/obscura.tar.gz -C /usr/local/bin \
    && rm /tmp/obscura.tar.gz \
    && curl --fail --location --retry 3 \
        "https://github.com/h4ckf0r0day/obscura/archive/refs/heads/main.tar.gz" \
        -o /tmp/obscura-skills.tar.gz \
    && mkdir -p /opt/hermes/skills \
    && tar -xzf /tmp/obscura-skills.tar.gz -C /opt/hermes/skills --strip-components=2 \
        obscura-main/skills/obscura \
    && rm /tmp/obscura-skills.tar.gz \
    && rm -rf /var/lib/apt/lists/*

USER hermes
