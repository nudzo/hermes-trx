# hermes-trx

[![Build and publish Hermes image](https://github.com/nudzo/hermes-trx/actions/workflows/build-image.yml/badge.svg)](https://github.com/nudzo/hermes-trx/actions/workflows/build-image.yml)
[![Container Registry](https://img.shields.io/badge/ghcr.io-nudzo%2Fhermes--trx-blue?logo=docker)](https://ghcr.io/nudzo/hermes-trx)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

An extended multi-architecture container image for [NousResearch Hermes Agent](https://github.com/NousResearch/hermes-agent), pre-equipped with Obscura, developer CLI utilities, runtime environments, and language servers for autonomous coding and tool use.

---

## Features & Included Tools

`hermes-trx` builds upon the official `nousresearch/hermes-agent` base image and layers additional capabilities:

### 1. Stealth & Agent Skills

- **[Obscura](https://github.com/h4ckf0r0day/obscura)**: Pre-compiled stealth binary installed to `/usr/local/bin/obscura`.
- **Obscura Skills**: Extracted and integrated into `/opt/hermes/skills/obscura`.

### 2. CLI & Productivity Utilities

- **HTTPie (`httpie`)**: User-friendly HTTP client for API interaction and testing.
- **fzf (`fzf`)**: Command-line fuzzy finder.
- **GitHub CLI (`gh`)**: GitHub's official CLI at `/usr/local/bin/gh`, for PRs, issues, releases, and API access. `git` is wired to use `gh` as its HTTPS credential helper, so one token authenticates both.
- **curl & CA Certificates**: Secure web transfers and up-to-date certificate authorities.

### 3. Runtimes, AST Tools & Language Servers

- **Bun (`bun`)**: Fast all-in-one JavaScript/TypeScript runtime, bundler, and package manager.
- **Bash Language Server (`bash-language-server`)**: Language Server Protocol (LSP) support for shell scripts.
- **ast-grep (`@ast-grep/cli`)**: Fast, AST-powered code search and refactoring tool.
- **Pyright (`pyright`)**: Static type checker and language server for Python.
- **Derive Python SDK (`derive-py`)**: Installed from a pinned Git revision for reproducible image builds.
- **TA-Lib Python package (`TA-Lib`)**: PyPI-distributed Python bindings for technical analysis workflows.
- **pyhood (`pyhood`)**: Additional Python tooling included in the image.

---

## Architecture Support

Images are automatically built for multiple CPU architectures via Docker Buildx and QEMU:

- `linux/amd64`
- `linux/arm64`

---

## Quick Start

### Pull the Image

```bash
docker pull ghcr.io/nudzo/hermes-trx:latest
```

### Run Interactively

```bash
docker run -it --rm ghcr.io/nudzo/hermes-trx:latest
```

### Pull Specific Version Tags

Images are tagged alongside upstream Hermes releases:

```bash
  docker pull ghcr.io/nudzo/hermes-trx:v2026.9.11
```

### GitHub Authentication

Supply a GitHub token via environment variable — no `gh auth login` needed. Both standard variables work; `gh` accepts either (if both are set, `GH_TOKEN` wins):

```bash
docker run -it --rm -e GITHUB_TOKEN=<your-PAT> ghcr.io/nudzo/hermes-trx:latest
```

A fine-grained PAT works as-is: `gh` reads it from the environment on every invocation, and the baked-in system gitconfig routes `git clone/push` over HTTPS through `gh auth git-credential`, which serves the same token. Effective permissions are exactly the token's — for repository work, grant the fine-grained PAT at least **Contents: read/write** (clone/push/PR) and, as needed, **Pull requests / Issues / Workflows: read/write**. No token is stored inside the image.

---

## Automated Builds & Tagging

GitHub Actions automatically builds and publishes images via [.github/workflows/build-image.yml](.github/workflows/build-image.yml):

- **Triggers**:
  - Pushes to the `main` branch.
  - Nightly scheduled cron (`0 3 * * *`) to stay up to date with upstream releases.
  - Manual trigger via `workflow_dispatch`.
- **Release Resolution**:
  - Dynamically fetches the latest stable release of [Obscura](https://github.com/h4ckf0r0day/obscura).
  - Fetches the latest and recent stable release tags of [hermes-agent](https://github.com/NousResearch/hermes-agent).
  - Publishes `latest` along with versioned tags matching upstream releases.
  - Automatically cleans up untagged container image versions.

---

## Local Development & Building

You can build the Docker image locally using [Dockerfile](Dockerfile):

```bash
# Set target versions
export HERMES_VERSION=latest
export OBSCURA_VERSION=v0.2.2

# Build with Docker Buildx
docker build \
  --build-arg HERMES_VERSION=${HERMES_VERSION} \
  --build-arg OBSCURA_VERSION=${OBSCURA_VERSION} \
  -t hermes-trx:local .
```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
