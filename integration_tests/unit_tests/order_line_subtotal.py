"""Execute the production model against independent connector-shaped fixtures.

Run with: uv run --no-project --with duckdb --with jinja2 python
integration_tests/unit_tests/order_line_subtotal.py

REST line_items.total_discount is not the canonical allocated discount:
https://shopify.dev/docs/api/admin-rest/latest/resources/order
"""

import re
from pathlib import Path
from types import SimpleNamespace

import duckdb
from jinja2 import Environment, StrictUndefined

root = Path(__file__).resolve().parents[2]
sql = (root / "models/rest/shopify__order_lines.sql").read_text()
env = Environment(undefined=StrictUndefined)
env.globals.update(
    config=lambda **kwargs: "",
    var=lambda name, default=None: default,
    ref=lambda name: name,
    dbt=SimpleNamespace(type_string=lambda: "varchar"),
    dbt_utils=SimpleNamespace(
        generate_surrogate_key=lambda fields: (
            "md5(source_relation || cast(order_line_id as varchar))"
        )
    ),
    fivetran_utils=SimpleNamespace(
        string_agg=lambda expr, separator: f"string_agg({expr}, {separator})"
    ),
)
con = duckdb.connect()
con.execute("""create table stg_shopify__order_line (
    order_line_id bigint, source_relation varchar, variant_id bigint,
    price double, quantity bigint, total_discount double, pre_tax_price double
);
insert into stg_shopify__order_line values
    (1, 'shop_a', 10, 12.5, 2, 0, null),
    (2, 'shop_a', 10, 12.5, 2, 0, null),
    (3, 'shop_a', 10, 12.5, 2, 99, null),
    (4, 'shop_a', 10, 12.5, 2, 0, null),
    (5, 'shop_a', 10, 12.5, 2, null, null),
    (1, 'shop_b', 10, 100, 2, 0, null);
create table stg_shopify__discount_allocation (
    order_line_id bigint, source_relation varchar, amount double
);
insert into stg_shopify__discount_allocation values
    (2, 'shop_a', 2), (2, 'shop_a', 3),
    (3, 'shop_a', 5), (4, 'shop_a', 5),
    (1, 'shop_b', 20);
create table shopify__orders__order_refunds (
    order_line_id bigint, source_relation varchar, quantity bigint,
    subtotal double, restock_type varchar
);
insert into shopify__orders__order_refunds values
    (3, 'shop_a', 1, 7, 'return'),
    (4, 'shop_a', 2, 20, 'return'),
    (1, 'shop_b', 1, 30, 'return');
create table stg_shopify__tax_line (
    order_line_id bigint, source_relation varchar, price double
);""")
variant_fields = sorted(set(re.findall(r"product_variants\.(\w+)", sql)))
con.execute(
    "create table stg_shopify__product_variant ("
    + ", ".join(
        f"{field} bigint" if field == "variant_id" else f"{field} varchar"
        for field in variant_fields
    )
    + ")"
)
con.execute("create table shopify__order_lines as " + env.from_string(sql).render())
test_sql = (
    root / "integration_tests/tests/integrity/order_line_subtotal_net_refunds.sql"
).read_text()
violations = con.execute(env.from_string(test_sql).render()).fetchall()
actual = con.execute(
    "select order_line_id, source_relation, subtotal_net_refunds from shopify__order_lines order by source_relation, order_line_id"
).fetchall()
print("Actual model output:", actual)
assert not violations, f"Package regression test found invalid subtotals: {violations}"
assert actual == [
    (1, "shop_a", 25.0),
    (2, "shop_a", 20.0),
    (3, "shop_a", 13.0),
    (4, "shop_a", 0.0),
    (5, "shop_a", 25.0),
    (1, "shop_b", 150.0),
]
print(
    "PASS: six actual-model cases; missing deprecated price, quantity, discounts, partial/full refunds and source isolation"
)
