# ==============================================================================
# ARTIFACT: claude-base Dockerfile
# DESCRIPTION: Core utility image containing the Node.js runtime and Claude CLI.
# SECURITY: Contains NO credentials. Clean for registry distribution.
# ==============================================================================

# Using Ubuntu 22.04 LTS for long-term stability and broad package support
FROM ubuntu:22.04

# ENV: DEBIAN_FRONTEND
# Ensures that apt-get commands do not hang waiting for user input during build
ENV DEBIAN_FRONTEND=noninteractive

# LAYER 1: Core OS Utilities
# - curl: For fetching Node.js setup scripts
# - git: Required for Claude Code to perform diffs and indexing
# - ca-certificates: Required for secure SSL/TLS connections
RUN apt-get update && apt-get install -y \
curl \
git \
vim \
ca-certificates \
&& rm -rf /var/lib/apt/lists/*

# LAYER 2: Node.js Runtime
# Claude Code is a TypeScript/Node-based CLI. We use Node 20 (LTS).
ARG CLAUDE_VERSION=latest
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
&& apt-get install -y nodejs \
&& npm install -g @anthropic-ai/claude-code@${CLAUDE_VERSION}

# LAYER 3: Environment Hardening
# - CLAUDE_CODE_NON_INTERACTIVE: Disables the initial onboarding 'Welcome' screens
# - WORKDIR: Sets the standard entry point for project mounting
ENV CLAUDE_CODE_NON_INTERACTIVE=true
WORKDIR /app

# The base image does not have an ENTRYPOINT; it is intended to be inherited.
