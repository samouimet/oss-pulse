with issues as (
    select
        fetched,
        unnest(data) as issue
    from {{ source('github', 'issues') }}
)

select

    cast(issue.id as BIGINT) as issue_id,
    cast(issue.user.id as BIGINT) as opened_by_actor_id,
    cast(issue.user.login as VARCHAR) as opened_by_actor_login,
    cast(issue.user.type as VARCHAR) as opened_by_actor_type,
    cast(issue.closed_by.id as BIGINT) as closed_by_actor_id,
    cast(issue.closed_by.login as VARCHAR) as closed_by_actor_login,
    cast(issue.closed_by.type as VARCHAR) as closed_by_actor_type,
    cast(issue.state as VARCHAR) as state,
    cast(issue.created_at as TIMESTAMP) as created_at,
    cast(issue.updated_at as TIMESTAMP) as updated_at,
    cast(issue.closed_at as TIMESTAMP) as closed_at,
    cast(issue.number as INT) as number,
    cast(issues.fetched as DATE) as snapshot_date,
    cast(issue.reactions.total_count as INT) as reactions_total_count,
    cast(
        coalesce(issue.pull_request is not null, false) as BOOLEAN
    ) as is_pull_request,
    cast(issue.repository_url as VARCHAR) as repository_url

from issues
