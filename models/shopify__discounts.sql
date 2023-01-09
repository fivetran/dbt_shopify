with discounts as (

    select *
    from {{ ref('int_shopify__discounts_with_aggregates') }}
),

price_rule as (

    select *
    from {{ var('shopify_price_rule') }}
),

select * from discounts