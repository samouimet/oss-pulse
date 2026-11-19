with monthly_with_prev_next as (

    select
        repository_id,
        actor_id,
        activity_month,
        lag(activity_month) over (
            partition by repository_id, actor_id order by activity_month
        ) as previous_activity_month,
        lead(activity_month) over (
            partition by repository_id, actor_id order by activity_month
        ) as next_activity_month

    from {{ ref('int_contributor_monthly') }}

),

latest_fetch as (

    -- one row: the month of the most recent fetch i.e. how far our data reaches
    select date_trunc('month', max(snapshot_date)) as latest_month
    from {{ ref('stg_github__repos') }}

)

-- part 1: a status for every row that exists (new / retained / resurrected)
select
    repository_id,
    actor_id,
    activity_month,
    case
        when previous_activity_month is null then 'new'
        when datediff('month', previous_activity_month, activity_month) = 1
            then 'retained'
        when datediff('month', previous_activity_month, activity_month) > 1
            then 'resurrected'
    end as status

from monthly_with_prev_next

union all

-- part 2: churned rows are created, dated the month AFTER the last active month
select
    a.repository_id,
    a.actor_id,
    cast(date_add(a.activity_month, interval 1 month) as date)
        as activity_month,
    'churned' as status

from monthly_with_prev_next as a
cross join latest_fetch as b    -- attaches the last-data month to every row
where
    -- a gap: the next active month is more than one month away
    datediff('month', a.activity_month, a.next_activity_month) > 1
    -- or no next active month at all, as long as we have data past this month
    or (a.next_activity_month is null and a.activity_month < b.latest_month)
