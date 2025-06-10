#!/bin/bash

# Check if credentials are provided
if [ -z "$GOOGLE_APPLICATION_CREDENTIALS_JSON" ]; then
    echo "Error: GOOGLE_APPLICATION_CREDENTIALS_JSON environment variable is not set"
    exit 1
fi

# Write credentials to file
echo "$GOOGLE_APPLICATION_CREDENTIALS_JSON" > /root/.config/gcloud/application_default_credentials.json

# Function to run dbt for a specific target
run_dbt_target() {
    local target=$1
    echo "Running dbt for target: $target"
    dbt run --target $target
}

# Run dbt for each target
run_dbt_target "vitrine_prod"
run_dbt_target "breathe_prod"

echo "Completed running dbt for all targets at $(date)" 