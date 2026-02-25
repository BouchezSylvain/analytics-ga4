{{ config(materialized="table") }}

select
    round(
        sum((select value.double_value from unnest(event_params) where key = 'value')),
        2
    ) as chiffre_affaires
from {{ source("ga4_events", "events") }}
where event_name = 'purchase'
