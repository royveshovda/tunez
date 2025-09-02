# For Codespaces: Elixir dev container with mise version manager
# Supports .tool-versions for flexible Elixir/Erlang versions

FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Install additional dependencies needed for Elixir/Erlang
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libwxgtk3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libffi-dev libgmp-dev inotify-tools && \
    rm -rf /var/lib/apt/lists/*

# Set default workdir
WORKDIR /workspaces

# Expose default Phoenix port
EXPOSE 4000
