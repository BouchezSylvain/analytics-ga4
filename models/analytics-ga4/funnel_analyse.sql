-- Analyse du funnel view_item => add_to_cart => begin_checkout => purchase
with
    order_funnel as (
        select 0 as num_step, 'view_item' as step_name,
        union all
        select 1, 'add_to_cart',
        union all
        select 2, 'begin_checkout',
        union all
        select 3, 'purchase'
    ),
    event_funnel as (
        select
            num_step,
            event_name,
            device.category as device_category,
            count(distinct user_pseudo_id) as nb_users
        from {{ source("ga4_events", "events") }} as events
        join order_funnel on order_funnel.step_name = events.event_name
        where event_name in ('view_item', 'add_to_cart', 'begin_checkout', 'purchase')
        group by event_name, device.category, num_step
        order by order_funnel.num_step
    ),
    events_funnel_mobile as (
        select
            *,
            coalesce(
                round(nb_users / (lag(nb_users) over (order by num_step)) * 100, 2), 0
            ) as perc_user_convert,
            round(
                nb_users / (
                    select nb_users
                    from event_funnel
                    where event_name = 'view_item' and device_category = 'mobile'
                )
                * 100,
                2
            ) as perc_user_convert_from_view_item
        from event_funnel
        where device_category = 'mobile'
    ),
    events_funnel_desktop as (
        select
            *,
            coalesce(
                round(nb_users / (lag(nb_users) over (order by num_step)) * 100, 2), 0
            ) as perc_user_convert,
            round(
                nb_users / (
                    select nb_users
                    from event_funnel
                    where event_name = 'view_item' and device_category = 'desktop'
                )
                * 100,
                2
            ) as perc_user_convert_from_view_item
        from event_funnel
        where device_category = 'desktop'
    ),
    events_funnel_tablet as (
        select
            *,
            coalesce(
                round(nb_users / (lag(nb_users) over (order by num_step)) * 100, 2), 0
            ) as perc_user_convert,
            round(
                nb_users / (
                    select nb_users
                    from event_funnel
                    where event_name = 'view_item' and device_category = 'tablet'
                )
                * 100,
                2
            ) as perc_user_convert_from_view_item
        from event_funnel
        where device_category = 'tablet'
    ),
    agggregate_funnel as (
        select *
        from events_funnel_mobile
        union all
        select *
        from events_funnel_desktop
        union all
        select *
        from events_funnel_tablet
    )
select *
from agggregate_funnel
order by device_category, num_step
