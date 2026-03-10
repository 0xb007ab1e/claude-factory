# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `factory-doctor.sh` — read-only environment diagnostic with ANSI-colored PASSED/FAILED/WARN output and a summary exit code.

### Changed

### Fixed

---

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

[Unreleased]: https://github.com/claude-factory/base/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/claude-factory/base/releases/tag/v0.1.0
