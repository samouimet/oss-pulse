with repo_mapping as (

    select distinct
        repository_id,
        repository_url
    from {{ ref('stg_github__repos') }}
)

select
    sgi.issue_id,
    rm.repository_id,
    sgi.opened_by_actor_id,
    sgi.closed_by_actor_id,
    sgi.state,
    sgi.created_at,
    sgi.updated_at,
    sgi.closed_at,
    sgi.number,
    sgi.snapshot_date,
    sgi.reactions_total_count,
    sgi.repository_url

from {{ ref('stg_github__issues') }} as sgi
inner join repo_mapping as rm
    on sgi.repository_url = rm.repository_url

where sgi.is_pull_request = FALSE
