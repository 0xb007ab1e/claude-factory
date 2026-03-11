#!/bin/bash
set -euo pipefail

# ==============================================================================
# ARTIFACT: platforms/linux/install.sh
# DESCRIPTION: Linux-specific installer for the AI Factory.
#              Handles package manager detection (apt, dnf, pacman) and
#              installs prerequisites: git, curl, docker or podman.
# USAGE: ./platforms/linux/install.sh
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FACTORY_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "AI Factory — Linux installer"
echo "Factory root: $FACTORY_ROOT"
echo ""
echo "TODO: Implement Linux-specific prerequisite installation."
echo "      - Detect package manager (apt-get, dnf, pacman)"
echo "      - Install: git, curl, docker or podman"
echo "      - Run: $FACTORY_ROOT/bin/factory-bootstrap.sh"
