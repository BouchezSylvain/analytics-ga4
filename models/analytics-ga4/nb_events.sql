{{ config(materialized='table') }}

with source_data as (

    SELECT
    event_name,
    COUNT(*)AS nb_events
    from {{ source("ga4_events", "events") }}
    group by event_name
    order by nb_events DESC
)

select *
from source_data