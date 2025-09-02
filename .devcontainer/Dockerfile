# For Codespaces: Elixir dev container with mise version manager
# Supports .tool-versions for flexible Elixir/Erlang versions

FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl git unzip build-essential libssl-dev automake autoconf libncurses5-dev libwxgtk3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libffi-dev libgmp-dev && \
    rm -rf /var/lib/apt/lists/*

# Install mise (universal version manager)
ENV MISE_VERSION=v2025.8.21
RUN curl -sSL https://mise.run | bash
ENV PATH="/root/.local/share/mise/bin:/root/.local/share/mise/shims:${PATH}"

# Install Elixir/Erlang as specified in .tool-versions (if present)
COPY .tool-versions /workspaces/.tool-versions
RUN cd /workspaces && \
    if [ -f .tool-versions ]; then mise install; fi

# Set default workdir
WORKDIR /workspaces

# Install Hex and Rebar (Elixir build tools)
RUN if command -v elixir >/dev/null 2>&1; then \
      mix local.hex --force && \
      mix local.rebar --force; \
    fi

# Set up recommended VS Code extensions
RUN mkdir -p /workspaces/.vscode && \
    echo '{
  "recommendations": [
    "jakebecker.elixir-ls",
    "ms-azuretools.vscode-docker"
  ]
}' > /workspaces/.vscode/extensions.json

# Expose default Phoenix port
EXPOSE 4000
