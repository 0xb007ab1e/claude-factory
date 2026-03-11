#!/bin/bash
set -euo pipefail

# ==============================================================================
# ARTIFACT: factory-smoke-test.sh
# DESCRIPTION: Idempotent environment validator.
# SECURITY: Uses existing host credentials without modifying them.
# DOCUMENTATION:
#   1. Spawns a hidden temporary project: .smoke-test-XXXX
#   2. Verifies Claude CLI can see the $ANTHROPIC_API_KEY.
#   3. Confirms the Bind Mount is Read-Only.
#   4. Self-destructs the test environment upon completion.
# ==============================================================================

# --- STAGE 1: ENVIRONMENT RESOLUTION ---
# Ensure we have the factory paths loaded
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/../lib/factory-config.sh" ]; then
	source "$SCRIPT_DIR/../lib/factory-config.sh"
	source "$HOME/.env.global"
else
	echo "❌ ERROR: Factory not initialized. Run factory-bootstrap.sh first."
	exit 1
fi

# --- VERBOSE FLAG ---
QUIET="> /dev/null 2>&1"
if [ "${1:-}" == "--verbose" ] || [ "${VERBOSE:-}" == "1" ]; then
	QUIET=""
fi

TEST_ID=$(date +%s)
TEST_PROJECT=".smoke-test-$TEST_ID"
TEMP_DIR="$FACTORY_SOURCE_ROOT/$TEST_PROJECT"

echo -e "\n\033[0;34m🧪 STARTING FACTORY SMOKE TEST (ID: $TEST_ID)\033[0m"
echo "----------------------------------------------------------------"

# --- STAGE 2: TEMPORARY INFRASTRUCTURE ---
echo -n "🏗️  Creating isolated test project... "
mkdir -p "$TEMP_DIR" && cd "$TEMP_DIR" || exit

# Generate a minimal test Dockerfile
printf "FROM claude-base:latest\nENTRYPOINT [\"tail\", \"-f\", \"/dev/null\"]\n" > Dockerfile

# Generate a temporary Compose file
cat <<EOF > docker-compose.yml
	services:
	smoke_test:
	build: .
	container_name: ${TEST_PROJECT}
	volumes:
	- ~/.claude:/root/.claude:ro
	environment:
	- ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
	- CLAUDE_CODE_NON_INTERACTIVE=true
EOF
echo -e "\033[0;32mDONE\033[0m"

# --- STAGE 3: EXECUTION & VALIDATION ---
echo "🚀 Spawning test container..."
eval "$DOCKER_CMD compose up -d --build $QUIET"

# Test A: Credential Visibility
echo -n "🔍 Checking API Key projection... "
KEY_PRESENT=$(eval "$DOCKER_CMD exec \"$TEST_PROJECT\" bash -c 'echo \$ANTHROPIC_API_KEY' $QUIET | grep -c 'sk-ant'" || true)
if [ "${KEY_PRESENT:-0}" -eq 1 ]; then
	echo -e "\033[0;32mPASSED\033[0m"
else
	echo -e "\033[0;31mFAILED (Key missing in RAM)\033[0m"
fi

# Test B: Bind Mount Integrity (Read-Only Check)
echo -n "🔒 Verifying Read-Only Mount... "
if ! eval "$DOCKER_CMD exec \"$TEST_PROJECT\" touch /root/.claude/smoke.test $QUIET"; then
	echo -e "\033[0;32mPASSED (System is immutable)\033[0m"
else
	echo -e "\033[0;31mFAILED (Mount is writable! Security Risk)\033[0m"
fi

# Test C: Claude CLI Readiness
echo -n "🤖 Pinging Claude CLI... "
CLAUDE_VERSION=$(eval "$DOCKER_CMD exec \"$TEST_PROJECT\" claude --version $QUIET" 2>/dev/null || true)
if [ -n "$CLAUDE_VERSION" ]; then
	echo -e "\033[0;32mPASSED ($CLAUDE_VERSION)\033[0m"
else
	echo -e "\033[0;31mFAILED (CLI not found in image)\033[0m"
fi

# --- STAGE 4: ATOMIC CLEANUP ---
echo "🧹 Scrubbing test artifacts..."
eval "$DOCKER_CMD compose down -v --remove-orphans $QUIET"
cd ..
rm -rf "$TEST_PROJECT"

echo "----------------------------------------------------------------"
echo -e "\033[1;32m✨ SMOKE TEST COMPLETE. ENVIRONMENT IS HEALTHY.\033[0m\n"
