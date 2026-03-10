#!/bin/bash
# ==============================================================================
# ARTIFACT: factory-aliases.sh
# DESCRIPTION: Shell aliases for the AI Factory. Sourced from ~/.bashrc.
#              Edit this file to update aliases — takes effect on next shell open.
# ==============================================================================

source "$FACTORY_BASE_DIR/factory-config.sh"
source "$HOME/.env.global"
alias mkproject='$FACTORY_BASE_DIR/factory-project-new.sh'
alias rmproject='$FACTORY_BASE_DIR/factory-project-rm.sh'
alias lsprojects='$FACTORY_BASE_DIR/factory-project-list.sh'
alias update-base='$FACTORY_BASE_DIR/factory-base-update.sh'
eval "$(direnv hook bash)"
