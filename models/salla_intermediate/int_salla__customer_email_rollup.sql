{{ config(materialized='view') }}

with customers as (

    select
        *,
        row_number() over(
            partition by email, source_relation
            order by created_timestamp desc)
            as customer_index

    from {{ ref('stg_salla__customer') }}
    where email is not null -- nonsensical to include any null emails here

), rollup_customers as (

    select
        -- fields to group by
        lower(customers.email) as email,
        customers.source_relation,

        -- fields to string agg together
        string_agg(distinct cast(customers.customer_id as string), ', ') as customer_ids,
        string_agg(distinct cast(customers.phone as string), ', ') as phone_numbers,

        -- fields to take aggregates of
        min(customers.created_timestamp) as first_account_created_at,
        max(customers.created_timestamp) as last_account_created_at,
        max(customers.updated_timestamp) as last_updated_at,
        max(customers._fivetran_synced) as last_fivetran_synced,

        -- for all other fields, just take the latest value
        max(case when customers.customer_index = 1 then customers.first_name else null end) as first_name,
        max(case when customers.customer_index = 1 then customers.last_name else null end) as last_name,
        max(case when customers.customer_index = 1 then customers.city else null end) as city,
        max(case when customers.customer_index = 1 then customers.country else null end) as country,
        max(case when customers.customer_index = 1 then customers.gender else null end) as gender,
        max(case when customers.customer_index = 1 then customers.mobile_code else null end) as mobile_code

    from customers

    group by 1,2

)

select *
from rollup_customers
