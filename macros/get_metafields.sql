{%- macro get_metafields(source_object, reference_values, id_column, lookup_object="stg_shopify__metafield", key_field="metafield_reference", key_value="value", reference_field="owner_resource") -%}
    {{ return(adapter.dispatch('get_metafields', 'shopify')(source_object, reference_values, id_column, lookup_object, key_field, key_value, reference_field)) }} 
{%- endmacro -%}

{%- macro default__get_metafields(source_object, reference_values, id_column, lookup_object="stg_shopify__metafield", key_field="metafield_reference", key_value="value", reference_field="owner_resource") -%}

{# Manually quote and join reference values #}
{%- set quoted_values = [] -%}
{%- for value in reference_values -%}
    {%- do quoted_values.append("'" ~ value | lower | trim ~ "'") -%}
{%- endfor -%}
{%- set reference_values_clause = quoted_values | join(", ") -%}

{%- set source_columns = adapter.get_columns_in_relation(ref(source_object)) -%}
{%- set source_column_count = source_columns | length -%}

{# Get the pivot fields dynamically based on the reference values while respecting warehouse column limits #}
{%- set pivot_fields = dbt_utils.get_column_values(
    table=ref(lookup_object),
    column=key_field,
    max_records=shopify.max_columns(source_column_count, id_column),
    where="lower(" ~ reference_field ~ ") in (" ~ reference_values_clause ~ ")") -%}
    
{# Create slug:[metafields] dictionary #}
{%- set slug_to_field_dict = {} -%}
{%- if pivot_fields is not none -%}
    {%- for field in pivot_fields -%}
        {%- set slug = dbt_utils.slugify(field) -%}

        {%- if slug in slug_to_field_dict -%}
            {% set existing = slug_to_field_dict[slug] %}
        {%-else -%}
            {% set existing = [] %}
        {%- endif -%}

        {%- set new_list = existing + [field] -%}

        {%- do slug_to_field_dict.update({ slug: new_list }) -%}
        
    {%- endfor -%}
{%- endif -%}

with source_table as (
    select *
    from {{ ref(source_object) }}
)

{%- if slug_to_field_dict is not none -%},
lookup_object as (
    select 
        *,
        {{ shopify.pivot_metafields(
                column=key_field, 
                values_dict=slug_to_field_dict, 
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
        {% for column in source_columns -%}
            source_table.{{ column.name }}{%- if not loop.last %},{% endif %}
        {% endfor -%}
        {%- for slug, fields in slug_to_field_dict.items() %}
            , max(lookup_object.{{ slug }}) as metafield_{{ slug }}
        {%- endfor %}
    from source_table
    left join lookup_object 
        on lookup_object.{{ reference_field }}_id = source_table.{{ id_column }}
        and lower(lookup_object.{{ reference_field }}) in ({{ reference_values_clause }})
    {{ dbt_utils.group_by(source_column_count) }}
)

select *
from final
{%- else -%}

select *
from source_table
{%- endif -%}
{%- endmacro -%}