# hadolint ignore=DL3007
FROM claude-base:latest

# versions: see apt-cache policy golang-go to query current
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
golang-go \
&& rm -rf /var/lib/apt/lists/*

# Set standard Go paths for the container environment
ENV GOPATH=/go
ENV PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
