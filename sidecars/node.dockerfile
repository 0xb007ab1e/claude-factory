# sidecars/node.dockerfile
# versions: see apt-cache policy nodejs npm to query current
RUN apt-get update && apt-get install -y \
nodejs \
npm \
&& rm -rf /var/lib/apt/lists/*

# Pre-install common tools for the agent to use
# Note: typescript, ts-node, and prettier are installed without version pins;
# they will resolve to the latest available on npm at build time.
RUN npm install -g typescript ts-node prettier
