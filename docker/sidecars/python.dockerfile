# hadolint ignore=DL3007
FROM claude-base:latest

# versions: see apt-cache policy python3 python3-pip to query current
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends python3 python3-pip && rm -rf /var/lib/apt/lists/*
