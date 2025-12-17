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
    
{%- set pivot_field_slugs = [] -%}
{%- if pivot_fields is not none -%}
    {%- for field in pivot_fields -%}
        {%- do pivot_field_slugs.append(dbt_utils.slugify(field)) -%}
    {%- endfor -%}
    {%- set pivot_field_slugs = pivot_field_slugs | unique | list -%}
{%- else -%}
    {%- set pivot_field_slugs = pivot_fields -%}
{%- endif -%}

{# Create slug:[field] dictionary #}
{%- set slug_to_fields = {} -%}
{%- if pivot_fields is not none -%}
    {%- for field in pivot_fields -%}
        {%- set slug = dbt_utils.slugify(field) -%}

        {%- if slug in slug_to_fields -%}
            {% set existing = slug_to_fields[slug] %}
        {%-else -%}
            {% set existing = [] %}
        {%- endif -%}

        {%- set new_list = existing + [field] -%}

        {%- do slug_to_fields.update({ slug: new_list }) -%}
        
    {%- endfor -%}
{%- endif -%}

{# Resolve collisions by picking the first field for each slug #}
{# {%- set pivot_field_slugs = [] -%}
{%- for slug, fields in slug_to_fields.items() -%}
    {%- do pivot_field_slugs.append(fields[0]) -%}
{%- endfor -%}
{%- set pivot_field_slugs = pivot_field_slugs | unique | list -%} #}

with source_table as (
    select *
    from {{ ref(source_object) }}
)

{%- if pivot_field_slugs is not none -%},
lookup_object as (
    select 
        *,
        {{ shopify.pivot_metafields(
                column=key_field, 
                values_dict=slug_to_fields, 
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
        {%- for field in pivot_field_slugs %}
            , max(lookup_object.{{ field }}) as metafield_{{ field }}
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