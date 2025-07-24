{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with transactions as (
    select 
        *,
        {{ dbt_utils.generate_surrogate_key(['source_relation', 'transaction_id'])}} as transactions_unique_id
    from {{ var('shopify_gql_transaction') }} 

), tender_transactions as (

    select *
    from {{ var('shopify_gql_tender_transaction') }}

), orders as (

    select *
    from {{ ref('int_shopify_gql__order') }}

), joined as (
    select 
        transactions.*,
        tender_transactions.payment_method,
        parent_transactions.created_timestamp as parent_created_timestamp,
        parent_transactions.kind as parent_kind,
        parent_transactions.amount_shop as parent_amount,
        parent_transactions.status as parent_status,
        orders.location_id,
        orders.source_name 

    from transactions
    left join tender_transactions
        on transactions.transaction_id = tender_transactions.transaction_id
        and transactions.source_relation = tender_transactions.source_relation
    left join transactions as parent_transactions
        on transactions.parent_id = parent_transactions.transaction_id
        and transactions.source_relation = parent_transactions.source_relation
    left join orders
        on transactions.order_id = orders.order_id
        and transactions.source_relation = orders.source_relation

), exchange_rate as (

    select
        *,
        {# QUESTION/ISSUE: Cannot confirm if receipt looks the same in GraphQL #}
        coalesce(cast(nullif({{ fivetran_utils.json_parse("receipt",["charges","data",0,"balance_transaction","exchange_rate"]) }}, '') as {{ dbt.type_numeric() }} ),1) as exchange_rate,
        coalesce(cast(nullif({{ fivetran_utils.json_parse("receipt",["charges","data",0,"balance_transaction","exchange_rate"]) }}, '') as {{ dbt.type_numeric() }} ),1) * amount_shop as currency_exchange_calculated_amount
    from joined

)

select *
from exchange_rate