#!/bin/bash
set -euo pipefail

# ==============================================================================
# ARTIFACT: factory-project-new.sh (Portable Edition)
# DESCRIPTION: Orchestrates project creation with configurable paths.
#   - Defaults to the 'node' template if -t is not supplied.
#   - Validates the requested template against available sidecars.
#   - Supports --list-templates to enumerate available templates.
#   - Generates Dockerfile and docker-compose.yml from the resolved template.
#   - Uses $DOCKER_CMD (exported by factory-config.sh) instead of bare docker.
# USAGE: ./factory-project-new.sh -n my-project [-t python] [-s ~/dev] [-b ~/ai-framework]
#        ./factory-project-new.sh --list-templates
# ==============================================================================

# --- STAGE 0: EARLY FLAG HANDLING ---
# Source config first so SIDECARS_DIR is available for --list-templates
source "$(dirname "$0")/../lib/factory-config.sh"
SIDECARS_DIR="${FACTORY_BASE_DIR}/docker/sidecars"

if [ "${1:-}" = "--list-templates" ]; then
	echo "Available templates:"
	for f in "$SIDECARS_DIR"/*.dockerfile; do
		basename "$f" .dockerfile
	done
	exit 0
fi

# --- STAGE 1: PARSE ARGUMENTS ---
while getopts "n:t:s:b:" opt; do
	case $opt in
	n) PROJECT_NAME="$OPTARG" ;;
	t) TEMPLATE="$OPTARG" ;;
	s) CUSTOM_SOURCE="$OPTARG" ;;
	b) CUSTOM_BASE="$OPTARG" ;;
	\?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
	esac
done

# --- STAGE 2: RESOLVE PATHS AND APPLY DEFAULTS ---
SOURCE_ROOT="${CUSTOM_SOURCE:-$FACTORY_SOURCE_ROOT}"
BASE_DIR="${CUSTOM_BASE:-$FACTORY_BASE_DIR}"
SIDECARS_DIR="$BASE_DIR/docker/sidecars"

# Default template
TEMPLATE="${TEMPLATE:-node}"

if [ -z "${PROJECT_NAME:-}" ]; then
	echo "❌ Usage: mkproject -n <name> [-t <template>] [-s <source_root>] [-b <base_dir>]"
	exit 1
fi

# --- STAGE 2b: TEMPLATE VALIDATION ---
if [ ! -f "$SIDECARS_DIR/${TEMPLATE}.dockerfile" ]; then
	echo "❌ Error: unknown template '${TEMPLATE}'." >&2
	echo "Available templates:" >&2
	for f in "$SIDECARS_DIR"/*.dockerfile; do
		basename "$f" .dockerfile >&2
	done
	exit 1
fi

# --- STAGE 3: EXECUTION ---
# Ensure target directories exist
mkdir -p "$SOURCE_ROOT/$PROJECT_NAME"
cd "$SOURCE_ROOT/$PROJECT_NAME" || exit

# Generate Dockerfile from base image + language sidecar
printf "FROM claude-base:latest\n" > Dockerfile
cat "$SIDECARS_DIR/${TEMPLATE}.dockerfile" >> Dockerfile
printf "\nENTRYPOINT [\"tail\", \"-f\", \"/dev/null\"]\n" >> Dockerfile

# Generate docker-compose.yml
cat <<EOF > docker-compose.yml
services:
  ${PROJECT_NAME}_dev:
    build: .
    container_name: ${PROJECT_NAME}_dev
    volumes:
      - ~/.claude:/root/.claude:ro
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - CLAUDE_CODE_NON_INTERACTIVE=true
    stdin_open: true
    tty: true
EOF

echo "🚀 Building in $SOURCE_ROOT/$PROJECT_NAME..."
$DOCKER_CMD compose up -d --build && $DOCKER_CMD exec -it "${PROJECT_NAME}_dev" /bin/bash
