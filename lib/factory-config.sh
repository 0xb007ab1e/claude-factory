#!/bin/bash

# ==============================================================================
# ARTIFACT: factory-config.sh
# DESCRIPTION: Central Path, Configuration & Runtime Resolver.
# DOCUMENTATION:
#   This script establishes the PROJECT_ROOT and FRAMEWORK_BASE.
#   It prioritizes: 1. CLI Arguments, 2. Env Variables, 3. Defaults.
#   It also detects the available container runtime (podman preferred over docker)
#   and exports it as DOCKER_CMD.
# ==============================================================================

# Default values if nothing is provided
DEFAULT_SOURCE_ROOT="$HOME/_src"

# Resolve Source Root (Where projects live)
export FACTORY_SOURCE_ROOT="${FACTORY_SOURCE_ROOT:-$DEFAULT_SOURCE_ROOT}"

# Resolve Framework Base (Where these scripts live)
# This uses the script's own location as a fallback to ensure it's "self-aware"
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export FACTORY_BASE_DIR="${FACTORY_BASE_DIR:-$SCRIPT_PATH}"

# Verbose logging for debugging (can be silenced)
# echo "🛠  Factory Root: $FACTORY_SOURCE_ROOT"
# echo "🛠  Factory Base: $FACTORY_BASE_DIR"

# Detect container runtime (podman preferred over docker)
DOCKER_CMD=$(command -v podman 2>/dev/null || command -v docker 2>/dev/null)
export DOCKER_CMD
if [ -z "$DOCKER_CMD" ]; then
  echo "❌ ERROR: Neither podman nor docker found in PATH." >&2
  exit 1
fi
