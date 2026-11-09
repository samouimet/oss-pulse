select
    repository_id,
    owner_actor_id,
    name,
    created_at,
    updated_at,
    pushed_at,
    default_branch,
    archived

from {{ ref('stg_github__repos') }}

qualify
    row_number() over (partition by repository_id order by snapshot_date desc)
    = 1
