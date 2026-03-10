#!/bin/bash
set -euo pipefail

# ==============================================================================
# ARTIFACT: factory-env-init.sh (Interactive Setup)
# DESCRIPTION: Customizes the host environment based on developer preference.
# ==============================================================================

echo "--- AI Factory Setup ---"

# Prompt for Developer Preferences
read -p "Enter your preferred Project Source Root [Default: $HOME/_src]: " USER_SRC
USER_SRC=${USER_SRC:-$HOME/_src}

read -p "Enter your Framework Base Directory [Default: $USER_SRC/base]: " USER_BASE
USER_BASE=${USER_BASE:-$USER_SRC/base}

# Ensure directories exist
mkdir -p "$USER_SRC"
mkdir -p "$USER_BASE/sidecars"

# Write preferences to the Global Env
GLOBAL_ENV="$HOME/.env.global"
cat <<EOF > "$GLOBAL_ENV"
# --- PATH CONFIGURATION ---
export FACTORY_SOURCE_ROOT="$USER_SRC"
export FACTORY_BASE_DIR="$USER_BASE"

# --- SECRETS ---
export ANTHROPIC_API_KEY="REPLACE_ME"
export GITHUB_TOKEN="REPLACE_ME"
EOF

echo "✅ Environment configured in $GLOBAL_ENV"
echo "✅ Directories initialized at $USER_SRC and $USER_BASE"
