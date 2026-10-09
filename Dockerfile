ARG HERMES_VERSION=latest
FROM nousresearch/hermes-agent:${HERMES_VERSION}

ARG TARGETARCH
ARG GH_VERSION=v2.101.0
ARG UV_VERSION=0.12.3
ARG OBSCURA_VERSION

USER root

# The base image no longer ships uv on PATH: upstream's 2026-10 pm toolchain
# rework stages the pinned uv privately under /opt/hermes/tools for pm's own
# use ("build consumers receive Python environments, never an installer
# executable"). Ship our own pinned uv — matching pm/lock.json's version —
# both for the installs below and as a PATH tool, as the base used to provide.
COPY --from=ghcr.io/astral-sh/uv:${UV_VERSION} /uv /uvx /usr/local/bin/
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl httpie fzf shfmt \
    && test -n "${OBSCURA_VERSION}" \
    && case "${TARGETARCH}" in \
        amd64) obscura_arch=x86_64 ;; \
        arm64) obscura_arch=aarch64 ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
    && curl --fail --location --retry 3 \
        "https://github.com/h4ckf0r0day/obscura/releases/download/${OBSCURA_VERSION}/obscura-${obscura_arch}-linux-stealth.tar.gz" \
        -o /tmp/obscura.tar.gz \
    && tar -xzf /tmp/obscura.tar.gz -C /usr/local/bin \
    && rm /tmp/obscura.tar.gz \
    && curl --fail --location --retry 3 \
        "https://github.com/h4ckf0r0day/obscura/archive/refs/tags/${OBSCURA_VERSION}.tar.gz" \
        -o /tmp/obscura-skills.tar.gz \
    && mkdir -p /opt/hermes/skills \
    && tar -xzf /tmp/obscura-skills.tar.gz -C /opt/hermes/skills --strip-components=2 \
        "obscura-${OBSCURA_VERSION#v}/skills/obscura" \
    && rm /tmp/obscura-skills.tar.gz \
    && curl --fail --location --retry 3 \
        "https://github.com/cli/cli/releases/download/${GH_VERSION}/gh_${GH_VERSION#v}_linux_${TARGETARCH}.tar.gz" \
        -o /tmp/gh.tar.gz \
    && curl --fail --location --retry 3 \
        "https://github.com/cli/cli/releases/download/${GH_VERSION}/gh_${GH_VERSION#v}_checksums.txt" \
        -o /tmp/gh_checksums.txt \
    && awk -v file="gh_${GH_VERSION#v}_linux_${TARGETARCH}.tar.gz" '$2 == file { print $1 "  /tmp/gh.tar.gz" }' /tmp/gh_checksums.txt > /tmp/gh.sha256 \
    && test -s /tmp/gh.sha256 \
    && sha256sum -c /tmp/gh.sha256 \
    && tar -xzf /tmp/gh.tar.gz -C /usr/local/bin --strip-components=2 \
        "gh_${GH_VERSION#v}_linux_${TARGETARCH}/bin/gh" \
    && rm /tmp/gh.tar.gz /tmp/gh_checksums.txt /tmp/gh.sha256 \
    && git config --system credential."https://github.com".helper "!/usr/local/bin/gh auth git-credential" \
    && git config --system credential."https://gist.github.com".helper "!/usr/local/bin/gh auth git-credential" \
    && npm install -g bun \
    && npm install -g bash-language-server \
    && npm install -g @ast-grep/cli \
    && uv pip install --python /opt/hermes/.venv/bin/python \
        pyright \
        "git+https://github.com/derivexyz/derive-py.git@38d8ef6645d7711185b0cd7b64efb85bce8e6158" \
        TA-Lib==0.7.1 \
        pyhood==0.12.1 \
    && rm -rf /var/lib/apt/lists/*

# USER hermes # base image starting under `root` user
