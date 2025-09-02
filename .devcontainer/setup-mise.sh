#!/bin/bash

# Install mise tools
mise install

# Add mise activation to shell profiles
if ! grep -q "mise activate" ~/.bashrc; then
    echo 'eval "$(mise activate bash)"' >> ~/.bashrc
fi

if ! grep -q "mise activate" ~/.profile; then
    echo 'eval "$(mise activate bash)"' >> ~/.profile
fi

# Source the bashrc to activate mise in current session
source ~/.bashrc

# Install mix dependencies
mise exec -- mix local.hex --force
mise exec -- mix local.rebar --force

echo "Mise setup completed successfully!"
