{{ config(materialized="table") }}

select
    round(
        avg((select value.double_value from unnest(event_params) where key = 'value')),
        2
    ) as panier_moyen
from {{ source("ga4_events", "events") }}
where event_name = 'purchase'
