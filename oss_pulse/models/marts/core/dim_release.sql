select

    a.release_id,
    a.published_by_actor_id,
    b.repository_id,
    a.tag_name,
    a.created_at,
    a.updated_at,
    a.published_at,
    a.draft,
    a.prerelease

from {{ ref('stg_github__releases') }} as a
left join {{ ref('stg_github__repos') }} as b
    on a.repository_url = b.repository_url

qualify
    row_number() over (partition by a.release_id order by a.snapshot_date desc)
    = 1
