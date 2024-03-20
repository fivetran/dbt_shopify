{% macro shopify_partition_by_cols(base_col, source_relation='source_relation') %}

{{ adapter.dispatch('shopify_partition_by_cols', 'shopify') (base_col, source_relation) }}

{%- endmacro %}

{% macro default__shopify_partition_by_cols(base_col, source_relation='source_relation') %}
# For redshift since upstream models are views, but applies to all other warehouses.
    {%- if var('shopify_union_schemas', false) or var('shopify_union_databases', false) -%}
    {{ base_col }}, {{ source_relation }}
    {%- else %}
    {{ base_col }}
    {%- endif %}

{% endmacro %}