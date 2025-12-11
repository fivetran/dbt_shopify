{% macro get_metafields(source_object, reference_values, id_column, lookup_object="stg_shopify__metafield", key_field="metafield_reference", key_value="value", reference_field="owner_resource") %}
    {{ return(adapter.dispatch('get_metafields', 'shopify')(source_object, reference_values, id_column, lookup_object, key_field, key_value, reference_field)) }} 
{%- endmacro %}

{% macro default__get_metafields(source_object, reference_values, id_column, lookup_object="stg_shopify__metafield", key_field="metafield_reference", key_value="value", reference_field="owner_resource") %}

{# Manually quote and join reference values #}
{% set quoted_values = [] %}
{% for value in reference_values %}
    {% do quoted_values.append("'" ~ value | lower | trim ~ "'") %}
{% endfor %}
{% set reference_values_clause = quoted_values | join(", ") %}

{# Get the pivot fields dynamically based on the reference values #}
{% set pivot_fields = dbt_utils.get_column_values(
    table=ref(lookup_object),
    column=key_field,
    where="lower(" ~ reference_field ~ ") in (" ~ reference_values_clause ~ ")") %}
    
{% set pivot_field_slugs = [] %}

{% for field in pivot_fields %}
    {% do pivot_field_slugs.append(dbt_utils.slugify(field)) %}
{% endfor %}
{% set pivot_field_slugs = pivot_field_slugs | unique | list %}

{% set source_columns = adapter.get_columns_in_relation(ref(source_object)) %}
{% set source_column_count = source_columns | length %}

with source_table as (
    select *
    from {{ ref(source_object) }}
)

{% if pivot_field_slugs is not none %},
lookup_object as (
    select 
        *,
        {{ dbt_utils.pivot(
                column=key_field, 
                values=pivot_field_slugs, 
                agg='', 
                then_value=key_value, 
                else_value="null",
                quote_identifiers=false
                ) 
        }}
    from {{ ref(lookup_object) }}
    where is_most_recent_record
),

final as (
    select
        {% for column in source_columns %}
            source_table.{{ column.name }}{% if not loop.last %},{% endif %}
        {% endfor %}
        {% for field in pivot_field_slugs %}
            , max(lookup_object.{{ field }}) as metafield_{{ field }}
        {% endfor %}
    from source_table
    left join lookup_object 
        on lookup_object.{{ reference_field }}_id = source_table.{{ id_column }}
        and lower(lookup_object.{{ reference_field }}) in ({{ reference_values_clause }})
    {{ dbt_utils.group_by(source_column_count) }}
)

select *
from final
{% else %}

select *
from source_table
{% endif %}
{% endmacro %}