#!/bin/bash

# Install uv if not already installed
curl -LsSf https://astral.sh/uv/install.sh | sh

# Create virtual environment if it doesn't exist
if [ ! -d ".venv" ]; then
    uv sync
fi

# Activate the virtual environment
source .venv/bin/activate
