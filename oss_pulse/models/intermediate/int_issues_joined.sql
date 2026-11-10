with repo_mapping as (

    select distinct
        repository_id,
        repository_url
    from {{ ref('stg_github__repos') }}
)

select
    issue_id,
    repository_id,
    opened_by_actor_id,
    closed_by_actor_id,
    state,
    created_at,
    updated_at,
    closed_at,
    number,
    snapshot_date,
    reactions_total_count,
    sgi.repository_url

from {{ ref('stg_github__issues') }} as sgi
inner join repo_mapping as rm
    on sgi.repository_url = rm.repository_url

where is_pull_request = FALSE
