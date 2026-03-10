#!/bin/bash
set -euo pipefail

# ==============================================================================
# ARTIFACT: factory-project-rm.sh (Cleanup Utility)
# DESCRIPTION: Shuts down containers and deletes ephemeral project folders.
# DOCUMENTATION:
#   - docker compose down -v: Stops container and removes the network.
#   - rm -rf: Deletes the project folder on the host.
# ==============================================================================

PROJECT_NAME=$1
TARGET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../$PROJECT_NAME"

if [ ! -d "$TARGET_DIR" ]; then
	echo "❌ ERROR: Target directory $TARGET_DIR does not exist."
	exit 1
	fi
	
	read -p "⚠️  PERMANENTLY DELETE $PROJECT_NAME? (y/n) " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		cd "$TARGET_DIR"
		# SECURITY: This only removes project-specific volumes, not the shared claude-config.
		docker compose down -v --remove-orphans
		cd ..
		rm -rf "$PROJECT_NAME"
		echo "✅ Workspace $PROJECT_NAME has been neutralized."
		fi
