FROM claude-base:latest

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# rustup installs the stable toolchain by default; no explicit version is pinned here.
# To target a specific version, pass: sh -s -- -y --default-toolchain <version>
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

ENV PATH="/root/.cargo/bin:${PATH}"
