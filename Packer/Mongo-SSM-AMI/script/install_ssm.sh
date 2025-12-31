#!/bin/bash
set -euxo pipefail

snap install amazon-ssm-agent --classic
snap start amazon-ssm-agent