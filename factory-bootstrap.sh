#!/bin/bash
set -euo pipefail

# ==============================================================================
# ARTIFACT: factory-bootstrap.sh (Auto-Activation Edition)
# DESCRIPTION: Full onboarding wizard with automatic shell environment refresh.
# ==============================================================================

# --- STAGE 1: DYNAMIC DEFAULTS ---
DEFAULT_SRC="$HOME/_src"
DEFAULT_BASE="$HOME/_src/base"
DEFAULT_GIT_NAME="$(git config --global user.name || echo "$USER")"
DEFAULT_GIT_EMAIL="$(git config --global user.email || echo "$USER@$(hostname)")"

while getopts "s:b:i:" opt; do
	case $opt in
	s) CUSTOM_SRC="$OPTARG" ;;
b) CUSTOM_BASE="$OPTARG" ;;
i) IMPORT_PATH="$OPTARG" ;;
esac
done

SRC_ROOT="${CUSTOM_SRC:-$DEFAULT_SRC}"
BASE_DIR="${CUSTOM_BASE:-$DEFAULT_BASE}"
SIDECAR_DIR="$BASE_DIR/sidecars"

echo -e "\n\033[0;34m================================================================\033[0m"
echo -e "\033[0;34m🛡️  AI FACTORY: FULL SYSTEM ONBOARDING\033[0m"
echo -e "\033[0;34m================================================================\033[0m"

# --- STAGE 2: IDENTITY & CREDENTIAL COLLECTION ---
echo -e "\n\033[1;33m[1/3] DEVELOPER IDENTITY\033[0m"
read -p "📝 Git Author Name [$DEFAULT_GIT_NAME]: " GIT_NAME
GIT_NAME=${GIT_NAME:-$DEFAULT_GIT_NAME}

read -p "📧 Git Author Email [$DEFAULT_GIT_EMAIL]: " GIT_EMAIL
GIT_EMAIL=${GIT_EMAIL:-$DEFAULT_GIT_EMAIL}

read -p "🔑 GitHub Username [$GIT_NAME]: " GH_USER
GH_USER=${GH_USER:-$GIT_NAME}

echo -e "\n\033[1;33m[2/3] CLAUDE API CONFIGURATION\033[0m"
while true; do
	read -rsp "🗝️  Enter Anthropic API Key (sk-ant-...): " CLAUDE_KEY
	history -d $(history 1) 2>/dev/null || true
	echo
	if [[ $CLAUDE_KEY == sk-ant-* ]]; then break
		else echo -e "\033[0;31m❌ Invalid format. Please try again.\033[0m"; fi
			done

			read -rsp "🗝️  Enter GitHub Personal Access Token (Optional): " GH_TOKEN
			history -d $(history 1) 2>/dev/null || true
			echo
			
			# --- STAGE 3: INFRASTRUCTURE GENERATION ---
			mkdir -p "$SRC_ROOT" "$SIDECAR_DIR" "$HOME/.claude"
			
			# Generate Path Resolver
			cat <<EOF > "$BASE_DIR/factory-config.sh"
			#!/bin/bash
			export FACTORY_SOURCE_ROOT="$SRC_ROOT"
			export FACTORY_BASE_DIR="$BASE_DIR"
			EOF
			chmod +x "$BASE_DIR/factory-config.sh"
			
			# Generate Global Secrets (Hardened)
			GLOBAL_ENV="$HOME/.env.global"
			cat <<EOF > "$GLOBAL_ENV"
			export GIT_AUTHOR_NAME="$GIT_NAME"
			export GIT_AUTHOR_EMAIL="$GIT_EMAIL"
			export GITHUB_USER="$GH_USER"
			export ANTHROPIC_API_KEY="$CLAUDE_KEY"
			export GITHUB_TOKEN="$GH_TOKEN"
			EOF
			chmod 600 "$GLOBAL_ENV"
			
			# Generate Claude Identity Shim
			printf '{"primaryProfile":"default","profiles":{"default":{"authMethod":"api-key","autoLogin":true}}}' > "$HOME/.claude/config.json"
			
			# Import Sidecars or Create Sample
			[ -d "$IMPORT_PATH" ] && cp -n "$IMPORT_PATH"/*.dockerfile "$SIDECAR_DIR/" 2>/dev/null
			if [ -z "$(ls -A "$SIDECAR_DIR")" ]; then
				echo "RUN apt-get update && apt-get install -y python3 && rm -rf /var/lib/apt/lists/*" > "$SIDECAR_DIR/sample.dockerfile.example"
				fi
				
				# --- STAGE 4: GH CLI INSTALL ---
			echo -e "\n\033[1;33m[3/3] GITHUB CLI\033[0m"
			GH_BIN="$HOME/.local/bin/gh"
			if command -v gh &>/dev/null || [ -x "$GH_BIN" ]; then
				echo -e "✅ gh CLI already installed: $(gh --version 2>/dev/null | head -1)"
			else
				echo -n "📦 Installing gh CLI... "
				GH_VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep -o '"tag_name": "[^"]*"' | grep -o 'v[0-9.]*')
				GH_TARBALL="gh_${GH_VERSION#v}_linux_amd64.tar.gz"
				curl -sLo "/tmp/$GH_TARBALL" "https://github.com/cli/cli/releases/download/${GH_VERSION}/${GH_TARBALL}"
				tar -xzf "/tmp/$GH_TARBALL" -C /tmp
				mkdir -p "$HOME/.local/bin"
				cp "/tmp/gh_${GH_VERSION#v}_linux_amd64/bin/gh" "$GH_BIN"
				rm -rf "/tmp/$GH_TARBALL" "/tmp/gh_${GH_VERSION#v}_linux_amd64"
				echo -e "\033[0;32mDONE ($GH_VERSION)\033[0m"
			fi

			# Add .local/bin to PATH permanently if not already present
			if ! grep -q '\.local/bin' "$HOME/.bashrc"; then
				echo -e '\n# Local user binaries\nexport PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
			fi
			export PATH="$HOME/.local/bin:$PATH"

			# Authenticate gh with the provided token
			if [ -n "$GH_TOKEN" ]; then
				echo -n "🔑 Authenticating gh CLI... "
				echo "$GH_TOKEN" | "$GH_BIN" auth login --hostname github.com --with-token 2>/dev/null \
					&& echo -e "\033[0;32mDONE\033[0m" \
					|| echo -e "\033[0;33mWARN: auth failed — run 'gh auth login' manually\033[0m"
			fi

			# Configure git credential helper
			git config --global credential.helper "$GH_BIN auth git-credential"

			# --- STAGE 5: SHELL INTEGRATION ---
				if ! grep -q "AI FACTORY ALIASES" "$HOME/.bashrc"; then
					cat <<EOF >> "$HOME/.bashrc"

					# --- AI FACTORY ALIASES ---
					export FACTORY_SOURCE_ROOT="$SRC_ROOT"
					export FACTORY_BASE_DIR="$BASE_DIR"
					source "\$FACTORY_BASE_DIR/factory-aliases.sh"
					EOF
					fi
					
					echo -e "\n\033[0;32m✅ SYSTEM INITIALIZED.\033[0m"
					echo -e "\033[1;32m🔄 REFRESHING SHELL... YOU ARE READY TO GO!\033[0m\n"
					
					# --- STAGE 6: AUTO-SOURCE & EXECUTION ---
					# This replaces the current shell with a new one that has the aliases loaded.
					exec bash
