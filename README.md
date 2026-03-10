# Claude Factory: Agentic Dev Environment

**https://github.com/0xb007ab1e/claude-factory**

Automates the creation of isolated, language-specific development containers optimized for the Claude Code AI agent. Uses a **Core + Sidecar** architecture to keep images lean while supporting polyglot development.

---

## Directory Structure

```
_src/
├── base/                        # This repository — the command center
│   ├── Dockerfile               # Core base image (Ubuntu + Node.js + Claude CLI)
│   ├── factory-bootstrap.sh     # One-time onboarding wizard
│   ├── factory-aliases.sh       # Shell aliases (sourced from ~/.bashrc)
│   ├── factory-config.sh        # Path resolver and runtime detection (docker/podman)
│   ├── factory-env-init.sh      # Lightweight path-only setup (alternative to bootstrap)
│   ├── factory-project-new.sh   # Create and launch a new project container
│   ├── factory-project-rm.sh    # Stop and remove a project container
│   ├── factory-project-list.sh  # Dashboard — lists all projects and their status
│   ├── factory-base-update.sh   # Rebuild the core claude-base image
│   ├── factory-smoke-test.sh    # Environment validation suite
│   ├── factory-doctor.sh        # Diagnostic script — checks environment health
│   └── sidecars/                # Language-specific Dockerfile overlays
│       ├── node.dockerfile
│       ├── python.dockerfile
│       ├── go.dockerfile
│       ├── rust.dockerfile
│       └── cpp.dockerfile
└── <project-name>/              # Generated project workspaces (siblings to base)
```

**Host files:**
- `~/.env.global` — secrets (API keys, GitHub token, Git identity). `chmod 600`.
- `~/.claude/` — Claude CLI config. Mounted read-only into all containers.

---

## Getting Started

### 1. Bootstrap (first-time setup)

```bash
bash factory-bootstrap.sh
```

Prompts for Git identity, Anthropic API key, and GitHub token. Generates `~/.env.global`, `~/.claude/config.json`, and adds factory aliases to `~/.bashrc`. Opens a new shell when complete.

### 2. Create a project

```bash
mkproject -n my-app -t python
```

Builds the core image + Python sidecar, generates a `docker-compose.yml`, and drops you into an interactive shell inside the container.

### 3. List projects

```bash
lsprojects
```

### 4. Remove a project

```bash
rmproject -n my-app
```

---

## Aliases

Defined in `factory-aliases.sh` and sourced automatically from `~/.bashrc`. Edit this file to change alias targets — takes effect on the next shell open.

| Alias | Script | Description |
| :--- | :--- | :--- |
| `mkproject` | `factory-project-new.sh` | Create and launch a new project container |
| `rmproject` | `factory-project-rm.sh` | Stop and remove a project |
| `lsprojects` | `factory-project-list.sh` | Dashboard of all projects |
| `update-base` | `factory-base-update.sh` | Rebuild the core `claude-base` image |

---

## Commands Reference

### `factory-project-new.sh`

```
Usage: mkproject -n <name> -t <template> [-s <source_root>] [-b <base_dir>]
       mkproject --list-templates
```

| Flag | Description |
| :--- | :--- |
| `-n <name>` | Project name (required) |
| `-t <template>` | Sidecar template to use. Defaults to `node`. |
| `-s <source_root>` | Override the project source root |
| `-b <base_dir>` | Override the base directory |
| `--list-templates` | Print all available sidecar templates and exit |

### `factory-base-update.sh`

```
Usage: factory-base-update.sh [<claude-version>]
```

Rebuilds `claude-base:latest` with `--no-cache`. Optionally accepts a specific Claude CLI version:

```bash
update-base              # pulls latest
update-base 1.2.3        # pins to a specific version
```

### `factory-smoke-test.sh`

```
Usage: factory-smoke-test.sh [--verbose]
```

Spins up a temporary container, runs three checks (API key projection, read-only mount, Claude CLI presence), then self-destructs. Pass `--verbose` to stream full container output.

### `factory-doctor.sh`

Checks the full environment without creating anything. Useful for diagnosing onboarding failures.

```bash
bash factory-doctor.sh
```

Checks: container runtime available, `claude-base:latest` image present, `~/.env.global` permissions, API key format, `~/.claude/config.json`, sidecars populated, all factory scripts executable.

---

## Language Templates

| Template | Installs |
| :--- | :--- |
| `node` | nodejs, npm, typescript, ts-node, prettier |
| `python` | python3, python3-pip |
| `go` | golang-go |
| `rust` | rustup (stable toolchain) |
| `cpp` | build-essential, cmake, gdb, clang-format |

Run `mkproject --list-templates` to see available templates at any time.

---

## Architecture

### Core + Sidecar

The base `Dockerfile` builds a minimal Ubuntu 22.04 image with Node.js LTS and the Claude CLI. Each sidecar (`sidecars/*.dockerfile`) is a thin overlay appended at project creation time — only the tools you need are installed.

### Container Runtime

`factory-config.sh` auto-detects the container runtime at shell load time, preferring `podman` over `docker`:

```bash
export DOCKER_CMD=$(command -v podman 2>/dev/null || command -v docker 2>/dev/null)
```

All scripts use `$DOCKER_CMD` — no manual configuration needed on Podman systems.

### Secret Injection

Credentials are never baked into images. They are injected at runtime via `docker-compose.yml` environment variables sourced from `~/.env.global`. The `~/.claude/` directory is mounted read-only.

### Version Pinning

The Claude CLI version can be pinned at build time:

```dockerfile
ARG CLAUDE_VERSION=latest
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_VERSION}
```

Pass a version to `factory-base-update.sh` to target a specific release.

---

## Troubleshooting

### "Neither podman nor docker found in PATH"

Install Docker or Podman, then open a new shell. On Debian/Parrot OS with Podman:

```bash
systemctl --user enable --now podman.socket
export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"
```

### "Factory not initialized"

Run `factory-bootstrap.sh` to generate `~/.env.global` and `factory-config.sh`.

### Environment not healthy

Run `factory-doctor.sh` for a full diagnostic, then `factory-smoke-test.sh --verbose` to validate the container runtime end-to-end.
