{{ config(
    unique_key='customer_id',
    partition_by={"field": "insert_date", "data_type": "timestamp"},
    cluster_by=["city", "state"]
) }}

with source_data as (
    select
        cast(customer_id as string) as customer_id,
        first_name,
        last_name,
        email,
        street,
        city,
        state,
        cast(zip_code as string) as zip_code,
        current_timestamp() as insert_date,
        current_timestamp() as update_date
    from {{ source('didier_bikes_raw', 'raw_customers') }}
)

select * from source_data

{% if is_incremental() %}
  where customer_id not in (select distinct customer_id from {{ this }})
  or insert_date > (select ifnull(max(insert_date), '1900-01-01') from {{ this }})
{% endif %}
