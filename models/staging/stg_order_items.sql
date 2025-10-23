{{ config(
    unique_key=['order_id', 'item_id'],
    partition_by={"field": "insert_date", "data_type": "timestamp"},
    cluster_by=["product_id"]
) }}

with source_data as (
    select
        cast(order_id as string) as order_id,
        cast(item_id as string) as item_id,
        cast(product_id as string) as product_id,
        SAFE_CAST(quantity as int64) as quantity,
        SAFE_CAST(list_price as float64) as unit_price,
        SAFE_CAST(discount as float64) as discount,
        current_timestamp() as insert_date,
        current_timestamp() as update_date
    from {{ source('didier_bikes_raw', 'raw_order_items') }}
),

deduplicated as (
    select *
    from (
        select *,
               row_number() over (
                   partition by order_id, item_id
                   order by insert_date desc
               ) as rn
        from source_data
    )
    where rn = 1
)

{% if is_incremental() %}

select 
    d.order_id,
    d.item_id,
    d.product_id,
    d.quantity,
    d.unit_price,
    d.discount,
    d.insert_date,
    d.update_date
from deduplicated d
left join {{ this }} t
on d.order_id = t.order_id
and d.item_id = t.item_id
where t.order_id is null

{% else %}

select 
    d.order_id,
    d.item_id,
    d.product_id,
    d.quantity,
    d.unit_price,
    d.discount,
    d.insert_date,
    d.update_date
from deduplicated

{% endif %}
