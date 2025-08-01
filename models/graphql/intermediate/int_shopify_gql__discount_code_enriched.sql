{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with discount_redeem_codes as (
    
    select *
    from {{ var('shopify_gql_discount_redeem_code') }}
),

discount_applications as (

    select *
    from {{ var('shopify_gql_discount_application') }}
),

unified_discount_codes as (

    select
        discount_code_id,
        'basic' as discount_type,
        applies_once_per_customer,
        usage_count,
        codes_count,
        codes_precision,
        combines_with_order_discounts,
        combines_with_product_discounts,
        combines_with_shipping_discounts,
        created_at,
        customer_selection_all_customers,
        ends_at, 
        starts_at,
        status,
        title,
        total_sales_amount,
        total_sales_currency_code,
        updated_at,
        usage_limit,
        source_relation
    from {{ var('shopify_gql_discount_code_basic') }}

    union all
    
    select
        discount_code_id,
        'bxgy' as discount_type, 
        applies_once_per_customer,
        usage_count,
        codes_count,
        codes_precision,
        combines_with_order_discounts,
        combines_with_product_discounts,
        combines_with_shipping_discounts,
        created_at,
        customer_selection_all_customers,
        ends_at,
        starts_at,
        status,
        title,
        total_sales_amount,
        total_sales_currency_code,
        updated_at,
        usage_limit,
        source_relation
    from {{ var('shopify_gql_discount_code_bxgy') }}

    union all
    
    select
        discount_code_id,
        'free_shipping' as discount_type, 
        applies_once_per_customer,
        usage_count,
        codes_count,
        codes_precision,
        combines_with_order_discounts,
        combines_with_product_discounts,
        combines_with_shipping_discounts,
        created_at,
        customer_selection_all_customers,
        ends_at, 
        starts_at,
        status,
        title,
        total_sales_amount,
        total_sales_currency_code,
        updated_at,
        usage_limit,
        source_relation
    from {{ var('shopify_gql_discount_code_free_shipping') }}

    {% if var('shopify_gql_using_discount_code_app', False) %}
    
    union all

    select  
        discount_code_id,
        'app' as discount_type,
        applies_once_per_customer,
        usage_count,
        codes_count,
        codes_precision,
        combines_with_order_discounts,
        combines_with_product_discounts,
        combines_with_shipping_discounts,
        created_at,
        customer_selection_all_customers,
        ends_at,
        starts_at,
        status,
        title,
        total_sales_amount,
        total_sales_currency_code,
        updated_at,
        usage_limit,
        source_relation
    from {{ var('shopify_gql_discount_code_app') }}
    {% endif %}
),

discounts_with_codes as (

    select
        discount_redeem_codes.code,
        unified_discount_codes.*
    from unified_discount_codes 
    left join discount_redeem_codes 
        on unified_discount_codes.discount_code_id = discount_redeem_codes.discount_id
        and unified_discount_codes.source_relation = discount_redeem_codes.source_relation
),

discounts_with_applications as (

    select
        discounts_with_codes.*,
        discount_applications.allocation_method,
        discount_applications.target_selection,
        discount_applications.target_type,
        discount_applications.value_amount,
        discount_applications.value_currency_code,
        discount_applications.value_percentage,
        discount_applications.value_type
    from discounts_with_codes
    left join discount_applications 
        on discounts_with_codes.code = discount_applications.code -- NEED this
        and discounts_with_codes.source_relation = discount_applications.source_relation
)

select *
from discounts_with_applications