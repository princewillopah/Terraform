#!/bin/bash

# Define the base directory
BASE_DIR="modules/ec2-instance"

# Create base directory
mkdir -p "$BASE_DIR"

# Create top-level files
touch "$BASE_DIR/README.md"
touch "$BASE_DIR/main.tf"
touch "$BASE_DIR/variables.tf"
touch "$BASE_DIR/outputs.tf"
touch "$BASE_DIR/versions.tf"

# Create user_data directory and file
mkdir -p "$BASE_DIR/user_data"
touch "$BASE_DIR/user_data/al2023-cloudinit.sh"

# Create policies directory and file
mkdir -p "$BASE_DIR/policies"
touch "$BASE_DIR/policies/ssm-managed-instance.json"

# Create examples directory and file
mkdir -p "$BASE_DIR/examples/basic"
touch "$BASE_DIR/examples/basic/main.tf"

# Create .tooling directory and files
mkdir -p "$BASE_DIR/.tooling"
touch "$BASE_DIR/.tooling/.tflint.hcl"
touch "$BASE_DIR/.tooling/.terraform-docs.yml"
touch "$BASE_DIR/.tooling/pre-commit-config.yaml"
touch "$BASE_DIR/.tooling/ci-example.yaml"

echo "Directory structure and files created successfully under $BASE_DIR"