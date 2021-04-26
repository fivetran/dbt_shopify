with transaction as (

    select *
    from {{ ref('stg_shopify__transaction') }}

), aggregated as (

    select
        refund_id,
        sum(amount) AS refund_amount
    from transaction
    WHERE kind = 'refund' AND status = 'success'
    group by 1

)

select *
from aggregated
