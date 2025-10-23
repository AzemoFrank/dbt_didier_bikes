{{ config(
    unique_key='order_id',
    partition_by={"field": "order_date", "data_type": "date"},
    cluster_by=["customer_id", "store_id"]
) }}

with source_data as (
    select
        cast(order_id as string) as order_id,
        cast(customer_id as string) as customer_id,
        SAFE_CAST(order_date AS date) as order_date,
        cast(order_status as string) as order_status,
        SAFE_CAST(required_date AS date) as required_date,
        SAFE_CAST(shipped_date AS date) as shipped_date,
        cast(store_id as string) as store_id,
        cast(staff_id as string) as staff_id,
        current_timestamp() as insert_date,
        current_timestamp() as update_date
    from {{ source('didier_bikes_raw', 'raw_orders') }}
)

select * from source_data

{% if is_incremental() %}
  where order_date > (
      select ifnull(max(order_date), '1900-01-01') from {{ this }}
  )
{% endif %}
