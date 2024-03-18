{% macro shopify_lookback(from_date, datepart, interval, safety_date='2010-01-01') %}

{{ adapter.dispatch('shopify_lookback', 'shopify') (from_date, datepart, interval, safety_date='2010-01-01') }}

{%- endmacro %}

{% macro default__shopify_lookback(from_date, datepart, interval, safety_date='2010-01-01')  %}

    coalesce(
        (select {{ dbt.dateadd(datepart=datepart, interval=-interval, from_date_or_timestamp=from_date) }} 
            from {{ this }}), 
        {{ "'" ~ safety_date ~ "'" }}
        )

{% endmacro %}