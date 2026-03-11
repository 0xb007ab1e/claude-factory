#!/bin/bash
set -euo pipefail

# ==============================================================================
# ARTIFACT: platforms/macos/install.sh
# DESCRIPTION: macOS-specific installer for the AI Factory.
#              Handles Homebrew installation and installs prerequisites:
#              git, curl, docker or podman.
# USAGE: ./platforms/macos/install.sh
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FACTORY_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "AI Factory — macOS installer"
echo "Factory root: $FACTORY_ROOT"
echo ""
echo "TODO: Implement macOS-specific prerequisite installation."
echo "      - Install Homebrew if not present"
echo "      - brew install git curl docker"
echo "      - Run: $FACTORY_ROOT/bin/factory-bootstrap.sh"
