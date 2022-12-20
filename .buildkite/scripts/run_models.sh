#!/bin/bash

set -euo pipefail

apt-get update
apt-get install libsasl2-dev

python3 -m venv venv
. venv/bin/activate
pip install --upgrade pip setuptools
pip install -r integration_tests/requirements.txt
mkdir -p ~/.dbt
cp integration_tests/ci/sample.profiles.yml ~/.dbt/profiles.yml

db=$1
echo `pwd`
cd integration_tests
dbt deps
dbt seed --target "$db" --full-refresh
dbt run --target "$db" --full-refresh
dbt test --target "$db"
dbt run --vars '{shopify__using_order_adjustment: false, shopify__using_order_line_refund: false, shopify__using_refund: false}' --target "$db" --full-refresh
dbt test --target "$db"
dbt run --vars '{shopify__using_order_line_refund: false}' --target "$db" --full-refresh
dbt run --vars '{shopify__using_refund: false}' --target "$db" --full-refresh