FROM claude-base:latest

# versions: see apt-cache policy build-essential cmake gdb clang-format to query current
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends build-essential cmake gdb clang-format && rm -rf /var/lib/apt/lists/*
