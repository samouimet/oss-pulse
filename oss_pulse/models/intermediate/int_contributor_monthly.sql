select

    cast(date_trunc('month', activity_at) as date) as activity_month,
    repository_id,
    actor_id,
    sum(case when activity_type = 'comment' then 1 else 0 end) as comment_count,
    sum(case when activity_type = 'commit' then 1 else 0 end) as commit_count,
    sum(case when activity_type = 'review' then 1 else 0 end) as review_count,
    sum(case when activity_type = 'issue_opened' then 1 else 0 end)
        as issue_opened_count,
    sum(case when activity_type = 'issue_closed' then 1 else 0 end)
        as issue_closed_count,
    sum(case when activity_type = 'pull_request_opened' then 1 else 0 end)
        as pull_request_opened_count,
    count(*) as total_activities

from {{ ref('int_contributor_activity') }}

group by 1, 2, 3
