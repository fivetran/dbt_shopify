{%- macro does_table_exist(table_name) -%}
    {%- if execute -%} -- returns true when dbt is in execute mode
    {%- set ns = namespace(has_table=false) -%} -- declare boolean namespace and default value 
        {%- for node in graph.sources.values() -%} -- grab sources from the dictionary of nodes 
        -- call the database for the matching table
            {%- if node.name | lower == table_name | lower -%} 
                {%- set source_relation = adapter.get_relation(
                        database=node.database,
                        schema=node.schema,
                        identifier=node.identifier ) -%} 
            {% endif %}
            {%- if source_relation == None -%} 
                {{ return(False) }} -- return false if relation identified by the database.schema.identifier does not exist for the given table name
            {% endif %}
        {%- endfor -%}
        {{ return(True) }}
    {%- endif -%} 
{%- endmacro -%}