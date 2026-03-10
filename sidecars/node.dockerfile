# hadolint ignore=DL3007
FROM claude-base:latest

# versions: see apt-cache policy nodejs npm to query current
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
nodejs \
npm \
&& rm -rf /var/lib/apt/lists/*

# Pre-install common tools for the agent to use
# Note: typescript, ts-node, and prettier are installed without version pins;
# they will resolve to the latest available on npm at build time.
# hadolint ignore=DL3016
RUN npm install -g typescript ts-node prettier
