with line_items as (

    select * 
    from {{ var('shopify_order_line')}}

), orders as ( 

    select * 
    from {{ var('shopify_order')}}

), product as (

    select *
    from {{ var('shopify_product')}}

), transactions as (

    select *
    from {{ var('shopify_transaction')}}

), tender_transactions as (

    select *
    from {{ var('shopify_tender_transaction')}}

), order_line_refund as (

    select *
    from {{ var('shopify_order_line_refund')}}

), customer as (

    select *
    from {{ var('shopify_customer')}}

), enhanced as (

    select
        li.order_id as header_id,
        li.order_line_id as line_item_id,
        li.index as line_item_index,
        o.created_timestamp as created_at,
        o.currency as currency,
        li.fulfillment_status as header_status,
        li.product_id as product_id,
        p.title as product_name,
        -- t.kind as transaction_type,
        null as transaction_type,
        null as billing_type,
        p.product_type as product_type,
        li.quantity as quantity,
        li.price as unit_amount,
        o.total_discounts as discount_amount,
        o.total_tax as tax_amount,
        (li.quantity*li.price) as total_amount,
        -- tt.transaction_id as payment_id,
        null as payment_id,
        null as payment_method_id,
        -- tt.payment_method as payment_method,
        null as payment_method,
        -- t.processed_timestamp as payment_at,
        null as payment_at,
        null as fee_amount,
        (olr.subtotal + olr.total_tax) as refund_amount,
        null as subscription_id,
        null as subscription_period_started_at,
        null as subscription_period_ended_at,
        null as subscription_status,
        o.customer_id,
        'customer' as customer_level,
        {{ dbt.concat(["c.first_name", "''", "c.last_name"]) }} as customer_name,
        o.shipping_address_company as customer_company,
        o.email as customer_email,
        o.shipping_address_city as customer_city,
        o.shipping_address_country as customer_country
    from line_items li
    left join orders o
        on li.order_id = o.order_id
    left join order_line_refund olr
        on li.order_line_id = olr.order_line_id
    left join product p 
        on li.product_id = p.product_id
    left join customer c
        on o.customer_id = c.customer_id
        
), final as (

    select 
        header_id,
        cast(line_item_id as {{ dbt.type_numeric() }}) as line_item_id,
        cast(line_item_index as {{ dbt.type_numeric() }}) as line_item_index,
        'line_item' as record_type,
        created_at,
        currency,
        header_status,
        billing_type,
        cast(product_id as {{ dbt.type_numeric() }}) as product_id,
        product_name,
        product_type,
        cast(quantity as {{ dbt.type_numeric() }}) as quantity,
        cast(unit_amount as {{ dbt.type_numeric() }}) as unit_amount,
        cast(null as {{ dbt.type_numeric() }}) as discount_amount,
        cast(null as {{ dbt.type_numeric() }}) as tax_amount,
        cast(total_amount as {{ dbt.type_numeric() }}) as total_amount,
        payment_id,
        payment_method_id,
        payment_method,
        payment_at,
        fee_amount,
        cast(null as {{ dbt.type_numeric() }}) as refund_amount,
        subscription_id,
        subscription_period_started_at,
        subscription_period_ended_at,
        subscription_status,
        customer_id,
        customer_level,
        customer_name,
        customer_company,
        customer_email,
        customer_city,
        customer_country
    from enhanced

    union all

    select 
        header_id,
        cast(null as {{ dbt.type_numeric() }}) as line_item_id,
        cast(0 as {{ dbt.type_numeric() }}) as line_item_index,
        'header' as record_type,
        created_at,
        currency,
        header_status,
        billing_type,
        cast(null as {{ dbt.type_numeric() }}) as product_id,
        cast(null as {{ dbt.type_string() }}) as product_name,
        cast(null as {{ dbt.type_string() }}) as product_type,
        cast(null as {{ dbt.type_numeric() }}) as quantity,
        cast(null as {{ dbt.type_numeric() }}) as unit_amount,
        discount_amount,
        tax_amount,
        cast(null as {{ dbt.type_numeric() }}) as total_amount,
        payment_id,
        payment_method_id,
        payment_method,
        payment_at,
        fee_amount,
        refund_amount,
        subscription_id,
        subscription_period_started_at,
        subscription_period_ended_at,
        subscription_status,
        customer_id,
        customer_level,
        customer_name,
        customer_company,
        customer_email,
        customer_city,
        customer_country
    from enhanced
    where line_item_index = 1 -- filter to just one arbitrary record

)

select * 
from final