with abandoned_checkouts as (

    select * from {{ source('shopify_raw', 'abandoned_checkouts') }}

), aggregated as (

    select
        cast(created_at as date) as date_day,
        'airbyte' as source_relation,

        count(distinct id) as count_abandoned_checkouts,
        count(distinct cast(json_extract_scalar(customer, '$.id') as int64)) as count_customers_abandoned_checkout,
        count(distinct email) as count_customer_emails_abandoned_checkout

    from abandoned_checkouts
    group by 1, 2

)

select * from aggregated
