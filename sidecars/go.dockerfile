# sidecars/go.dockerfile
# versions: see apt-cache policy golang-go to query current
RUN apt-get update && apt-get install -y \
golang-go \
&& rm -rf /var/lib/apt/lists/*

# Set standard Go paths for the container environment
ENV GOPATH=/go
ENV PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
