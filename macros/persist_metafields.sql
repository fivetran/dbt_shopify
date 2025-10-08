{%- macro persist_metafields(columns, alias='metafields') -%}
    {{ return(adapter.dispatch('persist_metafields', 'shopify')(columns, alias)) }}
{%- endmacro -%}

{%- macro default__persist_metafields(columns, alias='metafields') -%}

    {%- for column in columns -%}
        {% if column.name.startswith('metafield_') %}
            , '{{ alias }}'.{{ column.name }}
        {% endif %}
    {%- endfor %}

{%- endmacro -%}