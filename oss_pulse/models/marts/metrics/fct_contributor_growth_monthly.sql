-- status counts and quick ratio, per repository and month
with status_counts as (
    select

        repository_id,
        activity_month,
        sum(case when status = 'new' then 1 else 0 end) as new_count,
        sum(case when status = 'retained' then 1 else 0 end) as retained_count,
        sum(case when status = 'churned' then 1 else 0 end) as churned_count,
        sum(case when status = 'resurrected' then 1 else 0 end)
            as resurrected_count

    from {{ ref('int_contributor_status_monthly') }}

    group by 1, 2

)

select

    a.activity_month,
    a.repository_id,
    coalesce(b.new_count, 0) as new_count,
    coalesce(b.retained_count, 0) as retained_count,
    coalesce(b.churned_count, 0) as churned_count,
    coalesce(b.resurrected_count, 0) as resurrected_count,
    coalesce(b.new_count + b.retained_count + b.resurrected_count, 0)
        as active_count,
    b.retained_count
    / nullif(b.churned_count + b.retained_count, 0) as retention_ratio,
    (b.new_count + b.resurrected_count)
    / nullif(b.churned_count, 0) as quick_ratio,
    max(a.activity_month) over () = a.activity_month as is_current_partial_month

from {{ ref('dim_repository_month') }} as a
left join status_counts as b
    on
        a.repository_id = b.repository_id
        and a.activity_month = b.activity_month
