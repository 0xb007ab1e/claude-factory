#!/bin/bash
# ==============================================================================
# ARTIFACT: factory-aliases.sh
# DESCRIPTION: Shell aliases for the AI Factory. Sourced from ~/.bashrc.
#              Edit this file to update aliases — takes effect on next shell open.
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/factory-config.sh"
source "$HOME/.env.global"
alias mkproject='$FACTORY_BASE_DIR/bin/factory-project-new.sh'
alias rmproject='$FACTORY_BASE_DIR/bin/factory-project-rm.sh'
alias lsprojects='$FACTORY_BASE_DIR/bin/factory-project-list.sh'
alias update-base='$FACTORY_BASE_DIR/bin/factory-base-update.sh'
eval "$(direnv hook bash)"
