# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

---

## [0.2.0] - 2026-03-10

### Added
- `factory-doctor.sh` — read-only environment diagnostic with ANSI-colored PASSED/FAILED/WARN output across 7 checks; exits non-zero if any check fails.
- `factory-aliases.sh` — decoupled alias definitions sourced from `~/.bashrc`; edit once, takes effect on next shell open without re-running bootstrap.
- `factory-project-new.sh`: `--list-templates` flag to print available sidecars and exit.
- `factory-project-new.sh`: template validation with helpful error listing available options on unknown template.
- `factory-project-new.sh`: default template (`node`) when `-t` is omitted.
- `factory-project-new.sh`: complete `docker-compose.yml` generation replacing the previous stub.
- `factory-smoke-test.sh`: `--verbose` flag to stream container output instead of suppressing it.
- `factory-base-update.sh`: optional version argument (`$1`) passed as `--build-arg CLAUDE_VERSION` for reproducible builds.
- `Dockerfile`: `ARG CLAUDE_VERSION=latest` for pinnable Claude CLI installs.
- `factory-bootstrap.sh`: automatic `gh` CLI download and install to `~/.local/bin`.
- `factory-bootstrap.sh`: `~/.local/bin` added to `PATH` in `~/.bashrc` permanently.
- `factory-bootstrap.sh`: `gh auth login` via provided GitHub token during onboarding.
- `factory-bootstrap.sh`: `git credential.helper` configured to use `gh auth git-credential`.
- `.gitignore`, `CHANGELOG.md`, `LICENSE` — repo hygiene files.
- `README.md` — full documentation of all scripts, flags, architecture, and troubleshooting.

### Changed
- `factory-config.sh`: auto-detects container runtime (`podman` preferred over `docker`) and exports `$DOCKER_CMD`; all scripts now use `$DOCKER_CMD` instead of hardcoded `docker`.
- `factory-bootstrap.sh`: `.bashrc` integration reduced to a single `source factory-aliases.sh` line instead of individual alias definitions.
- `factory-bootstrap.sh`: credential `read` calls use `-r` flag and clear bash history after each sensitive prompt.
- `factory-project-list.sh`: null-safe iteration with `nullglob` handles empty project directories gracefully.
- All scripts: `set -euo pipefail` added for consistent error handling.
- All scripts: renamed to consistent `factory-<noun>-<verb>.sh` convention.
- `sidecars/`: version-query comments added to all sidecar Dockerfiles.

## [0.1.0] - 2026-03-10

### Added
- `factory-config.sh` — central path and configuration resolver; establishes `FACTORY_SOURCE_ROOT` and `FACTORY_BASE_DIR` with CLI-arg → env-var → default precedence.
- `factory-bootstrap.sh` — one-shot host setup: builds the `claude-base:latest` Docker image and initialises the global credential file.
- `factory-env-init.sh` — interactive wizard that creates and secures `~/.env.global` (chmod 600) with the user's `ANTHROPIC_API_KEY`.
- `factory-project-new.sh` — scaffolds a new isolated Claude agent project under `$FACTORY_SOURCE_ROOT` with a dedicated Dockerfile and docker-compose service.
- `factory-project-list.sh` — lists all active projects under `$FACTORY_SOURCE_ROOT`.
- `factory-project-rm.sh` — safely tears down and removes a named project directory and its container artifacts.
- `factory-base-update.sh` — rebuilds `claude-base:latest` in place, pulling the latest Claude CLI release.
- `factory-smoke-test.sh` — idempotent end-to-end validator; spawns a temporary container, verifies API key projection and read-only bind-mount integrity, then self-destructs.
- `Dockerfile` — base image definition installing Node.js, the Claude CLI, and common development utilities.
- `sidecars/` — language-specific sidecar Dockerfiles (Python, Node.js, Go, Rust, C++) for polyglot agent workspaces.

[Unreleased]: https://github.com/0xb007ab1e/claude-factory/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/0xb007ab1e/claude-factory/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/0xb007ab1e/claude-factory/releases/tag/v0.1.0
