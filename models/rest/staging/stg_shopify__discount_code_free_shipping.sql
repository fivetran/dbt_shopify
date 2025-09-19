{{ config(enabled=var('shopify_api', 'rest') == 'rest') }}

with base as (

    select * 
    from {{ ref('stg_shopify__discount_code_free_shipping_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify__discount_code_free_shipping_tmp')),
                staging_columns=get_discount_code_free_shipping_columns()
            )
        }}

        {{ fivetran_utils.source_relation(
            union_schema_variable='shopify_union_schemas', 
            union_database_variable='shopify_union_databases') 
        }}

    from base
),

final as (

    select
        id as discount_code_id,
        title,
        status,
        applies_once_per_customer,
        usage_limit,
        async_usage_count as usage_count,
        codes_count,
        codes_precision,
        combines_with_order_discounts,
        combines_with_product_discounts,
        combines_with_shipping_discounts,
        customer_selection_all_customers,
        recurring_cycle_limit,
        total_sales_amount,
        total_sales_currency_code,
        {{ shopify.fivetran_convert_timezone(column='cast(created_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', 'UTC'), source_tz='UTC') }} as created_at,
        {{ shopify.fivetran_convert_timezone(column='cast(updated_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', 'UTC'), source_tz='UTC') }} as updated_at,
        {{ shopify.fivetran_convert_timezone(column='cast(starts_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', 'UTC'), source_tz='UTC') }} as starts_at,
        {{ shopify.fivetran_convert_timezone(column='cast(ends_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', 'UTC'), source_tz='UTC') }} as ends_at,
        source_relation

    from fields
)

select *
from final