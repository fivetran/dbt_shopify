{% macro get_metafields(source_object, reference_values=None, reference_value=None, lookup_object="stg_shopify__metafield", key_field="metafield_reference", key_value="value", reference_field="owner_resource") %}

{# Handle backward compatibility for reference_value #}
{% if reference_values is none and reference_value is not none %}
    {% set reference_values = [reference_value] %}
{% endif %}

{# Ensure reference_values is defined #}
{% if reference_values is none %}
    {% do exceptions.raise_compiler_error("Either reference_values or reference_value must be provided.") %}
{% endif %}

{# Manually quote and join reference values #}
{% set quoted_values = [] %}
{% for value in reference_values %}
    {% do quoted_values.append("'" ~ value | lower ~ "'") %}
{% endfor %}
{% set reference_values_clause = quoted_values | join(", ") %}

{# Resolve the correct _id column dynamically #}
{% set id_column = reference_values[0] ~ '_id' %}

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
        on lookup_object.{{ reference_field }}_id = source_table.{{ id_column }}
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