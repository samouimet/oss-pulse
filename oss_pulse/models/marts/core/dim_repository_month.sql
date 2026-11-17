with first_active_months as (

    select
        repository_id,
        min(activity_month) as first_active_month
    from {{ ref('int_contributor_monthly') }}
    group by repository_id

),

latest_fetch as (

    select date_trunc('month', max(snapshot_date)) as latest_month
    from {{ ref('stg_github__repos') }}

)

select
    a.repository_id,
    cast(c.date_month as date) as activity_month

from first_active_months as a
cross join latest_fetch as b
inner join {{ ref('dim_month') }} as c
    on c.date_month between a.first_active_month and b.latest_month
