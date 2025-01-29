{% macro get_metafields(source_object, reference_values=None, lookup_object="stg_shopify__metafield", key_field="metafield_reference", key_value="value", reference_field="owner_resource") %}
    {{ adapter.dispatch('get_metafields', 'shopify')(
        source_object=source_object,
        reference_values=reference_values,
        lookup_object=lookup_object,
        key_field=key_field,
        key_value=key_value,
        reference_field=reference_field
    ) }} 
{%- endmacro %}

{% macro default__get_metafields(source_object, reference_values, lookup_object="stg_shopify__metafield", key_field="metafield_reference", key_value="value", reference_field="owner_resource") %}

{# Ensure reference_values is defined and always a list #}
{% if reference_values is none %}
    {% do exceptions.raise_compiler_error("The reference_values parameter must be provided.") %}
{% endif %}

{# Derive the _id column dynamically #}
{% set id_column = reference_values[0] ~ '_id' %}
{% do log("Dynamically resolved id_column: " ~ id_column, info=true) %}

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
    where="lower(" ~ reference_field ~ ") IN (" ~ reference_values_clause ~ ")"
) %}

{% set source_columns = adapter.get_columns_in_relation(ref(source_object)) %}
{% set source_column_count = source_columns | length %}

with source_table as (
    select *
    from {{ ref(source_object) }}
)

{% if pivot_fields is not none %},
lookup_object as (
    select 
        *,
        {{ dbt_utils.pivot(
                column=key_field, 
                values=pivot_fields, 
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
        {% for fields in pivot_fields %}
            , max(lookup_object.{{ dbt_utils.slugify(fields) }}) as metafield_{{ dbt_utils.slugify(fields) }}
        {% endfor %}
    from source_table
    left join lookup_object 
        on lookup_object.owner_resource_id = source_table.{{ id_column }}
        and lower(lookup_object.{{ reference_field }}) IN ({{ reference_values_clause }})
    {{ dbt_utils.group_by(source_column_count) }}
)

select *
from final
{% else %}

select *
from source_table
{% endif %}
{% endmacro %}