#!/bin/bash

# Install uv if not already installed
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install dependencies
uv sync

# Activate the virtual environment
source .venv/bin/activate
