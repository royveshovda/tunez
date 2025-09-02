# For Codespaces: Elixir dev container with mise version manager
# Supports .tool-versions for flexible Elixir/Erlang versions

FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl git unzip build-essential ca-certificates build-essential inotify-tools && \
    rm -rf /var/lib/apt/lists/*

# Install mise (universal version manager)
ENV MISE_VERSION=v2025.8.21
RUN curl -sSL https://mise.run | bash
ENV PATH="/root/.local/share/mise/bin:/root/.local/share/mise/shims:${PATH}"

# Set default workdir
WORKDIR /workspaces

# Expose default Phoenix port
EXPOSE 4000
