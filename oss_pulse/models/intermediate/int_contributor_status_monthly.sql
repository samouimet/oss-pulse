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
        ) as next_activity_month,
        -- latest month with any activity in this repo; used so we don't call
        -- someone churned for a month the data doesn't cover yet
        max(activity_month)
            over (partition by repository_id)
            as latest_activity_month

    from {{ ref('int_contributor_monthly') }}

)

-- part 1: a status for every row that exists (new / retained / resurrected)
select
    repository_id,
    actor_id,
    activity_month,
    case
        when previous_activity_month is null then 'new'
        when
            datediff('month', previous_activity_month, activity_month) = 1
            then 'retained'
        when
            datediff('month', previous_activity_month, activity_month) > 1
            then 'resurrected'
    end as status

from monthly_with_prev_next

union all

-- part 2: churned rows are created, dated the month AFTER the last active month
select
    repository_id,
    actor_id,
    cast(date_add(activity_month, interval 1 month) as date) as activity_month,
    'churned' as status

from monthly_with_prev_next
where
    -- a gap: the next active month is more than one month away
    datediff('month', activity_month, next_activity_month) > 1
    -- or no next active month at all, as long as the repo has later data
    or (next_activity_month is null and activity_month < latest_activity_month)
