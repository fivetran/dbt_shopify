with transactions as (
    select
        *,
        {{ dbt_utils.generate_surrogate_key(['source_relation', 'transaction_id'])}} as transactions_unique_id
    from {{ ref('stg_shopify__transaction') }}

), parent_transactions as (

    select
        transaction_id,
        source_relation,
        created_timestamp as parent_created_timestamp,
        kind as parent_kind,
        amount as parent_amount,
        status as parent_status
    from {{ ref('stg_shopify__transaction') }}

), with_parent as (

    select
        transactions.*,
        parent_transactions.parent_created_timestamp,
        parent_transactions.parent_kind,
        parent_transactions.parent_amount,
        parent_transactions.parent_status
    from transactions
    left join parent_transactions
        on transactions.parent_id = parent_transactions.transaction_id
        and transactions.source_relation = parent_transactions.source_relation

), with_exchange_rate as (

    select
        *,
        -- TODO: Parse receipt JSON for exchange_rate
        -- For now, default to 1 (no currency exchange)
        cast(1 as numeric) as exchange_rate,
        cast(1 as numeric) * amount as currency_exchange_calculated_amount
    from with_parent

)

select *
from with_exchange_rate
