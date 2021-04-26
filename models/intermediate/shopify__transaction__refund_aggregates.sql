with transaction as (

    select *
    from {{ ref('stg_shopify__transaction') }}

), aggregated as (

    select
        order_id,
        sum(amount) AS refunded_amount
    from transaction
    WHERE kind = 'refund' AND status = 'success'
    group by 1

)

select *
from aggregated
