#!/usr/bin/env bash
# Author:       Casey Sparks
# Date:         August 24, 2026
# Description:  Automatically remave all failed GitHub Actions runs.

for RUN_ID in $(gh run list --status failure --limit 1000 --json databaseId | jq '.[].databaseId'); do
    gh run delete "${RUN_ID}" &
done
