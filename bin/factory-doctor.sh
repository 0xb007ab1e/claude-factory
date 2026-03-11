#!/bin/bash

# ==============================================================================
# ARTIFACT: factory-doctor.sh
# DESCRIPTION: Read-only environment diagnostic. Checks all prerequisites
#   without creating or modifying anything.
# USAGE: ./factory-doctor.sh
# ==============================================================================

set -euo pipefail

# --- COLOR CODES ---
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
BOLD="\033[1m"
RESET="\033[0m"

PASSED_LABEL="${GREEN}PASSED${RESET}"
FAILED_LABEL="${RED}FAILED${RESET}"
WARN_LABEL="${YELLOW}WARN${RESET}"

# --- COUNTERS ---
PASS_COUNT=0
FAIL_COUNT=0

# --- SOURCE FACTORY CONFIG ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/../lib/factory-config.sh" ]; then
    source "$SCRIPT_DIR/../lib/factory-config.sh"
else
    echo -e "${RED}ERROR:${RESET} Cannot find factory-config.sh at $SCRIPT_DIR/../lib. Aborting."
    exit 1
fi

# --- HELPER FUNCTIONS ---
pass() {
    local msg="$1"
    echo -e "  [ ${PASSED_LABEL} ] $msg"
    (( PASS_COUNT++ )) || true
}

fail() {
    local msg="$1"
    echo -e "  [ ${FAILED_LABEL} ] $msg"
    (( FAIL_COUNT++ )) || true
}

warn() {
    local msg="$1"
    echo -e "  [  ${WARN_LABEL}  ] $msg"
}

section() {
    echo -e "\n${BOLD}$1${RESET}"
}

# ==============================================================================
# HEADER
# ==============================================================================
echo ""
echo -e "${BOLD}============================================================${RESET}"
echo -e "${BOLD}         AI FACTORY: ENVIRONMENT DIAGNOSTIC                ${RESET}"
echo -e "${BOLD}============================================================${RESET}"
echo ""

# ==============================================================================
# CHECK 1: Docker / Podman installed and running
# ==============================================================================
section "Check 1: Container runtime (Docker / Podman)"

if command -v "${DOCKER_CMD:-docker}" &>/dev/null; then
    RUNTIME="${DOCKER_CMD:-docker}"
elif command -v docker &>/dev/null; then
    RUNTIME="docker"
elif command -v podman &>/dev/null; then
    RUNTIME="podman"
else
    RUNTIME=""
fi

if [ -z "$RUNTIME" ]; then
    fail "No container runtime found (docker or podman not in PATH)"
else
    if $RUNTIME info &>/dev/null 2>&1; then
        pass "$RUNTIME is installed and the daemon is responding"
    else
        fail "$RUNTIME is installed but the daemon is not running or not accessible"
    fi
fi

# ==============================================================================
# CHECK 2: claude-base:latest image exists
# ==============================================================================
section "Check 2: claude-base:latest image"

RUNTIME_CMD="${RUNTIME:-docker}"
if $RUNTIME_CMD images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -q "^claude-base:latest$"; then
    pass "claude-base:latest image is present"
else
    fail "claude-base:latest image not found — run factory-bootstrap.sh to build it"
fi

# ==============================================================================
# CHECK 3: ~/.env.global exists and is chmod 600
# ==============================================================================
section "Check 3: ~/.env.global permissions"

ENV_GLOBAL="$HOME/.env.global"
if [ -f "$ENV_GLOBAL" ]; then
    PERMS=$(stat -c "%a" "$ENV_GLOBAL" 2>/dev/null || stat -f "%OLp" "$ENV_GLOBAL" 2>/dev/null)
    if [ "$PERMS" = "600" ]; then
        pass "$HOME/.env.global exists and is chmod 600"
    else
        fail "$HOME/.env.global exists but permissions are $PERMS (expected 600) — run: chmod 600 $HOME/.env.global"
    fi
else
    fail "$HOME/.env.global not found — run factory-env-init.sh to create it"
fi

# ==============================================================================
# CHECK 4: ANTHROPIC_API_KEY is set and starts with sk-ant-
# ==============================================================================
section "Check 4: ANTHROPIC_API_KEY"

# Source .env.global if it exists so the key is available even outside a container
if [ -f "$HOME/.env.global" ]; then
    set +u
    source "$HOME/.env.global" 2>/dev/null || true
    set -u
fi

if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
    if [[ "${ANTHROPIC_API_KEY}" == sk-ant-* ]]; then
        KEY_PREVIEW="${ANTHROPIC_API_KEY:0:12}..."
        pass "ANTHROPIC_API_KEY is set and matches expected prefix ($KEY_PREVIEW)"
    else
        fail "ANTHROPIC_API_KEY is set but does not start with 'sk-ant-' — verify the key value"
    fi
else
    fail "ANTHROPIC_API_KEY is not set — add it to ~/.env.global"
fi

# ==============================================================================
# CHECK 5: ~/.claude/config.json exists
# ==============================================================================
section "Check 5: ~/.claude/config.json"

CLAUDE_CONFIG="$HOME/.claude/config.json"
if [ -f "$CLAUDE_CONFIG" ]; then
    pass "$HOME/.claude/config.json exists"
else
    fail "$HOME/.claude/config.json not found — Claude CLI may not be configured on this host"
fi

# ==============================================================================
# CHECK 6: sidecars directory is non-empty
# ==============================================================================
section "Check 6: Sidecars directory"

SIDECARS_DIR="${FACTORY_BASE_DIR}/docker/sidecars"
if [ -d "$SIDECARS_DIR" ]; then
    SIDECAR_COUNT=$(find "$SIDECARS_DIR" -maxdepth 1 -type f | wc -l)
    if [ "$SIDECAR_COUNT" -gt 0 ]; then
        pass "sidecars/ directory exists and contains $SIDECAR_COUNT file(s)"
    else
        warn "sidecars/ directory exists but is empty"
    fi
else
    fail "sidecars/ directory not found at $SIDECARS_DIR"
fi

# ==============================================================================
# CHECK 7: All factory-*.sh scripts are executable
# ==============================================================================
section "Check 7: factory-*.sh scripts are executable"

NON_EXEC=()
while IFS= read -r -d '' script; do
    if [ ! -x "$script" ]; then
        NON_EXEC+=("$(basename "$script")")
    fi
done < <(find "$FACTORY_BASE_DIR/bin" -maxdepth 1 -name "factory-*.sh" -print0)

if [ "${#NON_EXEC[@]}" -eq 0 ]; then
    pass "All factory-*.sh scripts are executable"
else
    fail "The following factory scripts are not executable: ${NON_EXEC[*]}"
fi

# ==============================================================================
# SUMMARY
# ==============================================================================
echo ""
echo -e "${BOLD}============================================================${RESET}"
echo -e "${BOLD}                      SUMMARY                              ${RESET}"
echo -e "${BOLD}============================================================${RESET}"
echo -e "  ${GREEN}Passed:${RESET} $PASS_COUNT"
echo -e "  ${RED}Failed:${RESET} $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo -e "  ${RED}${BOLD}RESULT: DIAGNOSTIC FAILED${RESET} — $FAIL_COUNT check(s) require attention."
    echo ""
    exit 1
else
    echo -e "  ${GREEN}${BOLD}RESULT: ALL CHECKS PASSED${RESET} — environment looks healthy."
    echo ""
    exit 0
fi
