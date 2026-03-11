#!/bin/bash
set -euo pipefail

# ==============================================================================
# ARTIFACT: factory-project-list.sh
# DESCRIPTION: Comprehensive Dashboard for the AI Factory Framework.
# ARCHITECTURAL ROLE:
#   Provides visibility into ephemeral project states by cross-referencing
#   active Docker containers with the physical project directories on the host.
# ==============================================================================

# --- STAGE 1: PATH RESOLUTION ---
# Identifies the root source directory relative to the script's location.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/factory-config.sh"
SRC_DIR="$FACTORY_SOURCE_ROOT"

# --- STAGE 2: UI HEADER ---
echo "================================================================================"
echo "🛡️  AI FACTORY DASHBOARD | HOST: $(hostname) | USER: $USER"
echo "================================================================================"
printf "%-25s %-15s %-15s %-10s\n" "PROJECT NAME" "STATUS" "CONTAINER ID" "DISK USE"
echo "--------------------------------------------------------------------------------"

# --- STAGE 3: PROJECT ITERATION ---
# Iterates through all directories in the source folder, excluding the 'base' config.
shopt -s nullglob
project_dirs=()
for dir in "$SRC_DIR"/*/; do
	dir=${dir%*/}
	project_name=$(basename "$dir")
	if [ "$project_name" == "base" ]; then continue; fi
	project_dirs+=("$dir")
done

if [ ${#project_dirs[@]} -eq 0 ]; then
	echo "No projects found."
else
	for dir in "${project_dirs[@]}"; do
		project_name=$(basename "$dir")

		# Determine Container Status
		# - Checks if a container matching the project naming convention is running.
		container_info=$($DOCKER_CMD ps --filter "name=${project_name}_dev" --format "{{.ID}}|{{.Status}}")

		if [ -n "$container_info" ]; then
			cid=$(echo "$container_info" | cut -d'|' -f1)
			status="🟢 $(echo "$container_info" | cut -d'|' -f2 | awk '{print $1,$2}')"
		else
			cid="-----------"
			status="⚪ Offline"
		fi

		# Calculate Disk Usage
		# - Summarizes the host-side storage consumed by the project directory.
		disk_use=$(du -sh "$dir" | awk '{print $1}')

		# Output Row
		printf "%-25s %-15s %-15s %-10s\n" "$project_name" "$status" "$cid" "$disk_use"
	done
fi

# --- STAGE 4: GLOBAL RESOURCE FOOTPRINT ---
echo "--------------------------------------------------------------------------------"
echo "📦 GLOBAL FACTORY FOOTPRINT"
echo "--------------------------------------------------------------------------------"

# Total number of project directories
p_count=0
for _d in "$SRC_DIR"/*/; do
	[ "$(basename "${_d%/}")" != "base" ] && (( p_count++ )) || true
done

# Count of active containers
c_count=$($DOCKER_CMD ps --filter "name=_dev" -q | wc -l)

# Summary of the 'claude-base' image size
img_size=$($DOCKER_CMD images claude-base:latest --format "{{.Size}}")

echo "📂 Total Projects: $p_count"
echo "🚀 Active Agents: $c_count"
echo "💾 Base Image Size: $img_size"
echo "================================================================================"
