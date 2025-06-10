#!/bin/bash

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