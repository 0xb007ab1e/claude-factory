#!/bin/bash
set -euo pipefail

# ==============================================================================
# ARTIFACT: factory-base-update.sh
# DESCRIPTION: Force-rebuilds the core 'claude-base' Docker image.
# ARCHITECTURAL ROLE:
#   This script acts as the update mechanism for the AI Factory. By using
#   '--no-cache', it ensures that the 'npm install' layer is re-evaluated,
#   pulling the most recent version of the Claude Code CLI.
# ==============================================================================

# --- STAGE 1: PATH RESOLUTION ---
# Ensures the script can be executed from any directory while correctly
# locating the 'Dockerfile' sibling file.
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "${BASH_SOURCE[0]}")/factory-config.sh"

CLAUDE_VERSION=${1:-latest}

echo "🔄 Rebuilding Claude Base Image (claude-base:latest)..."

# --- STAGE 2: THE BUILD EXECUTION ---
# FLAG RATIONALE:
# --no-cache: Prevents Docker from reusing old layers. Without this, Docker
#              might skip the 'npm install' step if it thinks the command
#              hasn't changed, leaving you on an outdated version of Claude.
# -t claude-base:latest: Tags the result so 'factory-project-new.sh' can find it.
# -f "$BASE_DIR/Dockerfile": Explicitly points to our documented base file.
# --build-arg CLAUDE_VERSION: Pins the Claude CLI to a specific version (default: latest).
$DOCKER_CMD build --no-cache \
--build-arg CLAUDE_VERSION=${CLAUDE_VERSION} \
-t claude-base:latest \
-f "$BASE_DIR/Dockerfile" \
"$BASE_DIR"

# --- STAGE 3: VERIFICATION ---
if [ $? -eq 0 ]; then
	echo "----------------------------------------------------------------"
	echo "✅ Update complete! All NEW projects will use the updated agent."
	echo "VERSION CHECK:"
	$DOCKER_CMD run --rm claude-base:latest claude --version
	echo "----------------------------------------------------------------"
	else
		echo "❌ ERROR: Base image build failed. Check Dockerfile for syntax errors."
		exit 1
		fi
