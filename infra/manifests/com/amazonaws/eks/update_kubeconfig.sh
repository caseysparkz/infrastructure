#!/usr/bin/env bash
# Author:       Casey Sparks
# Date:         July 27, 2026
# Description:  Update your local kubeconfig to use the provisioned EKS cluster.

set -eo pipefail

# Check if AWS CLI is installed
if ! which aws > /dev/null 2>&1; then
    printf 'AWS CLI not installed.' >&2
    exit 1
fi

# Log in to AWS if needed
if ! aws sts get-caller-identity --no-cli-pager | grep -q caseysparkz; then aws sso login; fi

aws eks update-kubeconfig --name "$(terraform output -raw cluster_name)"
